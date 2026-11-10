import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../abas.dart';

/// Chamando outro profissional: o pedido volta para todos os ativos por
/// perto (radar no mapa). A busca segue em segundo plano se a pessoa sair.
class ChamandoOutroPage extends StatefulWidget {
  const ChamandoOutroPage({
    super.key,
    required this.pedido,
    this.animar = true,
  });

  final PedidoAndamento pedido;

  /// Desligado nas capturas de tela (imagem parada).
  final bool animar;

  @override
  State<ChamandoOutroPage> createState() => _ChamandoOutroPageState();
}

class _ChamandoOutroPageState extends State<ChamandoOutroPage>
    with TickerProviderStateMixin {
  // Raio expande sozinho em 60–90 s (regra do produto).
  late final _busca = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 75),
    value: widget.animar ? 0 : 0.3,
  );
  late final _pulso = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animar) {
      _busca.forward();
      _pulso.repeat();
    }
  }

  @override
  void dispose() {
    _busca.dispose();
    _pulso.dispose();
    super.dispose();
  }

  void _cancelar() {
    pedidos.cancelarAndamento();
    irParaAba(context, AbaCliente.inicio);
  }

  @override
  Widget build(BuildContext context) {
    final ela = widget.pedido.profissao.endsWith('a');
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: MapaFalso()),
                AnimatedBuilder(
                  animation: _pulso,
                  builder: (_, _) =>
                      CustomPaint(painter: _Radar(pulso: _pulso.value)),
                ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AlcaFolha(),
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chamando outro profissional',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ela ? 'A' : 'O'} ${widget.pedido.primeiroNome} '
                        'não está mais disponível.\nNada foi cobrado.',
                        style: TatuTexto.corpo,
                      ),
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: AnimatedBuilder(
                          animation: _busca,
                          builder: (_, _) => LinearProgressIndicator(
                            value: _busca.value,
                            minHeight: 6,
                            color: TatuColors.action,
                            backgroundColor: TatuColors.trilho,
                          ),
                        ),
                      ),
                      const SizedBox(height: TatuMedidas.entreSecoes),
                      FilledButton(
                        style: tatuBotaoSecundario(),
                        onPressed: _cancelar,
                        child: const Text('Cancelar pedido'),
                      ),
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
}

/// Círculos verdes em volta de quem pediu, profissionais por perto e o
/// ponto preto no centro.
class _Radar extends CustomPainter {
  const _Radar({required this.pulso});

  final double pulso;

  static const _profissionais = [
    Offset(-86, -120),
    Offset(94, -80),
    Offset(34, 70),
    Offset(-46, 110),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.34);
    final verde = Paint()..color = TatuColors.radar;
    for (final r in [60.0, 115.0, 170.0]) {
      canvas.drawCircle(centro, r + 6 * pulso, verde);
    }
    final borda = Paint()..color = TatuColors.bg;
    final pro = Paint()..color = TatuColors.online;
    for (final o in _profissionais) {
      canvas.drawCircle(centro + o, 10, borda);
      canvas.drawCircle(centro + o, 7.5, pro);
    }
    canvas.drawCircle(centro, 13, borda);
    canvas.drawCircle(centro, 10, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_Radar oldDelegate) => oldDelegate.pulso != pulso;
}
