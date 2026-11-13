import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/avaliacoes_profissional.dart';
import 'package:tatu/features/profissional/perfil/avaliacoes_profissional_page.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

void main() {
  // Fonte de verdade (a de teste é mais alta e não cabe no campo).
  setUpAll(() async {
    final inter = FontLoader('Inter');
    for (final w in [400, 500, 600, 700]) {
      inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await inter.load();
  });
  setUp(avaliacoesProfissional.restaurar);

  testWidgets('Resumo, filtros e dica da IA', (t) async {
    await _abrir(t, const AvaliacoesProfissionalPage());
    expect(find.text('4,9'), findsOneWidget);
    expect(find.text('312 avaliações'), findsOneWidget);
    expect(find.text('Subiu 0,1 este mês'), findsOneWidget);
    expect(find.text('Pontual · 128'), findsOneWidget);

    await t.tap(find.text('Com comentário'));
    await t.pump();
    // Sem o resumo, cabem todas: a sem comentário (Marina) some.
    expect(find.text('4,9'), findsNothing);
    expect(find.text('Júlia Costa'), findsOneWidget);
    expect(find.text('Marina Lopes'), findsNothing);

    await t.tap(find.text('Até 3'));
    await t.pump();
    expect(find.text('4,9'), findsNothing);
    expect(find.textContaining('“demora” 3 vezes'), findsOneWidget);
    expect(find.text('Roberto Alves'), findsOneWidget);
    expect(find.text('Ana Martins'), findsNothing);
    // Só a nota baixa (1–2) pode ser contestada.
    expect(find.text('Contestar'), findsOneWidget);
  });

  testWidgets('Contestar: escolhe o motivo e envia', (t) async {
    await _abrir(t, const AvaliacoesProfissionalPage(filtro: 2));
    await t.tap(find.text('Contestar'));
    await t.pumpAndSettle();
    expect(find.text('Júlia Costa · 1 estrela · 12 out\n'
        'Nossa equipe revisa em até 3 dias úteis.'), findsOneWidget);
    // Sem motivo, o botão não envia.
    await t.tap(find.text('Enviar para revisão'));
    await t.pump();
    expect(find.text('Recebemos sua contestação'), findsNothing);
    await t.tap(find.text('Ofensa ou preconceito'));
    await t.pump();
    await t.enterText(find.byType(TextField), 'Me xingou por eu ser mulher.');
    await t.tap(find.text('Enviar para revisão'));
    await t.pumpAndSettle();
    expect(find.text('Recebemos sua contestação'), findsOneWidget);
    await t.tap(find.text('Voltar para avaliações'));
    await t.pumpAndSettle();
    expect(find.text('Em revisão pela equipe'), findsOneWidget);
    expect(find.text('Contestar'), findsNothing);
  });

  testWidgets('Sem avaliações: estado vazio', (t) async {
    avaliacoesProfissional.limpar();
    await _abrir(t, const AvaliacoesProfissionalPage());
    expect(find.text('Nenhuma avaliação ainda'), findsOneWidget);
  });
}
