import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/profissional/atividade/ganhos_page.dart';

/// Ganhos do profissional: tocar numa barra mostra o valor do dia.
void main() {
  testWidgets('barras da semana: começa em hoje e troca ao tocar', (t) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const GanhosPage()),
    );
    await t.pumpAndSettle();

    // Hoje (quarta) já aparece escolhido.
    expect(find.text('Quarta (hoje)'), findsOneWidget);
    expect(find.text(r'R$ 145,00'), findsOneWidget);

    // Terça.
    await t.tap(find.bySemanticsLabel(RegExp(r'^Terça:')));
    await t.pumpAndSettle();
    expect(find.text('Terça'), findsOneWidget);
    expect(find.text(r'R$ 218,00'), findsOneWidget);

    // Dia que ainda não chegou.
    await t.tap(find.bySemanticsLabel(RegExp(r'^Sexta:')));
    await t.pumpAndSettle();
    expect(find.text('Sexta'), findsOneWidget);
    expect(find.text('Ainda não chegou'), findsOneWidget);
  });
}
