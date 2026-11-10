import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../atividade/pedido_andamento_page.dart';

/// Agora não dá para excluir: há um pedido em andamento.
class ExcluirBloqueadoPage extends StatelessWidget {
  const ExcluirBloqueadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      aviso: true,
      icone: const IconePermissao(TablerIcons.clock, cor: TatuColors.warning),
      titulo: 'Agora não dá para excluir',
      texto: 'Você tem um pedido em andamento.\nConclua ou cancele antes de excluir a conta.',
      principal: 'Ver pedido em andamento',
      onPrincipal: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PedidoAndamentoPage()),
      ),
      alternativa: 'Voltar',
      onAlternativa: () => Navigator.of(context).pop(),
    );
  }
}
