import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/chamado.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// "Ainda não chegamos aqui": região sem atendimento. Devolve `true` se a
/// pessoa quer mudar o endereço.
class ForaDaAreaPage extends StatelessWidget {
  const ForaDaAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(TablerIcons.map),
      titulo: 'Ainda não chegamos aqui',
      texto:
          'O Tatu ainda não atende nessa região.\nAvisamos assim que chegar.',
      principal: 'Me avise quando chegar',
      onPrincipal: () {
        chamado.pedirAviso();
        final nav = Navigator.of(context);
        mostrarAvisoTopo(
          context,
          titulo: 'Combinado',
          texto: 'Avisamos quando o Tatu chegar aí.',
        );
        nav.pop();
      },
      alternativa: 'Mudar endereço',
      onAlternativa: () => Navigator.of(context).pop(true),
    );
  }
}
