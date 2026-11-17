import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/conta.dart';
import '../../data/chamado.dart';
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
import '../../shared/widgets/lista_agrupada.dart';
import '../../shared/widgets/tatu_chip.dart';
import 'abas.dart';
import 'chamar/chamar.dart';
import 'foto/camera_desativada_page.dart';
import 'outros/outros_servicos_sheet.dart';
import 'endereco/onde_sheet.dart';
import 'perfil_page.dart';

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

  /// Fotos do problema (até [maxFotosChamado]).
  final _fotos = <Uint8List>[];
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
  }

  void _contaMudou() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _espera?.cancel();
    conta.removeListener(_contaMudou);
    _descricao.dispose();
    _focoDescricao.dispose();
    super.dispose();
  }

  void _descreveu(String texto) {
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

  Future<void> _anexarFoto() async {
    final origem = await mostrarFolha<OrigemFoto>(
      context,
      builder: (ctx) => FolhaOpcoes(
        itens: [
          ItemLista(
            icone: TablerIcons.camera,
            texto: 'Tirar foto',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.camera),
          ),
          ItemLista(
            icone: TablerIcons.photo,
            texto: 'Escolher da galeria',
            seta: false,
            onTap: () => Navigator.of(ctx).pop(OrigemFoto.galeria),
          ),
        ],
      ),
    );
    if (origem == null || !mounted) return;
    try {
      final imagem = await perfil.pedirImagem(origem);
      if (imagem == null || !mounted) return;
      setState(() => _fotos.add(imagem));
    } on CameraNegada {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraDesativadaPage(semAvatar: true),
        ),
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
                        SizedBox(
                          height: conta.pausadaPorAusencias
                              ? TatuMedidas.entreSecoes + 4
                              : 40,
                        ),
                        ListenableBuilder(
                          listenable: conta,
                          builder: (_, _) => Text(
                            'Oi, ${conta.nome}',
                            style: TatuTexto.detalhe,
                          ),
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
                                  : () => chamarProfissional(
                                      context,
                                      'Profissional',
                                      distancia: _distancia,
                                    ))
                            : servico == null
                            ? null
                            : () => chamarProfissional(
                                context,
                                servico,
                                distancia: _distancia,
                              ),
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
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        border: Border.all(
          color: _focoDescricao.hasFocus
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
              child: TextField(
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
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_fotos.length < maxFotosChamado)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Semantics(
                      button: true,
                      label: 'Enviar foto',
                      child: GestureDetector(
                        onTap: _anexarFoto,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: TatuColors.circle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(TablerIcons.camera, size: 20),
                        ),
                      ),
                    ),
                  ),
                for (final (i, f) in _fotos.indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _Miniatura(
                      imagem: f,
                      onRemover: () => setState(() => _fotos.removeAt(i)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniatura de foto anexada, com o "x" para tirar.
class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.imagem, required this.onRemover});

  final Uint8List imagem;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TatuMedidas.raioCodigo),
            child: Image.memory(
              imagem,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          Positioned(
            right: -4,
            top: -8,
            child: Semantics(
              button: true,
              label: 'Tirar foto',
              child: GestureDetector(
                onTap: onRemover,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: TatuColors.action,
                    shape: BoxShape.circle,
                    border: Border.all(color: TatuColors.bg, width: 1.5),
                  ),
                  child: const Icon(
                    TablerIcons.x,
                    size: 12,
                    color: TatuColors.onAction,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
