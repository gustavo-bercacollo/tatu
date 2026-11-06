import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/features/cliente/pagamento/novo_cartao_page.dart';
import 'package:tatu/features/cliente/perfil_page.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  pagamentos.restaurar();
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

Future<void> _preencher(WidgetTester t, String numero) async {
  final campos = find.byType(TextField);
  await t.enterText(campos.at(0), numero);
  await t.enterText(campos.at(1), '0828');
  await t.enterText(campos.at(2), '123');
  await t.enterText(campos.at(3), 'Ana Martins');
  await t.enterText(campos.at(4), '12345678900');
  await t.pump();
}

FilledButton _botao(WidgetTester t, String texto) =>
    t.widget(find.widgetWithText(FilledButton, texto));

void main() {
  testWidgets('Perfil → Pagamento mostra os cartões e o padrão', (t) async {
    await _abrir(t, const PerfilClientePage());
    expect(find.text('Visa 4242'), findsOneWidget);
    await t.tap(find.text('Pagamento'));
    await t.pumpAndSettle();
    expect(find.text('Visa final 4242'), findsOneWidget);
    expect(find.text('Padrão'), findsOneWidget);
    expect(find.text('Mastercard final 1881'), findsOneWidget);
    expect(find.text('Pix'), findsOneWidget);
  });

  testWidgets('Novo cartão: formata, valida e salva', (t) async {
    await _abrir(t, NovoCartaoPage(agora: DateTime(2026, 11, 5)));
    expect(_botao(t, 'Salvar cartão').onPressed, isNull);
    await _preencher(t, '5555444433331111');
    final numero = t.widget<TextField>(find.byType(TextField).at(0));
    expect(numero.controller!.text, '5555 4444 3333 1111');
    expect(_botao(t, 'Salvar cartão').onPressed, isNotNull);

    // Validade vencida não passa.
    await t.enterText(find.byType(TextField).at(1), '0125');
    await t.pump();
    expect(_botao(t, 'Salvar cartão').onPressed, isNull);
    await t.enterText(find.byType(TextField).at(1), '0828');
    await t.pump();

    await t.tap(find.text('Salvar cartão'));
    await t.pump();
    expect(pagamentos.cartoes.length, 3);
    expect(pagamentos.padrao!.titulo, 'Mastercard final 1111');
  });

  testWidgets('Banco recusa: aviso, botão "Tentar de novo"', (t) async {
    await _abrir(t, NovoCartaoPage(agora: DateTime(2026, 11, 5)));
    await _preencher(t, '4000000000000002');
    await t.tap(find.text('Salvar cartão'));
    await t.pump();
    expect(find.text('Cartão recusado'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Ler cartão com a câmera'), findsNothing);
    expect(pagamentos.cartoes.length, 2);
  });

  testWidgets('Detalhe: remover pede confirmação; sem cartões fica vazio', (
    t,
  ) async {
    await _abrir(t, const PerfilClientePage());
    await t.tap(find.text('Pagamento'));
    await t.pumpAndSettle();

    for (final titulo in ['Visa final 4242', 'Mastercard final 1881']) {
      await t.tap(find.text(titulo));
      await t.pumpAndSettle();
      await t.tap(find.text('Remover cartão'));
      await t.pumpAndSettle();
      expect(find.text('Remover este cartão?'), findsOneWidget);
      await t.tap(find.text('Remover cartão').last);
      await t.pumpAndSettle();
    }
    expect(find.text('Nenhuma forma de pagamento'), findsOneWidget);
    expect(pagamentos.padrao, isNull);
  });
}
