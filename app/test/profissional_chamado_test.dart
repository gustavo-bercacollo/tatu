import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
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

Future<void> _chat(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const ChatProfissionalPage()),
  );
}

/// Abre a folha, digita o valor do serviço (reais) e envia.
Future<void> _valor(WidgetTester t, String centavos) async {
  await t.tap(find.text('Enviar valor'));
  await t.pumpAndSettle();
  expect(find.text('Quanto vai custar?'), findsOneWidget);
  await t.enterText(find.byType(TextField).last, centavos);
  await t.pump();
  await t.tap(find.text('Enviar para Ana'));
  await t.pumpAndSettle();
}

void main() {
  navegacao.restaurar();
  ToqueChamado.ativo = false;
  testWidgets('Online: chega um chamado; aceitar abre o chat', (t) async {
    await _home(t);
    expect(find.text('NOVO CHAMADO'), findsOneWidget);
    expect(find.text('o cano da minha casa quebrou'), findsOneWidget);
    expect(find.text('Vila Mariana'), findsOneWidget);
    expect(find.text('Estimativa na região: R\$ 80 a R\$ 250'), findsOneWidget);
    await t.tap(find.text('Aceitar chamado'));
    await t.pumpAndSettle();
    expect(find.text('Ana Martins'), findsOneWidget);
    expect(find.text('Vila Mariana · 1,2 km'), findsOneWidget);
    await t.tap(find.text('Estou a caminho'));
    await t.pump();
    expect(find.text('Estou a caminho'), findsNWidgets(2));

    // 1º valor: a cliente propõe outro.
    await _valor(t, '150');
    expect(find.text('Seu valor · 1 de 3'), findsOneWidget);
    expect(find.text('Aguardando a Ana'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Ana propôs outro valor'), findsOneWidget);
    expect(find.text('Proposta da Ana · 1 de 3'), findsOneWidget);
    expect(find.text('Aceitar R\$ 120,00'), findsOneWidget);

    // Aceita a proposta: valor combinado e endereço liberado.
    await t.tap(find.text('Aceitar R\$ 120,00'));
    await t.pump();
    expect(find.text('Valor combinado'), findsOneWidget);
    expect(find.text('R\$ 120,00'), findsWidgets);
    expect(find.text('Material incluso'), findsNothing);
    expect(find.text('Rua das Flores, 120 · apto 32'), findsOneWidget);
    await t.tap(find.text('Estou a caminho').last);
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('A caminho da Ana'), findsOneWidget);
    expect(find.text('Rua das Flores, 120'), findsOneWidget);
    await t.pump(const Duration(seconds: 6)); // chega perto
    await t.tap(find.text('Cheguei'));
    await t.pump();
    await t.tap(find.text('Iniciar serviço'));
    await t.pumpAndSettle();
    expect(find.text('Em serviço'), findsOneWidget);
  });

  testWidgets('Valor: 2º valor perto da proposta é aceito', (t) async {
    await _chat(t);
    await _valor(t, '150');
    await t.pump(const Duration(seconds: 3));
    await t.tap(find.text('Enviar outro valor'));
    await t.pumpAndSettle();
    expect(find.text('Valor 2 de 3'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '130');
    await t.pump();
    expect(find.text('R\$ 117,00'), findsOneWidget); // pelo app, sem a taxa
    await t.tap(find.text('Enviar para Ana'));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Valor combinado'), findsOneWidget);
    expect(find.text('R\$ 130,00'), findsWidgets);
  });

  testWidgets('Valor: 3 rodadas sem acordo encerram o chamado', (t) async {
    await _chat(t);
    await _valor(t, '150');
    await t.pump(const Duration(seconds: 3));
    for (var i = 2; i <= 3; i++) {
      await t.tap(find.text('Enviar outro valor'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, '150');
      await t.pump();
      await t.tap(find.text('Enviar para Ana'));
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 3));
    }
    await t.pumpAndSettle();
    expect(find.text('Sem acordo de valor'), findsOneWidget);
    expect(find.text('Voltar para o início'), findsOneWidget);
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
