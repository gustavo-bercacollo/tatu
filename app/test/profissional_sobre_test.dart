import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/sobre_ia.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional
    ..demo()
    ..definirSobre('');
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
  );
  await t.tap(find.text('Sobre você'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Sobre você: melhorar com IA, usar o texto e salvar', (t) async {
    await _abrir(t);
    expect(find.text('Melhorar com IA'), findsNothing); // vazio
    await t.enterText(
      find.byType(TextField),
      'sou encanadora faz 9 anos, faço vazamento chuveiro e parte eletrica '
      'atendo zona sul sabado tbm',
    );
    await t.pump();
    expect(find.textContaining('/300'), findsOneWidget);
    await t.tap(find.text('Melhorar com IA'));
    await t.pump();
    expect(find.text('Melhorando…'), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.text('Sugestão de texto'), findsOneWidget);
    await t.tap(find.text('Usar este texto'));
    await t.pumpAndSettle();
    expect(
      find.textContaining('Encanadora e eletricista há 9 anos.'),
      findsOneWidget,
    );
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(profissional.sobre, startsWith('Encanadora e eletricista'));
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('Sobre você: telefone, e-mail e rede social bloqueiam', (
    t,
  ) async {
    await _abrir(t);
    for (final contato in [
      'me chama no (11) 98888-7777',
      'escreve para luiza@email.com',
      'segue @luiza_encanadora',
      'chama no zap',
    ]) {
      await t.enterText(find.byType(TextField), 'Encanadora. $contato');
      await t.pump();
      expect(
        find.textContaining('Tire telefone, e-mail e redes sociais.'),
        findsOneWidget,
        reason: contato,
      );
      expect(
        t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    }
    await t.enterText(find.byType(TextField), 'Encanadora há 9 anos.');
    await t.pump();
    expect(find.textContaining('Tire telefone'), findsNothing);
    expect(
      contatoProibido.hasMatch('Atendo há 9 anos, 2 pessoas na equipe'),
      isFalse,
    );
  });
}
