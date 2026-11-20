import 'package:flutter/material.dart';

import '../../data/nao_lidas.dart';
import '../../shared/widgets/abas_cliente.dart';
import 'atividade/atividade_page.dart';
import 'mensagens/mensagens_page.dart';

/// Troca de aba do cliente. Início é a primeira tela da pilha (a Home);
/// as outras abas abrem por cima dela, sem animação.
void irParaAba(BuildContext context, AbaCliente aba) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst);
  switch (aba) {
    case AbaCliente.inicio:
    case AbaCliente.perfil:
    // Ganhos só existe no modo profissional.
    case AbaCliente.ganhos:
      return;
    case AbaCliente.atividade:
      nav.push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const AtividadePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    case AbaCliente.mensagens:
      nav.push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MensagensPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
  }
}

/// Barra de abas do cliente já com a navegação.
class AbasDoCliente extends StatelessWidget {
  const AbasDoCliente({super.key, required this.ativa});

  final AbaCliente ativa;

  @override
  Widget build(BuildContext context) => AbasCliente(
    ativa: ativa,
    // RN-155: contador de não lidas na aba Mensagens.
    lado: LadoMensagens.cliente,
    // Início sempre volta para a Home (também do Perfil); as outras abas
    // não reabrem a si mesmas.
    onTrocar: (a) {
      if (a == ativa && a != AbaCliente.inicio) return;
      irParaAba(context, a);
    },
  );
}
