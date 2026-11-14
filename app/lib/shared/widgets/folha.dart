import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_theme.dart';
import '../../core/theme/tatu_texto.dart';
import 'lista_agrupada.dart';
import 'nota_icone.dart';

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
  Color fundo = TatuColors.bg,
  bool fechavel = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // [fechavel] falso: só fecha pelos botões (sem arrastar nem tocar fora).
    isDismissible: fechavel,
    enableDrag: fechavel,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: fundo,
    barrierColor: TatuColors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(TatuMedidas.raioFolha),
      ),
    ),
    builder: (ctx) {
      final folha = alturaRelativa == null
          ? builder(ctx)
          : FractionallySizedBox(
              heightFactor: alturaRelativa,
              child: builder(ctx),
            );
      return fechavel ? folha : PopScope(canPop: false, child: folha);
    },
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
  bool esquerda = false,
  String? nota,
  String? aviso,
}) async =>
    await perguntar(
      context,
      titulo: titulo,
      texto: texto,
      confirmar: confirmar,
      cancelar: cancelar,
      perigo: perigo,
      destacarCancelar: destacarCancelar,
      icone: icone,
      iconeAviso: iconeAviso,
      esquerda: esquerda,
      nota: nota,
      aviso: aviso,
    ) ??
    false;

/// Como [confirmar], mas devolve `null` se a pessoa fechar a folha sem
/// escolher (para quando "cancelar" também é uma ação, ex.: "Ver pedido").
/// [esquerda] alinha ícone e textos à esquerda; [nota] é uma linha pequena
/// abaixo do texto (ex.: "Você cadastra quando quiser, em Perfil.").
Future<bool?> perguntar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String confirmar,
  String cancelar = 'Cancelar',
  bool perigo = false,
  bool destacarCancelar = false,
  IconData? icone,
  bool iconeAviso = true,
  bool esquerda = false,
  String? nota,
  String? aviso,
}) async {
  final alinhar = esquerda ? TextAlign.left : TextAlign.center;
  return mostrarFolha<bool>(
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
                Align(
                  alignment: esquerda ? Alignment.centerLeft : Alignment.center,
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
              Text(titulo, textAlign: alinhar, style: TatuTexto.tituloFolha),
              const SizedBox(height: 8),
              Text(texto, textAlign: alinhar, style: TatuTexto.corpo),
              if (nota != null) ...[
                const SizedBox(height: 10),
                Text(nota, textAlign: alinhar, style: TatuTexto.nota),
              ],
              const SizedBox(height: TatuMedidas.entreSecoes),
              if (aviso != null) ...[
                CaixaAviso(aviso),
                const SizedBox(height: TatuMedidas.entreItens + 4),
              ],
              if (destacarCancelar) botaoCancelar else botaoConfirmar,
              const SizedBox(height: 10),
              if (destacarCancelar) botaoConfirmar else botaoCancelar,
            ],
          ),
        ),
      );
    },
  );
}

/// Folha com uma lista de opções (ícone + texto) e "Cancelar".
class FolhaOpcoes extends StatelessWidget {
  const FolhaOpcoes({super.key, required this.itens, this.fechar = 'Cancelar'});

  final List<ItemLista> itens;

  /// Botão cinza embaixo ("Cancelar" ou "Fechar").
  final String fechar;

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: TatuMedidas.entreSecoes),
            GrupoLista(fundo: TatuColors.fill, itens: itens),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(fechar),
            ),
          ],
        ),
      ),
    );
  }
}
