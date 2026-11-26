import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/servicos.dart';
import 'package:tatu/features/cliente/home_page.dart';

/// "Outros" do cliente: todas as profissões do modo (No local / À
/// distância), separadas pelos segmentos do catálogo (RN-92, RN-161).

Future<void> _abrirOutros(WidgetTester t, {bool distancia = false}) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  if (distancia) {
    await t.tap(find.text('À distância'));
    await t.pumpAndSettle();
  }
  await t.tap(find.text('Outros'));
  await t.pumpAndSettle();
}

void main() {
  test('cada modo tem todas as suas profissões, por segmento', () {
    final local = gruposDoModo(distancia: false);
    final remoto = gruposDoModo(distancia: true);
    // Nenhum grupo genérico "À distância": só os segmentos do catálogo.
    final segmentos = [for (final s in catalogoServicos.segmentos) s.$1];
    expect([for (final g in remoto) g.$1], everyElement(isIn(segmentos)));
    expect([for (final g in local) g.$1], everyElement(isIn(segmentos)));
    expect(
      remoto.map((g) => g.$1),
      containsAll(['Aulas', 'Tecnologia e criação']),
    );
    // Todas as profissões aparecem em pelo menos um dos modos.
    final nomes = {
      for (final g in [...local, ...remoto])
        for (final s in g.$2) s.nome,
    };
    expect(nomes, containsAll(catalogoServicos.todas.map((p) => p.nome)));
    // E cada uma só no modo que atende.
    for (final g in remoto) {
      for (final s in g.$2) {
        expect(catalogoServicos.encontrar(s.nome)!.remoto, isTrue);
      }
    }
    for (final g in local) {
      for (final s in g.$2) {
        expect(catalogoServicos.encontrar(s.nome)!.local, isTrue);
      }
    }
  });

  test('atalhos à distância existem e atendem à distância', () {
    for (final n in maisPedidosDistancia) {
      expect(catalogoServicos.encontrar(n)?.remoto, isTrue, reason: n);
    }
  });

  test('a busca respeita o modo', () {
    expect(buscarServicos('encanador', distancia: true), isEmpty);
    expect(
      buscarServicos('encanador', distancia: false).map((s) => s.nome),
      contains('Encanador'),
    );
    expect(
      buscarServicos('designer', distancia: true).map((s) => s.nome),
      contains('Designer gráfico'),
    );
  });

  testWidgets('À distância: atalhos e seções por segmento', (t) async {
    await _abrirOutros(t, distancia: true);
    expect(find.text('MAIS PEDIDOS À DISTÂNCIA'), findsOneWidget);
    expect(find.text('À DISTÂNCIA'), findsNothing);
    await t.scrollUntilVisible(
      find.text('AULAS'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('AULAS'), findsOneWidget);
    expect(find.text('Encanador'), findsNothing);
  });

  testWidgets('No local: segue por segmento, com Casa e reformas', (t) async {
    await _abrirOutros(t);
    expect(find.text('MAIS PEDIDOS PERTO DE VOCÊ'), findsOneWidget);
    expect(find.text('CASA E REFORMAS'), findsOneWidget);
  });
}
