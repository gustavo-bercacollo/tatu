import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrirDados(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilClientePage()),
  );
  await t.tap(find.text('Dados da conta'));
  await t.pumpAndSettle();
}

/// Digita o código de 6 dígitos e confirma.
Future<void> _codigo(WidgetTester t) async {
  await t.enterText(find.byType(TextField), '482719');
  await t.pump();
  if (find.text('Confirmar').evaluate().isNotEmpty) {
    await t.tap(find.text('Confirmar'));
  }
  await t.pumpAndSettle();
}

Future<void> _fecharAviso(WidgetTester t) async {
  await t.pump(const Duration(seconds: 4));
  await t.pumpAndSettle();
}

void main() {
  setUp(conta.restaurar);

  testWidgets('Mostra os dados e edita o nome', (t) async {
    await _abrirDados(t);
    expect(find.text('Ana Martins'), findsOneWidget);
    expect(find.text('+55 (11) 98888-7777'), findsOneWidget);
    expect(find.text('ana@email.com'), findsOneWidget);

    await t.tap(find.text('Ana Martins'));
    await t.pumpAndSettle();
    expect(find.text('Seu nome'), findsOneWidget);
    await t.enterText(find.byType(TextField).first, 'Aninha');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(find.text('Aninha Martins'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();
    expect(find.text('Aninha Martins'), findsOneWidget); // Perfil
  });

  testWidgets('Troca o celular com código e mostra o aviso', (t) async {
    await _abrirDados(t);
    await t.tap(find.text('+55 (11) 98888-7777'));
    await t.pumpAndSettle();
    expect(find.text('Novo celular'), findsWidgets);
    await t.enterText(find.byType(TextField), '11977776666');
    await t.pump();
    await t.tap(find.text('Enviar código'));
    await t.pumpAndSettle();
    expect(find.text('Digite o código'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    await _codigo(t);
    expect(find.text('Dados da conta'), findsOneWidget);
    expect(find.text('+55 (11) 97777-6666'), findsOneWidget);
    expect(find.text('Celular atualizado'), findsOneWidget);
    await _fecharAviso(t);
  });

  testWidgets('Troca o e-mail com código', (t) async {
    await _abrirDados(t);
    await t.tap(find.text('ana@email.com'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'ana.martins@email.com');
    await t.pump();
    await t.tap(find.text('Enviar código'));
    await t.pumpAndSettle();
    await _codigo(t);
    expect(find.text('ana.martins@email.com'), findsOneWidget);
    expect(find.text('E-mail atualizado'), findsOneWidget);
    await _fecharAviso(t);
  });

  testWidgets('Excluir conta: confirma e volta às Boas-vindas', (t) async {
    await _abrirDados(t);
    await t.tap(find.text('Excluir conta'));
    await t.pumpAndSettle();
    expect(find.text('Excluir sua conta?'), findsOneWidget);

    await t.tap(find.text('Excluir minha conta'));
    await t.pumpAndSettle();
    expect(find.text('Excluir de vez?'), findsOneWidget);
    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();
    expect(find.text('Excluir sua conta?'), findsOneWidget);

    await t.tap(find.text('Excluir minha conta'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sim, excluir conta'));
    await t.pumpAndSettle();
    expect(find.text('Preciso de um serviço'), findsOneWidget);
  });

  testWidgets('Com pedido em andamento não dá para excluir', (t) async {
    conta.pedidoEmAndamento = true;
    await _abrirDados(t);
    await t.tap(find.text('Excluir conta'));
    await t.pumpAndSettle();
    expect(find.text('Agora não dá para excluir'), findsOneWidget);
    await t.tap(find.text('Voltar'));
    await t.pumpAndSettle();
    expect(find.text('Dados da conta'), findsOneWidget);
  });
}
