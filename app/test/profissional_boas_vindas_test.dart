import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/entrada/boas_vindas_page.dart';

void main() {
  testWidgets('Quero trabalhar abre as boas-vindas do profissional', (t) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const BoasVindasPage()),
    );
    await t.tap(find.text('Quero trabalhar'));
    await t.pumpAndSettle();
    expect(find.text('Trabalhe com o que você sabe fazer'), findsOneWidget);
    expect(find.text('O cadastro leva uns 5 minutos'), findsOneWidget);
    expect(find.text('Verificação'), findsOneWidget);
    await t.tap(find.text('Começar cadastro'));
    await t.pump();
    expect(find.text('Cadastro: em breve'), findsOneWidget);
  });
}
