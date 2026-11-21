import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/profissional/atividade/atividade_profissional_page.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';
import 'package:tatu/shared/widgets/back_circle_button.dart';

void main() {
  testWidgets('Abas: Home → Atividade → Ganhos → volta ao Início', (t) async {
    t.view.physicalSize = const Size(430, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    profissional.demo();
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const HomeProfissionalPage()),
    );
    await t.tap(find.text('Atividade'));
    await t.pumpAndSettle();
    // Os ganhos ficam na aba Ganhos, não na Atividade.
    expect(find.text('Esta semana'), findsNothing);
    expect(find.text('Aguardando pagamento'), findsOneWidget);
    expect(find.text('Rafael Gomes'), findsOneWidget);
    expect(find.text('Por fora'), findsNothing);

    await t.tap(find.text('Em andamento'));
    await t.pump();
    expect(find.text('Nenhum serviço agora'), findsOneWidget);

    await t.tap(find.text('Ganhos'));
    await t.pumpAndSettle();
    expect(find.text('Total da semana'), findsOneWidget);
    // Serviços R$ 480 − taxa R$ 48 + gorjetas R$ 30 = R$ 462.
    expect(find.text('R\$ 462,00'), findsNWidgets(2)); // total e recebido
    expect(find.text('R\$ 52 a mais que na semana passada'), findsOneWidget);
    expect(find.text('Próximo Pix: R\$ 145,00'), findsOneWidget);
    // RN-141/RN-143: gorjetas à parte, sem taxa.
    expect(find.text('R\$ 30'), findsOneWidget);
    expect(find.text('+ R\$ 30,00'), findsOneWidget);
    expect(find.text('− R\$ 48,00'), findsOneWidget);
    expect(find.text('A receber · 1 esperando'), findsOneWidget);
    await t.tap(find.text('Hoje'));
    await t.pump();
    expect(find.text('Total de hoje'), findsOneWidget);
    expect(find.text('R\$ 145,00'), findsWidgets);
    expect(find.text('R\$ 73 a menos que ontem'), findsOneWidget);
    // Últimos recebimentos com a gorjeta de cada um; "Ver todos".
    await t.scrollUntilVisible(
      find.text('Ver todos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('+ R\$ 10 de gorjeta'), findsOneWidget);
    await t.tap(find.text('Ver todos'));
    await t.pumpAndSettle();
    expect(find.text('Recebimentos'), findsOneWidget);
    expect(find.text('Joana Reis'), findsOneWidget);
    await t.tap(find.byType(BackCircleButton));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver taxas do Tatu'));
    await t.pumpAndSettle();
    expect(find.text('Taxas do Tatu'), findsOneWidget);
    await t.tap(find.text('Entendi'));
    await t.pumpAndSettle();
    // Aba: sem voltar.
    expect(find.byType(BackCircleButton), findsNothing);

    await t.tap(find.text('Início'));
    await t.pumpAndSettle();
    expect(find.text('Você está offline'), findsOneWidget);
    await t.tap(find.text('Mensagens'));
    await t.pumpAndSettle();
    expect(find.text('Buscar conversa'), findsOneWidget);
    expect(find.text('Perfil'), findsNothing); // perfil só pela foto
  });

  testWidgets('Chamado aceito aparece em Atividade · Em andamento', (t) async {
    t.view.physicalSize = const Size(1179, 2556); // 393×852
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    atendimentoProfissional.restaurar();
    navegacao.restaurar();
    await t.pumpWidget(
      MaterialApp(
        theme: tatuTheme(),
        home: const AtividadeProfissionalPage(aba: 0),
      ),
    );
    expect(find.text('Nenhum serviço agora'), findsOneWidget);

    atendimentoProfissional.aceitar(chamadoExemplo);
    await t.pump();
    expect(find.text('Combinando'), findsOneWidget);
    expect(find.text(chamadoExemplo.cliente), findsOneWidget);

    atendimentoProfissional.irAteCliente(servicoExemplo);
    await t.pump();
    expect(find.text('A caminho'), findsWidgets);
    await t.tap(find.text(servicoExemplo.cliente));
    await t.pumpAndSettle();
    expect(find.textContaining('A caminho d'), findsOneWidget);

    atendimentoProfissional.encerrar();
    await t.pump();
    expect(atendimentoProfissional.ativo, isFalse);
  });
}
