import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/anexos.dart';
import 'folha.dart';

/// RN-139: miniatura de um anexo do pedido. Foto mostra a imagem (ou o
/// ícone de foto); arquivo mostra o ícone e o tipo ("PDF"). Com
/// [onRemover], aparece o X para excluir.
class MiniaturaAnexo extends StatelessWidget {
  const MiniaturaAnexo({super.key, required this.anexo, this.onRemover});

  final AnexoPedido anexo;
  final VoidCallback? onRemover;

  static const tamanho = 46.0;
  static const _raio = 10.0;

  @override
  Widget build(BuildContext context) {
    final img = anexo.imagem;
    final Widget corpo = anexo.foto
        ? ClipRRect(
            borderRadius: BorderRadius.circular(_raio),
            child: img != null
                ? Image.memory(
                    img,
                    width: tamanho,
                    height: tamanho,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Container(
                    width: tamanho,
                    height: tamanho,
                    color: TatuColors.circle,
                    child: const Icon(
                      TablerIcons.photo,
                      size: 20,
                      color: TatuColors.textSecondary,
                    ),
                  ),
          )
        : Container(
            width: tamanho,
            height: tamanho,
            decoration: BoxDecoration(
              color: TatuColors.bg,
              borderRadius: BorderRadius.circular(_raio),
              border: Border.all(color: TatuColors.chevron),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(TablerIcons.file_text, size: 18),
                Text(
                  anexo.etiqueta,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
    return SizedBox(
        width: tamanho,
        height: tamanho,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              label: anexo.foto ? 'Foto anexada' : 'Arquivo ${anexo.etiqueta}',
              excludeSemantics: true,
              child: corpo,
            ),
            if (onRemover != null)
              Positioned(
                right: -5,
                top: -5,
                child: Semantics(
                  button: true,
                  label: 'Excluir anexo',
                  child: GestureDetector(
                    onTap: onRemover,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: TatuColors.action,
                        shape: BoxShape.circle,
                        border: Border.all(color: TatuColors.bg, width: 1.5),
                      ),
                      child: const Icon(
                        TablerIcons.x,
                        size: 11,
                        color: TatuColors.onAction,
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

/// C89 · RN-139: o clipe da descrição abre "Escolher da galeria" (0) ou
/// "Arquivo (PDF, documento)" (1).
class FolhaAnexar extends StatelessWidget {
  const FolhaAnexar({super.key, required this.onEscolha});

  final ValueChanged<int> onEscolha;

  @override
  Widget build(BuildContext context) {
    Widget linha(int i, IconData icone, String texto) => InkWell(
      onTap: () => onEscolha(i),
      child: SizedBox(
        height: TatuMedidas.alturaLinha + 2,
        child: Row(
          children: [
            Icon(icone, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          8,
          TatuMedidas.margem,
          TatuMedidas.base + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            const Text('Anexar', style: TatuTexto.tituloFolha),
            const SizedBox(height: 14),
            linha(0, TablerIcons.photo, 'Escolher da galeria'),
            const Padding(
              padding: EdgeInsets.only(left: 38),
              child: Divider(height: 0.5, thickness: 0.5),
            ),
            linha(1, TablerIcons.file_text, 'Arquivo (PDF, documento)'),
          ],
        ),
      ),
    );
  }
}
