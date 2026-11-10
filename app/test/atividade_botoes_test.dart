import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/atividade/atividade_page.dart';

Future<void> _concluidos(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const AtividadePage(aba: 1)),
  );
}

Future<void> _fecharAviso(WidgetTester t) async {
  await t.pump(const Duration(seconds: 4));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    pedidos.restaurar();
    conta.restaurar();
  });

  testWidgets('Cancelado não tem Recibo; avaliado mostra estrelas', (t) async {
    await _concluidos(t);
    expect(find.text('Cancelado'), findsOneWidget);
    expect(find.text('Recibo'), findsNWidgets(2));
    expect(find.text('Avaliar'), findsOneWidget);
    expect(find.text('Pedir de novo'), findsNWidgets(3));
  });

  testWidgets('Avaliar a Luiza: nota, elogios e enviar', (t) async {
    await _concluidos(t);
    await t.tap(find.text('Avaliar'));
    await t.pumpAndSettle();
    expect(find.text('Como foi com a Luiza?'), findsOneWidget);
    final enviar = find.widgetWithText(FilledButton, 'Enviar avaliação');
    expect(t.widget<FilledButton>(enviar).onPressed, isNull);

    await t.tap(find.bySemanticsLabel('4 estrelas'));
    await t.tap(find.text('Educada'));
    await t.pump();
    await t.tap(enviar);
    await t.pumpAndSettle();
    expect(pedidos.concluidos.first.avaliacao, 4);
    expect(pedidos.concluidos.first.minhaAvaliacao!.tags, ['Educada']);
    expect(find.text('Avaliar'), findsNothing);
    await _fecharAviso(t);
  });

  testWidgets('Sua avaliação do Rafael e editar', (t) async {
    await _concluidos(t);
    await t.tap(find.bySemanticsLabel(RegExp('^Sua avaliação')));
    await t.pumpAndSettle();
    expect(find.text('Você pode editar até 09 nov.'), findsOneWidget);
    expect(find.text('Pontual'), findsOneWidget);
    await t.tap(find.text('Editar avaliação'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('3 estrelas'));
    await t.pump();
    await t.tap(find.text('Salvar avaliação'));
    await t.pumpAndSettle();
    expect(pedidos.concluidos[1].avaliacao, 3);
    await _fecharAviso(t);
  });

  testWidgets('Recibo pelo app e comprovante pago por fora', (t) async {
    conta.email = null;
    await _concluidos(t);
    await t.tap(find.text('Recibo').first);
    await t.pumpAndSettle();
    expect(find.text('Pago · Visa 4242'), findsOneWidget);
    expect(find.text('#TT-48213'), findsOneWidget);
    // Sem e-mail: pede antes de enviar.
    await t.tap(find.text('Enviar por e-mail'));
    await t.pumpAndSettle();
    expect(find.text('Seu e-mail'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();

    await t.tap(find.text('Recibo').last);
    await t.pumpAndSettle();
    expect(find.text('Comprovante'), findsOneWidget);
    expect(find.text('Pago direto ao profissional'), findsOneWidget);
    expect(find.text('Baixar comprovante'), findsOneWidget);
  });

  testWidgets('Pedir de novo: mesma pessoa (online) ou offline', (t) async {
    await _concluidos(t);
    await t.tap(find.text('Pedir de novo').first);
    await t.pumpAndSettle();
    expect(find.text('Online · chega em ~15 min'), findsOneWidget);
    expect(find.text('Chamar a Luiza'), findsNWidgets(2));
    await t.tap(find.widgetWithText(FilledButton, 'Chamar a Luiza'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Chamando a Luiza'), findsOneWidget);
    // 2 min sem aceitar: chama os outros.
    await t.pump(const Duration(minutes: 2));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Procurando um profissional'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Fechar'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Pedir de novo com profissional offline', (t) async {
    await _concluidos(t);
    await t.tap(find.text('Pedir de novo').at(1));
    await t.pumpAndSettle();
    expect(find.text('Offline agora'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Chamar qualquer eletricista'),
      findsOneWidget,
    );
  });
}
