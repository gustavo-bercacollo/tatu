import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/chamado.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/enderecos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/features/cliente/chamar/imprevisto_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/chamar/som_encontrado.dart';
import 'package:tatu/features/cliente/home_page.dart';

void _tela(WidgetTester t) {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

/// Home com o encanador já marcado pela IA.
Future<void> _homePronta(WidgetTester t) async {
  _tela(t);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.enterText(find.byType(TextField), 'o cano da pia está vazando');
  await t.pump(const Duration(milliseconds: 600));
}

/// A busca abriu; fecha no "x" (a busca segue em segundo plano).
Future<void> _abriuBusca(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 500));
  await t.pump(const Duration(milliseconds: 500));
  expect(find.text('Procurando um profissional'), findsOneWidget);
  await t.tap(find.bySemanticsLabel('Fechar'));
  await t.pump();
  await t.pump(const Duration(milliseconds: 500));
  expect(pedidos.busca, isNotNull);
}

Future<void> _chamar(WidgetTester t) async {
  await t.tap(find.text('Chamar encanador'));
  await t.pumpAndSettle();
}

void main() {
  ProcurandoPage.aceitaEm = null;
  SomEncontrado.ativo = false;
  setUp(() {
    conta.restaurar();
    enderecos.restaurar();
    pedidos.restaurar();
    chamado.restaurar();
    perfil.restaurar();
  });

  testWidgets('Abertura do app: nada em andamento; 1º chamado já busca', (
    t,
  ) async {
    pedidos.comecarSemAndamento();
    expect(pedidos.semNadaEmAndamento, isTrue);
    await _homePronta(t);
    expect(find.textContaining('chega em'), findsNothing);
    // Sem pedido a caminho, não pergunta nada: vai direto para a busca.
    await t.tap(find.text('Chamar encanador'));
    await _abriuBusca(t);
    expect(find.text('Já tem um encanador a caminho'), findsNothing);
  });

  testWidgets('Já tem encanador a caminho: ver pedido ou chamar outro', (
    t,
  ) async {
    await _homePronta(t);
    await _chamar(t);
    expect(find.text('Já tem um encanador a caminho'), findsOneWidget);
    expect(find.textContaining('chega em 12 min'), findsWidgets);
    await t.tap(find.text('Chamar outro'));
    await _abriuBusca(t);

    await _chamar(t);
    await t.tap(find.text('Ver pedido atual'));
    await t.pumpAndSettle();
    // RN-165: a caminho, o pedido é o mapa.
    expect(find.textContaining('Chega em'), findsOneWidget);
  });

  testWidgets('Busca: expande aos 60 s e vira "Ninguém ativo" aos 90 s', (
    t,
  ) async {
    pedidos.limpar();
    await _homePronta(t);
    await t.tap(find.text('Chamar encanador'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Procurando um profissional'), findsOneWidget);
    await t.pump(const Duration(seconds: 61));
    expect(find.text('Expandindo a busca para sua região…'), findsOneWidget);
    await t.pump(const Duration(seconds: 30));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Ninguém ativo nesse momento'), findsOneWidget);
    expect(pedidos.busca?.servico, 'Encanador');
    await t.tap(find.text('Voltar ao início'));
    await t.pumpAndSettle();
    expect(find.text('Do que você precisa?'), findsOneWidget);
  });

  testWidgets('Localização desativada → usar endereço salvo', (t) async {
    enderecos.localizacaoPermitida = false;
    await _homePronta(t);
    await _chamar(t);
    expect(
      find.text('Sem ela, não achamos profissionais\nperto de você.'),
      findsOneWidget,
    );
    await t.tap(find.text('Usar um endereço salvo'));
    await t.pumpAndSettle();
    expect(find.text('Onde é o serviço?'), findsOneWidget);
  });

  testWidgets('Fora da área → me avise quando chegar', (t) async {
    chamado.definirRegiaoAtendida(false);
    await _homePronta(t);
    await _chamar(t);
    expect(find.text('Ainda não chegamos aqui'), findsOneWidget);
    await t.tap(find.text('Me avise quando chegar'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(chamado.avisarQuandoChegar, isTrue);
    expect(find.text('Combinado'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
    await t.pumpAndSettle();
  });

  testWidgets('Cadastro pelo e-mail: confirma o celular antes', (t) async {
    conta.cadastrou(email: 'ana@email.com');
    pedidos.limpar();
    await _homePronta(t);
    await _chamar(t);
    expect(find.text('Confirme seu celular'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '11977776666');
    await t.pump();
    await t.tap(find.text('Enviar código'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '482719');
    await t.pump();
    await t.tap(find.text('Confirmar'));
    // Sem pumpAndSettle: a busca anima sem parar.
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 300));
    }
    expect(conta.celular, '11977776666');
    await _abriuBusca(t);
  });

  testWidgets('Fotos na descrição: anexa e tira', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    perfil.escolherImagem = (_) async => bytes;
    await _homePronta(t);
    // RN-139: o clipe abre galeria ou arquivo.
    await t.tap(find.bySemanticsLabel('Anexar'));
    await t.pumpAndSettle();
    await t.tap(find.text('Escolher da galeria'));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('^Foto anexada')), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Excluir anexo'));
    await t.pump();
    expect(find.bySemanticsLabel(RegExp('^Foto anexada')), findsNothing);
  });

  testWidgets('Imprevisto → chamando outro → cancelar', (t) async {
    _tela(t);
    await t.pumpWidget(
      MaterialApp(
        theme: tatuTheme(),
        home: const HomeClientePage(),
        builder: (context, child) => child!,
      ),
    );
    final nav = t.state<NavigatorState>(find.byType(Navigator));
    nav.push(
      MaterialPageRoute(
        builder: (_) => ImprevistoPage(pedido: pedidos.andamento!),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('A Luiza teve um imprevisto'), findsOneWidget);
    await t.tap(find.text('Chamar outro encanador'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Chamando outro profissional'), findsOneWidget);
    await t.tap(find.text('Cancelar pedido'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(pedidos.andamento, isNull);
    expect(find.text('Do que você precisa?'), findsOneWidget);
  });
}
