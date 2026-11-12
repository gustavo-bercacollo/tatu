import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

void main() {
  testWidgets('A caminho → Cheguei (perto) → Iniciar serviço', (t) async {
    t.view.physicalSize = const Size(430, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const ACaminhoPage()),
    );
    expect(find.text('A caminho'), findsOneWidget);
    expect(find.text('Rua Bruno Lobo, 29'), findsOneWidget);
    // Longe: "Cheguei" ainda não funciona.
    await t.tap(find.text('Cheguei'));
    await t.pump();
    expect(find.text('Você chegou'), findsNothing);
    await t.pump(const Duration(seconds: 6));
    await t.tap(find.text('Cheguei'));
    await t.pump();
    expect(find.text('Você chegou'), findsOneWidget);
    expect(find.text('Ana foi avisada de que você está aí.'), findsOneWidget);
    await t.tap(find.text('Iniciar serviço'));
    await t.pumpAndSettle();
    expect(find.text('Serviço em andamento'), findsOneWidget);
    expect(find.text('Concluir e cobrar'), findsOneWidget);
  });
}
