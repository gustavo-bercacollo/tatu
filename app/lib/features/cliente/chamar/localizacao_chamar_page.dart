import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../shared/widgets/tela_permissao.dart';

/// Ao chamar sem localização: Ajustes ou usar um endereço salvo.
/// Devolve `true` se a pessoa escolheu "Usar um endereço salvo".
class LocalizacaoChamarPage extends StatelessWidget {
  const LocalizacaoChamarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.map_pin, riscado: true),
      titulo: 'Localização desativada',
      texto: 'Sem ela, não achamos profissionais\nperto de você.',
      alternativa: 'Usar um endereço salvo',
      onAlternativa: () => Navigator.of(context).pop(true),
    );
  }
}
