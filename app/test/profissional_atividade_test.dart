import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
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
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('R\$ 445,00'), findsOneWidget);
    expect(find.text('3 serviços · R\$ 150,00 a receber'), findsOneWidget);
    expect(find.text('Aguardando pagamento'), findsOneWidget);
    expect(find.text('Rafael Gomes'), findsOneWidget);
    expect(find.text('Por fora'), findsOneWidget);

    await t.tap(find.text('Em andamento'));
    await t.pump();
    expect(find.text('Nenhum serviço agora'), findsOneWidget);

    await t.tap(find.text('Esta semana'));
    await t.pumpAndSettle();
    expect(find.text('Total da semana'), findsOneWidget);
    expect(find.text('R\$ 355,00'), findsOneWidget);
    await t.tap(find.text('Hoje'));
    await t.pump();
    expect(find.text('Total de hoje'), findsOneWidget);
    expect(find.text('R\$ 135,00'), findsNWidgets(2));
    await t.tap(find.text('Ver taxas do Tatu'));
    await t.pumpAndSettle();
    expect(find.text('Taxas do Tatu'), findsOneWidget);
    await t.tap(find.text('Entendi'));
    await t.pumpAndSettle();
    await t.tap(find.byType(BackCircleButton));
    await t.pumpAndSettle();

    await t.tap(find.text('Início'));
    await t.pumpAndSettle();
    expect(find.text('Você está offline'), findsOneWidget);
    await t.tap(find.text('Mensagens'));
    await t.pumpAndSettle();
    expect(find.text('Buscar conversa'), findsOneWidget);
    expect(find.text('Perfil'), findsNothing); // perfil só pela foto
  });
}
