import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Cinco estrelas: cheias até a nota, as outras só com contorno.
class Estrelas extends StatelessWidget {
  const Estrelas({super.key, required this.nota, this.tamanho = 14});

  final int nota;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$nota de 5 estrelas',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: EdgeInsets.only(right: tamanho * 0.3),
                child: Icon(
                  i < nota ? TablerIcons.star_filled : TablerIcons.star,
                  size: tamanho,
                  color: TatuColors.warning,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
