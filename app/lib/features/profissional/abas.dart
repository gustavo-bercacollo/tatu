import 'package:flutter/material.dart';

import '../../shared/widgets/abas_cliente.dart';
import 'atividade/atividade_profissional_page.dart';
import 'mensagens/mensagens_profissional_page.dart';

/// Troca de aba do profissional. Início é a primeira tela da pilha (a
/// Home); as outras abrem por cima dela, sem animação.
void irParaAbaProfissional(BuildContext context, AbaCliente aba) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst);
  final Widget? tela = switch (aba) {
    AbaCliente.inicio => null,
    AbaCliente.atividade => const AtividadeProfissionalPage(),
    AbaCliente.mensagens => const MensagensProfissionalPage(),
    AbaCliente.perfil => null,
  };
  if (tela == null) return;
  nav.push(
    PageRouteBuilder(
      pageBuilder: (_, _, _) => tela,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

/// Barra de abas do profissional: Início · Atividade · Mensagens.
/// O Perfil abre pela foto no canto da Home.
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
