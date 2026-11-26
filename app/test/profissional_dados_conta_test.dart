import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/features/profissional/cadastro/verificacao_page.dart';
import 'package:tatu/features/profissional/perfil/perfil_profissional_page.dart';

Future<void> _dados(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1100);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional.demo();
  conta.restaurar();
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const PerfilProfissionalPage()),
  );
  await t.scrollUntilVisible(find.text('Dados da conta'), 200);
  // Um pouco mais (o item "Seus selos" empurrou a lista).
  await t.drag(find.byType(Scrollable).first, const Offset(0, -150));
  await t.pumpAndSettle();
  await t.tap(find.text('Dados da conta'));
  await t.pumpAndSettle();
}

void main() {
  CameraVerificacaoPage.cameraAoVivo = false;

  testWidgets('Dados do documento têm cadeado e pedem novo documento', (
    t,
  ) async {
    await _dados(t);
    expect(find.text('12/04/1990'), findsOneWidget);
    expect(find.text('•••.456.789-••'), findsOneWidget);
    await t.tap(find.text('Luiza Vilela'));
    await t.pumpAndSettle();
    expect(find.text('Seu nome vem do documento'), findsOneWidget);
    await t.tap(find.text('Enviar novo documento'));
    await t.pumpAndSettle();
    expect(find.text('Frente do documento'), findsWidgets);
  });

  testWidgets('Excluir com saldo a receber é bloqueado', (t) async {
    await _dados(t);
    await t.tap(find.text('Excluir conta'));
    await t.pumpAndSettle();
    expect(find.text('Agora não dá para excluir'), findsOneWidget);
    expect(find.textContaining('R\$ 135,00 a receber'), findsOneWidget);
    await t.tap(find.text('Ver meus ganhos'));
    await t.pumpAndSettle();
    expect(find.text('Total da semana'), findsOneWidget);
  });

  testWidgets('RN-185: com retorno aberto, não encerra o perfil', (t) async {
    retornos.restaurar(); // a demo tem um retorno aberto da Júlia
    await _dados(t);
    await t.tap(find.text('Encerrar perfil profissional'));
    await t.pumpAndSettle();
    expect(find.textContaining('um retorno aberto'), findsOneWidget);
    final botao = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Encerrar perfil profissional'),
    );
    expect(botao.onPressed, isNull);
  });

  testWidgets('Encerrar perfil profissional volta ao modo cliente', (t) async {
    retornos.retornos.clear();
    await _dados(t);
    await t.tap(find.text('Encerrar perfil profissional'));
    await t.pumpAndSettle();
    expect(find.text('Sua conta de cliente continua.'), findsOneWidget);
    await t.tap(find.text('Encerrar perfil profissional').last);
    await t.pumpAndSettle();
    expect(find.text('Perfil profissional encerrado'), findsOneWidget);
    await t.tap(find.text('Ir para o modo cliente'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(profissional.verificacao, Verificacao.naoEnviada);
  });
}
