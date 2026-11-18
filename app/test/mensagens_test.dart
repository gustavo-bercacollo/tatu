import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/perfil.dart';
import 'package:tatu/features/cliente/home_page.dart';

Future<void> _abrirMensagens(WidgetTester t) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const HomeClientePage()),
  );
  await t.tap(find.text('Mensagens'));
  await t.pumpAndSettle();
}

Future<void> _abrirLuiza(WidgetTester t) async {
  await _abrirMensagens(t);
  await t.tap(find.text('Luiza Souza'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    conversas.restaurar();
    perfil.restaurar();
  });

  testWidgets('Lista: grupos, busca e não lidas', (t) async {
    await _abrirMensagens(t);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Anteriores'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'marcos');
    await t.pump();
    expect(find.text('Marcos Dias'), findsOneWidget);
    expect(find.text('Luiza Souza'), findsNothing);
  });

  testWidgets('Chat: envia mensagem e lê as não lidas', (t) async {
    await _abrirLuiza(t);
    expect(
      find.text(
        'Você aceitou a Luiza. Combinem os detalhes e o valor por aqui.',
      ),
      findsOneWidget,
    );
    await t.enterText(find.byType(TextField), 'Pode ser às 15h?');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pump();
    expect(find.text('Pode ser às 15h?'), findsOneWidget);
    expect(conversas.conversas.first.naoLidas, 0);
  });

  testWidgets('Sem internet: não enviada e tentar de novo', (t) async {
    conversas.definirSemInternet(true);
    await _abrirLuiza(t);
    await t.enterText(find.byType(TextField), 'Pode ser às 15h?');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pump();
    expect(find.text('Sem internet. Reconectando...'), findsOneWidget);
    expect(find.text('Não enviada · Tentar de novo'), findsOneWidget);

    conversas.definirSemInternet(false);
    await t.tap(find.text('Não enviada · Tentar de novo'));
    await t.pump();
    expect(find.text('Não enviada · Tentar de novo'), findsNothing);
  });

  testWidgets('Foto da galeria aparece como enviada', (t) async {
    final bytes = File('assets/avatares/avatar-2.png').readAsBytesSync();
    perfil.escolherImagem = (_) async => bytes;
    await _abrirLuiza(t);
    await t.tap(find.bySemanticsLabel('Enviar foto'));
    await t.pumpAndSettle();
    await t.tap(find.text('Escolher da galeria'));
    await t.pumpAndSettle();
    expect(find.textContaining('Enviada · '), findsOneWidget);
  });

  testWidgets('Menu → Denunciar → Denúncia enviada → volta', (t) async {
    await _abrirLuiza(t);
    await t.tap(find.bySemanticsLabel(RegExp('^Opções da conversa')));
    await t.pumpAndSettle();
    // RN-140: sem valor confirmado não existe ligar.
    expect(find.text('Ligar para Luiza'), findsNothing);
    await t.tap(find.text('Denunciar'));
    await t.pumpAndSettle();
    expect(find.text('Denunciar Luiza'), findsOneWidget);
    await t.tap(find.text('Perfil falso'));
    await t.pump();
    await t.tap(find.text('Enviar denúncia'));
    await t.pumpAndSettle();
    expect(find.text('Denúncia enviada'), findsOneWidget);
    await t.tap(find.text('Voltar para a conversa'));
    await t.pumpAndSettle();
    expect(find.text('Chego em 12 min.'), findsOneWidget);
  });

  // RN-42: a conversa continua aberta depois do serviço.
  testWidgets('Conversa anterior continua aberta; lista vazia', (t) async {
    await _abrirMensagens(t);
    await t.tap(find.text('Rafael Lima'));
    await t.pumpAndSettle();
    expect(find.text('Serviço concluído · R\$ 220,00 · 02 nov'), findsOneWidget);
    expect(
      find.text(
        'A conversa continua aberta. Precisou de novo, é só chamar por aqui.',
      ),
      findsOneWidget,
    );
    expect(find.text('Esta conversa foi encerrada'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);

    conversas.limpar();
    await t.tap(find.bySemanticsLabel('Voltar'));
    await t.pumpAndSettle();
    // RN-115: sem conversas, o canal do Tatu continua fixado.
    expect(find.text('Tatu'), findsOneWidget);
    expect(
      find.text('Quando você aceitar um profissional,\na conversa aparece aqui.'),
      findsOneWidget,
    );
  });
}
