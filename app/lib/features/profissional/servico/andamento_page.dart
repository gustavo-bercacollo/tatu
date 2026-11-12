import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// P24 · A caminho e "Você chegou": mapa com o painel do serviço.
/// "Cheguei" só libera perto do local (protótipo: depois de [chegaEm]).
class ACaminhoPage extends StatefulWidget {
  const ACaminhoPage({
    super.key,
    this.servico = servicoExemplo,
    this.chegaEm = const Duration(seconds: 5),
    this.chegou = false,
  });

  final ServicoAceito servico;
  final Duration chegaEm;

  /// Abre já no local (para o fluxograma e testes).
  final bool chegou;

  @override
  State<ACaminhoPage> createState() => _ACaminhoPageState();
}

class _ACaminhoPageState extends State<ACaminhoPage> {
  late bool _perto = widget.chegou;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const MapaFalso(),
              foregroundPainter: _chegou ? _NoLocal() : _Rota(),
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
                      if (_chegou) ..._topoChegou(s) else ..._topoCaminho(s),
                      const SizedBox(height: TatuMedidas.entreItens),
                      CartaoEndereco(servico: s),
                      const SizedBox(height: 10),
                      CartaoServico(servico: s),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      if (_chegou) ...[
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => EmAndamentoPage(
                                    servico: s,
                                    inicio: DateTime.now(),
                                  ),
                                ),
                              ),
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
                        FilledButton.icon(
                          onPressed: () => _emBreve(context, 'Abrir rota'),
                          icon: const Icon(TablerIcons.navigation, size: 20),
                          label: const Text('Abrir rota'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          style: tatuBotaoSecundario(),
                          onPressed: _perto
                              ? () => setState(() => _chegou = true)
                              : null,
                          child: const Text('Cheguei'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _perto
                              ? 'Você está perto do local.'
                              : 'Libera quando você estiver perto do local.',
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

  List<Widget> _topoCaminho(ServicoAceito s) => [
    Row(
      children: [
        const SeloPreto('A caminho'),
        const Spacer(),
        Text(
          '${s.minutos} min · ${s.distanciaKm.toStringAsFixed(1).replaceAll('.', ',')} km',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    ),
    const SizedBox(height: TatuMedidas.entreItens),
    LinhaCliente(
      titulo: s.cliente,
      detalhe:
          '${s.notaCliente.toStringAsFixed(1).replaceAll('.', ',')} · cliente',
      onMensagem: () => _emBreve(context, 'Chat'),
    ),
  ];

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

/// P25 · Serviço em andamento: concluir e cobrar.
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
                  Expanded(
                    child: ListView(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: SeloPreto('Em andamento'),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Serviço em andamento',
                          style: TextStyle(
                            fontSize: 30,
                            height: 36 / 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Iniciado às $hora', style: TatuTexto.detalhe),
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        LinhaCliente(
                          titulo: s.cliente,
                          detalhe: s.rua,
                          onMensagem: () => _emBreve(context, 'Chat'),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens),
                        CartaoServico(servico: s, comObservacao: true),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: LinkAzul(
                            'Precisa mudar o valor?',
                            onTap: () => _emBreve(context, 'Chat'),
                          ),
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

/// Rota no mapa: ponto azul (você) até o ponto preto (cliente).
class _Rota extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(size.width * .26, size.height * .40);
    final b = Offset(size.width * .26, size.height * .30);
    final c = Offset(size.width * .58, size.height * .30);
    final d = Offset(size.width * .58, size.height * .12);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..lineTo(d.dx, d.dy),
      Paint()
        ..color = TatuColors.action
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(a, 9, Paint()..color = TatuColors.bg);
    canvas.drawCircle(a, 6.5, Paint()..color = TatuColors.verified);
    canvas.drawCircle(d, 11, Paint()..color = TatuColors.action);
    canvas.drawCircle(d, 4, Paint()..color = TatuColors.bg);
  }

  @override
  bool shouldRepaint(_Rota oldDelegate) => false;
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
