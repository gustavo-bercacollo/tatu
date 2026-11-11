import 'package:flutter/material.dart';

import '../../shared/widgets/abas_cliente.dart';
import 'atividade/atividade_profissional_page.dart';

/// Troca de aba do profissional. Início é a primeira tela da pilha (a
/// Home); Atividade abre por cima dela, sem animação. Mensagens ainda
/// não tem desenho.
void irParaAbaProfissional(BuildContext context, AbaCliente aba) {
  final nav = Navigator.of(context);
  switch (aba) {
    case AbaCliente.inicio:
      nav.popUntil((r) => r.isFirst);
    case AbaCliente.atividade:
      nav.popUntil((r) => r.isFirst);
      nav.push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const AtividadeProfissionalPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    case AbaCliente.mensagens:
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Mensagens: em breve')));
  }
}

/// Barra de abas do profissional (Início · Atividade · Mensagens).
class AbasDoProfissional extends StatelessWidget {
  const AbasDoProfissional({super.key, required this.ativa});

  final AbaCliente ativa;

  @override
  Widget build(BuildContext context) => AbasCliente(
    ativa: ativa,
    onTrocar: (a) {
      if (a == ativa) return;
      irParaAbaProfissional(context, a);
    },
  );
}
