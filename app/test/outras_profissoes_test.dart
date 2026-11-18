import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/servicos.dart';
import 'package:tatu/data/sugestoes_profissao.dart';
import 'package:tatu/features/profissional/cadastro/profissoes_page.dart';
import 'package:tatu/features/profissional/cadastro/servicos_page.dart';

Future<void> _abrirOutras(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const ServicosProfissionalPage()),
  );
  await t.tap(find.text('Outros'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    profissional.restaurar();
    sugestoesProfissao.restaurar();
  });

  test('RN-161: catálogo vem do .md, com segmentos e sinônimos', () {
    expect(catalogoServicos.segmentos.first.$1, 'Casa e reformas');
    final enc = catalogoServicos.porNome('Encanador')!;
    expect(enc.sinonimos, contains('bombeiro hidráulico'));
    // Sem acento e sem maiúsculas.
    final achados = buscarServicos('BOMBEIRO HIDRAULICO', profissional: true);
    expect(achados.first.nome, 'Encanador');
  });

  testWidgets('RN-161: "Outros" do cadastro abre "Outras profissões"', (
    t,
  ) async {
    await _abrirOutras(t);
    expect(find.text('Outras profissões'), findsOneWidget);
    expect(find.text('MAIS PROCURADAS'), findsOneWidget);
    expect(find.text('CASA E REFORMAS'), findsOneWidget);
    expect(find.text('Não achei a minha'), findsOneWidget);
    expect(find.text('Sugerir uma profissão ao Tatu'), findsOneWidget);
  });

  testWidgets('RN-161: sinônimo encontra a profissão', (t) async {
    await _abrirOutras(t);
    await t.enterText(find.byType(TextField).last, 'bombeiro hidr');
    await t.pump();
    expect(find.text('RESULTADOS'), findsOneWidget);
    expect(find.text('Encanador'), findsWidgets);
    expect(find.text('Também chamado de bombeiro hidráulico'), findsOneWidget);
    // O rodapé continua embaixo dos resultados.
    expect(find.text('Não achei a minha'), findsOneWidget);
  });

  testWidgets('RN-162: sugestão vai para o suporte e fica em análise', (
    t,
  ) async {
    await _abrirOutras(t);
    await t.scrollUntilVisible(
      find.text('Não achei a minha'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await t.tap(find.text('Não achei a minha'));
    await t.pumpAndSettle();
    expect(find.text('Sugerir profissão'), findsOneWidget);
    expect(find.text('Fica em análise por até 2 dias úteis.'), findsOneWidget);
    final botao = find.widgetWithText(FilledButton, 'Enviar sugestão');
    expect(t.widget<FilledButton>(botao).onPressed, isNull);

    await t.enterText(find.byType(TextField).last, 'Afinador de piano');
    await t.pump();
    await t.tap(botao);
    await t.pumpAndSettle();
    expect(find.text('Sugestão enviada'), findsOneWidget);
    expect(find.text('Outras profissões'), findsNothing);

    final fila = sugestoesProfissao.filaSuporte;
    expect(fila.single.nome, 'Afinador de piano');
    expect(fila.single.status, StatusSugestao.emAnalise);

    // No perfil (Profissões): "Em análise".
    await t.pumpWidget(
      MaterialApp(
        theme: tatuTheme(),
        home: const ProfissoesPage(doPerfil: true),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Afinador de piano'), findsOneWidget);
    expect(find.text('Em análise'), findsOneWidget);
  });

  test('RN-162: nome curto ou repetido não entra na fila', () {
    expect(sugestoesProfissao.sugerir('ab', profissional: 'Rafael'), isNull);
    expect(sugestoesProfissao.sugerir('Afinador', profissional: 'Rafael'),
        isNotNull);
    expect(sugestoesProfissao.sugerir('afinador', profissional: 'Rafael'),
        isNull);
    expect(sugestoesProfissao.filaSuporte, hasLength(1));
  });
}
