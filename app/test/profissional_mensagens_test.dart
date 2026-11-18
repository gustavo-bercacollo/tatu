import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/profissional/mensagens/mensagens_profissional_page.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  profissional.demo();
  conversasProfissional.restaurar();
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const MensagensProfissionalPage()),
  );
}

void main() {
  testWidgets('Lista: grupos, selos, busca e vazio', (t) async {
    await _abrir(t);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Anteriores'), findsOneWidget);
    expect(find.text('Valor combinado · R\$ 150'), findsOneWidget);
    expect(find.text('Proposta 2 de 3'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'júlia');
    await t.pump();
    expect(find.text('Júlia Costa'), findsOneWidget);
    expect(find.text('Ana Martins'), findsNothing);
    conversasProfissional.limpar();
    await t.pump();
    // RN-115: sem conversas, o canal do Tatu continua fixado.
    expect(find.text('Tatu'), findsOneWidget);
    expect(
      find.text(
        'Quando você aceitar um chamado,\na conversa com o cliente aparece aqui.',
      ),
      findsOneWidget,
    );
  });

  // RN-42 e RN-87: a conversa continua e dá para enviar um novo valor.
  testWidgets('Conversa anterior continua: Enviar novo valor', (t) async {
    await _abrir(t);
    await t.tap(find.text('Júlia Costa'));
    await t.pumpAndSettle();
    expect(find.text('Serviço concluído · R\$ 120,00 · 04 nov'), findsOneWidget);
    expect(find.text('12 nov'), findsOneWidget);
    expect(find.text('Esta conversa foi encerrada'), findsNothing);
    expect(find.text('Enviar novo valor'), findsOneWidget);
    expect(find.text('Estou a caminho'), findsNothing);
  });

  testWidgets('Opções: denunciar a cliente', (t) async {
    await _abrir(t);
    await t.tap(find.text('Ana Martins'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel(RegExp('Opções da conversa')));
    await t.pumpAndSettle();
    // RN-140: sem valor confirmado não existe ligar.
    expect(find.text('Ligar para Ana'), findsNothing);
    await t.tap(find.text('Denunciar cliente'));
    await t.pumpAndSettle();
    expect(find.text('Denunciar Ana'), findsOneWidget);
    await t.tap(find.text('Perfil falso'));
    await t.pump();
    await t.tap(find.text('Enviar denúncia'));
    await t.pumpAndSettle();
    expect(find.text('Denúncia enviada'), findsOneWidget);
    await t.tap(find.text('Voltar para a conversa'));
    await t.pumpAndSettle();
    expect(find.text('Ana Martins'), findsOneWidget);
  });

  testWidgets('Opções: cancelar atendimento tira a conversa', (t) async {
    await _abrir(t);
    await t.tap(find.text('Ana Martins'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel(RegExp('Opções da conversa')));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancelar atendimento'));
    await t.pumpAndSettle();
    expect(find.text('Cancelar muito baixa sua posição.'), findsOneWidget);
    await t.tap(find.text('Continuar atendimento'));
    await t.pumpAndSettle();
    expect(find.text('Cancelar atendimento?'), findsNothing);
    await t.tap(find.bySemanticsLabel(RegExp('Opções da conversa')));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancelar atendimento'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancelar atendimento').last);
    await t.pumpAndSettle();
    expect(find.text('Buscar conversa'), findsOneWidget);
    expect(find.text('Ana Martins'), findsNothing);
  });
}
