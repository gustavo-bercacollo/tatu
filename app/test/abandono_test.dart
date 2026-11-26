import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/navegacao.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/prazos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/features/cliente/atividade/pedido_andamento_page.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/chamado/toque_chamado.dart';
import 'package:tatu/features/profissional/home/home_profissional_page.dart';

/// Profissional que aceita e não aparece (RN-76 a RN-79).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

/// Chat do profissional até o valor combinado (aceita a proposta da Ana).
Future<void> _combinar(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: const ChatProfissionalPage()),
  );
  await t.tap(find.text('Enviar valor'));
  await t.pumpAndSettle();
  await t.enterText(find.byType(TextField).last, '150');
  await t.pump();
  await t.tap(find.text('Enviar para Ana'));
  await t.pumpAndSettle();
  await t.pump(const Duration(seconds: 3));
  await t.tap(find.text('Aceitar R\$ 120,00'));
  await t.pump();
  expect(find.text('Pagamento garantido · pode ir'), findsOneWidget);
}

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter');
    for (final w in [400, 500, 600, 700]) {
      inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
    await inter.load();
  });
  // Nos testes, o relógio do app anda no tempo real.
  Prazos.aceleracao = 1;
  ProcurandoPage.aceitaEm = null;
  ToqueChamado.ativo = false;

  setUp(() {
    navegacao.restaurar();
    pedidos.restaurar();
    profissional.demo();
  });

  group('Profissional', () {
    testWidgets('RN-76/77: sem "Estou a caminho", pergunta e devolve', (
      t,
    ) async {
      await _combinar(t);
      await t.pump(const Duration(minutes: 9));
      expect(find.text('Ainda vai até a Ana?'), findsNothing);
      await t.pump(const Duration(minutes: 1));
      await t.pumpAndSettle();
      expect(find.text('Ainda vai até a Ana?'), findsOneWidget);
      expect(find.textContaining('Sem resposta em 5:00'), findsOneWidget);
      await t.pump(const Duration(seconds: 8));
      expect(find.textContaining('Sem resposta em 4:52'), findsOneWidget);

      // Sem resposta em 5 min: volta à busca e conta como abandono.
      await t.pump(const Duration(minutes: 5));
      await t.pumpAndSettle();
      expect(find.text('O chamado voltou à busca'), findsOneWidget);
      expect(find.textContaining('1 de 3 nos últimos 30 dias'), findsOneWidget);
      expect(profissional.abandonosRecentes, 1);
    });

    testWidgets('"Não consigo ir" devolve na hora', (t) async {
      await _combinar(t);
      await t.pump(const Duration(minutes: 10));
      await t.pumpAndSettle();
      await t.tap(find.text('Não consigo ir'));
      await t.pumpAndSettle();
      expect(find.textContaining('não consegue ir'), findsOneWidget);
      expect(profissional.abandonosRecentes, 1);
    });

    testWidgets('"Sim, estou saindo" vai para A caminho', (t) async {
      await _combinar(t);
      await t.pump(const Duration(minutes: 10));
      await t.pumpAndSettle();
      await t.tap(find.text('Sim, estou saindo'));
      await t.pumpAndSettle();
      expect(find.textContaining('A caminho d'), findsOneWidget);
      expect(profissional.abandonosRecentes, 0);
    });

    testWidgets('RN-79: 3 abandonos em 30 dias pausam a conta', (t) async {
      profissional.pausarPorAbandonosParaDemo();
      await _abrir(t, const HomeProfissionalPage());
      expect(find.text('Conta pausada'), findsOneWidget);
      expect(
        find.textContaining('3 chamados abandonados em 30 dias.'),
        findsOneWidget,
      );
      await t.tap(find.text('Ficar online'));
      await t.pump();
      expect(profissional.online, isFalse);
    });
  });

  group('Cliente', () {
    PedidoAndamento combinado() => const PedidoAndamento(
      servico: 'Encanador',
      profissao: 'Encanadora',
      profissional: 'Luiza Souza',
      nota: '4,9',
      endereco: 'Rua das Flores, 120',
      valor: r'R$ 190,00',
      pagamento: 'Visa 4242',
      etapasFeitas: 1,
    );

    testWidgets('RN-76/77: ainda não saiu → volta à busca sem cobrar', (
      t,
    ) async {
      pedidos.aceitar(combinado());
      pedidos.valorConfirmado();
      await _abrir(t, const PedidoAndamentoPage());
      expect(find.text('A Luiza ainda não saiu'), findsNothing);

      await t.pump(const Duration(minutes: 10));
      await t.pump();
      expect(find.text('A Luiza ainda não saiu'), findsOneWidget);
      expect(find.text('Ainda não saiu'), findsOneWidget);

      await t.pump(const Duration(minutes: 5));
      // A busca tem animação sem fim: avança só o necessário.
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Chamando outro encanador'), findsOneWidget);
      expect(
        find.text('A Luiza não confirmou que vinha.\nNada foi cobrado.'),
        findsOneWidget,
      );
      // RN-90: sai só este pedido; o que já existia continua.
      expect(pedidos.andamentos, hasLength(1));
      await t.tap(find.text('Cancelar pedido'));
      await t.pump(const Duration(milliseconds: 600));
    });

    testWidgets('RN-78: atrasou o dobro → chamar outro sem custo', (t) async {
      await _abrir(t, const PedidoAndamentoPage());
      // Previsto 12 min; o aviso vem com 24 min (o dobro).
      await t.pump(const Duration(minutes: 23));
      expect(find.text('A Luiza está atrasada'), findsNothing);
      await t.pump(const Duration(minutes: 1, seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('A Luiza está atrasada'), findsOneWidget);
      expect(find.text('Era para chegar há 12 minutos.\n'
          'Você pode chamar outro sem pagar nada.'), findsOneWidget);
      await t.tap(find.text('Chamar outro encanador'));
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('A Luiza está atrasada.\nNada foi cobrado.'),
          findsOneWidget);
      expect(pedidos.andamento, isNull);
      await t.tap(find.text('Cancelar pedido'));
      await t.pump(const Duration(milliseconds: 600));
    });

    testWidgets('"Continuar esperando" não pergunta de novo', (t) async {
      await _abrir(t, const PedidoAndamentoPage());
      await t.pump(const Duration(minutes: 25));
      await t.pumpAndSettle();
      await t.tap(find.text('Continuar esperando'));
      await t.pumpAndSettle();
      await t.pump(const Duration(minutes: 5));
      await t.pumpAndSettle();
      expect(find.text('A Luiza está atrasada'), findsNothing);
      expect(pedidos.andamento?.esperandoAtraso, isTrue);
      pedidos.restaurar(); // RN-80: ela chegou; para o relógio da espera
    });
  });
}
