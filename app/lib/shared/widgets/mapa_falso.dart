import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';

/// Mapa ilustrativo (sem serviço de mapas ainda): quarteirões cinza,
/// ruas brancas levemente inclinadas e duas praças verdes.
class MapaFalso extends CustomPainter {
  const MapaFalso();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = TatuColors.mapaFundo);
    final verde = Paint()..color = TatuColors.mapaVerde;
    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * .64,
        50,
        size.width * .86,
        110,
        const Radius.circular(10),
      ),
      verde,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * .08,
        size.height * .74,
        size.width * .33,
        size.height * .9,
        const Radius.circular(10),
      ),
      verde,
    );
    final rua = Paint()
      ..color = TatuColors.bg
      ..strokeWidth = 9;
    for (var x = -40.0; x < size.width + 40; x += 72) {
      canvas.drawLine(Offset(x + 10, 0), Offset(x - 10, size.height), rua);
    }
    for (var y = 40.0; y < size.height + 40; y += 92) {
      canvas.drawLine(Offset(0, y - 6), Offset(size.width, y + 6), rua);
    }
  }

  @override
  bool shouldRepaint(MapaFalso oldDelegate) => false;
}
