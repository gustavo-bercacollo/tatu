import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/notificacoes.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilClientePage()),
  );
  await t.tap(find.text('Notificações'));
  await t.pumpAndSettle();
}

CupertinoSwitch _interruptor(WidgetTester t, String texto) => t.widget(
  find.descendant(
    of: find.bySemanticsLabel(texto),
    matching: find.byType(CupertinoSwitch),
  ),
);

Future<void> _tocar(WidgetTester t, String texto) async {
  final interruptor = find.descendant(
    of: find.bySemanticsLabel(texto),
    matching: find.byType(CupertinoSwitch),
  );
  await t.ensureVisible(interruptor);
  await t.pumpAndSettle();
  await t.tap(interruptor);
  await t.pumpAndSettle();
}

void main() {
  setUp(notificacoes.restaurar);

  testWidgets('Aviso de pedido pede confirmação para desligar', (t) async {
    await _abrir(t);
    expect(_interruptor(t, 'Profissional aceitou').value, isTrue);

    await _tocar(t, 'Profissional aceitou');
    expect(find.text('Desligar este aviso?'), findsOneWidget);
    await t.tap(find.text('Manter ligado'));
    await t.pumpAndSettle();
    expect(_interruptor(t, 'Profissional aceitou').value, isTrue);

    await _tocar(t, 'Profissional aceitou');
    await t.tap(find.text('Desligar mesmo assim'));
    await t.pumpAndSettle();
    expect(_interruptor(t, 'Profissional aceitou').value, isFalse);
  });

  testWidgets('Extras desligam direto; "Ativar todas" liga tudo', (t) async {
    await _abrir(t);
    await _tocar(t, 'Lembrete para avaliar');
    expect(find.text('Desligar este aviso?'), findsNothing);
    expect(_interruptor(t, 'Lembrete para avaliar').value, isFalse);

    await t.scrollUntilVisible(find.text('Ativar todas'), -200);
    await t.tap(find.text('Ativar todas'));
    await t.pump();
    await t.scrollUntilVisible(find.text('Lembrete para avaliar'), 200);
    expect(_interruptor(t, 'Lembrete para avaliar').value, isTrue);
    expect(_interruptor(t, 'Novidades do Tatu').value, isTrue);
  });

  testWidgets('Bloqueadas no celular: aviso e interruptores desligados', (
    t,
  ) async {
    notificacoes.negarNoCelular();
    await _abrir(t);
    expect(find.textContaining('Desativadas no'), findsOneWidget);
    expect(find.text('Abrir Ajustes'), findsOneWidget);
    expect(find.text('Ativar todas'), findsNothing);
    final s = _interruptor(t, 'Mensagens');
    expect(s.value, isFalse);
    expect(s.onChanged, isNull);
  });
}
