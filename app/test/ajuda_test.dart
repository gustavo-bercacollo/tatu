import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrirAjuda(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilClientePage()),
  );
  await t.scrollUntilVisible(find.text('Ajuda'), 200);
  await t.ensureVisible(find.text('Ajuda'));
  await t.pumpAndSettle();
  await t.tap(find.text('Ajuda'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Assunto → artigo → "Isso ajudou?"', (t) async {
    await _abrirAjuda(t);
    await t.tap(find.text('Pagamento e valores'));
    await t.pumpAndSettle();
    expect(find.text('Cobraram o valor errado'), findsOneWidget);

    await t.tap(find.text('Como funciona o pagamento?'));
    await t.pumpAndSettle();
    expect(find.text('Pelo app'), findsOneWidget);
    await t.ensureVisible(find.text('Sim'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sim'));
    await t.pump();
    expect(find.text('Obrigado pela resposta!'), findsOneWidget);
  });

  testWidgets('Busca: resultados e "Nada encontrado"', (t) async {
    await _abrirAjuda(t);
    await t.tap(find.text('Buscar na ajuda'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'pix');
    await t.pump();
    expect(find.text('3 RESULTADOS'), findsOneWidget);
    expect(find.text('Chave Pix do profissional'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'reembolso de cripto');
    await t.pump();
    expect(find.text('Nada encontrado'), findsOneWidget);
    await t.tap(find.text('Falar com o suporte'));
    await t.pumpAndSettle();
    expect(find.text('Sobre o que é?'), findsOneWidget);
  });

  testWidgets('Suporte sobre um pedido: chat e resposta', (t) async {
    await _abrirAjuda(t);
    await t.tap(find.text('Falar com o suporte'));
    await t.pumpAndSettle();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('Qual pedido?'), findsOneWidget);
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();

    expect(find.text('Pedido · Encanador'), findsOneWidget);
    expect(find.text('Vi seu pedido com a Luiza. Como ajudo?'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Cobraram duas vezes no cartão.');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pump();
    expect(find.text('Cobraram duas vezes no cartão.'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Já estou vendo, um instante.'), findsOneWidget);
  });

  testWidgets('Outro assunto vai direto ao chat', (t) async {
    await _abrirAjuda(t);
    await t.tap(find.text('Falar com o suporte'));
    await t.pumpAndSettle();
    await t.tap(find.text('Outro assunto'));
    await t.pump();
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();
    expect(find.text('Como posso ajudar?'), findsOneWidget);
    expect(find.text('Pedido · Encanador'), findsNothing);
  });
}
