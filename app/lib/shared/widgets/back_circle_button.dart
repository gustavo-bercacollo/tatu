import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Botão redondo de voltar (36 px, fundo cinza claro).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Voltar',
      child: Material(
        color: TatuColors.fill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              TablerIcons.chevron_left,
              size: 20,
              color: TatuColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
