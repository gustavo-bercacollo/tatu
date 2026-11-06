import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_theme.dart';
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

/// Folha de confirmação: ícone opcional, título, texto e dois botões.
/// Devolve `true` se a pessoa escolheu [confirmar].
/// - [perigo]: o botão de confirmar fica vermelho claro (ex.: remover).
/// - [destacarCancelar]: a opção segura vira o botão principal (preto) e a
///   de confirmar fica embaixo, cinza (ex.: "Manter ligado" / "Desligar").
/// - [icone]: círculo no topo; [iconeAviso] usa o laranja de atenção.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String confirmar,
  String cancelar = 'Cancelar',
  bool perigo = false,
  bool destacarCancelar = false,
  IconData? icone,
  bool iconeAviso = true,
}) async {
  final r = await mostrarFolha<bool>(
    context,
    builder: (ctx) {
      final botaoConfirmar = FilledButton(
        style: perigo
            ? tatuBotaoPerigo()
            : destacarCancelar
            ? tatuBotaoSecundario()
            : null,
        onPressed: () => Navigator.of(ctx).pop(true),
        child: Text(confirmar),
      );
      final botaoCancelar = FilledButton(
        style: destacarCancelar ? null : tatuBotaoSecundario(),
        onPressed: () => Navigator.of(ctx).pop(false),
        child: Text(cancelar),
      );
      return SafeArea(
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
              if (icone != null) ...[
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconeAviso
                          ? TatuColors.warningSoft
                          : TatuColors.fill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icone,
                      size: 26,
                      color: iconeAviso
                          ? TatuColors.warningTexto
                          : TatuColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TatuTexto.tituloFolha,
              ),
              const SizedBox(height: 8),
              Text(texto, textAlign: TextAlign.center, style: TatuTexto.corpo),
              const SizedBox(height: TatuMedidas.entreSecoes),
              if (destacarCancelar) botaoCancelar else botaoConfirmar,
              const SizedBox(height: 10),
              if (destacarCancelar) botaoConfirmar else botaoCancelar,
            ],
          ),
        ),
      );
    },
  );
  return r ?? false;
}
