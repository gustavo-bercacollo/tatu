import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/encontrados.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/chamar/encontrado_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/chamar/som_encontrado.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

void main() {
  SomEncontrado.ativo = false;
  setUp(() {
    pedidos.restaurar();
    conversas.restaurar();
    reiniciarFila();
    ProcurandoPage.aceitaEm = const Duration(seconds: 8);
  });
  tearDown(() => ProcurandoPage.aceitaEm = null);

  testWidgets('A busca encontra a Luiza; Ver outro chama o Carlos', (t) async {
    pedidos.limpar(); // ninguém atendendo: a fila começa na Luiza
    await _abrir(
      t,
      const ProcurandoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
    );
    await t.pump(const Duration(seconds: 8));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Encontramos uma encanadora'), findsOneWidget);
    expect(find.text('Luiza Souza'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);
    expect(find.text(r'R$ 80 a R$ 250'), findsOneWidget);

    await t.pump(const Duration(seconds: 12));
    expect(find.text('2:48'), findsOneWidget);

    await t.tap(find.text('Ver outro'));
    await t.pumpAndSettle();
    expect(find.text('Ver outro profissional?'), findsOneWidget);
    expect(find.text('Ficar com a Luiza'), findsOneWidget);
    await t.tap(find.text('Ficar com a Luiza'));
    await t.pumpAndSettle();
    expect(find.text('Luiza Souza'), findsOneWidget);

    await t.tap(find.text('Ver outro'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver outro profissional'));
    await t.pumpAndSettle();
    expect(find.text('Encontramos um encanador'), findsOneWidget);
    expect(find.text('Carlos Pereira'), findsOneWidget);
    expect(find.text('Aceitar Carlos'), findsOneWidget);
  });

  testWidgets('O prazo acaba: chama o próximo da fila', (t) async {
    await _abrir(
      t,
      const EncontradoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
    );
    await t.pump(const Duration(seconds: 165));
    expect(find.text('0:15'), findsOneWidget);
    await t.pump(const Duration(seconds: 15));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Carlos Pereira'), findsOneWidget);
  });

  testWidgets('Aceitar abre o chat e vira o pedido em andamento', (t) async {
    await _abrir(
      t,
      const EncontradoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
    );
    await t.tap(find.text('Aceitar Luiza'));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byType(ChatPage), findsOneWidget);
    expect(pedidos.andamento?.profissional, 'Luiza Souza');
    expect(pedidos.andamento?.etapasFeitas, 1);
    expect(conversas.conversas.first.nome, 'Luiza Souza');
    // RN-87/RN-90: a conversa com a Luiza continua (nada some).
    expect(
      find.textContaining('Aceitei também o seu pedido de encanador'),
      findsOneWidget,
    );
    // RN-26: o chat já chega com o valor (visita + serviço).
    expect(find.text('Visita R\$ 40 · Serviço R\$ 150'), findsOneWidget);
    expect(conversas.conversas.first.valor?.total, 190);
  });

  testWidgets('Ver perfil mostra o perfil; Aceitar de lá abre o chat', (
    t,
  ) async {
    await _abrir(
      t,
      const EncontradoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
    );
    await t.tap(find.text('Ver perfil'));
    await t.pumpAndSettle();
    expect(find.text('Encanadora · 1,2 km de você'), findsOneWidget);
    // RN-219: a seção de selos vem antes das especialidades.
    expect(find.text('SELOS'), findsOneWidget);
    await t.scrollUntilVisible(
      find.text('Vazamentos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Vazamentos'), findsOneWidget);
    expect(find.text('Aceitar Luiza'), findsOneWidget);
    await t.tap(find.text('Aceitar Luiza'));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byType(ChatPage), findsOneWidget);
    expect(pedidos.andamento?.profissional, 'Luiza Souza');
  });

  testWidgets('Ver outro no perfil pergunta e chama o próximo', (t) async {
    await _abrir(
      t,
      const EncontradoPage(servico: 'Encanador', endereco: 'Rua A, 1'),
    );
    await t.tap(find.text('Ver perfil'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver outro'));
    await t.pumpAndSettle();
    await t.tap(find.text('Ver outro profissional'));
    await t.pumpAndSettle();
    expect(find.text('Carlos Pereira'), findsOneWidget);
  });
}
