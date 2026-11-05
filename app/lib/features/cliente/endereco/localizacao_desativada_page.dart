import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../shared/widgets/tela_permissao.dart';
import 'buscar_endereco_page.dart';

/// Localização desativada: sem permissão, oferece Ajustes ou digitar.
class LocalizacaoDesativadaPage extends StatelessWidget {
  const LocalizacaoDesativadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.map_pin_off),
      titulo: 'Localização desativada',
      texto: 'Sem ela não achamos você no mapa.\nAtive nos Ajustes ou digite o endereço.',
      alternativa: 'Digitar endereço',
      onAlternativa: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BuscarEnderecoPage()),
      ),
    );
  }
}
