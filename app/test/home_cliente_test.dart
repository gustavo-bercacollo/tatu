import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/home_page.dart';

FilledButton _botao(WidgetTester t) => t.widget(find.byType(FilledButton));

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
}

void main() {
  // Sem profissional a caminho: a Home mostra a saudação (RN-165).
  setUp(() => pedidos..restaurar()..cancelarAndamento());

  testWidgets('Home vazia: saudação, iniciais e botão desabilitado', (t) async {
    await _abrir(t);
    expect(find.text('Oi, Ana'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Perfil')), findsOneWidget);
    expect(find.text('Profissionais ativos perto de você'), findsOneWidget);
    expect(find.text('Escolha um serviço'), findsOneWidget);
    expect(_botao(t).onPressed, isNull);
  });

  testWidgets('IA marca o serviço pela descrição; escolha manual vence', (
    t,
  ) async {
    await _abrir(t);
    await t.enterText(
      find.byType(TextField),
      'o cano da pia da cozinha está vazando e a água não para',
    );
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Chamar encanador'), findsOneWidget);
    expect(
      find.text('Sugerido pela descrição. Toque em outro para trocar.'),
      findsOneWidget,
    );

    await t.tap(find.text('Eletricista'));
    await t.pump();
    expect(find.text('Chamar eletricista'), findsOneWidget);
    expect(
      find.text('Sugerido pela descrição. Toque em outro para trocar.'),
      findsNothing,
    );

    // Mudar a descrição não troca a escolha manual.
    await t.enterText(find.byType(TextField), 'tem um vazamento no cano');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Chamar eletricista'), findsOneWidget);
  });

  testWidgets('Avatar abre o Perfil; Início volta; Sair leva às Boas-vindas', (
    t,
  ) async {
    await _abrir(t);
    await t.tap(find.bySemanticsLabel(RegExp('^Perfil')));
    await t.pumpAndSettle();
    expect(find.text('Ana Martins'), findsOneWidget);
    expect(find.text('Trocar para modo profissional'), findsOneWidget);
    expect(find.text('4,8 · 23 pedidos'), findsOneWidget);

    await t.tap(find.text('Início'));
    await t.pumpAndSettle();
    expect(find.text('Do que você precisa?'), findsOneWidget);

    await t.tap(find.bySemanticsLabel(RegExp('^Perfil')));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Sair da conta'), 200);
    await t.tap(find.text('Sair da conta'));
    await t.pumpAndSettle();
    expect(find.text('Como você quer usar o Tatu?'), findsOneWidget);
  });

  testWidgets('Sem confiança, a IA não marca nada', (t) async {
    await _abrir(t);
    await t.enterText(find.byType(TextField), 'preciso de ajuda em casa');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Escolha um serviço'), findsOneWidget);
  });
}
