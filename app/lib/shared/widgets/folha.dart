import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Alça cinza no topo das folhas.
class AlcaFolha extends StatelessWidget {
  const AlcaFolha({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: TatuColors.fillStrong,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}

/// Abre uma folha (bottom sheet) com o visual padrão do Tatu.
Future<T?> mostrarFolha<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double? alturaRelativa,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: TatuColors.bg,
    barrierColor: TatuColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(TatuMedidas.raioFolha),
      ),
    ),
    builder: (ctx) => alturaRelativa == null
        ? builder(ctx)
        : FractionallySizedBox(
            heightFactor: alturaRelativa,
            child: builder(ctx),
          ),
  );
}

/// Folha de confirmação: título, texto e dois botões. Com [perigo], o botão
/// de confirmar fica vermelho claro (ex.: remover). Devolve `true` se confirmou.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String confirmar,
  String cancelar = 'Cancelar',
  bool perigo = false,
}) async {
  final r = await mostrarFolha<bool>(
    context,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 26),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center, style: TatuTexto.corpo),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              style: perigo
                  ? FilledButton.styleFrom(
                      backgroundColor: TatuColors.dangerSoft,
                      foregroundColor: TatuColors.danger,
                    )
                  : null,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmar),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: TatuColors.fill,
                foregroundColor: TatuColors.textPrimary,
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelar),
            ),
          ],
        ),
      ),
    ),
  );
  return r ?? false;
}
