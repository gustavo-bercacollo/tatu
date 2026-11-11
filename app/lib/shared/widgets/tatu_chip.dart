import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Chip em pílula (38 px): cinza; selecionado fica preto, com ícone opcional.
class TatuChip extends StatelessWidget {
  const TatuChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selecionado = false,
    this.icone,
    this.seta = false,
    this.iconeFixo,
    this.pequeno = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selecionado;

  /// Ícone antes do texto quando selecionado (ex.: ✦ da IA).
  final IconData? icone;

  /// Setinha para baixo: o chip abre uma lista (ex.: "Outros").
  final bool seta;

  /// Ícone sempre visível antes do texto (ex.: botões da Atividade).
  final IconData? iconeFixo;

  /// Versão menor, para botões dentro de cartões.
  final bool pequeno;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? TatuColors.onAction : TatuColors.textPrimary;
    return Semantics(
      selected: selecionado,
      button: true,
      child: Material(
        color: selecionado ? TatuColors.action : TatuColors.fill,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            height: pequeno
                ? TatuMedidas.alturaChipPequeno
                : TatuMedidas.alturaChip,
            padding: EdgeInsets.symmetric(horizontal: pequeno ? 12 : 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selecionado && icone != null) ...[
                  Icon(icone, size: 16, color: cor),
                  const SizedBox(width: 6),
                ],
                if (iconeFixo != null) ...[
                  Icon(iconeFixo, size: pequeno ? 16 : 18, color: cor),
                  SizedBox(width: pequeno ? 6 : 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: pequeno ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: cor,
                    ),
                  ),
                ),
                if (seta) ...[
                  const SizedBox(width: 6),
                  Icon(TablerIcons.chevron_down, size: 16, color: cor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
