import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Campo de busca cinza com lupa e botão de limpar. Com [onTap] e sem
/// [controller], vira só um atalho que abre a tela de busca.
class CampoBusca extends StatelessWidget {
  const CampoBusca({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: TatuMedidas.alturaBusca,
        padding: const EdgeInsets.only(left: 14, right: 10),
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        ),
        child: Row(
          children: [
            const Icon(
              TablerIcons.search,
              size: 20,
              color: TatuColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: c == null
                  ? Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 17,
                        color: TatuColors.textSecondary,
                      ),
                    )
                  : TextField(
                      controller: c,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      cursorColor: TatuColors.textPrimary,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 17),
                      decoration: InputDecoration.collapsed(
                        hintText: hint,
                        hintStyle: const TextStyle(
                          fontSize: 17,
                          color: TatuColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            if (c != null)
              ListenableBuilder(
                listenable: c,
                builder: (context, _) => c.text.isEmpty
                    ? const SizedBox.shrink()
                    : Semantics(
                        button: true,
                        label: 'Limpar busca',
                        child: GestureDetector(
                          onTap: () {
                            c.clear();
                            onChanged?.call('');
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: TatuColors.fillStrong,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(TablerIcons.x, size: 14),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
