import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../data/conta.dart';
import '../../data/perfil.dart';
import 'avatar_iniciais.dart';

/// Imagem redonda (avatar pronto ou foto).
class AvatarImagem extends StatelessWidget {
  const AvatarImagem({super.key, required this.imagem, required this.tamanho});

  final ImageProvider imagem;
  final double tamanho;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image(
      image: imagem,
      width: tamanho,
      height: tamanho,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    ),
  );
}

/// Imagem atual do perfil: foto, avatar pronto ou null (só iniciais).
ImageProvider? imagemDoPerfil() {
  if (perfil.foto != null) return MemoryImage(perfil.foto!);
  if (perfil.avatar != null) return AssetImage(perfil.avatar!);
  return null;
}

/// Avatar da pessoa logada: foto ou avatar escolhido; sem nenhum, as
/// iniciais. Atualiza sozinho quando a foto muda.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    this.tamanho = 36,
    this.camera = false,
    this.nome,
  });

  final double tamanho;

  /// Nome para as iniciais quando não há foto nem avatar
  /// (padrão: o nome da conta).
  final String? nome;

  /// Mostra o selo de câmera (Perfil: toque para trocar a foto).
  final bool camera;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([perfil, conta]),
      builder: (context, _) {
        final imagem = imagemDoPerfil();
        final base = imagem == null
            ? AvatarIniciais(nome: nome ?? conta.nomeCompleto, tamanho: tamanho)
            : AvatarImagem(imagem: imagem, tamanho: tamanho);
        if (!camera) return base;
        return SizedBox(
          width: tamanho,
          height: tamanho,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              base,
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: TatuColors.action,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TatuColors.surfaceGrouped,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    TablerIcons.camera,
                    size: 15,
                    color: TatuColors.onAction,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Avatar com aro preto (escolhido). [selo] põe o ✓ no canto.
class AvatarComAro extends StatelessWidget {
  const AvatarComAro({
    super.key,
    required this.imagem,
    required this.tamanho,
    this.escolhido = true,
    this.selo = false,
  });

  final ImageProvider imagem;
  final double tamanho;
  final bool escolhido;
  final bool selo;

  static const _folga = 2.0; // espaço branco entre o aro e a imagem

  @override
  Widget build(BuildContext context) {
    const borda = TatuMedidas.aroAvatar + _folga;
    final total = tamanho + borda * 2;
    return SizedBox(
      width: total,
      height: total,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (escolhido)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TatuColors.action,
                  width: TatuMedidas.aroAvatar,
                ),
              ),
            ),
          AvatarImagem(imagem: imagem, tamanho: tamanho),
          if (escolhido && selo)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: TatuColors.action,
                  shape: BoxShape.circle,
                  border: Border.all(color: TatuColors.bg, width: 2),
                ),
                child: const Icon(
                  TablerIcons.check,
                  size: 13,
                  color: TatuColors.onAction,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
