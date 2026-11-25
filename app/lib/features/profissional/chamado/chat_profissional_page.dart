import '../../../shared/widgets/selo_plano_fixo.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../cliente/mensagens/entrega_distancia.dart' show LinhaArquivo;
import '../../entrada/chat_encerrado.dart';
import '../../entrada/conta_suspensa_page.dart';
import 'escolher_entrega.dart';
import '../../entrada/denunciar_arquivo.dart';
import '../../../data/arquivos_seguros.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/regras_distancia.dart';
import '../../../data/atendimento_profissional.dart';
import 'ainda_vai.dart';
import '../../../data/profissional.dart';
import '../../../data/prazos.dart';import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servico_profissional.dart';
import '../../../data/ajuda.dart';
import '../../../data/conversas_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../cliente/ajuda/ajuda_page.dart';
import '../../cliente/mensagens/denunciar_page.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../servico/andamento_page.dart';
import 'enviar_valor_sheet.dart';
import '../../../data/denuncias.dart';
import '../../entrada/denunciar_mensagem.dart';
import '../../entrada/ligacao_page.dart';
import '../../../data/ligacao.dart';
import 'package:clock/clock.dart';

import '../../../data/retorno.dart';
import '../retorno/retorno_profissional.dart';

import '../../../data/plano_fixo.dart';
import '../plano_fixo/plano_fixo_profissional.dart';

/// Cada lado pode propor até 3 valores.
const maxRodadas = 3;

/// Em que ponto está a combinação do valor.
enum EstadoValor { inicio, aguardando, contraproposta, combinado }

/// P23 · Chat do profissional com o cliente: combinar o valor.
/// O profissional envia um valor; o cliente aceita ou propõe outro
/// (até 3 rodadas). O endereço exato só aparece com o valor combinado.
///
/// Protótipo: o cliente responde sozinho em [resposta]. Ele propõe 20%
/// a menos no 1º valor e depois aceita qualquer valor até 15% acima da
/// proposta dele.
class ChatProfissionalPage extends StatefulWidget {
  const ChatProfissionalPage({
    super.key,
    this.chamado = chamadoExemplo,
    this.resposta = const Duration(seconds: 2),
    this.concluidoPor,
    this.concluidoEm,
    this.depois = const [],
    this.diaDepois,
    this.mensagens,
  });

  /// Mensagens do começo da conversa (texto, minha); nulo = as de exemplo.
  final List<(String, bool)>? mensagens;

  final ChamadoNovo chamado;
  final Duration resposta;

  /// Serviço já concluído por esse valor. RN-42: a conversa continua e
  /// dá para enviar um novo valor (RN-87).
  final double? concluidoPor;
  final String? concluidoEm;

  /// Mensagens depois do serviço concluído (texto, minha) e o dia delas.
  final List<(String, bool)> depois;
  final String? diaDepois;

  @override
  State<ChatProfissionalPage> createState() => _ChatProfissionalPageState();
}

class _ChatProfissionalPageState extends State<ChatProfissionalPage> {
  final _campo = TextEditingController();
  Timer? _timer;

  /// RN-76: prazo para tocar "Estou a caminho" depois de combinar.
  Timer? _prazoSaida;

  /// (texto, minha): conversa de exemplo.
  late final _mensagens = <(String, bool)>[
    if (widget.mensagens != null)
      ...widget.mensagens!
    // RN-179: "Pedir de novo" aceito: a conversa é a mesma, o pedido é novo.
    else if (widget.chamado.pediuDeNovo) ...[
      ('Oi, ${widget.chamado.primeiroNome}! Aceitei, já te mando o valor.', true),
    ] else if (widget.chamado.distancia) ...[
      ('Oi, ${widget.chamado.primeiroNome}! Que estilo você imagina?', true),
      ('Algo simples e colorido.', false),
    ] else ...[
      ('Oi! A pia não para de vazar.', false),
      ('Posso ir agora. Já te mando o valor.', true),
    ],
  ];

  EstadoValor _estado = EstadoValor.inicio;
  int _rodada = 0; // quantos valores o profissional já enviou
  double _meuValor = 0;
  String _meuDetalhe = ''; // "Visita R$ 40 · Serviço R$ 150"
  double _minhaVisita = 0;
  double _proposta = 0; // proposta do cliente
  double _combinado = 0;

  /// RN-102: sinal pedido no valor enviado (à distância).
  double _meuSinal = 0;

  String get _nome => widget.chamado.primeiroNome;

  @override
  void dispose() {
    _timer?.cancel();
    _prazoSaida?.cancel();
    _campo.dispose();
    super.dispose();
  }

  /// Já teve um serviço concluído nesta conversa (RN-42).
  bool get _concluida => widget.concluidoPor != null;

  /// Quantas mensagens vieram antes do serviço concluído.
  late final int _antes;

  @override
  void initState() {
    super.initState();
    _antes = _mensagens.length;
    _mensagens.addAll(widget.depois);
    // RN-188: confere os prazos do retorno ao abrir.
    WidgetsBinding.instance.addPostFrameCallback((_) => conferirRetornos());
    // RN-155: abriu, leu; o contador da aba diminui na hora.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in conversasProfissional.conversas) {
        if (c.chamado.cliente == widget.chamado.cliente) {
          conversasProfissional.marcarLida(c);
        }
      }
    });
  }

  /// Toque no nome: ligar, ver chamado, ajuda, cancelar e denunciar.
  Future<void> _menu() async {
    final c = widget.chamado;
    final escolha = await mostrarFolha<String>(
      context,
      builder: (ctx) {
        ItemLista item(IconData i, String t, {bool perigo = false}) =>
            ItemLista(
              icone: i,
              texto: t,
              seta: false,
              cor: perigo ? TatuColors.danger : null,
              onTap: () => Navigator.of(ctx).pop(t),
            );
        return FolhaOpcoes(
          fechar: 'Fechar',
          itens: [
            // RN-140: ligar só existe durante o atendimento.
            if (_podeLigar) item(TablerIcons.phone, 'Ligar para $_nome'),
            item(TablerIcons.file_text, 'Ver chamado'),
            // RN-144: plano fixo com este cliente.
            if (_plano != null && _plano!.status != StatusPlano.pendente)
              item(TablerIcons.calendar_repeat, 'Ver plano fixo'),
            item(TablerIcons.help_circle, 'Ajuda'),
            if (!_concluida || _estado != EstadoValor.inicio)
              item(TablerIcons.x, 'Cancelar atendimento', perigo: true),
            item(TablerIcons.alert_triangle, 'Denunciar cliente', perigo: true),
          ],
        );
      },
    );
    if (escolha == null || !mounted) return;
    switch (escolha) {
      case 'Cancelar atendimento':
        return _cancelar();
      case 'Denunciar cliente':
        // RN-133: mesmos motivos do cliente.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DenunciarPage.pessoa(
              nome: _nome,
              feminino: c.feminino,
              denunciado: c.cliente,
              // RN-56: assédio ou discriminação encerra na hora.
              aoBloquear: () =>
                  atendimentoProfissional.clienteSuspensoNo(c.cliente),
            ),
          ),
        );
      case 'Ver plano fixo':
        return _verPlano();
      case 'Ajuda':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AjudaPage(conteudo: conteudoProfissional),
          ),
        );
      default:
        if (escolha.startsWith('Ligar')) return _ligar();
        _emBreve(escolha);
    }
  }

  /// RN-144: plano fixo pedido por este cliente.
  PlanoFixo? get _plano => planosFixos.planoDoCliente(widget.chamado.cliente);

  void _verPlano() {
    final p = _plano;
    if (p == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanoFixoProfissionalPage(plano: p)),
    );
  }

  /// RN-144: o profissional responde com o valor por visita (uma vez).
  Future<void> _valorDoPlano(PlanoFixo p) async {
    final v = await pedirValorPlano(context, p);
    if (v == null || !mounted) return;
    planosFixos.enviarValor(p, v);
  }

  /// RN-202/RN-205: o plano com este cliente, mesmo encerrado.
  PlanoFixo? get _planoVisivel =>
      planosFixos.ultimoCom(cliente: widget.chamado.cliente);

  /// RN-202/RN-205: barra do plano para o profissional.
  BarraPlano? get _barraPlano => _planoVisivel?.barra(cliente: false);

  /// Topo do chat com a barra fixa do plano logo abaixo (RN-202).
  Widget _comBarraDoPlano(Widget topo) {
    final b = _barraPlano;
    if (b == null) return topo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        topo,
        const SizedBox(height: TatuMedidas.entreItens),
        BarraPlanoFixo(
          barra: b,
          onTap: () {
            final p = _planoVisivel;
            if (p == null || p.status == StatusPlano.pendente) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlanoFixoProfissionalPage(plano: p),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _planoNoChat() {
    final p = _planoVisivel;
    if (p == null) return const [];
    final estado = p.estado();
    // RN-202: com o plano em andamento, a barra no topo já mostra.
    if (estado != EstadoPlano.aguardandoValor &&
        estado != EstadoPlano.valorEnviado &&
        estado != EstadoPlano.encerrado) {
      return const [];
    }
    return [
      const SizedBox(height: 18),
      // RN-205: encerrado: só o divisor.
      if (estado == EstadoPlano.encerrado)
        MarcadorChat(
          'Plano fixo encerrado · ${diaMes(p.encerradoEm ?? clock.now())}',
        )
      else if (p.status == StatusPlano.pendente && p.valorPorVisita == null)
        CartaoPedidoPlano(plano: p, onEnviarValor: () => _valorDoPlano(p))
      else
        NotaChat(
          'Valor do plano enviado · ${reaisInteiros(p.valorPorVisita!)} por '
          'visita. Aguardando ${p.clienteFeminina ? 'a' : 'o'} '
          '${p.primeiroCliente}.',
        ),
    ];
  }

  /// RN-140: do valor combinado (confirmado pelo cliente) até concluir.
  bool get _podeLigar => RegrasLigacao.disponivel(
    valorConfirmado: _estado == EstadoValor.combinado,
    concluido: false,
    encerrado:
        atendimentoProfissional.encerrados.containsKey(widget.chamado.cliente),
  );

  /// RN-140: o balão aparece uma vez, quando o ligar é liberado.
  bool _dicaLigarVista = false;

  void _ligar() {
    if (!_podeLigar) return;
    setState(() => _dicaLigarVista = true);
    ligarPeloTatu(context, widget.chamado.cliente, profissional: true);
  }

  Future<void> _cancelar() async {
    final c = widget.chamado;
    final sim = await confirmar(
      context,
      titulo: 'Cancelar atendimento?',
      texto:
          'A $_nome será avisada e vamos buscar\n'
          'outro profissional para ${c.feminino ? 'ela' : 'ele'}.',
      aviso: 'Cancelar muito baixa sua posição.',
      confirmar: 'Cancelar atendimento',
      cancelar: 'Continuar atendimento',
      perigo: true,
    );
    if (!sim || !mounted) return;
    _timer?.cancel();
    conversasProfissional.cancelar(c);
    atendimentoProfissional.encerrar();
    Navigator.of(context).pop();
  }

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  void _enviar([String? pronto]) {
    final texto = (pronto ?? _campo.text).trim();
    if (texto.isEmpty) return;
    setState(() => _mensagens.add((texto, true)));
    if (pronto == null) _campo.clear();
  }

  Future<void> _enviarValor() async {
    final v = await pedirValor(
      context,
      cliente: _nome,
      rodada: _rodada + 1,
      distancia: widget.chamado.distancia,
      // RN-181: no chat de um serviço concluído, é um novo serviço.
      novo: _concluida,
    );
    if (v == null || !mounted) return;
    setState(() {
      _rodada++;
      _meuValor = v.total;
      _meuDetalhe = v.detalhe;
      _minhaVisita = v.visita;
      _meuSinal = v.sinal;
      _estado = EstadoValor.aguardando;
    });
    _timer?.cancel();
    _timer = Timer(widget.resposta, _clienteResponde);
  }

  /// Resposta simulada do cliente.
  void _clienteResponde() {
    if (!mounted) return;
    // RN-181: protótipo: o novo valor pelo chat é confirmado pelo cliente.
    final aceita =
        _concluida || (_rodada > 1 && _meuValor <= _proposta * 1.15);
    if (aceita) {
      setState(() {
        _combinado = _meuValor;
        _estado = EstadoValor.combinado;
      });
      // RN-181: confirmado, vira um atendimento novo (aparece na Atividade).
      if (_concluida) atendimentoProfissional.aceitar(widget.chamado);
      _contarPrazoSaida();
    } else if (_rodada >= maxRodadas) {
      atendimentoProfissional.encerrar();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SemAcordoPage(
            cliente: '${widget.chamado.feminino ? 'A' : 'O'} $_nome',
          ),
        ),
      );
    } else {
      setState(() {
        _proposta = _rodada == 1
            ? (_meuValor * 0.8 / 10).round() * 10.0
            : _proposta + 10;
        _estado = EstadoValor.contraproposta;
      });
    }
  }

  void _aceitarProposta() {
    setState(() {
      _combinado = _proposta;
      _estado = EstadoValor.combinado;
    });
    _contarPrazoSaida();
  }

  /// RN-76: valor combinado; se não tocar em "Estou a caminho" dentro do
  /// prazo, o app pergunta "Ainda vai?".
  void _contarPrazoSaida() {
    _prazoSaida?.cancel();
    // RN-95: à distância não há "Estou a caminho" (abandono à distância
    // ainda é decisão em aberto). O valor vira marcador (RN-103: sinal).
    if (widget.chamado.distancia) {
      setState(
        () => _mensagens.add((
          '${_esp}marca:Valor combinado · ${reais(_combinado)}'
              '${_meuSinal > 0 ? ' · sinal de ${reaisInteiros(_meuSinal)} pago' : ''}',
          false,
        )),
      );
      return;
    }
    _prazoSaida = Timer(
      Prazos.naDemo(Prazos.estouACaminho),
      _perguntarAindaVai,
    );
  }

  Future<void> _perguntarAindaVai() async {
    if (!mounted) return;
    final c = widget.chamado;
    final vai = await perguntarAindaVai(
      context,
      cliente: c.primeiroNome,
      feminino: c.feminino,
    );
    if (!mounted) return;
    if (vai == true) {
      _irAteOCliente();
    } else {
      _devolver(naoConsegue: vai == false);
    }
  }

  /// RN-77: "Não consigo ir" ou sem resposta: o chamado volta à busca,
  /// nada é cobrado do cliente e conta como abandono.
  void _devolver({required bool naoConsegue}) {
    _prazoSaida?.cancel();
    profissional.registrarAbandono();
    atendimentoProfissional.encerrar();
    final c = widget.chamado;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChamadoDevolvidoPage(
          cliente: c.primeiroNome,
          feminino: c.feminino,
          naoConsegue: naoConsegue,
        ),
      ),
    );
  }

  void _irAteOCliente() {
    _prazoSaida?.cancel();
    final c = widget.chamado;
    final s = ServicoAceito(
      cliente: c.cliente,
      notaCliente: c.notaCliente,
      rua: c.rua,
      referencia: c.complemento,
      descricao: c.resumo,
      valor: _combinado,
      visita: _minhaVisita < _combinado ? _minhaVisita : 0,
      distanciaKm: c.distanciaKm,
      minutos: c.minutos,
    );
    atendimentoProfissional.irAteCliente(s);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ACaminhoPage(servico: s)),
    );
  }

  /// RN-95: à distância, combinado o valor, vai direto para Em andamento
  /// (sem rota, "Cheguei" nem código na porta).
  Future<void> _comecarDistancia() async {
    final c = widget.chamado;
    final s = ServicoAceito(
      cliente: c.cliente,
      notaCliente: c.notaCliente,
      rua: '',
      referencia: '',
      descricao: c.resumo,
      valor: _combinado,
      visita: 0,
      distanciaKm: 0,
      minutos: 0,
      feminino: c.feminino,
      distancia: true,
      sinal: _meuSinal,
    );
    final agora = DateTime.now();
    if (atendimentoProfissional.etapa != EtapaAtendimento.emServico) {
      atendimentoProfissional
        ..irAteCliente(s)
        ..iniciar(agora);
    }
    _inicioDistancia ??= agora;
    // Volta ao chat: de lá saem a prévia e a entrega (RN-99, RN-100).
    final acao = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EmAndamentoPage(servico: s, inicio: _inicioDistancia!),
      ),
    );
    if (!mounted) return;
    if (acao == 'previa') _enviarPrevia();
    if (acao == 'entrega') _enviarEntrega();
  }

  DateTime? _inicioDistancia;

  // ---------- Entrega à distância (RN-99 a RN-103) ----------

  /// P112 · "O que você vai mandar?": prévia protegida ou entrega.
  Future<void> _anexo() async {
    final restantes =
        RegrasDistancia.maxEntregas - atendimentoProfissional.entregas;
    final escolha = await mostrarFolha<String>(
      context,
      builder: (ctx) => _FolhaAnexo(
        cliente: _nome,
        restantes: restantes,
        onEscolher: (e) => Navigator.of(ctx).pop(e),
      ),
    );
    if (!mounted) return;
    if (escolha == 'previa') _enviarPrevia();
    if (escolha == 'entrega') _enviarEntrega();
  }

  /// RN-99: prévia protegida, à vontade.
  void _enviarPrevia() {
    // RN-127: prévia só com imagem, vídeo, PDF ou link de teste. Protótipo:
    // a prévia é uma imagem.
    if (!RegrasArquivo.permitidoNaPrevia('previa.jpg')) return;
    atendimentoProfissional.enviarPrevia();
    setState(() => _mensagens.add(('${_esp}previa', true)));
  }

  /// RN-100/RN-101/RN-103: entrega (no máximo 2). Na 1ª, o sinal é
  /// liberado. Protótipo: na 1ª a cliente pede ajuste; na 2ª, aprova.
  Future<void> _enviarEntrega() async {
    final a = atendimentoProfissional;
    if (!a.podeEntregar) return;
    final c = widget.chamado;
    // RN-125: link do site ou arquivo (programa só em tecnologia).
    final escolha = await escolherEntrega(
      context,
      numero: a.entregas + 1,
      cliente: _nome,
      tecnologia: ehTecnologia(c.profissao),
    );
    if (escolha == null || !mounted) return;
    // RN-126: antivírus em todo arquivo e verificação em todo link.
    final arquivo = escolha.arquivo;
    final r = arquivo == null
        ? await segurancaConteudo.enviarLink(escolha.link!)
        : await segurancaConteudo.enviarEntrega(
            arquivo,
            tecnologia: ehTecnologia(c.profissao),
          );
    if (!mounted) return;
    if (r == ResultadoEnvio.contaBanida || r == ResultadoEnvio.contaSuspensa) {
      return mostrarContaSuspensa(context, profissional: true);
    }
    if (r != ResultadoEnvio.entregue) {
      setState(
        () => _mensagens.add((
          '${_esp}nota:Entrega barrada · não chegou ${c.feminino ? 'à' : 'ao'} $_nome',
          false,
        )),
      );
      return;
    }
    a.enviarEntrega();
    final n = a.entregas;
    final ela = c.feminino ? 'a' : 'o';
    final nome = escolha.link ?? arquivo!.nome;
    final detalhe = escolha.link != null
        ? 'Link do site · verificado'
        : '${arquivo!.detalhe} · sem vírus';
    setState(() {
      // As prévias anteriores já foram vistas e expiraram.
      for (var i = 0; i < _mensagens.length; i++) {
        if (_mensagens[i].$1 == '${_esp}previa') {
          _mensagens[i] = ('${_esp}previa:vista', true);
        }
      }
      _mensagens
        ..add((
          '${_esp}entrega:$n|$nome|$detalhe|${escolha.link != null ? 'link' : ''}',
          true,
        ))
        ..add((
          '${_esp}nota:${n == 1 && _meuSinal > 0 ? 'Sinal de ${reaisInteiros(_meuSinal)} liberado · ' : ''}'
              'aguardando $ela $_nome aprovar',
          false,
        ));
    });
    _timer?.cancel();
    _timer = Timer(widget.resposta, () {
      if (!mounted) return;
      setState(() {
        _mensagens.removeWhere((m) => m.$1.startsWith('${_esp}nota:'));
        _mensagens.add(
          n < RegrasDistancia.maxEntregas
              ? (
                  '${_esp}ajuste:Quero as letras maiores e o rosa um pouco '
                      'mais claro.',
                  false,
                )
              : ('${_esp}aprovada', false),
        );
      });
    });
  }

  /// RN-123: denúncia de um arquivo recebido; ele some deste chat e vai
  /// para o suporte com prioridade máxima.
  Future<void> _denunciarArquivo(String mensagem, String arquivo) async {
    final motivo = await denunciarArquivo(context);
    if (motivo == null || !mounted) return;
    segurancaConteudo.denunciar(arquivo, motivo);
    setState(() => _mensagens.removeWhere((m) => m.$1 == mensagem));
  }

  /// Balão especial (prévia, entrega, nota, ajuste, aprovada).
  /// Chave de cada balão, para o menu abrir no lugar dele (RN-134).
  final _chaves = <int, GlobalKey>{};

  /// RN-134: segurar uma mensagem de texto do cliente.
  Future<void> _segurar(int i) async {
    final c = widget.chamado;
    final texto = _mensagens[i].$1;
    final motivo = await segurarMensagem(
      context,
      alvo: _chaves.putIfAbsent(i, GlobalKey.new),
      balao: BalaoChat(texto: texto, outro: '${c.feminino ? 'a' : 'o'} $_nome'),
      texto: texto,
      nome: _nome,
      feminino: c.feminino,
    );
    if (motivo == null || !mounted) return;
    // Contexto: as mensagens de texto em volta (sem as especiais).
    final textos = <String>[];
    var pos = 0;
    for (final (j, m) in _mensagens.indexed) {
      if (m.$1.startsWith(_esp)) continue;
      if (j == i) pos = textos.length;
      textos.add('${m.$2 ? 'Eu' : _nome}: ${m.$1}');
    }
    denuncias.denunciarMensagem(
      denunciante: profissional.nome,
      denunciado: c.cliente,
      motivo: motivo,
      mensagem: texto,
      contexto: RegrasDenuncia.contexto(textos, pos),
    );
    // Some só desta conversa; o cliente não vê nada (RN-133).
    setState(() => _mensagens[i] = ('${_esp}denunciada', false));
  }

  Widget _especial(String t) {
    final c = widget.chamado;
    final corpo = t.substring(1);
    // RN-134: só quem denunciou vê isso no lugar da mensagem.
    if (corpo == 'denunciada') return const MensagemDenunciada();
    final max = RegrasDistancia.maxEntregas;
    if (corpo.startsWith('previa')) {
      return BalaoPrevia(
        minha: true,
        valida: !corpo.endsWith(':vista'),
        vistaPor: _nome,
      );
    }
    if (corpo.startsWith('entrega:')) {
      final partes = corpo.substring(8).split('|');
      final n = int.parse(partes.first);
      final depois = _mensagens.any((m) => m.$1.startsWith('${_esp}ajuste:'));
      if (depois && n == 1) {
        return MarcadorChat('Entrega $n de $max enviada');
      }
      return _CartaoEntregaEnviada(
        numero: n,
        arquivo: partes.length > 1 ? partes[1] : 'entrega-final.zip',
        detalhe: partes.length > 2 ? partes[2] : 'ZIP · 8 MB',
        link: partes.length > 3 && partes[3] == 'link',
      );
    }
    // RN-120: arquivo barrado; só quem enviou vê.
    if (corpo == 'bloqueada') return const BalaoBloqueado();
    // RN-123: arquivo recebido do cliente; segurar o dedo denuncia.
    if (corpo.startsWith('arquivo:')) {
      final p = corpo.substring(8).split('|');
      return GestureDetector(
        onLongPress: () => _denunciarArquivo(t, p.first),
        child: BalaoArquivo(
          nome: p.first,
          detalhe: p.length > 1 ? p[1] : '',
        ),
      );
    }
    if (corpo.startsWith('nota:')) return MarcadorChat(corpo.substring(5));
    if (corpo.startsWith('marca:')) return MarcadorChat(corpo.substring(6));
    if (corpo.startsWith('ajuste:')) {
      final ultima = !_mensagens.any((m) => m.$1 == '${_esp}entrega:2');
      return _AjustePedido(
        cliente: _nome,
        feminino: c.feminino,
        texto: corpo.substring(7),
        botoes: ultima,
        onPrevia: _enviarPrevia,
        onEntrega: _enviarEntrega,
      );
    }
    // RN-100: a cliente aprovou: o restante é cobrado.
    return MarcoConcluido(
      '${c.feminino ? 'A' : 'O'} $_nome aprovou · ${reais(_combinado)}',
      nota: false,
    );
  }

  /// RN-42: faixa "Serviço concluído" e o dia das mensagens seguintes.
  List<Widget> _marco() => [
    const SizedBox(height: 18),
    MarcoConcluido(
      'Serviço concluído · ${reais(widget.concluidoPor!)}'
      '${widget.concluidoEm == null ? '' : ' · ${widget.concluidoEm}'}',
      nota: false,
    ),
    if (widget.diaDepois != null) ...[
      const SizedBox(height: 18),
      SeparadorDia(widget.diaDepois!),
    ],
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      atendimentoProfissional,
      planosFixos,
      retornos,
    ]),
    builder: (context, _) => _tela(context),
  );

  Widget _tela(BuildContext context) {
    final c = widget.chamado;
    final km = c.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    // RN-131/RN-132: o cliente foi suspenso e o Tatu encerrou.
    final fim = atendimentoProfissional.encerrados[c.cliente];
    return TelaChat(
      rodapeColado: fim != null,
      // P31 · RN-140: o ligar acabou de ser liberado.
      sobre: _podeLigar && !_dicaLigarVista
          ? BalaoLigarLiberado(
              onFechar: () => setState(() => _dicaLigarVista = true),
            )
          : null,
      topo: fim != null
          ? const TopoContaIndisponivel(detalhe: 'Cliente')
          : _comBarraDoPlano(Row(
        children: [
          const BackCircleButton(),
          Expanded(
            child: Semantics(
              container: true,
              button: true,
              label: 'Opções da conversa',
              child: GestureDetector(
                onTap: _menu,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarIniciais(nome: c.cliente),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.cliente,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // RN-202: "Cliente · Plano fixo".
                          Text(
                            _barraPlano == null
                                ? 'Cliente'
                                : 'Cliente · Plano fixo',
                            style: TatuTexto.nota,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // RN-140: o telefone só aparece com o valor confirmado.
          if (_podeLigar)
            BotaoLigar(onTap: _ligar)
          else
            const SizedBox(width: 48),
        ],
      )),
      mensagens: [
        CartaoPedidoChat(
          rotulo: 'Chamado',
          servico: c.profissao,
          descricao: c.resumo,
          lado: c.distancia ? 'À distância' : '${c.bairro} · $km km',
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        if (fim == null)
          const NotaChat('Você aceitou o chamado. Combinem o valor por aqui.'),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        // RN-203: visitas do plano já feitas.
        if (fim == null && _planoVisivel != null)
          for (final v in _planoVisivel!.visitas)
            if (v.situacao == SituacaoVisita.feita) ...[
              DivisorChat('Visita do plano · ${diaMes(v.dia)} · feita'),
              const SizedBox(height: 18),
            ],
        // RN-179: o mesmo divisor que o cliente vê, depois do serviço
        // anterior.
        if (c.pediuDeNovoEm case final dia?) ...[
          if (c.valorAnterior case final valor?) ...[
            MarcoConcluido(
              'Serviço concluído · ${reais(valor)} · $dia',
              nota: false,
            ),
            const SizedBox(height: 18),
          ],
          DivisorChat('Novo pedido · ${diaMes(clock.now())} · ${c.resumo}'),
          const SizedBox(height: 18),
        ],
        for (final (i, m) in _mensagens.indexed) ...[
          if (_concluida && i == _antes) ..._marco(),
          Padding(
            padding: EdgeInsets.only(
              top: m.$1.startsWith(_esp) ||
                      (i > 0 && _mensagens[i - 1].$1.startsWith(_esp))
                  ? 18
                  : espacoAntesDoBalao(
                      anteriorMinha: i == 0 ? null : _mensagens[i - 1].$2,
                      minha: m.$2,
                    ),
            ),
            child: m.$1.startsWith(_esp)
                ? _especial(m.$1)
                : GestureDetector(
                    key: _chaves.putIfAbsent(i, GlobalKey.new),
                    // RN-134: segurar a mensagem do cliente.
                    onLongPress: m.$2 || fim != null ? null : () => _segurar(i),
                    child: BalaoChat(
                      texto: m.$1,
                      minha: m.$2,
                      outro: '${c.feminino ? 'a' : 'o'} $_nome',
                    ),
                  ),
          ),
        ],
        if (_concluida && _mensagens.length == _antes) ..._marco(),
        if (fim == null) ..._planoNoChat(),
        // P152 a P155 · RN-186: pedido de retorno deste cliente.
        if (fim == null ? retornos.doCliente(c.cliente) : null
            case final r?)
          ...secaoRetornoProfissional(
            context,
            r,
            onOutroValor: _enviarValor,
          ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        if (fim != null) ...[
          // RN-131: o Tatu avisa o que o profissional recebe.
          CartaoTatuChat(texto: fim.mensagem),
          if (fim.nota != null) ...[
            const SizedBox(height: TatuMedidas.entreSecoes),
            NotaChat(fim.nota!),
          ],
        ] else
        ...switch (_estado) {
            EstadoValor.inicio => const <Widget>[],
            // P104 · RN-181: novo valor no chat de um serviço concluído.
            EstadoValor.aguardando when _concluida => [
              _MeuValor(
                rodada: _rodada,
                valor: _meuValor,
                detalhe: '',
                icone: TablerIcons.clock,
                titulo: 'Novo valor',
                situacao:
                    'Aguardando ${c.feminino ? 'a' : 'o'} $_nome confirmar',
                aviso: true,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              NotaChat(
                'Só vira serviço quando ${c.feminino ? 'a' : 'o'} $_nome '
                'confirmar.',
              ),
            ],
            EstadoValor.aguardando => [
              _MeuValor(
                rodada: _rodada,
                valor: _meuValor,
                detalhe: _meuDetalhe,
                icone: TablerIcons.clock,
                situacao: 'Aguardando a $_nome',
              ),
            ],
            EstadoValor.contraproposta => [
              _MeuValor(
                rodada: _rodada,
                valor: _meuValor,
                detalhe: _meuDetalhe,
                icone: TablerIcons.refresh,
                situacao: '$_nome propôs outro valor',
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              _Proposta(
                nome: _nome,
                rodada: _rodada,
                valor: _proposta,
                onAceitar: _aceitarProposta,
                onOutro: _enviarValor,
              ),
            ],
            // À distância, o valor combinado vira marcador na conversa.
            EstadoValor.combinado when c.distancia => const <Widget>[],
            EstadoValor.combinado => [
              // RN-181: o mesmo card preto que o cliente vê.
              if (_concluida) ...[
                DivisorChat(
                  'Novo serviço iniciado pelo chat · ${reais(_combinado)}',
                  nota: 'Ele aparece na sua Atividade.',
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
              ],
              _ValorCombinado(valor: _combinado),
              const SizedBox(height: TatuMedidas.entreItens),
              // RN-28: no local, o endereço aparece.
              _EnderecoLiberado(chamado: c),
            ],
          },
        const SizedBox(height: TatuMedidas.entreItens),
      ],
      // RN-132: só leitura depois que o Tatu encerra.
      // RN-42: fora isso, a conversa nunca fecha.
      rodape: fim != null
          ? const RodapeConversaEncerrada()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_estado == EstadoValor.inicio && _concluida) ...[
                  // RN-87: cada valor combinado é um pagamento novo.
                  FilledButton(
                    onPressed: _enviarValor,
                    child: const Text('Enviar novo valor'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ] else if (_estado == EstadoValor.inicio) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        if (!c.distancia)
                        TatuChip(
                          label: 'Estou a caminho',
                          onTap: () => _enviar('Estou a caminho'),
                        ),
                        TatuChip(
                          label: c.distancia ? 'Mandar arquivo' : 'Mandar foto',
                          onTap: () => _emBreve('Mandar foto'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  FilledButton(
                    onPressed: _enviarValor,
                    child: const Text('Enviar valor'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ],
                if (_estado == EstadoValor.combinado) ...[
                  FilledButton(
                    onPressed: c.distancia ? _comecarDistancia : _irAteOCliente,
                    child: Text(c.distancia ? 'Ver em andamento' : 'Estou a caminho'),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                ],
                // RN-85: contato não passa pelo chat.
                BarraMensagem(
                  controller: _campo,
                  onEnviar: _enviar,
                  // RN-99/RN-100: à distância, anexo é prévia ou entrega.
                  onCamera: c.distancia && _estado == EstadoValor.combinado
                      ? _anexo
                      : () => _emBreve('Mandar foto'),
                  porQue:
                      'Pelo Tatu você recebe garantido, e o serviço conta '
                      'para sua nota.',
                ),
              ],
            ),
    );
  }
}

/// Cartão com contorno, à direita: o valor que o profissional enviou.
class _MeuValor extends StatelessWidget {
  const _MeuValor({
    required this.rodada,
    required this.valor,
    required this.detalhe,
    required this.icone,
    required this.situacao,
    this.titulo,
    this.aviso = false,
  });

  final int rodada;
  final double valor;
  final String detalhe;
  final IconData icone;
  final String situacao;

  /// Título no lugar de "Seu valor · 1 de 3" (ex.: "Novo valor").
  final String? titulo;

  /// Situação em laranja (esperando o cliente confirmar).
  final bool aviso;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: Border.all(color: TatuColors.textPrimary, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo ?? 'Seu valor · $rodada de $maxRodadas',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: 2),
              _Valor(valor),
              if (detalhe.isNotEmpty) Text(detalhe, style: TatuTexto.nota),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    icone,
                    size: 15,
                    color: aviso
                        ? TatuColors.warningTexto
                        : TatuColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      situacao,
                      style: TatuTexto.nota.copyWith(
                        fontWeight: FontWeight.w600,
                        color: aviso ? TatuColors.warningTexto : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão cinza, à esquerda: o valor que o cliente propôs.
class _Proposta extends StatelessWidget {
  const _Proposta({
    required this.nome,
    required this.rodada,
    required this.valor,
    required this.onAceitar,
    required this.onOutro,
  });

  final String nome;
  final int rodada;
  final double valor;
  final VoidCallback onAceitar;
  final VoidCallback onOutro;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Proposta da $nome · $rodada de $maxRodadas',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: 2),
              _Valor(valor),
              const SizedBox(height: TatuMedidas.entreItens),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(TatuMedidas.alturaBusca),
                ),
                onPressed: onAceitar,
                child: Text('Aceitar ${reais(valor)}'),
              ),
              const SizedBox(height: 4),
              Center(child: LinkAzul('Enviar outro valor', onTap: onOutro)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Valor extends StatelessWidget {
  const _Valor(this.valor);

  final double valor;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      reais(valor),
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
    ),
  );
}

/// Cartão verde: os dois lados fecharam o valor.
class _ValorCombinado extends StatelessWidget {
  const _ValorCombinado({required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.onlineSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: TatuColors.online,
            child: Icon(
              TablerIcons.check,
              size: 18,
              color: TatuColors.onAction,
            ),
          ),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor combinado',
                  style: TatuTexto.nota.copyWith(color: TatuColors.onlineTexto),
                ),
                const SizedBox(height: 2),
                Text(
                  reais(valor),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

/// Cartão cinza: endereço exato, liberado só com o valor combinado.
class _EnderecoLiberado extends StatelessWidget {
  const _EnderecoLiberado({required this.chamado});

  final ChamadoNovo chamado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(TablerIcons.map_pin, size: 20),
          ),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Endereço liberado', style: TatuTexto.nota),
                const SizedBox(height: 2),
                Text(
                  '${chamado.rua} · ${chamado.complemento}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${chamado.bairro}, ${chamado.cidade}',
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// P28 · RN-209: o cliente recusou o último valor: o chamado é encerrado
/// sem custo e não conta contra o profissional (nem como cancelamento,
/// RN-64, nem como abandono, RN-79).
class SemAcordoPage extends StatelessWidget {
  const SemAcordoPage({super.key, this.cliente = 'A Ana'});

  /// "A Ana", "O Carlos".
  final String cliente;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      icone: const IconePermissao(TablerIcons.x, cor: TatuColors.textPrimary),
      titulo: 'Sem acordo de valor',
      texto:
          '$cliente recusou o último valor.\n'
          'O chamado foi encerrado sem custo e\n'
          'não conta contra você. Você continua\n'
          'online para novos chamados.',
      principal: 'Voltar para o início',
      onPrincipal: () => Navigator.of(context).popUntil((r) => r.isFirst),
    );
  }
}

/// Prefixo das mensagens especiais da entrega à distância.
const _esp = '\u0001';

/// P112 · Folha "O que você vai mandar?" (RN-99, RN-101).
class _FolhaAnexo extends StatelessWidget {
  const _FolhaAnexo({
    required this.cliente,
    required this.restantes,
    required this.onEscolher,
  });

  final String cliente;
  final int restantes;
  final ValueChanged<String> onEscolher;

  @override
  Widget build(BuildContext context) {
    Widget opcao({
      required IconData icone,
      required String titulo,
      required String detalhe,
      required String lado,
      required VoidCallback? onTap,
    }) => Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        child: InkWell(
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(icone, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(detalhe, style: TatuTexto.nota),
                    ],
                  ),
                ),
                Text(lado, style: TatuTexto.nota),
              ],
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          10,
          TatuMedidas.margemCadastro,
          TatuMedidas.base + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            const Text(
              'O que você vai mandar?',
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            opcao(
              icone: TablerIcons.lock,
              titulo: 'Prévia protegida',
              // RN-127: só imagem, vídeo, PDF ou link de teste.
              detalhe: 'Imagem, vídeo, PDF ou link de teste.',
              lado: 'à vontade',
              onTap: () => onEscolher('previa'),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            opcao(
              icone: TablerIcons.upload,
              titulo: 'Entrega',
              // RN-125: arquivo, programa ou link do site.
              detalhe: 'Arquivo, programa ou link do site.',
              lado: restantes == 1 ? '1 restante' : '$restantes restantes',
              onTap: restantes > 0 ? () => onEscolher('entrega') : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// P113 · Cartão preto da entrega enviada (RN-100).
class _CartaoEntregaEnviada extends StatelessWidget {
  const _CartaoEntregaEnviada({
    required this.numero,
    required this.arquivo,
    this.detalhe = 'ZIP · 8 MB',
    this.link = false,
  });

  final int numero;
  final String arquivo;
  final String detalhe;
  final bool link;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: TatuColors.action,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entrega $numero de ${RegrasDistancia.maxEntregas}',
                style: TatuTexto.nota.copyWith(
                  color: TatuColors.avisoEscuroTexto,
                ),
              ),
              const SizedBox(height: 10),
              LinhaArquivo(
                nome: arquivo,
                detalhe: detalhe,
                escuro: true,
                icone: link ? TablerIcons.location : TablerIcons.file_text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// P114 · A cliente pediu ajuste depois da 1ª entrega (RN-101).
class _AjustePedido extends StatelessWidget {
  const _AjustePedido({
    required this.cliente,
    required this.feminino,
    required this.texto,
    required this.botoes,
    required this.onPrevia,
    required this.onEntrega,
  });

  final String cliente;
  final bool feminino;
  final String texto;

  /// Ainda falta mandar a 2ª entrega.
  final bool botoes;
  final VoidCallback onPrevia;
  final VoidCallback onEntrega;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.82,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TatuColors.warningSoft,
                borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        TablerIcons.pencil,
                        size: 18,
                        color: TatuColors.warningTexto,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$cliente pediu um ajuste',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TatuColors.warningTexto,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('“$texto”', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 10),
                  Text(
                    'Você tem mais 1 entrega. É a última.',
                    style: TatuTexto.nota.copyWith(
                      color: TatuColors.warningTexto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (botoes) ...[
          const SizedBox(height: TatuMedidas.entreItens + 4),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: tatuBotaoSecundario().copyWith(
                    minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
                  ),
                  onPressed: onPrevia,
                  child: const FittedBox(child: Text('Enviar prévia')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: onEntrega,
                  child: const FittedBox(child: Text('Enviar entrega 2')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
