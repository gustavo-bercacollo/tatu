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
    FilledButton botao() =>
        tester.widget(find.widgetWithText(FilledButton, 'Continuar'));
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

    FilledButton botao() =>
        tester.widget(find.widgetWithText(FilledButton, 'Continuar'));
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
    FilledButton botao() =>
        tester.widget(find.widgetWithText(FilledButton, 'Continuar'));
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.pump();
    expect(botao().onPressed, isNotNull);
  });

  testWidgets(
    'Entrar: abre pelo Entrar, manda código e Criar conta leva ao cadastro',
    (tester) async {
      // Tamanho de celular (393×852) para o "Entrar" ficar visível.
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const TatuApp());
      await tester.tapOnText(find.textRange.ofSubstring('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Digite o celular do seu cadastro.\nEnviamos um código por SMS.',
        ),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), '11988887777');
      await tester.pump();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Digite o código'), findsOneWidget);

      await tester.tap(find.text('Trocar número'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usar e-mail'));
      await tester.pumpAndSettle();
      expect(find.text('Qual é o seu e-mail?'), findsOneWidget);
      await tester.tap(find.text('Usar celular'));
      await tester.pumpAndSettle();
      await tester.tapOnText(find.textRange.ofSubstring('Criar conta'));
      await tester.pumpAndSettle();
      expect(find.text('Qual é o seu celular?'), findsOneWidget);
    },
  );

  testWidgets('E-mail: Usar e-mail, valida o e-mail e manda código', (
    tester,
  ) async {
    await tester.pumpWidget(const TatuApp());
    await tester.tap(find.text('Preciso de um serviço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar e-mail'));
    await tester.pumpAndSettle();

    expect(find.text('Qual é o seu e-mail?'), findsOneWidget);
    FilledButton botao() =>
        tester.widget(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.enterText(find.byType(TextField), 'ana@email');
    await tester.pump();
    expect(botao().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'ana@email.com');
    await tester.pump();
    expect(botao().onPressed, isNotNull);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Enviamos um e-mail para\nana@email.com'), findsOneWidget);
    expect(find.text('Trocar e-mail'), findsOneWidget);
    expect(find.text('Não chegou? Veja a caixa de spam.'), findsOneWidget);

    await tester.tap(find.text('Trocar e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar celular'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é o seu celular?'), findsOneWidget);
  });
}
