import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// Baixar meus dados: pede uma cópia por e-mail.
class BaixarDadosPage extends StatelessWidget {
  const BaixarDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      icone: const IconePermissao(
        TablerIcons.file_text,
        cor: TatuColors.textPrimary,
      ),
      titulo: 'Baixar meus dados',
      texto:
          'Enviamos uma cópia dos seus dados\npara ${conta.email}.\nPode levar até 15 dias.',
      principal: 'Pedir cópia',
      // Sem backend ainda: só confirma o pedido.
      onPrincipal: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DadosPedidosPage()),
      ),
      alternativa: 'Agora não',
      onAlternativa: () => Navigator.of(context).pop(),
    );
  }
}

/// Pedido recebido: a cópia dos dados vai por e-mail.
class DadosPedidosPage extends StatelessWidget {
  const DadosPedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
      titulo: 'Pedido recebido',
      texto: 'Vamos enviar seus dados para\n${conta.email} em até 15 dias.',
      principal: 'Concluir',
      onPrincipal: () => Navigator.of(context).pop(),
    );
  }
}
