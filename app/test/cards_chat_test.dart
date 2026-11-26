import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/regras_valor.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/features/cliente/mensagens/cartao_valor.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';

/// Ajustes no chat (RN-229, RN-230, RN-231).

Future<void> _abrir(WidgetTester t, Conversa c, {double altura = 1100}) async {
  t.view.physicalSize = Size(430, altura);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: tatuTheme(),
      home: ChatPage(conversa: c),
    ),
  );
  await t.pump();
}

Conversa get _luiza => conversas.conversas.first;

void main() {
  setUp(() {
    conversas.restaurar();
    pagamentos.restaurar();
    pedidos.restaurar();
    retornos.restaurar();
    conta.restaurar();
  });
  tearDown(pedidos.restaurar);

  group('RN-229: validade', () {
    test('30 min no imediato; 24 h à distância', () {
      expect(
        ValorProposta(visita: 40, servico: 150).validade,
        RegrasValor.validadeImediata,
      );
      expect(
        ValorProposta(visita: 0, servico: 150, distancia: true).validade,
        RegrasValor.validadeAgendada,
      );
    });

    test('passou da validade: expira e não confirma mais', () {
      final c = _luiza;
      final v = c.valor!;
      conversas.conferirValidade(
        c,
        agora: v.valeAte.subtract(const Duration(minutes: 1)),
      );
      expect(v.situacao, SituacaoValor.aguardandoVoce);
      conversas.conferirValidade(
        c,
        agora: v.valeAte.add(const Duration(seconds: 1)),
      );
      expect(v.situacao, SituacaoValor.expirado);
      expect(conversas.confirmarValor(c), isFalse);
    });

    test('novo valor da mesma pessoa: o anterior expira no lugar dele', () {
      final c = _luiza;
      final antes = c.valor!..ancora = 2;
      conversas
        ..pedirOutroValor(c, 150)
        ..profissionalResponde(c);
      expect(c.valoresExpirados, hasLength(1));
      expect(c.valoresExpirados.single.total, antes.total);
      expect(c.valoresExpirados.single.ancora, 2);
      expect(c.valor!.ancora, c.mensagens.length);
      expect(c.valor!.situacao, SituacaoValor.aguardandoVoce);
    });

    test('pedido cancelado: o valor em aberto expira', () {
      final c = _luiza;
      conversas.expirarPorCancelamento(c);
      expect(c.valor!.situacao, SituacaoValor.expirado);
    });

    test('"Pedir de novo" avisa e o profissional reenvia', () {
      final c = _luiza;
      conversas
        ..expirarPorCancelamento(c)
        ..pedirValorDeNovo(c);
      expect(c.mensagens.last.marcador, 'Você pediu um novo valor à Luiza');
      conversas.profissionalReenviaValor(c);
      expect(c.valor!.situacao, SituacaoValor.aguardandoVoce);
      expect(c.valoresExpirados, hasLength(1));
    });
  });

  group('Telas', () {
    testWidgets('C112: "Vale até" no card e a hora do envio', (t) async {
      await _abrir(t, _luiza);
      final v = _luiza.valor!;
      expect(find.text('Vale até ${horaMinuto(v.valeAte)}'), findsOneWidget);
      expect(
        find.text('Luiza enviou um valor · ${horaMinuto(v.enviadoEm)}'),
        findsOneWidget,
      );
    });

    testWidgets('C114: expirado vira linha cinza com "Pedir de novo"', (
      t,
    ) async {
      final c = _luiza;
      conversas.conferirValidade(
        c,
        agora: c.valor!.valeAte.add(const Duration(minutes: 1)),
      );
      await _abrir(t, c);
      expect(find.byType(CartaoValorExpirado), findsOneWidget);
      expect(find.textContaining('Valor expirado · '), findsOneWidget);
      expect(find.text('Confirmar valor'), findsNothing);
      await t.tap(find.text('Pedir de novo'));
      await t.pump();
      expect(c.mensagens.last.marcador, 'Você pediu um novo valor à Luiza');
    });

    testWidgets('C113: o card fica no lugar e a barra leva até ele', (t) async {
      final c = _luiza;
      await _abrir(t, c, altura: 800);
      for (var i = 0; i < 12; i++) {
        await t.enterText(find.byType(TextField), 'Mensagem $i');
        await t.testTextInput.receiveAction(TextInputAction.send);
        await t.pump();
        await t.pump();
      }
      // As mensagens novas vêm depois do card (não abaixo dele preso).
      expect(find.text('Mensagem 11'), findsOneWidget);
      expect(find.text('Confirmar valor'), findsNothing);
      await t.pump();
      expect(find.textContaining('Valor pendente · '), findsOneWidget);
      await t.tap(find.textContaining('Valor pendente · '));
      await t.pumpAndSettle();
      expect(find.text('Confirmar valor'), findsOneWidget);
      await t.pump();
      expect(find.textContaining('Valor pendente · '), findsNothing);
    });

    testWidgets('C250/C252: um card só do retorno, que muda de estado', (
      t,
    ) async {
      final c = _luiza;
      final r = retornos.pedir(
        PedidoRetorno(
          servico: '#TT-5',
          servicoNome: 'Encanador',
          descricaoServico: 'Vazamento na pia',
          diaServico: '04 nov',
          profissional: c.nome,
          profissionalFeminino: true,
          cliente: conta.nomeCompleto,
          clienteFeminina: true,
          valorServico: 150,
          descricao: 'A pia voltou a vazar no mesmo cano.',
          fotos: [],
          pedidoEm: clock.now(),
          retido: false,
          horarios: [
            OpcaoHorario(
              clock.now().add(const Duration(days: 2)),
              PeriodoDia.manha,
            ),
          ],
        ),
      )!;
      await _abrir(t, c, altura: 1600);
      expect(find.text('Pedido de retorno'), findsOneWidget);
      expect(find.text('Encanadora · serviço de 04 nov'), findsOneWidget);
      expect(find.text('Aguardando'), findsOneWidget);
      expect(
        find.text('“A pia voltou a vazar no mesmo cano.”'),
        findsOneWidget,
      );
      expect(find.textContaining('A Luiza responde até'), findsOneWidget);
      expect(find.textContaining('Você pode: '), findsOneWidget);

      final quando = r.horarios.first.as(9);
      retornos.aceitar(r, quando);
      await t.pump();
      expect(find.text('Aceito'), findsOneWidget);
      expect(find.text(quandoRetorno(quando)), findsOneWidget);
      expect(find.text('Sem custo'), findsOneWidget);
      expect(find.text('Remarcar'), findsOneWidget);
      // Sem o bloco verde solto; a aceitação vira um aviso pequeno.
      expect(find.text('Retorno aceito · sem custo'), findsNothing);
      expect(
        find.text('A Luiza aceitou · ${quandoCurto(quando)}'),
        findsOneWidget,
      );
    });
  });
}
