import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/perfil.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import 'ajustar_foto_page.dart';
import 'camera_desativada_page.dart';
import 'escolher_avatar_page.dart';

enum _Opcao { camera, galeria, avatar, remover }

/// Folha "Foto do perfil" e o fluxo de cada opção. Ao trocar, mostra o
/// aviso "Foto atualizada" no topo.
Future<void> trocarFotoDoPerfil(BuildContext context) async {
  final opcao = await mostrarFolha<_Opcao>(
    context,
    builder: (ctx) => const _FolhaFoto(),
  );
  if (opcao == null || !context.mounted) return;
  final nav = Navigator.of(context);

  switch (opcao) {
    case _Opcao.remover:
      perfil.remover();
      return;
    case _Opcao.avatar:
      final salvou = await nav.push<bool>(
        MaterialPageRoute(builder: (_) => const EscolherAvatarPage()),
      );
      if (salvou == true && context.mounted) _avisar(context, avatar: true);
      return;
    case _Opcao.camera:
    case _Opcao.galeria:
      final origem = opcao == _Opcao.camera
          ? OrigemFoto.camera
          : OrigemFoto.galeria;
      try {
        final imagem = await perfil.pedirImagem(origem);
        if (imagem == null || !context.mounted) return;
        final recorte = await nav.push<Uint8List>(
          MaterialPageRoute(builder: (_) => AjustarFotoPage(imagem: imagem)),
        );
        if (recorte == null || !context.mounted) return;
        perfil.usarFoto(recorte);
        _avisar(context, avatar: false);
      } on CameraNegada {
        if (!context.mounted) return;
        // Por lá a pessoa pode escolher um avatar (devolve true ao salvar).
        final salvou = await nav.push<bool>(
          MaterialPageRoute(builder: (_) => const CameraDesativadaPage()),
        );
        if (salvou == true && context.mounted) _avisar(context, avatar: true);
      }
  }
}

void _avisar(BuildContext context, {required bool avatar}) => mostrarAvisoTopo(
  context,
  titulo: 'Foto atualizada',
  texto: avatar
      ? 'Seu novo avatar já aparece no app.'
      : 'Sua nova foto já aparece no app.',
);

class _FolhaFoto extends StatelessWidget {
  const _FolhaFoto();

  @override
  Widget build(BuildContext context) {
    void escolher(_Opcao o) => Navigator.of(context).pop(o);
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
            const Text(
              'Foto do perfil',
              textAlign: TextAlign.center,
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            GrupoLista(
              fundo: TatuColors.fill,
              itens: [
                ItemLista(
                  icone: TablerIcons.camera,
                  texto: 'Tirar foto',
                  seta: false,
                  onTap: () => escolher(_Opcao.camera),
                ),
                ItemLista(
                  icone: TablerIcons.photo,
                  texto: 'Escolher da galeria',
                  seta: false,
                  onTap: () => escolher(_Opcao.galeria),
                ),
                ItemLista(
                  icone: TablerIcons.user,
                  texto: 'Escolher um avatar',
                  seta: false,
                  onTap: () => escolher(_Opcao.avatar),
                ),
              ],
            ),
            if (perfil.temImagem) ...[
              const SizedBox(height: TatuMedidas.entreItens),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: TatuColors.danger,
                  minimumSize: const Size.fromHeight(TatuMedidas.alturaBotao),
                  textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 17),
                ),
                onPressed: () => escolher(_Opcao.remover),
                child: const Text('Remover foto'),
              ),
            ],
            const SizedBox(height: TatuMedidas.entreItens),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
