import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';

/// "0:07".
String tempoDitado(int segundos) =>
    '${segundos ~/ 60}:${(segundos % 60).toString().padLeft(2, '0')}';

/// RN-137/RN-138: bolinha vermelha + "Gravando · 0:07" / "Ouvindo · 0:07".
class RotuloOuvindo extends StatelessWidget {
  const RotuloOuvindo(this.texto, {super.key, this.pequeno = false});

  final String texto;

  /// Versão do campo do chat (menor).
  final bool pequeno;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: pequeno ? 8 : 10,
        height: pequeno ? 8 : 10,
        decoration: const BoxDecoration(
          color: TatuColors.danger,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: pequeno ? 6 : 8),
      Text(
        texto,
        style: TextStyle(
          fontSize: pequeno ? 12 : 14,
          fontWeight: FontWeight.w600,
          color: TatuColors.danger,
        ),
      ),
    ],
  );
}

/// Ondinha cinza enquanto ouve (só desenho; nada é gravado, RN-137).
class OndaDitado extends StatelessWidget {
  const OndaDitado({super.key});

  // Alturas fixas, como no desenho C15.
  static const _alturas = [
    6, 18, 6, 18, 9, 16, 12, 14, 15, 12, 17, 8, 18, 5, 18, 8, 17, 11, 16,
    14, 13, 16, 10, 17, 7, 18, 6, 18, 9, 17, 12, 15, 15, 12, 17, 9, 18, 5,
    18, 7,
  ];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRect(
      child: SizedBox(
        height: 18,
        // Só as barrinhas que cabem.
        child: LayoutBuilder(
          builder: (context, c) => Row(
            children: [
              for (final a in _alturas.take((c.maxWidth / 5).floor())) ...[
                Container(
                  width: 3,
                  height: a.toDouble(),
                  decoration: BoxDecoration(
                    color: TatuColors.textSecondary,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
