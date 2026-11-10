import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../shared/widgets/tela_permissao.dart';
import 'escolher_avatar_page.dart';

/// Câmera desativada: sem permissão, oferece Ajustes ou escolher um avatar.
/// Devolve `true` se a pessoa salvou um avatar.
class CameraDesativadaPage extends StatelessWidget {
  const CameraDesativadaPage({super.key, this.semAvatar = false});

  /// Fora da foto do perfil (descrição, chat): só "Abrir Ajustes".
  final bool semAvatar;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.camera, riscado: true),
      titulo: 'Câmera desativada',
      texto: semAvatar ? 'Ative nos Ajustes para tirar uma foto.' : 'Ative nos Ajustes para tirar uma foto.\nVocê também pode escolher um avatar.',
      alternativa: semAvatar ? null : 'Escolher um avatar',
      onAlternativa: semAvatar
          ? null
          : () async {
              final nav = Navigator.of(context);
              final salvou = await nav.push<bool>(
                MaterialPageRoute(builder: (_) => const EscolherAvatarPage()),
              );
              if (salvou == true) nav.pop(true);
            },
    );
  }
}
