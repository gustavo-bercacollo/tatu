import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Recusar o último valor da negociação (RN-27, RN-200, RN-201).

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

Conversa get _luiza =>
    conversas.conversas.firstWhere((c) => c.nome == 'Luiza Souza');

Finder get _lista => find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

/// Chat da Luiza já no 3º valor.
Future<void> _ultimoValor(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  _luiza.valor!.rodada = 3;
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: ChatPage(conversa: _luiza)),
  );
  await t.pumpAndSettle();
  await t.scrollUntilVisible(find.text('Recusar valor'), 200,
      scrollable: _lista);
  await t.pumpAndSettle();
}

Future<void> _abrirFolha(WidgetTester t) async {
  await t.tap(find.text('Recusar valor'));
  await t.pumpAndSettle();
  expect(find.text('Recusar o valor?'), findsOneWidget);
}

void main() {
  setUpAll(_carregarInter);
  ProcurandoPage.aceitaEm = null;
  setUp(() {
    conversas.restaurar();
    pagamentos.restaurar();
    pedidos.restaurar();
  });

  testWidgets('RN-200: rodadas 1 e 2 pedem outro valor, sem recusar', (
    t,
  ) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: ChatPage(conversa: _luiza)),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Pedir outro valor'), 200,
        scrollable: _lista);
    expect(find.text('Recusar valor'), findsNothing);
    expect(find.textContaining('Último valor'), findsNothing);
  });

  testWidgets('RN-200: no 3º valor, aviso e "Recusar valor"', (t) async {
    await _ultimoValor(t);
    expect(find.text('Pedir outro valor'), findsNothing);
    expect(
      find.text(
        'Último valor. Se recusar, a conversa com a Luiza termina sem custo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('RN-200: "Voltar" não muda nada', (t) async {
    await _ultimoValor(t);
    await _abrirFolha(t);
    expect(find.text('Recusar e chamar outro'), findsOneWidget);
    expect(find.text('Recusar e cancelar pedido'), findsOneWidget);
    await t.tap(find.text('Voltar'));
    await t.pumpAndSettle();
    expect(_luiza.semAcordo, isFalse);
    expect(pedidos.doProfissional('Luiza Souza'), isNotNull);
  });

  testWidgets('RN-200/RN-201: recusar e cancelar o pedido', (t) async {
    await _ultimoValor(t);
    await _abrirFolha(t);
    await t.tap(find.text('Recusar e cancelar pedido'));
    await t.pumpAndSettle();
    expect(find.text('Pedido cancelado'), findsOneWidget);
    expect(find.text('Nada foi cobrado.'), findsOneWidget);
    // Sem custo: o pedido sai; a conversa fica só para leitura.
    expect(pedidos.doProfissional('Luiza Souza'), isNull);
    expect(_luiza.semAcordo, isTrue);
    expect(_luiza.emAndamento, isFalse);
    expect(conversas.anteriores, contains(_luiza));
    expect(find.text('Esta conversa foi encerrada.'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
    await t.pumpAndSettle();
  });

  testWidgets('RN-200/RN-201: recusar e chamar outro (ela não volta)', (
    t,
  ) async {
    await _ultimoValor(t);
    await _abrirFolha(t);
    await t.tap(find.text('Recusar e chamar outro'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Procurando um profissional'), findsOneWidget);
    expect(pedidos.recusados, contains('Luiza Souza'));
    expect(pedidos.doProfissional('Luiza Souza'), isNull);
    await t.tap(find.bySemanticsLabel('Fechar'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
  });

  testWidgets('RN-201: profissional vê que não conta contra ele', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: tatuTheme(),
        home: const SemAcordoPage(cliente: 'A Ana'),
      ),
    );
    expect(find.text('Sem acordo de valor'), findsOneWidget);
    expect(find.textContaining('A Ana recusou o último valor.'),
        findsOneWidget);
    expect(find.textContaining('não conta contra você'), findsOneWidget);
  });
}
