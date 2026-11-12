import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Espaço reservado para anúncio (353 × 76). Por enquanto só o
/// contorno tracejado, para mostrar onde o anúncio vai entrar.
class EspacoAnuncio extends StatelessWidget {
  const EspacoAnuncio({super.key});

  static const altura = 76.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Espaço reservado para anúncio',
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: const _Tracejado(),
          child: const SizedBox(
            height: altura,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Espaço reservado para anúncio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '353 × 76',
                  style: TextStyle(
                    fontSize: 11,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tracejado extends CustomPainter {
  const _Tracejado();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(TatuMedidas.raioCampo),
    ).deflate(0.75);
    canvas.drawRRect(rrect, Paint()..color = TatuColors.surfaceGrouped);
    final tinta = Paint()
      ..color = TatuColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 11) {
        canvas.drawPath(m.extractPath(d, d + 6), tinta);
      }
    }
  }

  @override
  bool shouldRepaint(_Tracejado oldDelegate) => false;
}
