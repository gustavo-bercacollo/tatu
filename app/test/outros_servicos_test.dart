import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/shared/widgets/tatu_chip.dart';

Future<void> _abrirOutros(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.tap(find.text('Outros'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Escolhe Chaveiro: chip vira "Chaveiro" e botão chama', (
    t,
  ) async {
    await _abrirOutros(t);
    expect(find.text('Outros serviços'), findsOneWidget);
    expect(find.text('CASA E REFORMAS'), findsOneWidget);
    await t.ensureVisible(find.text('Marceneiro'));
    await t.pumpAndSettle();
    await t.tap(find.text('Marceneiro'));
    await t.pumpAndSettle();
    expect(find.text('Marceneiro'), findsOneWidget);
    // RN-161: "Outros" continua como seletor, nunca selecionado.
    final outros = t.widget<TatuChip>(find.widgetWithText(TatuChip, 'Outros'));
    expect(outros.seletor, isTrue);
    expect(outros.selecionado, isFalse);
    expect(
      t
          .widget<TatuChip>(find.widgetWithText(TatuChip, 'Marceneiro'))
          .selecionado,
      isTrue,
    );
    expect(find.text('Chamar marceneiro'), findsOneWidget);

    // Escolher um serviço da Home volta o chip para "Outros".
    await t.tap(find.text('Pintor'));
    await t.pump();
    expect(find.text('Outros'), findsOneWidget);
  });

  testWidgets('Busca com resultados e sem resultados', (t) async {
    await _abrirOutros(t);
    await t.enterText(find.byType(TextField).last, 'desent');
    await t.pump();
    // RN-228: a seção leva o nome do modo atual.
    expect(find.text('NO LOCAL'), findsOneWidget);
    expect(find.text('Encanador'), findsWidgets);
    expect(find.text('Desentupimento'), findsOneWidget);

    await t.enterText(find.byType(TextField).last, 'afinador de piano');
    await t.pump();
    expect(find.text('Não achamos esse serviço'), findsOneWidget);
    expect(find.text('Sugerir esse serviço ao Tatu'), findsOneWidget);
  });

  testWidgets('Não sei: pede descrição e chama profissional', (t) async {
    await _abrirOutros(t);
    await t.tap(find.text('Não sei qual serviço'));
    await t.pumpAndSettle();
    expect(find.text('Não sei'), findsOneWidget);
    expect(
      find.text('Descreva o problema para acharmos quem resolve.'),
      findsOneWidget,
    );
    final botao = find.widgetWithText(FilledButton, 'Descreva o problema');
    expect(t.widget<FilledButton>(botao).onPressed, isNull);

    await t.enterText(find.byType(TextField), 'meu piano está desafinado');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Chamar profissional'), findsOneWidget);
    expect(
      find.text('Vamos achar o profissional pela sua descrição.'),
      findsOneWidget,
    );
  });
}
