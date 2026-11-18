import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Botão com contorno tracejado para "adicionar" (ex.: Adicionar endereço).
class BotaoTracejado extends StatelessWidget {
  const BotaoTracejado({
    super.key,
    required this.texto,
    required this.onTap,
    this.detalhe,
  });

  final String texto;
  final VoidCallback onTap;

  /// Linha cinza embaixo (com ela, o cartão ganha fundo cinza).
  final String? detalhe;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: const _Tracejado(),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: TatuMedidas.alturaBotao,
            ),
            decoration: detalhe == null
                ? null
                : BoxDecoration(
                    color: TatuColors.fill,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                  ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: detalhe == null ? 0 : 14,
              ),
              child: Row(
                children: [
                  const Icon(TablerIcons.plus, size: 22),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          texto,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (detalhe != null)
                          Text(detalhe!, style: TatuTexto.nota),
                      ],
                    ),
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

/// Quadrado tracejado para foto ("+" adiciona; imagem = espaço vazio).
class QuadradoFoto extends StatelessWidget {
  const QuadradoFoto({
    super.key,
    this.icone = TablerIcons.photo,
    this.onTap,
    this.rotulo,
  });

  final IconData icone;
  final VoidCallback? onTap;

  /// Nome lido pelo leitor de tela.
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: rotulo,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: const _Tracejado(),
          child: SizedBox.square(
            dimension: TatuMedidas.quadradoFoto,
            child: Icon(icone, size: 24, color: TatuColors.textSecondary),
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
      const Radius.circular(TatuMedidas.raioCartao),
    ).deflate(0.75);
    final tinta = Paint()
      ..color = TatuColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metrica in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += 9) {
        canvas.drawPath(metrica.extractPath(d, d + 5), tinta);
      }
    }
  }

  @override
  bool shouldRepaint(_Tracejado oldDelegate) => false;
}
