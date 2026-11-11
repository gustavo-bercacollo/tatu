import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';

Future<void> _home(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional.demo();
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeProfissionalPage()),
  );
  await t.tap(find.text('Ficar online'));
  await t.pump();
  await t.pump(const Duration(seconds: 6)); // chega o chamado
  await t.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('Online: chega um chamado; aceitar abre o chat', (t) async {
    await _home(t);
    expect(find.text('NOVO CHAMADO'), findsOneWidget);
    expect(find.text('o cano da minha casa quebrou'), findsOneWidget);
    expect(find.text('Butantã'), findsOneWidget);
    expect(find.text('Estimativa na região: R\$ 80 a R\$ 250'), findsOneWidget);
    await t.tap(find.text('Aceitar chamado'));
    await t.pumpAndSettle();
    expect(find.text('Combine o valor com a Ana'), findsOneWidget);
    await t.tap(find.text('Estou a caminho'));
    await t.pump();
    expect(find.text('Estou a caminho'), findsNWidgets(2));
    await t.enterText(find.byType(TextField), 'Levo as peças');
    await t.pump();
    await t.tap(find.bySemanticsLabel('Enviar mensagem'));
    await t.pump();
    expect(find.text('Levo as peças'), findsOneWidget);

    // Envia o valor; a cliente confirma e o endereço aparece.
    await t.tap(find.text('Enviar valor'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '150');
    await t.pump();
    await t.tap(find.text('Enviar valor').last);
    await t.pumpAndSettle();
    expect(find.text('Valor do serviço: R\$ 150,00'), findsOneWidget);
    expect(find.text('Aguardando a Ana confirmar o valor…'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('A caminho'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 29'), findsOneWidget);
    await t.pump(const Duration(seconds: 6)); // chega perto
    await t.tap(find.text('Cheguei'));
    await t.pump();
    await t.tap(find.text('Iniciar serviço'));
    await t.pumpAndSettle();
    expect(find.text('Serviço em andamento'), findsOneWidget);
  });

  testWidgets('Chamado: recusar ou deixar o tempo acabar volta à Home', (
    t,
  ) async {
    await _home(t);
    await t.tap(find.text('Recusar'));
    await t.pumpAndSettle();
    expect(find.text('Você está online'), findsOneWidget);

    // Fica offline e online de novo: outro chamado, que expira sozinho.
    await t.tap(find.text('Ficar offline'));
    await t.pump();
    await t.tap(find.text('Ficar online'));
    await t.pump();
    await t.pump(const Duration(seconds: 6));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('NOVO CHAMADO'), findsOneWidget);
    for (var i = 0; i < 31; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    await t.pumpAndSettle();
    expect(find.text('Você está online'), findsOneWidget);
  });
}
