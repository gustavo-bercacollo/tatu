import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/enderecos.dart';
import 'package:tatu/features/cliente/home_page.dart';

Future<void> _abrirHome(WidgetTester t) async {
  enderecos.restaurar();
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: tatuTheme(),
      home: const HomeClientePage(nome: 'Ana Martins'),
    ),
  );
}

Future<void> _abrirFolha(WidgetTester t) async {
  await t.tap(find.text(enderecos.atual.rua));
  await t.pumpAndSettle();
  expect(find.text('Onde é o serviço?'), findsOneWidget);
}

void main() {
  testWidgets('Folha: escolher um endereço salvo troca o topo da Home', (
    t,
  ) async {
    await _abrirHome(t);
    expect(find.text('Rua Bruno Lobo, 29'), findsOneWidget);
    await _abrirFolha(t);
    expect(find.byIcon(TablerIcons.check), findsOneWidget); // ✓ na Casa

    await t.tap(find.text('Trabalho'));
    await t.pumpAndSettle();
    expect(find.text('Onde é o serviço?'), findsNothing);
    expect(find.text('Av. Paulista, 1000'), findsOneWidget);
  });

  testWidgets('Buscar → confirmar no mapa → salva e volta para a Home', (
    t,
  ) async {
    await _abrirHome(t);
    await _abrirFolha(t);
    await t.tap(find.text('Buscar rua e número'));
    await t.pumpAndSettle();
    expect(find.text('Buscar endereço'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'bruno lo');
    await t.pump();
    expect(find.text('Resultados'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 300'), findsOneWidget);

    await t.tap(find.text('Rua Bruno Lobo, 300'));
    await t.pumpAndSettle();
    expect(find.text('Confirme o endereço'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, 'Bloco B');
    await t.tap(find.text('Outro'));
    await t.pump();
    await t.tap(find.text('Confirmar endereço'));
    await t.pumpAndSettle();

    expect(find.text('Do que você precisa?'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 300'), findsOneWidget);
    expect(enderecos.salvos.length, 3);
    expect(enderecos.atual.complemento, 'Bloco B');
  });

  testWidgets('Sem permissão de localização: tela e "Digitar endereço"', (
    t,
  ) async {
    await _abrirHome(t);
    enderecos.localizacaoPermitida = false;
    await _abrirFolha(t);
    await t.tap(find.text('Usar minha localização atual'));
    await t.pumpAndSettle();
    expect(find.text('Localização desativada'), findsOneWidget);

    await t.tap(find.text('Digitar endereço'));
    await t.pumpAndSettle();
    expect(find.text('Buscar endereço'), findsOneWidget);
  });

  testWidgets('Perfil → Endereços: editar, excluir até ficar vazio', (t) async {
    await _abrirHome(t);
    await t.tap(find.text('AM'));
    await t.pumpAndSettle();
    await t.tap(find.text('Endereços'));
    await t.pumpAndSettle();
    expect(find.text('Rua Bruno Lobo, 29 · Apto 4'), findsOneWidget);

    await t.tap(find.text('Casa'));
    await t.pumpAndSettle();
    expect(find.text('Editar endereço'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(2), 'Apto 7');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(find.text('Rua Bruno Lobo, 29 · Apto 7'), findsOneWidget);

    for (final nome in ['Casa', 'Trabalho']) {
      await t.tap(find.text(nome));
      await t.pumpAndSettle();
      await t.tap(find.text('Excluir endereço'));
      await t.pumpAndSettle();
    }
    expect(find.text('Nenhum endereço salvo'), findsOneWidget);
    expect(find.text('Adicionar endereço'), findsOneWidget);
  });
}
