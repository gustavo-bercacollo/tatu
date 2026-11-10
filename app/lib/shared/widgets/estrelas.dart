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

/// Cinco estrelas grandes para escolher a nota (toque na estrela).
class EstrelasEscolha extends StatelessWidget {
  const EstrelasEscolha({
    super.key,
    required this.nota,
    this.onMudar,
    this.tamanho = 36,
  });

  final int nota;

  /// Sem [onMudar], só mostra (ex.: "Sua avaliação").
  final ValueChanged<int>? onMudar;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          Semantics(
            button: onMudar != null,
            selected: i <= nota,
            label: '$i estrela${i > 1 ? 's' : ''}',
            child: GestureDetector(
              onTap: onMudar == null ? null : () => onMudar!(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tamanho * 0.15),
                child: Icon(
                  i <= nota ? TablerIcons.star_filled : TablerIcons.star,
                  size: tamanho,
                  color: TatuColors.warning,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
