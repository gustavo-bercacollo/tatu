import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../shared/widgets/tela_permissao.dart';

/// C10 · RN-110 a RN-112: o Tatu é só para maiores de 18 anos. Vale para
/// o cadastro do cliente e o passo 1 do profissional. A conta não é
/// criada: "Entendi" volta para o começo.
class MenorDeIdadePage extends StatelessWidget {
  const MenorDeIdadePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      aviso: true,
      icone: const Icon(
        TablerIcons.user,
        size: 40,
        color: TatuColors.warningTexto,
      ),
      titulo: 'O Tatu é para maiores\nde 18 anos',
      texto:
          'Peça para um adulto da sua casa\n'
          'chamar o profissional pelo celular dele.',
      principal: 'Entendi',
      onPrincipal: () =>
          Navigator.of(context).popUntil((r) => r.isFirst),
    );
  }
}
