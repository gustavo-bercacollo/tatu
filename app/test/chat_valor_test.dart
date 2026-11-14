import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';

Future<Conversa> _chat(WidgetTester t) async {
  t.view.physicalSize = const Size(430, 1100);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  conversas.restaurar();
  pagamentos.restaurar();
  final c = conversas.conversas.first;
  await t.pumpWidget(
    MaterialApp(theme: tatuTheme(), home: ChatPage(conversa: c)),
  );
  return c;
}

void main() {
  testWidgets('Valor recebido: confirmar reserva no cartão', (t) async {
    final c = await _chat(t);
    expect(find.text('Luiza enviou um valor'), findsOneWidget);
    expect(find.text('Visita R\$ 40 · Serviço R\$ 150'), findsOneWidget);
    expect(find.text('R\$ 190,00'), findsOneWidget);
    expect(find.text('Visa final 4242'), findsOneWidget);
    expect(find.text('Reservamos agora. Só cobramos no fim.'), findsOneWidget);
    await t.tap(find.text('Confirmar valor'));
    await t.pump();
    expect(c.valor!.situacao, SituacaoValor.confirmado);
    expect(find.text('Valor confirmado'), findsOneWidget);
    expect(find.text('Reservado no Visa 4242. Só cobramos no fim.'),
        findsOneWidget);
    // RN-76: confirmar começa o prazo da Luiza para sair.
    expect(pedidos.andamento?.etapasFeitas, 2);
    pedidos.restaurar(); // para os relógios do prazo
  });

  testWidgets('Trocar abre a forma de pagamento', (t) async {
    await _chat(t);
    await t.tap(find.text('Trocar'));
    await t.pumpAndSettle();
    expect(find.text('Pagamento'), findsWidgets);
  });

  testWidgets('Pedir outro valor: a profissional manda um novo', (t) async {
    final c = await _chat(t);
    await t.tap(find.text('Pedir outro valor'));
    await t.pumpAndSettle();
    expect(find.text('Quanto você quer pagar?'), findsOneWidget);
    expect(find.text('Valor 1 de 3'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '150');
    await t.pump();
    await t.tap(find.text('Enviar para a Luiza'));
    await t.pumpAndSettle();
    expect(find.text('Aguardando a Luiza'), findsOneWidget);
    expect(find.text('R\$ 150,00'), findsOneWidget);

    await t.pump(const Duration(seconds: 2));
    expect(c.valor!.rodada, 2);
    expect(find.text('R\$ 170,00'), findsOneWidget); // meio do caminho
    expect(find.text('Visita R\$ 40 · Serviço R\$ 130'), findsOneWidget);
    expect(find.text('Confirmar valor'), findsOneWidget);
  });
}
