import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/anexos.dart';
import '../../data/arquivos_seguros.dart';
import '../../data/ditado.dart';
import '../../data/filtro_palavras.dart';
import '../../shared/widgets/miniatura_anexo.dart';
import '../../shared/widgets/ditado.dart';
import 'dart:typed_data';
import '../entrada/conta_suspensa_page.dart';
import '../../data/conta.dart';
import '../../data/enderecos.dart';
import '../../data/perfil.dart';
import '../../data/servicos.dart';
import '../../data/sugestao_servico.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../../shared/widgets/conta_pausada.dart';
import '../../shared/widgets/segmento.dart';
import '../../data/ajuda.dart';
import 'ajuda/abrir_ajuda.dart';
import '../../data/prazos.dart';
import '../../shared/widgets/espaco_anuncio.dart';
import '../../shared/widgets/avatar_usuario.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/tatu_chip.dart';
import '../../data/pedidos.dart';
import 'abas.dart';
import 'atividade/acompanhar.dart';
import 'atividade/pedido_andamento_page.dart';
import 'chamar/chamar.dart';
import 'foto/camera_desativada_page.dart';
import 'outros/outros_servicos_sheet.dart';
import 'endereco/onde_sheet.dart';
import 'perfil_page.dart';
import '../../data/aceites.dart';
import '../entrada/documentos_legais_page.dart';

/// Home do cliente: descreve o problema, escolhe (ou a IA marca) o serviço e chama.
class HomeClientePage extends StatefulWidget {
  const HomeClientePage({
    super.key,
    this.ia = const SugestaoServicoMock(),
    this.distancia = false,
  });

  final SugestaoServico ia;

  /// Abre já no modo "À distância" (fluxograma e testes).
  final bool distancia;

  @override
  State<HomeClientePage> createState() => _HomeClientePageState();
}

class _HomeClientePageState extends State<HomeClientePage> {
  final _descricao = TextEditingController();
  final _focoDescricao = FocusNode();

  /// RN-139: fotos e arquivos do pedido (até [RegrasAnexo.maxPorPedido]).
  final _anexos = AnexosPedido();

  /// RN-137: ditado na descrição. [_gravando]: ouvindo agora;
  /// [_transcrito]: o texto veio do ditado e a pessoa ainda não mexeu.
  bool _gravando = false;
  bool _transcrito = false;
  String _parcial = '';
  int _segundos = 0;
  Timer? _relogio;
  StreamSubscription<String>? _ouvindo;
  Timer? _espera;

  /// Escolha da pessoa; nunca é trocada pela IA.
  String? _manual;

  /// Sugestão da IA pela descrição; só aparece sem escolha manual.
  String? _sugerido;

  /// RN-92: pedido "No local" (padrão) ou "À distância".
  late bool _distancia = widget.distancia;

  /// Chips da Home no modo atual.
  List<String> get _chips => _distancia ? servicosDistanciaHome : servicosHome;

  String? get _servico => _manual ?? _sugerido;
  bool get _pelaIa => _manual == null && _sugerido != null;

  /// "Não sei qual serviço": a gente descobre pela descrição.
  bool get _naoSei => _manual == naoSeiServico;

  /// Serviço escolhido em "Outros" (fica no lugar do chip "Outros").
  String? get _outro =>
      _manual != null && !_chips.contains(_manual) ? _manual : null;

  @override
  void initState() {
    super.initState();
    _focoDescricao.addListener(() => setState(() {}));
    conta.addListener(_contaMudou);
    // RN-151: versão nova dos documentos bloqueia até aceitar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) verificarDocumentos(context, tipo: TipoAceite.cliente);
    });
  }

  void _contaMudou() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _ouvindo?.cancel();
    if (_gravando) ditado.parar();
    _anexos.dispose();
    _espera?.cancel();
    conta.removeListener(_contaMudou);
    _descricao.dispose();
    _focoDescricao.dispose();
    super.dispose();
  }

  void _descreveu(String texto) {
    // RN-137: mexeu no texto, já conferiu.
    if (_transcrito) setState(() => _transcrito = false);
    // "Não sei": o botão depende de ter descrição.
    if (_naoSei) setState(() {});
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(
          () => _sugerido = widget.ia.sugerir(texto, distancia: _distancia),
        );
      }
    });
  }

  /// RN-92: troca No local / À distância; a escolha manual não vale para
  /// o outro modo e a IA sugere de novo entre os serviços dele.
  void _mudarModo(bool distancia) => setState(() {
    if (_distancia == distancia) return;
    _distancia = distancia;
    _manual = null;
    _sugerido = widget.ia.sugerir(_descricao.text, distancia: distancia);
  });

  /// RN-124: a descrição do pedido passa pelo filtro de palavras.
  void _chamar(String servico) {
    if (FiltroPalavras.barrada(_descricao.text) != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(FiltroPalavras.aviso)));
      return;
    }
    chamarProfissional(context, servico, distancia: _distancia);
  }

  void _tocouServico(String s) => setState(() {
    _manual = _servico == s && !_pelaIa ? null : s;
    if (_manual == null && _sugerido == s) _sugerido = null;
  });

  Future<void> _outros() async {
    final escolha = await escolherOutroServico(
      context,
      distancia: _distancia,
    );
    if (escolha == null || !mounted) return;
    setState(() => _manual = escolha);
    if (escolha == naoSeiServico && _descricao.text.trim().isEmpty) {
      _focoDescricao.requestFocus();
    }
  }

  /// RN-139: anexa e mostra o motivo quando não dá.
  Future<void> _anexar(ArquivoEnviado a, {Uint8List? imagem}) async {
    final r = await _anexos.adicionar(a, imagem: imagem);
    if (!mounted) return;
    final aviso = switch (r) {
      ResultadoAnexo.anexado => null,
      ResultadoAnexo.limite =>
        'Até ${RegrasAnexo.maxPorPedido} anexos por pedido.',
      ResultadoAnexo.tipoNaoPermitido => 'Vão só fotos, vídeos curtos e PDF.',
      ResultadoAnexo.grandeDemais =>
        'Arquivo grande demais (até ${RegrasArquivo.limiteChatMb} MB).',
      ResultadoAnexo.barrado => 'Este arquivo foi bloqueado.',
      ResultadoAnexo.contaSuspensa => null,
    };
    if (r == ResultadoAnexo.contaSuspensa) return mostrarContaSuspensa(context);
    if (aviso == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(aviso)));
  }

  void _cheio() => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Até ${RegrasAnexo.maxPorPedido} anexos por pedido.'),
      ),
    );

  /// Câmera: tira a foto do problema.
  Future<void> _foto(OrigemFoto origem) async {
    if (_anexos.cheio) return _cheio();
    try {
      final imagem = await perfil.pedirImagem(origem);
      if (imagem == null || !mounted) return;
      await _anexar(const ArquivoEnviado('foto.jpg', mb: 2), imagem: imagem);
    } on CameraNegada {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraDesativadaPage(semAvatar: true),
        ),
      );
    }
  }

  /// C89 · RN-139: clipe → "Escolher da galeria" ou "Arquivo".
  Future<void> _clipe() async {
    if (_anexos.cheio) return _cheio();
    final escolha = await mostrarFolha<int>(
      context,
      builder: (ctx) => FolhaAnexar(onEscolha: (i) => Navigator.of(ctx).pop(i)),
    );
    if (escolha == null || !mounted) return;
    if (escolha == 0) return _foto(OrigemFoto.galeria);
    final a = await seletorArquivo.escolher();
    if (a == null || !mounted) return;
    await _anexar(a);
  }

  // ---------- Ditado (RN-137) ----------

  Future<void> _ditar() async {
    // Permissão do microfone só no primeiro toque.
    if (!await ditado.permitir()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Permita o microfone nas configurações para ditar.'),
          ),
        );
      return;
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _gravando = true;
      _parcial = '';
      _segundos = 0;
    });
    _relogio = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _segundos++),
    );
    _ouvindo = ditado.ouvir().listen((t) => setState(() => _parcial = t));
  }

  /// ✓: o texto vai para a descrição (editável) e a IA sugere o serviço.
  Future<void> _pararDitado({required bool usar}) async {
    _relogio?.cancel();
    unawaited(_ouvindo?.cancel());
    await ditado.parar();
    if (!mounted) return;
    final texto = _parcial.trim();
    setState(() {
      _gravando = false;
      if (usar && texto.isNotEmpty) {
        _descricao.text = texto;
        _transcrito = true;
      }
    });
    if (usar && texto.isNotEmpty) {
      _transcrito = true;
      _espera?.cancel();
      setState(
        () => _sugerido = widget.ia.sugerir(texto, distancia: _distancia),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servico = _servico;
    return Scaffold(
      bottomNavigationBar: const AbasDoCliente(ativa: AbaCliente.inicio),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      14,
                      TatuMedidas.margem,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _cabecalho(),
                        // RN-82: ausências demais pausam a conta.
                        ListenableBuilder(
                          listenable: conta,
                          builder: (_, _) => conta.pausadaPorAusencias
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: TatuMedidas.entreSecoes,
                                  ),
                                  child: AvisoContaPausada(
                                    motivo:
                                        '${conta.ausenciasRecentes} ausências em '
                                        '${Prazos.janelaAusencias.inDays} dias.',
                                    destaque: 'Fale com o suporte para voltar a pedir.',
                                    onTap: () =>
                                        abrirSuporte(context, conteudoCliente),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // RN-165: profissional a caminho: a faixa
                        // "[nome] chega em X min" fica no lugar da saudação.
                        ListenableBuilder(
                          listenable: Listenable.merge([pedidos, conta]),
                          builder: (context, _) {
                            final ps = pedidos.andamentos;
                            if (FaixaACaminho.mostra(ps)) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: TatuMedidas.entreSecoes + 4,
                                ),
                                child: FaixaACaminho(
                                  pedidos: ps,
                                  onTap: () {
                                    // RN-170: com 2 ou mais, a Atividade.
                                    if (ps.length > 1) {
                                      return irParaAba(
                                        context,
                                        AbaCliente.atividade,
                                      );
                                    }
                                    pedidos.abrir(ps.single);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PedidoAndamentoPage(),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: conta.pausadaPorAusencias
                                      ? TatuMedidas.entreSecoes + 4
                                      : 40,
                                ),
                                Text(
                                  'Oi, ${conta.nome}',
                                  style: TatuTexto.detalhe,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Do que você precisa?',
                                  style: TextStyle(
                                    fontSize: 30,
                                    height: 36 / 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        _caixaDescricao(),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Serviço',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TatuColors.textSecondary,
                                ),
                              ),
                            ),
                            // RN-92: o cliente escolhe o tipo de pedido.
                            SizedBox(
                              width: TatuMedidas.larguraSegmentoPequeno,
                              child: Segmento(
                                pequeno: true,
                                opcoes: const ['No local', 'À distância'],
                                selecionada: _distancia ? 1 : 0,
                                onMudar: (i) => _mudarModo(i == 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in _chips)
                              TatuChip(
                                label: s,
                                selecionado: servico == s,
                                icone: _pelaIa ? TablerIcons.sparkles : null,
                                onTap: () => _tocouServico(s),
                              ),
                            TatuChip(
                              label: _outro ?? 'Outros',
                              selecionado: _outro != null,
                              seta: _outro != null,
                              onTap: _outros,
                            ),
                          ],
                        ),
                        if (_pelaIa || _naoSei) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                TablerIcons.sparkles,
                                size: 14,
                                color: TatuColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              // Uma linha só, como no desenho; encolhe em telas estreitas.
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _pelaIa
                                        ? 'Sugerido pela descrição. Toque em outro para trocar.'
                                        : _descricao.text.trim().isEmpty
                                        ? 'Descreva o problema para acharmos quem resolve.'
                                        : 'Vamos achar o profissional pela sua descrição.',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      letterSpacing: -0.1,
                                      color: TatuColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    0,
                    TatuMedidas.margem,
                    17,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const EspacoAnuncio(),
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: TatuColors.online,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              // RN-93: à distância, vale quem está online.
                              _distancia
                                  ? 'Profissionais online agora'
                                  : 'Profissionais ativos perto de você',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: TatuColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        // RN-82: conta pausada não chama ninguém.
                        onPressed: conta.pausadaPorAusencias
                            ? null
                            : _naoSei
                            ? (_descricao.text.trim().isEmpty
                                  ? null
                                  : () => _chamar('Profissional'))
                            : servico == null
                            ? null
                            : () => _chamar(servico),
                        child: Text(
                          conta.pausadaPorAusencias
                              ? 'Chamar profissional'
                              : _naoSei
                              ? (_descricao.text.trim().isEmpty
                                    ? 'Descreva o problema'
                                    : 'Chamar profissional')
                              : servico == null
                              ? 'Escolha um serviço'
                              : 'Chamar ${servico.toLowerCase()}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        // RN-93: à distância, o endereço não conta.
        if (_distancia)
          const Expanded(
            child: Text(
              'À distância · de qualquer lugar',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: TatuColors.textSecondary),
            ),
          )
        else
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => abrirOndeServico(context),
            child: Row(
              children: [
                const Icon(TablerIcons.map_pin, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: ListenableBuilder(
                    listenable: enderecos,
                    builder: (context, _) => Text(
                      enderecos.atual.rua,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  TablerIcons.chevron_down,
                  size: 14,
                  color: TatuColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Perfil',
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PerfilClientePage()),
            ),
            child: const AvatarUsuario(),
          ),
        ),
      ],
    );
  }

  Widget _caixaDescricao() {
    final gravando = _gravando;
    return ListenableBuilder(
      listenable: _anexos,
      builder: (context, _) => Container(
        height: TatuMedidas.alturaDescricao,
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          border: Border.all(
            color: gravando
                ? TatuColors.danger
                : _focoDescricao.hasFocus
                ? TatuColors.textPrimary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 52),
                child: gravando ? _ouvindoAgora() : _campoDescricao(),
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              bottom: 12,
              child: gravando ? _barraGravando() : _barraAnexos(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoDescricao() => TextField(
    controller: _descricao,
    focusNode: _focoDescricao,
    onChanged: _descreveu,
    maxLines: null,
    expands: true,
    textCapitalization: TextCapitalization.sentences,
    cursorColor: TatuColors.textPrimary,
    style: const TextStyle(fontSize: 17, height: 24 / 17),
    decoration: const InputDecoration.collapsed(
      hintText: 'O que está acontecendo?',
      hintStyle: TextStyle(fontSize: 17, color: TatuColors.textSecondary),
    ),
  );

  /// C15 · "Gravando · 0:07" e o texto aparecendo enquanto a pessoa fala.
  Widget _ouvindoAgora() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RotuloOuvindo('Gravando · ${tempoDitado(_segundos)}'),
      const SizedBox(height: 8),
      Expanded(
        child: Text(
          _parcial.isEmpty ? 'Pode falar…' : '$_parcial…',
          overflow: TextOverflow.fade,
          style: const TextStyle(
            fontSize: 17,
            height: 24 / 17,
            color: TatuColors.textSecondary,
          ),
        ),
      ),
    ],
  );

  Widget _barraGravando() => Row(
    children: [
      _BotaoCaixa(
        icone: TablerIcons.trash,
        rotulo: 'Descartar ditado',
        fundo: TatuColors.bg,
        cor: TatuColors.danger,
        onTap: () => _pararDitado(usar: false),
      ),
      const SizedBox(width: 16),
      const Expanded(child: OndaDitado()),
      const SizedBox(width: 16),
      _BotaoCaixa(
        icone: TablerIcons.check,
        rotulo: 'Usar o texto',
        fundo: TatuColors.action,
        cor: TatuColors.onAction,
        tamanho: 40,
        onTap: () => _pararDitado(usar: true),
      ),
    ],
  );

  Widget _barraAnexos() {
    final itens = _anexos.itens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _BotaoCaixa(
          icone: TablerIcons.camera,
          rotulo: 'Tirar foto',
          onTap: () => _foto(OrigemFoto.camera),
        ),
        const SizedBox(width: 10),
        _BotaoCaixa(
          icone: TablerIcons.paperclip,
          rotulo: 'Anexar',
          onTap: _clipe,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, a) in itens.indexed) ...[
                  MiniaturaAnexo(anexo: a, onRemover: () => _anexos.remover(i)),
                  const SizedBox(width: 12),
                ],
                // RN-137: o texto veio do ditado; a pessoa confere.
                if (_transcrito)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Transcrito do áudio · confira',
                      style: TatuTexto.legenda,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // RN-137: microfone à direita; nome "Ditar" no leitor de tela.
        _BotaoCaixa(icone: TablerIcons.microphone, rotulo: 'Ditar', onTap: _ditar),
      ],
    );
  }
}

/// Botão redondo da caixa de descrição.
class _BotaoCaixa extends StatelessWidget {
  const _BotaoCaixa({
    required this.icone,
    required this.rotulo,
    required this.onTap,
    this.fundo = TatuColors.circle,
    this.cor = TatuColors.textPrimary,
    this.tamanho = 36,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;
  final Color fundo;
  final Color cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: rotulo,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
        child: Icon(icone, size: 20, color: cor),
      ),
    ),
  );
}
