import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/conversas_profissional.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/regras_valor.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';
import 'package:tatu/features/profissional/servico/andamento_page.dart';

/// Conversa contínua e parcelamento (RN-42, RN-87 a RN-91).

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1179, 2556); // 393×852
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
  await t.pumpAndSettle();
}

Conversa _rafael() =>
    conversas.conversas.firstWhere((c) => c.nome == 'Rafael Lima');

Future<void> _carregarInter() async {
  final f = FontLoader('Inter');
  for (final p in ['400', '500', '600', '700']) {
    f.addFont(rootBundle.load('assets/fonts/Inter-$p.ttf'));
  }
  await f.load();
}

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    conversas.restaurar();
    conversasProfissional.restaurar();
    pagamentos.restaurar();
    profissional.demo();
    atendimentoProfissional.restaurar();
  });

  group('RegrasValor', () {
    test('RN-91: parcela a partir de R\$ 300, até 6x', () {
      expect(RegrasValor.podeParcelar(299.99), isFalse);
      expect(RegrasValor.podeParcelar(300), isTrue);
      expect(RegrasValor.maxParcelas, 6);
      expect(RegrasValor.opcoesParcelas, [1, 3, 6]);
    });

    test('RN-89: valor aberto vence depois de 7 dias', () {
      final agora = DateTime(2026, 11, 14);
      expect(
        RegrasValor.vencido(agora.subtract(const Duration(days: 6)), agora),
        isFalse,
      );
      expect(
        RegrasValor.vencido(agora.subtract(const Duration(days: 8)), agora),
        isTrue,
      );
    });
  });

  testWidgets('RN-42: a conversa continua depois do serviço', (t) async {
    await _abrir(t, ChatPage(conversa: _rafael()));
    expect(find.text('Serviço concluído · R\$ 220,00 · 02 nov'), findsOneWidget);
    expect(find.text('12 nov'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Esta conversa foi encerrada'), findsNothing);
  });

  testWidgets('RN-87 e RN-91: novo valor parcelado em 6x', (t) async {
    await _abrir(t, ChatPage(conversa: _rafael()));
    await t.scrollUntilVisible(
      find.text('Confirmar valor'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.textContaining('Rafael enviou um novo valor · '), findsOneWidget);
    expect(find.text('Novo serviço · troca do quadro de luz'), findsOneWidget);
    expect(find.text('R\$ 1.200,00'), findsOneWidget);
    expect(find.text('À vista'), findsOneWidget);

    await t.ensureVisible(find.text('Mudar'));
    await t.pumpAndSettle();
    await t.tap(find.text('Mudar'));
    await t.pumpAndSettle();
    expect(find.text('Parcelar R\$ 1.200,00'), findsOneWidget);
    expect(find.text('6 parcelas de R\$ 200,00'), findsOneWidget);
    expect(find.text('Parcelamento a partir de R\$ 300,00.'), findsOneWidget);
    await t.tap(find.text('6x'));
    await t.pump();
    await t.tap(find.text('Usar 6x'));
    await t.pumpAndSettle();
    expect(find.text('Em 6x de R\$ 200,00'), findsOneWidget);
    expect(_rafael().valor?.parcelas, 6);

    await t.tap(find.text('Confirmar valor'));
    await t.pumpAndSettle();
    expect(find.text('Valor confirmado'), findsOneWidget);
    expect(find.text('Em 6x de R\$ 200,00'), findsOneWidget);
  });

  testWidgets('RN-91: abaixo de R\$ 300 não parcela', (t) async {
    await _abrir(t, ChatPage(conversa: conversas.emAndamento.first));
    await t.scrollUntilVisible(
      find.text('Confirmar valor'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Mudar'), findsNothing);
  });

  testWidgets('RN-87 e RN-88: profissional envia novo valor com a taxa', (
    t,
  ) async {
    final c = conversasProfissional.anteriores.first;
    await _abrir(
      t,
      ChatProfissionalPage(
        chamado: c.chamado,
        concluidoPor: c.concluidaPor,
        concluidoEm: c.concluidaEm,
        depois: c.depois,
        diaDepois: c.diaDepois,
      ),
    );
    await t.tap(find.text('Enviar novo valor'));
    await t.pumpAndSettle();
    expect(find.text('Quanto vai custar?'), findsOneWidget);
    expect(find.text('Taxa do Tatu (10%)'), findsOneWidget);
  });

  test('RN-90: valor em aberto não impede ficar online', () {
    atendimentoProfissional.aceitar(chamadoExemplo);
    profissional.ficarOnline(true);
    expect(atendimentoProfissional.ativo, isTrue);
    expect(profissional.online, isTrue);
  });

  testWidgets('RN-89: aviso de valor aberto há mais de 7 dias', (t) async {
    await _abrir(
      t,
      EmAndamentoPage(
        inicio: DateTime.now().subtract(const Duration(days: 8)),
      ),
    );
    expect(find.textContaining('aberto há mais de 7 dias'), findsOneWidget);
    await _abrir(t, EmAndamentoPage(inicio: DateTime.now()));
    expect(find.textContaining('aberto há mais de 7 dias'), findsNothing);
  });
}
