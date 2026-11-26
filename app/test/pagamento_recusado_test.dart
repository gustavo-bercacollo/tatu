import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pagamento.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/features/cliente/home_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Pagamento recusado em cada etapa (RN-146, RN-222 a RN-226).

Future<void> _abrir(WidgetTester t, Widget tela, {Size? tamanho}) async {
  t.view.physicalSize = tamanho ?? const Size(430, 1100);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(theme: tatuTheme(), home: tela));
}

PlanoFixo _plano() {
  final p = planosFixos.pedir(
    cliente: conta.nomeCompleto,
    profissional: 'Júlia Costa',
    endereco: 'Rua A',
    frequencia: FrequenciaPlano.mensal,
    visitasPorSemana: 1,
    dias: const [5],
    horario: '9:00',
    profissao: 'Diarista',
  )!;
  planosFixos
    ..enviarValor(p, 150)
    ..confirmar(p, cartao: 'Visa 4242', inicio: DateTime(2026, 11, 23));
  return p;
}

void main() {
  setUp(() {
    conversas.restaurar();
    pagamentos.restaurar();
    pedidos.restaurar();
    planosFixos.restaurar();
    canalTatu.restaurar();
    conta.restaurar();
    PagamentosRepo.recusarReservas = false;
    PagamentosRepo.falharCobranca = false;
  });
  tearDown(() {
    PagamentosRepo.recusarReservas = false;
    PagamentosRepo.falharCobranca = false;
    simularPagamentoGarantido = null;
    pedidos.restaurar();
  });

  group('Regras', () {
    test('RN-223: reserva recusada não confirma; expira em 10 min', () {
      final c = conversas.conversas.first;
      PagamentosRepo.recusarReservas = true;
      final agora = clock.now();
      expect(conversas.confirmarValor(c), isFalse);
      final p = c.valor!.pagamento!;
      expect(p.situacao, SituacaoPagamento.recusado);
      expect(p.cartaoRecusado, 'Visa final 4242');
      expect(c.valor!.situacao, SituacaoValor.aguardandoVoce);
      conversas.conferirPagamento(
        c,
        agora: agora.add(const Duration(minutes: 9)),
      );
      expect(p.situacao, SituacaoPagamento.recusado);
      conversas.conferirPagamento(
        c,
        agora: agora
            .add(RegrasPagamento.prazoPagar)
            .add(const Duration(seconds: 1)),
      );
      expect(p.expirado, isTrue);
      // Expirado, não dá mais para confirmar.
      PagamentosRepo.recusarReservas = false;
      expect(conversas.confirmarValor(c), isFalse);
    });

    test('RN-224: Pix gerado vale 30 min; pago, garante o valor', () {
      final c = conversas.conversas.first;
      PagamentosRepo.recusarReservas = true;
      conversas
        ..confirmarValor(c)
        ..gerarPix(c);
      final p = c.valor!.pagamento!;
      expect(p.situacao, SituacaoPagamento.pixAguardando);
      expect(
        p.pixAte!.difference(clock.now()).inMinutes,
        closeTo(RegrasPagamento.validadePix.inMinutes, 1),
      );
      expect(conversas.confirmarValor(c, pix: true), isTrue);
      expect(c.valor!.pagamento!.garantido, isTrue);
      expect(c.valor!.situacao, SituacaoValor.confirmado);
    });

    test('RN-226: cobrança falha nas tentativas → pendência; cartão novo '
        'resolve', () {
      expect(pagamentos.cobrarAoConcluir(190), isTrue);
      expect(pagamentos.temPendencia, isFalse);
      PagamentosRepo.falharCobranca = true;
      expect(pagamentos.cobrarAoConcluir(190), isFalse);
      expect(pagamentos.pendencia, 190);
      PagamentosRepo.falharCobranca = false;
      pagamentos.definirPadrao(pagamentos.cartoes.last, true);
      expect(pagamentos.temPendencia, isFalse);
    });

    test('RN-146/RN-225: véspera reservada; recusada suspende', () {
      final p = _plano();
      final v = p.proximas.first;
      expect(planosFixos.reservarVespera(p, v), isTrue);
      expect(v.reservada, isTrue);

      final w = p.proximas.elementAt(1);
      PagamentosRepo.recusarReservas = true;
      expect(planosFixos.reservarVespera(p, w), isFalse);
      expect(w.situacao, SituacaoVisita.suspensa);
      expect(
        w.atualizarAte,
        DateTime(w.dia.year, w.dia.month, w.dia.day - 1, 20),
      );
      final dia = diaLongo(w.dia.weekday);
      final bc = p.barra(cliente: true)!;
      expect(bc.texto, 'Visita de $dia suspensa');
      expect(bc.direita, 'Atualizar');
      expect(bc.laranja, isTrue);
      final bp = p.barra(cliente: false)!;
      expect(bp.direita, 'Não precisa ir');
      expect(bp.laranja, isFalse);

      // Resolveu no prazo: volta e a profissional é avisada.
      PagamentosRepo.recusarReservas = false;
      final antes = canalTatu.profissional.mensagens.length;
      expect(
        planosFixos.atualizarPagamentoVisita(
          p,
          w,
          agora: w.atualizarAte!.subtract(const Duration(hours: 1)),
        ),
        isTrue,
      );
      expect(w.situacao, SituacaoVisita.agendada);
      expect(canalTatu.profissional.mensagens.length, antes + 1);
    });

    test('RN-225: sem resolver no prazo, não acontece (sem falta)', () {
      final p = _plano();
      final w = p.proximas.elementAt(1);
      PagamentosRepo.recusarReservas = true;
      planosFixos
        ..reservarVespera(p, w)
        ..conferirSuspensas(
          agora: w.atualizarAte!.add(const Duration(minutes: 1)),
        );
      expect(w.situacao, SituacaoVisita.semPagamento);
      expect(p.visitaSuspensa, isNull);
    });
  });

  group('Telas', () {
    testWidgets('C110/C111: cartão recusado → Pagar com Pix', (t) async {
      PagamentosRepo.recusarReservas = true;
      final c = conversas.conversas.first;
      await _abrir(t, ChatPage(conversa: c));
      await t.tap(find.text('Confirmar valor'));
      await t.pump();
      expect(find.text('Cartão recusado'), findsOneWidget);
      expect(find.text('Visa final 4242 · nada foi cobrado'), findsOneWidget);
      expect(find.text('Usar outro cartão'), findsOneWidget);
      // O atendimento fica parado (nada de acompanhamento).
      expect(c.valor!.situacao, SituacaoValor.aguardandoVoce);
      await t.tap(find.text('Pagar com Pix'));
      await t.pumpAndSettle();
      expect(find.text('Copiar código Pix'), findsOneWidget);
      expect(find.textContaining('Código vale 30 min · '), findsOneWidget);
      expect(find.textContaining('Não chega à Luiza antes.'), findsOneWidget);
      // A área de transferência do sistema (simulada).
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (_) async => null,
      );
      await t.tap(find.text('Copiar código Pix'));
      await t.pump();
      await t.pump();
      expect(find.text('Código Pix copiado'), findsOneWidget);
      // Fecha a folha (o prazo continua contando).
      Navigator.of(t.element(find.text('Copiar código Pix'))).pop();
      await t.pumpAndSettle();
    });

    testWidgets('C112: pendência na Home bloqueia pedido novo', (t) async {
      pagamentos.pendencia = 190;
      await _abrir(
        t,
        const HomeClientePage(),
        tamanho: const Size(1179 / 3, 852),
      );
      expect(find.text('Pagamento pendente'), findsOneWidget);
      expect(
        find.text('Atualize o cartão para fazer novos pedidos'),
        findsOneWidget,
      );
      await t.enterText(find.byType(TextField), 'o cano da pia está vazando');
      await t.pump(const Duration(milliseconds: 600));
      await t.tap(find.text('Chamar encanador'));
      await t.pumpAndSettle();
      expect(find.text('Atualizar cartão'), findsOneWidget);
    });

    testWidgets('P38/P39: aguardando o pagamento → garantido', (t) async {
      simularPagamentoGarantido = const Duration(seconds: 2);
      await _abrir(t, const ChatProfissionalPage());
      await t.tap(find.text('Enviar valor'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, '150');
      await t.pump();
      await t.tap(find.text('Enviar para Ana'));
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 3));
      await t.tap(find.text('Enviar outro valor'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).last, '130');
      await t.pump();
      await t.tap(find.text('Enviar para Ana'));
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 3)); // a Ana aceita
      expect(find.text('Aguardando o pagamento da Ana'), findsOneWidget);
      expect(find.textContaining('Não saia ainda.'), findsOneWidget);
      // Sem "Estou a caminho" antes do pagamento garantido.
      expect(
        find.widgetWithText(FilledButton, 'Estou a caminho'),
        findsNothing,
      );
      expect(find.textContaining('recusado'), findsNothing);
      await t.pump(const Duration(seconds: 2));
      expect(find.text('Pagamento garantido · pode ir'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Estou a caminho'),
        findsOneWidget,
      );
    });
  });
}
