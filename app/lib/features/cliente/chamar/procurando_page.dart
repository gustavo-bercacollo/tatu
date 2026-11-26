import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/encontrados.dart' show filaPara, inicioDaFila;
import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/espaco_anuncio.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../entrada/seguranca.dart';
import '../abas.dart';
import '../mensagens/chat_page.dart';
import 'encontrado_page.dart';
import 'ninguem_ativo_page.dart';

/// Fase da busca mostrada na tela.
enum FaseBusca { inicio, expandindo }

/// Por que a busca recomeçou com [ProcurandoPage.anterior].
enum TrocaProfissional {
  /// O profissional cancelou (RN-44).
  cancelou,

  /// Não confirmou que vinha: voltou sozinho à busca (RN-77).
  naoConfirmou,

  /// O cliente trocou por atraso, sem custo (RN-78).
  atrasou,
}

/// Procurando um profissional: o pedido vai ao mesmo tempo para todos os
/// ativos por perto (radar no mapa). O raio expande sozinho aos 60 s e,
/// aos 90 s sem ninguém, a busca segue em segundo plano ("Ninguém ativo").
/// Fechar (x) também deixa a busca em segundo plano.
///
/// Com [anterior], é a busca depois que esse profissional cancelou
/// ("Chamando outro profissional").
class ProcurandoPage extends StatefulWidget {
  const ProcurandoPage({
    super.key,
    required this.servico,
    required this.endereco,
    this.anterior,
    this.animar = true,
    this.fase = FaseBusca.inicio,
    this.direto,
    this.diretoFeminino = true,
    this.simularAceite = true,
    this.troca = TrocaProfissional.cancelou,
    this.distancia = false,
    this.descricao = '',
    this.deNovo,
  });

  /// O que a pessoa escreveu (RN-176: no "Pedir de novo", a descrição do
  /// pedido anterior).
  final String descricao;

  /// RN-176/RN-177: "Pedir de novo" com a mesma pessoa: aceito, abre a
  /// mesma conversa com um atendimento novo (RN-179).
  final PedidoConcluido? deNovo;

  /// RN-94: busca à distância, sem mapa nem raio, em ondas: primeiro os
  /// mais bem avaliados online, depois todos os online.
  final bool distancia;

  /// Motivo da nova busca quando há [anterior].
  final TrocaProfissional troca;

  /// Protótipo: alguém aceita depois de [aceitaEm] (nulo nos testes que
  /// esperam o raio expandir). Desligado depois de passar pela fila toda.
  final bool simularAceite;
  static Duration? aceitaEm = const Duration(seconds: 8);

  /// "Pedir de novo" com o mesmo profissional: chama só ele por
  /// [esperaDireto]; se não aceitar, chama todos os outros por perto.
  final String? direto;
  final bool diretoFeminino;

  static const esperaDireto = Duration(minutes: 2);

  final String servico;
  final String endereco;
  final PedidoAndamento? anterior;

  /// Desligado nas capturas de tela (imagem parada na [fase]).
  final bool animar;
  final FaseBusca fase;

  /// Tempo até expandir o raio e até desistir (regra: 60–90 s).
  static const expandeEm = Duration(seconds: 60);
  static const desisteEm = Duration(seconds: 90);

  @override
  State<ProcurandoPage> createState() => _ProcurandoPageState();
}

class _ProcurandoPageState extends State<ProcurandoPage>
    with TickerProviderStateMixin {
  late final _busca = AnimationController(
    vsync: this,
    duration: widget.direto == null
        ? ProcurandoPage.desisteEm
        : ProcurandoPage.esperaDireto,
    value: widget.animar
        ? 0
        : widget.direto != null
        ? 0.45
        : (widget.fase == FaseBusca.inicio ? 0.3 : 0.75),
  );
  late final _pulso = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  Timer? _fim;
  Timer? _aceite;
  bool _saiu = false;

  double get _limiteExpandir =>
      ProcurandoPage.expandeEm.inMilliseconds /
      ProcurandoPage.desisteEm.inMilliseconds;

  @override
  void initState() {
    super.initState();
    if (widget.animar) {
      _busca.forward();
      _pulso.repeat();
      _fim = widget.direto == null
          ? Timer(ProcurandoPage.desisteEm, _ninguemAtivo)
          : Timer(ProcurandoPage.esperaDireto, _chamarOutros);
      final aceita = ProcurandoPage.aceitaEm;
      if (widget.simularAceite && aceita != null) {
        _aceite = Timer(aceita, _encontrou);
      }
    }
  }

  @override
  void dispose() {
    _fim?.cancel();
    _aceite?.cancel();
    _busca.dispose();
    _pulso.dispose();
    // Saiu pelo "x" ou voltar: a busca continua em segundo plano.
    if (!_saiu && widget.animar) {
      final busca = BuscaSegundoPlano(
        servico: widget.servico,
        endereco: widget.endereco,
        descricao: widget.descricao,
      );
      // Depois do quadro atual (a árvore está sendo desmontada).
      Future.microtask(() => pedidos.buscarEmSegundoPlano(busca));
    }
    super.dispose();
  }

  void _emSegundoPlano() => pedidos.buscarEmSegundoPlano(
    BuscaSegundoPlano(
      servico: widget.servico,
      endereco: widget.endereco,
      descricao: widget.descricao,
    ),
  );

  void _ninguemAtivo() {
    if (!mounted) return;
    _saiu = true;
    _emSegundoPlano();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NinguemAtivoPage(servico: widget.servico),
      ),
    );
  }

  /// Alguém aceitou: "Profissional encontrado". Depois que um
  /// profissional cancelou, a fila começa no próximo.
  void _encontrou() {
    if (!mounted) return;
    _saiu = true;
    _fim?.cancel();
    if (widget.deNovo case final p?) return _aceitouDeNovo(p);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EncontradoPage(
          servico: widget.servico,
          endereco: widget.endereco,
          // RN-90: cada chamada começa em outra pessoa.
          indice:
              inicioDaFila(
                fila: filaPara(
                  soMulheres: seguranca.preferirMulheres,
                  distancia: widget.distancia,
                ),
                ocupados: {
                  for (final p in pedidos.andamentos) p.profissional,
                  // RN-229: quem ficou sem acordo não volta.
                  ...pedidos.recusados,
                },
              ) +
              (widget.anterior == null ? 0 : 1),
          distancia: widget.distancia,
          descricao: widget.descricao,
        ),
      ),
    );
  }

  /// RN-177/RN-179: a mesma pessoa aceitou dentro dos 2 min. O cliente já
  /// escolheu quem chamar: vai direto para a mesma conversa, com o
  /// divisor "Novo pedido" e o valor (fluxo normal a partir daqui).
  void _aceitouDeNovo(PedidoConcluido p) {
    final descricao = widget.descricao.isEmpty ? p.descricao : widget.descricao;
    pedidos.aceitar(
      PedidoAndamento(
        servico: widget.servico,
        profissao: p.profissao,
        profissional: p.profissional,
        nota: '4,9',
        endereco: widget.endereco,
        valor: '',
        pagamento: '',
        etapasFeitas: 1,
        chegaEm: p.chegaEm,
        descricao: descricao,
      ),
    );
    final c = conversas.comecar(
      nome: p.profissional,
      profissao: p.profissao,
      feminino: p.feminino,
      servico: widget.servico,
      rua: widget.endereco,
      descricao: descricao,
    );
    final nav = Navigator.of(context);
    irParaAba(context, AbaCliente.mensagens);
    nav.push(MaterialPageRoute(builder: (_) => ChatPage(conversa: c)));
  }

  /// O profissional chamado direto não aceitou: busca normal.
  void _chamarOutros() {
    if (!mounted) return;
    _saiu = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProcurandoPage(
          servico: widget.servico,
          endereco: widget.endereco,
          distancia: widget.distancia,
          descricao: widget.descricao,
        ),
      ),
    );
  }

  bool get _expandindo =>
      widget.direto == null && _busca.value >= _limiteExpandir;

  void _cancelar() {
    _saiu = true;
    if (widget.anterior != null) pedidos.cancelarAndamento();
    irParaAba(context, AbaCliente.inicio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.distancia)
                  // RN-94: sem mapa; os avatares são quem está online.
                  ColoredBox(
                    color: TatuColors.surfaceGrouped,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulso, _busca]),
                      builder: (_, _) => _RadarDistancia(
                        pulso: _pulso.value,
                        todos: _expandindo,
                      ),
                    ),
                  )
                else ...[
                const CustomPaint(painter: MapaFalso()),
                AnimatedBuilder(
                  animation: Listenable.merge([_pulso, _busca]),
                  builder: (_, _) => CustomPaint(
                    painter: _Radar(
                      pulso: _pulso.value,
                      expandido: _expandindo,
                      circulos: widget.direto == null,
                    ),
                  ),
                ),
                ],
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.topo,
                      0,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        button: true,
                        label: 'Fechar',
                        child: Material(
                          color: TatuColors.bg,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(TablerIcons.x, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preferência de atendimento do cliente no topo do mapa.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: TatuMedidas.topo + 6),
              child: Align(
                alignment: Alignment.topCenter,
                child: ListenableBuilder(
                  listenable: seguranca,
                  builder: (_, _) => seguranca.preferirMulheres
                      ? const SeloPreferencia('Só profissionais mulheres')
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(TatuMedidas.raioFolha),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    10,
                    TatuMedidas.margem,
                    TatuMedidas.base,
                  ),
                  child: AnimatedBuilder(
                    animation: _busca,
                    builder: (_, _) => _painel(expandindo: _expandindo),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _painel({required bool expandindo}) {
    final a = widget.anterior;
    final String titulo;
    final String texto;
    if (widget.distancia) {
      // RN-94: ondas, sem raio.
      final s = widget.servico.toLowerCase();
      titulo = 'Procurando um $s';
      texto = expandindo
          ? 'Agora avisamos todos os profissionais\nque estão online.'
          : 'Avisamos primeiro os mais bem avaliados\nque estão online agora.';
    } else if (widget.direto != null) {
      final ela = widget.diretoFeminino;
      titulo = 'Chamando ${ela ? 'a' : 'o'} ${widget.direto}';
      texto =
          'Se ${ela ? 'ela' : 'ele'} não aceitar em 2 min,\nchamamos outro ${widget.servico.toLowerCase()} perto de você.';
    } else if (expandindo) {
      titulo = 'Procurando um profissional';
      texto = 'Ninguém aceitou ainda. Estamos chamando\nmais profissionais.';
    } else if (a != null) {
      final ela = a.profissao.endsWith('a');
      final quem = a.artigoNome;
      switch (widget.troca) {
        case TrocaProfissional.naoConfirmou:
          // RN-77: voltou à busca sozinho, sem cobrar nada.
          titulo = 'Chamando outro ${widget.servico.toLowerCase()}';
          texto = '$quem não confirmou que vinha.\nNada foi cobrado.';
        case TrocaProfissional.atrasou:
          // RN-78: troca por atraso, sem custo (nem a visita).
          titulo = 'Chamando outro ${widget.servico.toLowerCase()}';
          texto =
              '$quem está ${ela ? 'atrasada' : 'atrasado'}.\n'
              'Nada foi cobrado.';
        case TrocaProfissional.cancelou:
          titulo = 'Chamando outro profissional';
          texto = '$quem não está mais disponível.\nNada foi cobrado.';
      }
    } else {
      titulo = 'Procurando um profissional';
      texto = 'Avisamos quem está ativo perto de você.\nO primeiro que aceitar fala com você.';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AlcaFolha(),
        const SizedBox(height: TatuMedidas.entreSecoes),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            titulo,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(texto, style: TatuTexto.corpo),
        const SizedBox(height: TatuMedidas.entreSecoes),
        if (expandindo && !widget.distancia) ...[
          const Row(
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: TatuColors.online,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Expandindo a busca para sua região…',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
        ],
        // Três etapas da busca (o raio cresce a cada uma).
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (_busca.value * 3 - i).clamp(0.0, 1.0),
                    minHeight: 6,
                    color: TatuColors.action,
                    backgroundColor: TatuColors.trilho,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const EspacoAnuncio(),
        const SizedBox(height: TatuMedidas.entreSecoes),
        FilledButton(
          style: tatuBotaoSecundario(),
          onPressed: _cancelar,
          child: const Text('Cancelar pedido'),
        ),
      ],
    );
  }
}

/// RN-94: busca à distância: círculos verdes e os avatares de quem está
/// online (sem mapa). Na 2ª onda ([todos]) os círculos crescem.
class _RadarDistancia extends StatelessWidget {
  const _RadarDistancia({required this.pulso, required this.todos});

  final double pulso;
  final bool todos;

  static const _online = [
    ('Marina Reis', Offset(-88, -92)),
    ('Tiago Santos', Offset(96, -66)),
    ('Carla Lima', Offset(-78, 76)),
    ('Julia Prado', Offset(66, 92)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final centro = Offset(c.maxWidth / 2, c.maxHeight * 0.33);
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _Radar(
                  pulso: pulso,
                  expandido: todos,
                  semPontos: true,
                ),
              ),
            ),
            for (final (nome, o) in _online)
              Positioned(
                left: centro.dx + o.dx - 18,
                top: centro.dy + o.dy - 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AvatarIniciais(nome: nome, tamanho: 36),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: TatuColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(color: TatuColors.bg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Círculos verdes em volta de quem pediu, profissionais por perto e o
/// ponto preto no centro. [expandido] aumenta o raio.
class _Radar extends CustomPainter {
  const _Radar({
    required this.pulso,
    required this.expandido,
    this.circulos = true,
    this.semPontos = false,
  });

  final double pulso;
  final bool expandido;

  /// Sem os pontos verdes (à distância, viram avatares).
  final bool semPontos;

  /// Sem círculos quando chama um profissional só.
  final bool circulos;

  static const _profissionais = [
    Offset(-86, -120),
    Offset(94, -80),
    Offset(34, 70),
    Offset(-46, 110),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(
      size.width / 2,
      size.height * (semPontos ? 0.33 : 0.34),
    );
    final escala = expandido ? 1.25 : 1.0;
    final verde = Paint()..color = TatuColors.radar;
    for (final r in circulos ? [60.0, 115.0, 170.0] : const <double>[]) {
      canvas.drawCircle(centro, r * escala + 6 * pulso, verde);
    }
    final borda = Paint()..color = TatuColors.bg;
    final pro = Paint()..color = TatuColors.online;
    for (final o in semPontos ? const <Offset>[] : _profissionais) {
      canvas.drawCircle(centro + o * escala, 10, borda);
      canvas.drawCircle(centro + o * escala, 7.5, pro);
    }
    canvas.drawCircle(centro, 13, borda);
    canvas.drawCircle(centro, 10, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_Radar oldDelegate) =>
      oldDelegate.pulso != pulso || oldDelegate.expandido != expandido;
}
