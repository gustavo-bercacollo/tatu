import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';

/// Como a borda está agora.
enum ModoBorda {
  /// Faixa clara dando a volta (caixa vazia e sem foco).
  girando,

  /// O mesmo gradiente, parado ("Reduzir movimento" ou caixa com texto).
  parada,

  /// Toda #1C1C1E (a pessoa está digitando).
  solida,

  /// Sem borda (ex.: gravando, que já tem a própria).
  nenhuma,
}

/// RN-221 · Borda de 2 px desenhada por cima de [child], com o mesmo
/// arredondamento: grafite com uma faixa clara que dá UMA volta (8
/// segundos) quando o app abre e depois fica grafite parada (Home do
/// cliente, "O que está acontecendo?").
///
/// Só o pintor redesenha (a tela não é reconstruída). A volta para com
/// "Reduzir movimento", quando a tela não está visível (outra aba ou rota
/// por cima) e com o app em segundo plano.
class BordaAnimada extends StatefulWidget {
  const BordaAnimada({
    super.key,
    required this.modo,
    required this.raio,
    required this.child,
    this.largura = 2,
  });

  final ModoBorda modo;
  final double raio;
  final double largura;
  final Widget child;

  /// Uma volta completa.
  static const volta = Duration(seconds: 8);

  /// Desligado nos testes (assim a tela assenta sem esperar o giro).
  static bool girar = true;

  /// Já deu a volta desde que o app abriu: não gira de novo (só na
  /// próxima vez que o app abrir).
  static bool jaGirou = false;

  @override
  State<BordaAnimada> createState() => _BordaAnimadaState();
}

class _BordaAnimadaState extends State<BordaAnimada>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _giro = AnimationController(
    vsync: this,
    duration: BordaAnimada.volta,
  );
  bool _appAtivo = true;
  bool _reduzir = false;
  bool _visivel = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _giro.addStatusListener((s) {
      if (s != AnimationStatus.completed) return;
      // Uma volta e acabou: fica grafite parada.
      BordaAnimada.jaGirou = true;
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduzir = MediaQuery.disableAnimationsOf(context);
    // Rota coberta ou outra aba: o Flutter desliga o TickerMode.
    _visivel = TickerMode.valuesOf(context).enabled;
    _atualizar();
  }

  @override
  void didUpdateWidget(BordaAnimada old) {
    super.didUpdateWidget(old);
    if (old.modo != widget.modo) _atualizar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appAtivo = state == AppLifecycleState.resumed;
    _atualizar();
  }

  bool get _gira =>
      BordaAnimada.girar &&
      !BordaAnimada.jaGirou &&
      widget.modo == ModoBorda.girando &&
      !_reduzir &&
      _visivel &&
      _appAtivo;

  void _atualizar() {
    if (_gira) {
      if (!_giro.isAnimating) _giro.forward();
    } else if (_giro.isAnimating) {
      _giro.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _giro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _PintorBorda(
        giro: _giro,
        // Fora do giro (já deu a volta, foco, texto, "Reduzir
        // movimento"): toda grafite.
        modo: widget.modo == ModoBorda.nenhuma
            ? ModoBorda.nenhuma
            : _giro.isAnimating
            ? ModoBorda.girando
            : ModoBorda.solida,
        raio: widget.raio,
        largura: widget.largura,
      ),
      child: widget.child,
    );
  }
}

class _PintorBorda extends CustomPainter {
  _PintorBorda({
    required this.giro,
    required this.modo,
    required this.raio,
    required this.largura,
  }) : super(repaint: giro);

  final Animation<double> giro;
  final ModoBorda modo;
  final double raio;
  final double largura;

  /// Grafite com uma faixa clara larga (cerca de 1/4 da volta), branca
  /// no meio, que vai clareando e escurecendo aos poucos.
  static const _cores = [
    TatuColors.action, // #1C1C1E
    TatuColors.action,
    TatuColors.textSecondary, // #8E8E93
    TatuColors.trilho, // #E5E5EA
    TatuColors.bg, // #FFFFFF (o brilho)
    TatuColors.trilho,
    TatuColors.textSecondary,
    TatuColors.action,
    TatuColors.action,
  ];
  static const _paradas = [0.0, 0.18, 0.32, 0.42, 0.50, 0.58, 0.68, 0.82, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    if (modo == ModoBorda.nenhuma) return;
    final rect = Offset.zero & size;
    final borda = RRect.fromRectAndRadius(
      rect.deflate(largura / 2),
      Radius.circular(math.max(0, raio - largura / 2)),
    );
    final tinta = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = largura;
    if (modo == ModoBorda.solida) {
      tinta.color = TatuColors.action;
    } else {
      tinta.shader = SweepGradient(
        colors: _cores,
        stops: _paradas,
        transform: GradientRotation(2 * math.pi * giro.value),
      ).createShader(rect);
    }
    canvas.drawRRect(borda, tinta);
  }

  @override
  bool shouldRepaint(_PintorBorda old) =>
      old.modo != modo || old.raio != raio || old.largura != largura;
}
