import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Um item do menu de contexto.
@immutable
class ItemMenuContexto<T> {
  const ItemMenuContexto(this.valor, this.icone, this.texto, {this.cor});

  final T valor;
  final IconData icone;
  final String texto;
  final Color? cor;
}

/// Menu ao segurar um item (ex.: uma conversa, RN-208): a tela escurece,
/// o item fica em destaque no mesmo lugar ([destaque], na posição de
/// [alvo]) e as opções abrem logo abaixo (ou acima, sem espaço).
Future<T?> mostrarMenuContexto<T>(
  BuildContext context, {
  required GlobalKey alvo,
  required Widget destaque,
  required List<ItemMenuContexto<T>> itens,
}) {
  final caixa = alvo.currentContext?.findRenderObject() as RenderBox?;
  final rect = caixa == null
      ? Rect.zero
      : caixa.localToGlobal(Offset.zero) & caixa.size;
  final alturaMenu = TatuMedidas.alturaLinha * itens.length;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: TatuColors.scrim,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, _, _) {
      final altura = MediaQuery.sizeOf(ctx).height;
      final embaixo = rect.bottom + 10 + alturaMenu < altura - 24;
      return Stack(
        children: [
          Positioned.fromRect(
            rect: rect,
            child: IgnorePointer(
              child: Material(
                color: TatuColors.bg,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                clipBehavior: Clip.antiAlias,
                child: destaque,
              ),
            ),
          ),
          Positioned(
            left: rect.left + TatuMedidas.margem / 2,
            top: embaixo ? rect.bottom + 10 : null,
            bottom: embaixo ? null : altura - rect.top + 10,
            child: _Menu<T>(
              itens: itens,
              onEscolher: (v) => Navigator.of(ctx).pop(v),
            ),
          ),
        ],
      );
    },
  );
}

class _Menu<T> extends StatelessWidget {
  const _Menu({required this.itens, required this.onEscolher});

  final List<ItemMenuContexto<T>> itens;
  final ValueChanged<T> onEscolher;

  static const largura = 250.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: largura,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, it) in itens.indexed) ...[
              if (i > 0)
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: TatuColors.tabBarLine,
                ),
              InkWell(
                onTap: () => onEscolher(it.valor),
                child: SizedBox(
                  height: TatuMedidas.alturaLinha,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          it.icone,
                          size: 18,
                          color: it.cor ?? TatuColors.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          it.texto,
                          style: TextStyle(
                            fontSize: 16,
                            color: it.cor ?? TatuColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
