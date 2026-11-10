import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';

/// Etapas de um pedido: as feitas com ✓ verde, as próximas com círculo
/// vazio ligado por um traço.
class LinhaDoTempo extends StatelessWidget {
  const LinhaDoTempo({super.key, required this.etapas, required this.feitas});

  final List<String> etapas;
  final int feitas;

  static const _altura = 38.0;
  static const _bola = 22.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < etapas.length; i++)
          SizedBox(
            height: _altura,
            child: Row(
              children: [
                SizedBox(
                  width: _bola,
                  height: _altura,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Traço entre etapas que ainda não aconteceram.
                      if (i >= feitas && i < etapas.length - 1)
                        Positioned(
                          top: _altura / 2,
                          bottom: -_altura / 2,
                          child: Container(
                            width: 1.5,
                            color: TatuColors.chevron,
                          ),
                        ),
                      _Bola(feita: i < feitas),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  etapas[i],
                  style: TextStyle(
                    fontSize: 17,
                    color: i < feitas
                        ? TatuColors.textPrimary
                        : TatuColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bola extends StatelessWidget {
  const _Bola({required this.feita});

  final bool feita;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LinhaDoTempo._bola,
      height: LinhaDoTempo._bola,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: feita ? TatuColors.online : TatuColors.bg,
        border: feita
            ? null
            : Border.all(color: TatuColors.chevron, width: 1.5),
      ),
      child: feita
          ? const Icon(TablerIcons.check, size: 14, color: TatuColors.onAction)
          : null,
    );
  }
}

/// Selo verde claro com a situação (ex.: "A caminho").
class SeloVerde extends StatelessWidget {
  const SeloVerde(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const ShapeDecoration(
        color: TatuColors.onlineSoft,
        shape: StadiumBorder(),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TatuColors.onlineTexto,
        ),
      ),
    );
  }
}
