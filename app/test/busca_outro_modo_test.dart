import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/shared/widgets/segmento.dart';
import 'package:tatu/shared/widgets/tatu_chip.dart';

/// Profissão de outro modo na busca (RN-228).

Future<void> _buscar(WidgetTester t, String termo) async {
  t.view.physicalSize = const Size(1179, 2556);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.enterText(find.byType(TextField), 'quero um logo pra minha loja');
  await t.pump(const Duration(milliseconds: 600));
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pump();
  await t.tap(find.text('Outros'));
  await t.pumpAndSettle();
  await t.enterText(find.byType(TextField).last, termo);
  await t.pump();
}

void main() {
  testWidgets('C23: modo atual e "Só à distância" separados', (t) async {
    await _buscar(t, 'design');
    expect(find.text('NO LOCAL'), findsOneWidget);
    expect(find.text('Designer de interiores'), findsOneWidget);
    expect(find.text('SÓ À DISTÂNCIA'), findsOneWidget);
    expect(find.text('Designer gráfico'), findsOneWidget);
    expect(find.text('À distância'), findsWidgets); // etiqueta no item
    expect(find.text('Tocar muda o pedido para À distância.'), findsOneWidget);
  });

  testWidgets('quem atende nos dois modos fica só no modo atual', (t) async {
    await _buscar(t, 'arquitet');
    expect(find.text('NO LOCAL'), findsOneWidget);
    expect(find.text('Arquiteto'), findsOneWidget);
    expect(find.text('SÓ À DISTÂNCIA'), findsNothing);
  });

  testWidgets('sem resultado em nenhum modo: sugerir ao Tatu', (t) async {
    await _buscar(t, 'xyzqwe');
    expect(find.text('Não achamos esse serviço'), findsOneWidget);
  });

  testWidgets('C24: tocar troca o modo, seleciona e explica', (t) async {
    await _buscar(t, 'design');
    await t.tap(find.text('Designer gráfico'));
    await t.pump();
    // Sem aviso flutuante.
    expect(find.byType(SnackBar), findsNothing);
    Segmento chave() => t.widget<Segmento>(
      find.byWidgetPredicate(
        (w) => w is Segmento && w.opcoes.contains('À distância'),
      ),
    );
    expect(chave().selecionada, 1);
    expect(chave().destacar, isTrue);
    // O chip da Home equivalente ("Designer") já fica escolhido.
    expect(
      t.widget<TatuChip>(find.widgetWithText(TatuChip, 'Designer')).selecionado,
      isTrue,
    );
    expect(find.text('Designer gráfico é só à distância.'), findsOneWidget);
    // A descrição continua.
    expect(find.text('quero um logo pra minha loja'), findsOneWidget);
    // O destaque dura 1 segundo.
    await t.pump(RegrasHome.destaqueModo);
    await t.pumpAndSettle();
    expect(chave().destacar, isFalse);
    // Desfazer: tocar no outro modo na própria chave.
    await t.tap(find.text('No local'));
    await t.pumpAndSettle();
    expect(chave().selecionada, 0);
    expect(find.text('Designer gráfico é só à distância.'), findsNothing);
  });
}
