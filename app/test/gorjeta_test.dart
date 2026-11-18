import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/gorjeta.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/features/cliente/atividade/avaliar_page.dart';
import 'package:tatu/features/cliente/atividade/gorjeta.dart';

/// Gorjeta na avaliação (RN-141 a RN-143).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pump();
}

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

/// Abre a avaliação de um pedido concluído ainda sem avaliação.
Future<PedidoConcluido> _avaliar(WidgetTester t) async {
  final p = pedidos.concluidos.firstWhere((p) => p.minhaAvaliacao == null);
  await _abrir(t, AvaliarPage(pedido: p));
  await t.tap(find.bySemanticsLabel('5 estrelas'));
  await t.pump();
  return p;
}

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    gorjetas.restaurar();
    pedidos.restaurar();
    pagamentos.restaurar();
    conta.restaurar();
  });

  group('RN-141: limite e quando existe', () {
    test('acima de R\$ 100 é bloqueada', () {
      expect(RegrasGorjeta.valida(100), isTrue);
      expect(RegrasGorjeta.valida(101), isFalse);
      expect(RegrasGorjeta.valida(0), isFalse);
      expect(
        gorjetas.cobrar(
          cliente: 'Ana',
          profissional: 'Luiza Souza',
          valor: 150,
          cartao: 'Visa 4242',
          servicoConcluido: true,
        ),
        isNull,
      );
      expect(gorjetas.cobradas, isEmpty);
    });

    test('nunca antes do serviço concluído', () {
      expect(
        gorjetas.cobrar(
          cliente: 'Ana',
          profissional: 'Luiza Souza',
          valor: 5,
          cartao: 'Visa 4242',
          servicoConcluido: false,
        ),
        isNull,
      );
      expect(gorjetas.cobradas, isEmpty);
    });

    testWidgets('"Outro" acima de R\$ 100 não deixa usar', (t) async {
      await _abrir(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () => pedirOutroValorGorjeta(c),
            child: const Text('abrir'),
          ),
        ),
      );
      await t.tap(find.text('abrir'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), '150');
      await t.pump();
      expect(find.text('Até R\$ 100.'), findsWidgets);
      final b = t.widget<FilledButton>(find.byType(FilledButton));
      expect(b.onPressed, isNull);
      await t.enterText(find.byType(TextField), '15');
      await t.pump();
      expect(find.text('Usar R\$ 15'), findsOneWidget);
    });
  });

  group('RN-142: cobrança e repasse', () {
    testWidgets('sem gorjeta não cobra nada', (t) async {
      await _avaliar(t);
      expect(find.text('Quer pagar um café para a Luiza?'), findsOneWidget);
      expect(find.text('Enviar avaliação'), findsOneWidget);
      await t.tap(find.text('Enviar avaliação'));
      await t.pumpAndSettle();
      expect(gorjetas.cobradas, isEmpty);
      expect(gorjetas.avisos, isEmpty);
    });

    testWidgets('com R\$ 5: cobra no cartão padrão e avisa a profissional', (
      t,
    ) async {
      final p = await _avaliar(t);
      await t.tap(find.text('R\$ 5'));
      await t.pump();
      expect(find.text('Enviar avaliação e R\$ 5'), findsOneWidget);
      expect(
        find.text('Cobrado no Visa 4242 junto com a avaliação.'),
        findsOneWidget,
      );
      await t.tap(find.text('Enviar avaliação e R\$ 5'));
      await t.pumpAndSettle();
      expect(find.text('Obrigado!'), findsOneWidget);
      final g = gorjetas.cobradas.single;
      expect(g.valor, 5);
      expect(g.cartao, 'Visa 4242');
      expect(g.profissional, p.profissional);
      // RN-143: só uma notificação para o profissional.
      expect(gorjetas.avisos, ['Ana deixou R\$ 5 de gorjeta']);
      // RN-143: a gorjeta não muda a avaliação.
      final a = pedidos.atual(p).minhaAvaliacao!;
      expect(a.nota, 5);
    });

    testWidgets('tocar de novo no valor tira a gorjeta', (t) async {
      await _avaliar(t);
      await t.tap(find.text('R\$ 10'));
      await t.pump();
      await t.tap(find.text('R\$ 10'));
      await t.pump();
      expect(find.text('Enviar avaliação'), findsOneWidget);
    });

    test('repasse = valor − taxa do cartão (0% de comissão)', () {
      expect(RegrasGorjeta.comissaoTatu, 0);
      final g = gorjetas.cobrar(
        cliente: 'Ana',
        profissional: 'Luiza Souza',
        valor: 10,
        cartao: 'Visa 4242',
        servicoConcluido: true,
      )!;
      expect(g.repasse, 10 - RegrasGorjeta.taxa(10));
      expect(RegrasGorjeta.taxa(10), 10 * RegrasGorjeta.taxaCartao);
      // Vai no Pix com o próximo repasse.
      expect(gorjetas.proximoRepasse('Luiza Souza'), g.repasse);
    });
  });

  testWidgets('editar avaliação não oferece gorjeta', (t) async {
    final p = pedidos.concluidos.firstWhere((p) => p.minhaAvaliacao != null);
    await _abrir(t, AvaliarPage(pedido: p));
    expect(find.textContaining('café'), findsNothing);
  });
}
