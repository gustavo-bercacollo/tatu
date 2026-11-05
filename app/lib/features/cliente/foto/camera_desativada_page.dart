import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../shared/widgets/tela_permissao.dart';
import 'escolher_avatar_page.dart';

/// Câmera desativada: sem permissão, oferece Ajustes ou escolher um avatar.
/// Devolve `true` se a pessoa salvou um avatar.
class CameraDesativadaPage extends StatelessWidget {
  const CameraDesativadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.camera, riscado: true),
      titulo: 'Câmera desativada',
      texto: 'Ative nos Ajustes para tirar uma foto.\nVocê também pode escolher um avatar.',
      alternativa: 'Escolher um avatar',
      onAlternativa: () async {
        final nav = Navigator.of(context);
        final salvou = await nav.push<bool>(
          MaterialPageRoute(builder: (_) => const EscolherAvatarPage()),
        );
        if (salvou == true) nav.pop(true);
      },
    );
  }
}
