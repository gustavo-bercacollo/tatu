import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/notificacoes_profissional.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';
import 'package:tatu/shared/widgets/back_circle_button.dart';

Future<void> _perfil(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1100);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional.demo();
  notificacoesProfissional.restaurar();
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
  );
}

Future<void> _abrirNotificacoes(WidgetTester t) async {
  await t.scrollUntilVisible(find.text('Notificações'), 200);
  await t.tap(find.text('Notificações'));
  await t.pumpAndSettle();
}

void main() {
  ToqueChamado.ativo = false;

  testWidgets('1ª vez pede a permissão; Agora não desativa', (t) async {
    await _perfil(t);
    await _abrirNotificacoes(t);
    expect(find.text('Não perca nenhum chamado'), findsOneWidget);
    await t.tap(find.text('Agora não'));
    await t.pumpAndSettle();
    expect(find.text('Desativadas'), findsOneWidget);
    await _abrirNotificacoes(t);
    expect(find.textContaining('Desativadas no'), findsOneWidget);
  });

  testWidgets('Ativar avisos; desligar novo chamado pede confirmação', (
    t,
  ) async {
    await _perfil(t);
    await _abrirNotificacoes(t);
    await t.tap(find.text('Ativar avisos'));
    await t.pumpAndSettle();
    expect(find.text('Ativar todas'), findsOneWidget);
    await t.tap(find.byType(CupertinoSwitch).first);
    await t.pumpAndSettle();
    expect(find.text('Desligar novo chamado?'), findsOneWidget);
    await t.tap(find.text('Manter ligado'));
    await t.pumpAndSettle();
    expect(notificacoesProfissional.ligado('novo'), isTrue);
    await t.tap(find.byType(CupertinoSwitch).first);
    await t.pumpAndSettle();
    await t.tap(find.text('Desligar mesmo assim'));
    await t.pumpAndSettle();
    expect(notificacoesProfissional.ligado('novo'), isFalse);
    await t.tap(find.text('Ativar todas'));
    await t.pump();
    expect(notificacoesProfissional.ligado('dicas'), isTrue);
  });

  testWidgets('Som do novo chamado: escolher e vibrar', (t) async {
    await _perfil(t);
    notificacoesProfissional.responderPermissao(permitiu: true);
    await _abrirNotificacoes(t);
    expect(find.text('Alerta Tatu'), findsOneWidget);
    await t.tap(find.text('Som do novo chamado'));
    await t.pumpAndSettle();
    await t.tap(find.text('Buzina'));
    await t.pump();
    expect(notificacoesProfissional.som, SomChamado.buzina);
    await t.tap(find.byType(CupertinoSwitch));
    await t.pump();
    expect(notificacoesProfissional.vibrar, isFalse);
    await t.tap(find.text('Ouvir o som'));
    await t.pump();
    await t.tap(find.byType(BackCircleButton));
    await t.pumpAndSettle();
    expect(find.text('Buzina'), findsOneWidget);
  });
}
