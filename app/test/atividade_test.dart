import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/home_page.dart';

Future<void> _abrirAtividade(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.tap(find.text('Atividade'));
  await t.pumpAndSettle();
}

void main() {
  setUp(pedidos.restaurar);

  testWidgets('Em andamento: pedido e busca em segundo plano', (t) async {
    await _abrirAtividade(t);
    expect(find.text('Encanador · Vazamento na pia'), findsOneWidget);
    expect(find.text('Buscando em segundo plano'), findsOneWidget);
    await t.tap(find.text('Cancelar'));
    await t.pump();
    expect(find.text('Buscando em segundo plano'), findsNothing);
  });

  testWidgets('Cancelar pedido → Pedido cancelado → Ninguém aceitou', (
    t,
  ) async {
    await _abrirAtividade(t);
    await t.tap(find.text('Encanador · Vazamento na pia'));
    await t.pumpAndSettle();
    expect(find.text('Pedido'), findsOneWidget);
    await t.tap(find.text('Cancelar pedido'));
    await t.pumpAndSettle();
    expect(find.text('Cancelar pedido?'), findsOneWidget);
    await t.tap(find.text('Cancelar pedido').last);
    await t.pumpAndSettle();
    expect(find.text('Pedido cancelado'), findsOneWidget);

    await t.tap(find.text('Voltar para Atividade'));
    await t.pumpAndSettle();
    expect(find.text('Ninguém aceitou ainda'), findsOneWidget);
  });

  testWidgets('Concluídos: lista e detalhe', (t) async {
    await _abrirAtividade(t);
    await t.tap(find.text('Concluídos'));
    await t.pump();
    expect(find.text('Novembro'), findsOneWidget);
    expect(find.text('Rafael Lima'), findsOneWidget);
    await t.tap(find.text('Luiza Souza'));
    await t.pumpAndSettle();
    expect(find.text('Pedido concluído'), findsOneWidget);
    expect(find.text('Sua avaliação'), findsNothing); // ainda não avaliou
    expect(find.text('Vazamento na pia'), findsOneWidget);
  });

  testWidgets('Vazio: Pedir um serviço volta para a Home', (t) async {
    pedidos.limpar();
    await _abrirAtividade(t);
    expect(find.text('Nenhum pedido agora'), findsOneWidget);
    await t.tap(find.text('Concluídos'));
    await t.pump();
    expect(find.text('Nada por aqui ainda'), findsOneWidget);
    await t.tap(find.text('Em andamento'));
    await t.pump();
    await t.tap(find.text('Pedir um serviço'));
    await t.pumpAndSettle();
    expect(find.text('Oi, Ana'), findsOneWidget);
  });
}
