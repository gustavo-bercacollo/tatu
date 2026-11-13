import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/atendimento_profissional.dart';import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/navegacao.dart';
import '../../../data/seguranca.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'rota.dart';
import '../../entrada/seguranca.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// P24 · A caminho do cliente: rota no mapa, endereço, "Abrir rota" e
/// "Cheguei", que só libera perto do local (protótipo: depois de
/// [chegaEm]) e com a localização ligada. Perto, vira "Quase lá" com o
/// aviso no topo. Depois do "Cheguei": "Você chegou".
class ACaminhoPage extends StatefulWidget {
  const ACaminhoPage({
    super.key,
    this.servico = servicoExemplo,
    this.chegaEm = const Duration(seconds: 5),
    this.perto = false,
    this.chegou = false,
  });

  final ServicoAceito servico;
  final Duration chegaEm;

  /// Abre já perto do local (fluxograma e testes).
  final bool perto;

  /// Abre já no local (para o fluxograma e testes).
  final bool chegou;

  @override
  State<ACaminhoPage> createState() => _ACaminhoPageState();
}

class _ACaminhoPageState extends State<ACaminhoPage> {
  late bool _perto = widget.perto || widget.chegou;
  late bool _chegou = widget.chegou;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_perto) {
      _timer = Timer(widget.chegaEm, () {
        if (mounted) setState(() => _perto = true);
      });
    }
    // Atendimento novo: o alerta do anterior não continua.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => seguranca.encerrarAlerta(cliente: false),
    );
    if (!navegacao.localizacaoAtiva) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pedirLocalizacao());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pedirLocalizacao() async {
    if (!mounted) return;
    final s = widget.servico;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocalizacaoCaminhoPage(
          cliente: s.primeiroNome,
          feminino: s.feminino,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final localizacao = navegacao.localizacaoAtiva;
    final perto = _perto && localizacao && !_chegou;
    final daCliente = '${s.feminino ? 'da' : 'do'} ${s.primeiroNome}';
    final km = s.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const MapaFalso(),
              foregroundPainter: _chegou ? _NoLocal() : _Rota(perto: perto),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      button: true,
                      label: 'Voltar',
                      child: Material(
                        color: TatuColors.bg,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(TablerIcons.chevron_left, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (perto) ...[
                    const SizedBox(height: 8),
                    _AvisoPerto(
                      titulo: 'Você chegou perto $daCliente',
                      texto:
                          'Toque em “Cheguei” para avisá-${s.feminino ? 'la' : 'lo'}.',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: TatuMedidas.larguraMax,
              ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AlcaFolha(),
                      const SizedBox(height: 16),
                      if (_chegou) ...[
                        ..._topoChegou(s),
                        const SizedBox(height: TatuMedidas.entreItens),
                        CartaoEndereco(servico: s),
                        const SizedBox(height: 10),
                        CartaoServico(servico: s),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        FilledButton(
                          onPressed: () {
                            final agora = DateTime.now();
                            atendimentoProfissional.iniciar(agora);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => EmAndamentoPage(
                                  servico: s,
                                  inicio: agora,
                                ),
                              ),
                            );
                          },
                          child: const Text('Iniciar serviço'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          style: tatuBotaoSecundario(),
                          onPressed: () => _emBreve(context, 'Chat'),
                          icon: const Icon(
                            TablerIcons.message_circle,
                            size: 20,
                          ),
                          label: Text('Falar com ${s.primeiroNome}'),
                        ),
                      ] else ...[
                        Text(
                          perto ? 'Quase lá' : 'A caminho $daCliente',
                          style: TatuTexto.tituloFolha,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perto
                              ? '200 m $daCliente'
                              : 'Chegada em ${s.minutos} min · $km km',
                          style: TatuTexto.detalhe,
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        CartaoEndereco(servico: s),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        FilledButton(
                          style: tatuBotaoSecundario(),
                          onPressed: () => abrirRota(context, s),
                          child: const Text('Abrir rota'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          style: perto ? null : tatuBotaoSecundario(),
                          onPressed: perto
                              ? () {
                                  atendimentoProfissional.chegou();
                                  setState(() => _chegou = true);
                                }
                              : null,
                          child: const Text('Cheguei'),
                        ),
                        const SizedBox(height: 10),
                        if (!localizacao)
                          Center(
                            child: LinkAzul(
                              'Ativar localização',
                              onTap: _pedirLocalizacao,
                            ),
                          )
                        else
                          Text(
                            perto
                                ? 'Toque quando estiver na porta.'
                                : '“Cheguei” libera quando você estiver perto.',
                            textAlign: TextAlign.center,
                            style: TatuTexto.nota,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _topoChegou(ServicoAceito s) => [
    const Align(
      alignment: Alignment.centerLeft,
      child: SeloVerde('No local', pequeno: true),
    ),
    const SizedBox(height: 10),
    const Text('Você chegou', style: TatuTexto.tituloFolha),
    const SizedBox(height: 4),
    Text(
      '${s.primeiroNome} foi ${s.feminino ? 'avisada' : 'avisado'} de que você está aí.',
      style: TatuTexto.detalhe,
    ),
  ];
}

/// Aviso escuro fixo no topo do mapa ("Você chegou perto da Ana").
class _AvisoPerto extends StatelessWidget {
  const _AvisoPerto({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: TatuColors.avisoEscuro,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Row(
      children: [
        const Icon(TablerIcons.map_pin, color: TatuColors.onAction, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.onAction,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  color: TatuColors.avisoEscuroTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// P25 · Serviço em andamento: cliente, valor, início, escudo de
/// segurança no topo e "Concluir e cobrar".
class EmAndamentoPage extends StatelessWidget {
  const EmAndamentoPage({
    super.key,
    this.servico = servicoExemplo,
    required this.inicio,
  });

  final ServicoAceito servico;
  final DateTime inicio;

  @override
  Widget build(BuildContext context) {
    final s = servico;
    final hora =
        '${inicio.hour.toString().padLeft(2, '0')}:'
        '${inicio.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BackCircleButton(),
                        ),
                        const Text(
                          'Em andamento',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: BotaoEscudo(
                            servico: Atendimento.doServico(s, chegouAs: hora),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: seguranca,
                    builder: (_, _) => seguranca.alertaProfissional
                        ? const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Center(child: SeloAlertaAtivo()),
                          )
                        : const SizedBox(height: 10),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10),
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                          decoration: BoxDecoration(
                            color: TatuColors.bg,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioOpcao,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  AvatarIniciais(nome: s.cliente, tamanho: 44),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.cliente,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.descricao} · ${reais(s.valor)}',
                                          style: TatuTexto.detalhe,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(
                                height: 1,
                                color: TatuColors.hairline,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Iniciado às $hora',
                                      style: TatuTexto.detalhe,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: TatuColors.online,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Em serviço',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: TatuColors.onlineTexto,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 8),
                        CartaoAcao(
                          icone: const Icon(TablerIcons.pencil, size: 22),
                          titulo: 'Precisa mudar o valor?',
                          detalhe: 'Envie uma nova proposta pelo chat.',
                          onTap: () => _emBreve(context, 'Chat'),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _emBreve(context, 'Cobrar o cliente'),
                    child: const Text('Concluir e cobrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cliente com avatar de iniciais e botão de mensagem à direita.
class LinhaCliente extends StatelessWidget {
  const LinhaCliente({
    super.key,
    required this.titulo,
    required this.detalhe,
    required this.onMensagem,
  });

  final String titulo;
  final String detalhe;
  final VoidCallback onMensagem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarIniciais(nome: titulo, tamanho: 44),
        const SizedBox(width: TatuMedidas.entreItens),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(detalhe, style: TatuTexto.nota),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Mensagem',
          child: GestureDetector(
            onTap: onMensagem,
            child: const IconeCirculo(TablerIcons.message_circle),
          ),
        ),
      ],
    );
  }
}

/// Cartão cinza com o endereço revelado.
class CartaoEndereco extends StatelessWidget {
  const CartaoEndereco({super.key, required this.servico});

  final ServicoAceito servico;

  @override
  Widget build(BuildContext context) => _CartaoCinza(
    icone: TablerIcons.map_pin,
    titulo: servico.rua,
    detalhe: servico.referencia,
  );
}

/// Cartão cinza com o serviço e o valor combinado.
class CartaoServico extends StatelessWidget {
  const CartaoServico({
    super.key,
    required this.servico,
    this.comObservacao = false,
  });

  final ServicoAceito servico;
  final bool comObservacao;

  @override
  Widget build(BuildContext context) => _CartaoCinza(
    icone: TablerIcons.tool,
    titulo: servico.descricao,
    detalhe: comObservacao && servico.observacao.isNotEmpty
        ? servico.observacao
        : null,
    direita: reais(servico.valor),
  );
}

class _CartaoCinza extends StatelessWidget {
  const _CartaoCinza({
    required this.icone,
    required this.titulo,
    this.detalhe,
    this.direita,
  });

  final IconData icone;
  final String titulo;
  final String? detalhe;
  final String? direita;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: TatuColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: detalhe != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (detalhe != null) ...[
                  const SizedBox(height: 2),
                  Text(detalhe!, style: TatuTexto.nota),
                ],
              ],
            ),
          ),
          if (direita != null) ...[
            const SizedBox(width: 8),
            Text(
              direita!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rota no mapa: ponto verde (você) até o ponto preto (cliente). [perto]
/// põe o ponto verde quase em cima do preto.
class _Rota extends CustomPainter {
  const _Rota({this.perto = false});

  final bool perto;

  @override
  void paint(Canvas canvas, Size size) {
    // Medidas do desenho (393 × 852).
    final sx = size.width / 393;
    final sy = size.height / 852;
    Offset o(double x, double y) => Offset(x * sx, y * sy);
    final a = o(90, 90);
    final d = o(262, 380);
    final rota = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(120 * sx, 130 * sy, 140 * sx, 230 * sy, 175 * sx, 275 * sy)
      ..cubicTo(205 * sx, 315 * sy, 255 * sx, 330 * sy, d.dx, d.dy);
    canvas.drawPath(
      rota,
      Paint()
        ..color = TatuColors.action
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    final eu = perto ? o(250, 360) : a;
    canvas.drawCircle(d, 15, Paint()..color = TatuColors.bg);
    canvas.drawCircle(d, 11, Paint()..color = TatuColors.action);
    canvas.drawCircle(eu, 12, Paint()..color = TatuColors.bg);
    canvas.drawCircle(eu, 9, Paint()..color = TatuColors.online);
  }

  @override
  bool shouldRepaint(_Rota oldDelegate) => oldDelegate.perto != perto;
}

/// No local: ponto preto com o círculo verde em volta.
class _NoLocal extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .25);
    canvas.drawCircle(c, 44, Paint()..color = TatuColors.radar);
    canvas.drawCircle(
      c,
      44,
      Paint()
        ..color = TatuColors.online.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(c, 11, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_NoLocal oldDelegate) => false;
}
