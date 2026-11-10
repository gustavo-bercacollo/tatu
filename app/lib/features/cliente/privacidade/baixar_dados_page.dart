import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/conta.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../conta/novo_email_page.dart';

/// Baixar meus dados: pede uma cópia por e-mail.
class BaixarDadosPage extends StatelessWidget {
  const BaixarDadosPage({super.key});

  /// Sem e-mail na conta (cadastro pelo celular), pede antes de enviar.
  Future<void> _pedir(BuildContext context) async {
    final nav = Navigator.of(context);
    if (conta.email == null) {
      final email = await nav.push<String>(
        MaterialPageRoute(builder: (_) => const NovoEmailPage()),
      );
      if (email == null) return;
      conta.definirEmail(email);
    }
    // Sem backend ainda: só confirma o pedido.
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => const DadosPedidosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = conta.email;
    return TelaPermissao(
      icone: const IconePermissao(
        TablerIcons.file_text,
        cor: TatuColors.textPrimary,
      ),
      titulo: 'Baixar meus dados',
      texto: email == null
          ? 'Enviamos uma cópia dos seus dados\npor e-mail.\nPode levar até 15 dias.'
          : 'Enviamos uma cópia dos seus dados\npara $email.\nPode levar até 15 dias.',
      principal: email == null ? 'Informar e-mail' : 'Pedir cópia',
      onPrincipal: () => _pedir(context),
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
