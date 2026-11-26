import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import 'icone_profissao.dart';

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
    this.desabilitado = false,
    this.contorno = false,
    this.seletor = false,
    this.profissao,
    this.iconeOutros = false,
  });

  /// RN-227: ícone da profissão antes do texto (branco quando
  /// selecionado). O [icone] da seleção (ex.: ✦ da IA) tem prioridade.
  final String? profissao;

  /// RN-227: o botão "Outros" (grade de quadradinhos).
  final bool iconeOutros;

  /// Fundo branco com contorno escuro (ex.: "Tornar fixa", RN-209).
  final bool contorno;

  /// Abre uma lista e nunca fica selecionado (ex.: "Outros", RN-161):
  /// fundo branco, contorno cinza e seta para baixo cinza (a mesma do
  /// campo "Estado").
  final bool seletor;

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

  /// Apagado (ex.: já tem 3 escolhidos). Ainda recebe o toque.
  final bool desabilitado;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? TatuColors.onAction
        : desabilitado
        ? TatuColors.textDisabled
        : TatuColors.textPrimary;
    return Semantics(
      selected: selecionado,
      button: true,
      child: Material(
        color: selecionado
            ? TatuColors.action
            : contorno || seletor
            ? TatuColors.bg
            : desabilitado
            ? TatuColors.surfaceGrouped
            : TatuColors.fill,
        shape: contorno
            ? const StadiumBorder(
                side: BorderSide(color: TatuColors.textPrimary, width: 1.5),
              )
            : seletor
            ? const StadiumBorder(
                side: BorderSide(color: TatuColors.chevron, width: 1.5),
              )
            : const StadiumBorder(),
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
                ] else if (profissao != null) ...[
                  IconeProfissao(profissao!, cor: cor),
                  const SizedBox(width: 6),
                ] else if (iconeOutros) ...[
                  IconeProfissao.outros(
                    cor: desabilitado ? cor : TatuColors.textPrimary,
                  ),
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
                if (seta || seletor) ...[
                  const SizedBox(width: 6),
                  Icon(
                    TablerIcons.chevron_down,
                    size: 16,
                    color: seletor && !desabilitado
                        ? TatuColors.textSecondary
                        : cor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
