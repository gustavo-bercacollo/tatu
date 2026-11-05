import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import 'back_circle_button.dart';

/// Topo de tela interna: voltar à esquerda, título no centro e ação opcional
/// (texto azul) à direita.
class TopoTela extends StatelessWidget {
  const TopoTela({super.key, required this.titulo, this.acao, this.onAcao});

  final String titulo;
  final String? acao;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: BackCircleButton(),
          ),
          Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          if (acao != null)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onAcao,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    acao!,
                    style: const TextStyle(
                      fontSize: 17,
                      color: TatuColors.verified,
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
