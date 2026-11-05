import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Seletor de abas em trilho cinza (ex.: Recebidas / Enviadas).
class Segmento extends StatelessWidget {
  const Segmento({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.onMudar,
  });

  final List<String> opcoes;
  final int selecionada;
  final ValueChanged<int> onMudar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TatuMedidas.alturaSegmento,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: TatuColors.trilho,
        borderRadius: BorderRadius.circular(TatuMedidas.raioSegmento),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selecionada,
                child: GestureDetector(
                  onTap: () => onMudar(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selecionada
                          ? TatuColors.bg
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        TatuMedidas.raioSegmento - 2,
                      ),
                    ),
                    child: Text(
                      opcoes[i],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: i == selecionada
                            ? TatuColors.textPrimary
                            : TatuColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
