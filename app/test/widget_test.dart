import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tatu/main.dart';

void main() {
  testWidgets('Boas-vindas mostra as duas opções e o Entrar', (tester) async {
    await tester.pumpWidget(const TatuApp());

    expect(find.text('Como você quer usar o Tatu?'), findsOneWidget);
    expect(find.text('Preciso de um serviço'), findsOneWidget);
    expect(find.text('Quero trabalhar'), findsOneWidget);
    expect(find.textContaining('Entrar', findRichText: true), findsOneWidget);
  });

  testWidgets('Celular: formata o número e libera Continuar com 11 dígitos', (
    tester,
  ) async {
    await tester.pumpWidget(const TatuApp());
    await tester.tap(find.text('Preciso de um serviço'));
    await tester.pumpAndSettle();

    expect(find.text('Qual é o seu celular?'), findsOneWidget);
    FilledButton botao() => tester.widget(find.byType(FilledButton));
    String valor() =>
        tester.widget<TextField>(find.byType(TextField)).controller!.text;
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '1198888777');
    await tester.pump();
    expect(valor(), '(11) 98888-777');
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '11988887777');
    await tester.pump();
    expect(valor(), '(11) 98888-7777');
    expect(botao().onPressed, isNotNull);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Como você quer usar o Tatu?'), findsOneWidget);
  });

  testWidgets('Código: mostra o número, conta 60 s e libera com 6 dígitos', (
    tester,
  ) async {
    await tester.pumpWidget(const TatuApp());
    await tester.tap(find.text('Preciso de um serviço'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11988887777');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Digite o código'), findsOneWidget);
    expect(
      find.text('Enviamos um SMS para\n+55 (11) 98888-7777'),
      findsOneWidget,
    );
    expect(find.text('Reenviar código em 1:00'), findsOneWidget);
    await tester.pump(const Duration(seconds: 18));
    expect(find.text('Reenviar código em 0:42'), findsOneWidget);
    await tester.pump(const Duration(seconds: 42));
    expect(find.text('Reenviar código'), findsOneWidget);

    FilledButton botao() => tester.widget(find.byType(FilledButton));
    await tester.enterText(find.byType(TextField), '48271');
    await tester.pump();
    expect(botao().onPressed, isNull);
    await tester.enterText(find.byType(TextField), '482719');
    await tester.pump();
    expect(botao().onPressed, isNotNull);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Como podemos\nte chamar?'), findsOneWidget);
  });

  testWidgets('Nome: Continuar só com nome; sobrenome é opcional', (
    tester,
  ) async {
    await tester.pumpWidget(const TatuApp());
    await tester.tap(find.text('Preciso de um serviço'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11988887777');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '482719');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Como podemos\nte chamar?'), findsOneWidget);
    FilledButton botao() => tester.widget(find.byType(FilledButton).last);
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.pump();
    expect(botao().onPressed, isNotNull);
  });
}
