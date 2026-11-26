import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/shared/widgets/borda_animada.dart';

/// Borda animada da caixa "O que está acontecendo?" (Home do cliente).

Widget _caixa(ModoBorda modo, {bool reduzir = false, bool visivel = true}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduzir),
        child: TickerMode(
          enabled: visivel,
          child: Center(
            child: BordaAnimada(
              modo: modo,
              raio: 18,
              child: const SizedBox(width: 300, height: 150),
            ),
          ),
        ),
      ),
    );

/// A animação está pedindo quadros (girando)?
Future<bool> _girando(WidgetTester t) async {
  await t.pump(const Duration(milliseconds: 100));
  return t.binding.hasScheduledFrame;
}

void main() {
  // Aqui a borda gira de verdade (nos outros testes fica parada).
  setUp(() {
    BordaAnimada.girar = true;
    BordaAnimada.jaGirou = false;
  });
  tearDown(() => BordaAnimada.girar = false);

  testWidgets('ao abrir: dá uma volta e para (não gira de novo)', (t) async {
    await t.pumpWidget(_caixa(ModoBorda.girando));
    expect(await _girando(t), isTrue);
    await t.pump(BordaAnimada.volta);
    await t.pump();
    expect(BordaAnimada.jaGirou, isTrue);
    expect(await _girando(t), isFalse);
    // Voltar para a Home não gira de novo (só ao abrir o app).
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(_caixa(ModoBorda.girando));
    expect(await _girando(t), isFalse);
  });

  testWidgets('com foco (sólida) ou com texto (parada): não gira', (t) async {
    await t.pumpWidget(_caixa(ModoBorda.solida));
    expect(await _girando(t), isFalse);
    await t.pumpWidget(_caixa(ModoBorda.parada));
    expect(await _girando(t), isFalse);
    // Volta a girar quando a caixa fica vazia e sem foco.
    await t.pumpWidget(_caixa(ModoBorda.girando));
    expect(await _girando(t), isTrue);
  });

  testWidgets('"Reduzir movimento": parada', (t) async {
    await t.pumpWidget(_caixa(ModoBorda.girando, reduzir: true));
    expect(await _girando(t), isFalse);
  });

  testWidgets('fora da tela (outra aba, rota por cima): parada', (t) async {
    await t.pumpWidget(_caixa(ModoBorda.girando, visivel: false));
    expect(await _girando(t), isFalse);
  });

  testWidgets('app em segundo plano: para; ao voltar, gira', (t) async {
    await t.pumpWidget(_caixa(ModoBorda.girando));
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(await _girando(t), isFalse);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(await _girando(t), isTrue);
  });

  testWidgets('Home: gira vazia, fica sólida ao digitar, volta ao apagar', (
    t,
  ) async {
    BordaAnimada.girar = false; // a Home tem outras animações
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
    );
    await t.pumpAndSettle();
    ModoBorda modo() => t.widget<BordaAnimada>(find.byType(BordaAnimada)).modo;
    expect(modo(), ModoBorda.girando);
    await t.tap(find.text('O que está acontecendo?'));
    await t.pump();
    expect(modo(), ModoBorda.solida);
    await t.enterText(find.byType(TextField), 'a pia vazou');
    await t.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump();
    expect(modo(), ModoBorda.parada);
    await t.tap(find.byType(TextField));
    await t.pump();
    await t.enterText(find.byType(TextField), '');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump(const Duration(milliseconds: 600));
    expect(modo(), ModoBorda.girando);
  });
}
