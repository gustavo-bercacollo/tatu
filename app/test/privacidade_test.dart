import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilClientePage()),
  );
  await t.scrollUntilVisible(find.text('Privacidade e termos'), 200);
  await t.ensureVisible(find.text('Privacidade e termos'));
  await t.pumpAndSettle();
  await t.tap(find.text('Privacidade e termos'));
  await t.pumpAndSettle();
}

void main() {
  setUp(perfil.restaurar);

  testWidgets('Documentos: termos e política com link para seus dados', (
    t,
  ) async {
    await _abrir(t);
    await t.tap(find.text('Termos de uso'));
    await t.pumpAndSettle();
    expect(find.text('1. O que é o Tatu'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();

    await t.tap(find.text('Política de privacidade'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver seus dados e direitos'));
    await t.pumpAndSettle();
    expect(find.text('Baixar meus dados'), findsOneWidget);
  });

  testWidgets('Permissões mostram o estado de cada uma', (t) async {
    perfil.definirPermissoes(fotos: false);
    await _abrir(t);
    await t.tap(find.text('Permissões'));
    await t.pumpAndSettle();
    expect(find.text('Ao usar o app'), findsOneWidget);
    expect(find.text('Permitida'), findsOneWidget);
    expect(find.text('Negada'), findsOneWidget);
    expect(find.text('Ativadas'), findsOneWidget);
  });

  testWidgets('Baixar meus dados → Pedido recebido → Concluir', (t) async {
    await _abrir(t);
    await t.tap(find.text('Seus dados e direitos'));
    await t.pumpAndSettle();
    await t.tap(find.text('Baixar meus dados'));
    await t.pumpAndSettle();
    expect(find.textContaining('ana@email.com'), findsOneWidget);
    await t.tap(find.text('Pedir cópia'));
    await t.pumpAndSettle();
    expect(find.text('Pedido recebido'), findsOneWidget);
    await t.tap(find.text('Concluir'));
    await t.pumpAndSettle();
    expect(find.text('Seus dados'), findsOneWidget);
  });
}
