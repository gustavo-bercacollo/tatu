import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/atendimento_profissional.dart';
import 'package:tatu/data/conta.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/pedidos.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/servico_profissional.dart';
import 'package:tatu/data/suspender_conta.dart';
import 'package:tatu/data/suspensao.dart';
import 'package:tatu/features/cliente/chamar/procurando_page.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/features/profissional/chamado/chat_profissional_page.dart';

/// Conta pausada ou suspensa com atendimentos em andamento (RN-128 a
/// RN-132).

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

/// Conversa à distância com valor confirmado e sinal guardado.
Conversa _distanciaComSinal() {
  final c = conversas.comecar(
    nome: 'Bia Lopes',
    profissao: 'Designer',
    feminino: true,
    servico: 'Designer',
    rua: 'À distância',
    distancia: true,
  );
  conversas.confirmarValor(c);
  return c;
}

void main() {
  setUpAll(_carregarInter);
  setUp(() {
    ProcurandoPage.aceitaEm = null;
    conversas.restaurar();
    pedidos.restaurar();
    conta.restaurar();
    profissional.restaurar();
    atendimentoProfissional.restaurar();
  });
  tearDown(() => ProcurandoPage.aceitaEm = const Duration(seconds: 8));

  group('RN-128: pausa não encerra atendimento', () {
    test('cliente pausado por ausências continua com o pedido', () {
      final antes = conversas.emAndamento.length;
      conta.pausarPorAusenciasParaDemo();
      final estado = estadoDaConta(
        pausada: conta.pausadaPorAusencias,
        suspensa: false,
      );
      expect(estado, EstadoConta.pausada);
      expect(RegrasSuspensao.encerraAtendimentos(estado), isFalse);
      expect(conversas.emAndamento.length, antes);
      expect(pedidos.andamento, isNotNull);
      expect(conversas.conversas.any((c) => c.encerrada), isFalse);
    });

    test('profissional pausado por abandonos continua o atendimento', () {
      atendimentoProfissional
        ..aceitar(chamadoExemplo)
        ..irAteCliente(const ServicoAceito());
      profissional.pausarPorAbandonosParaDemo();
      expect(profissional.pausada, isTrue);
      expect(
        RegrasSuspensao.encerraAtendimentos(
          estadoDaConta(pausada: profissional.pausada, suspensa: false),
        ),
        isFalse,
      );
      expect(atendimentoProfissional.ativo, isTrue);
      expect(atendimentoProfissional.etapa, EtapaAtendimento.aCaminho);
      expect(atendimentoProfissional.encerrados, isEmpty);
    });

    test('RN-129: só a suspensão encerra', () {
      expect(
        estadoDaConta(pausada: true, suspensa: true),
        EstadoConta.suspensa,
      );
      expect(
        RegrasSuspensao.encerraAtendimentos(EstadoConta.suspensa),
        isTrue,
      );
    });
  });

  group('RN-130: profissional suspenso', () {
    test('libera a reserva e devolve o sinal guardado', () {
      final c = _distanciaComSinal();
      final v = c.valor!;
      final e = profissionalSuspenso(c);
      expect(e.sinalDevolvido, v.sinal);
      expect(e.liberado, v.total - v.sinal);
      expect(e.cobrado, 0);
      expect(e.chamarOutro, isTrue);
      expect(
        e.mensagem,
        'A profissional não pode mais continuar este atendimento. '
        'Nada foi cobrado.',
      );
      // RN-132: só leitura, sem nome, histórico guardado.
      expect(c.encerrada, isTrue);
      expect(c.nomeVisivel, 'Conta indisponível');
      expect(c.emAndamento, isFalse);
      expect(c.mensagens, isNotEmpty);
    });

    test('pedido a caminho: a reserva inteira é liberada', () {
      final c = conversas.conversas.first; // Luiza, pedido a caminho
      final e = profissionalSuspenso(c);
      expect(e.liberado, c.valor!.total);
      expect(e.sinalDevolvido, 0);
      expect(pedidos.andamento, isNull);
    });

    test('com entrega, o sinal já é do profissional e não volta', () {
      final c = _distanciaComSinal();
      conversas.receberEntrega(c);
      final e = profissionalSuspenso(c);
      expect(e.sinalDevolvido, 0);
      expect(e.mensagem, isNot(contains('Nada foi cobrado')));
    });

    test('repasse de concluído há menos de 24 h fica em análise', () {
      final agora = DateTime(2026, 11, 17, 12);
      AtendimentoAberto concluido(Duration ha) => AtendimentoAberto(
        ponto: PontoAtendimento.concluido,
        visita: 40,
        servico: 150,
        concluidoEm: agora.subtract(ha),
      );
      expect(
        RegrasSuspensao.profissionalSuspenso(
          concluido(const Duration(hours: 23)),
          agora,
        ).repasseEmAnalise,
        isTrue,
      );
      expect(
        RegrasSuspensao.profissionalSuspenso(
          concluido(const Duration(hours: 25)),
          agora,
        ).repasseEmAnalise,
        isFalse,
      );
    });

    test('RN-132: parcelas futuras são canceladas', () {
      const a = AtendimentoAberto(
        ponto: PontoAtendimento.confirmado,
        servico: 1200,
        parcelas: 6,
      );
      expect(
        RegrasSuspensao.profissionalSuspenso(a, DateTime(2026))
            .parcelasCanceladas,
        6,
      );
      const pago = AtendimentoAberto(
        ponto: PontoAtendimento.concluido,
        servico: 1200,
        parcelas: 6,
      );
      expect(RegrasSuspensao.clienteSuspenso(pago).parcelasCanceladas, 0);
    });
  });

  group('RN-131: cliente suspenso', () {
    test('profissional a caminho recebe a visita da reserva', () {
      atendimentoProfissional
        ..aceitar(chamadoExemplo)
        ..irAteCliente(const ServicoAceito(visita: 40, valor: 150));
      final e = atendimentoProfissional.clienteSuspenso()!;
      expect(e.cobrado, 40);
      expect(e.liberado, 150);
      expect(
        e.mensagem,
        'Este atendimento foi encerrado pelo Tatu. '
        'Você recebe a visita de R\$ 40,00.',
      );
      expect(e.nota, 'Pode ficar online para novos chamados.');
      expect(atendimentoProfissional.ativo, isFalse);
      expect(
        atendimentoProfissional.encerrados[chamadoExemplo.cliente],
        same(e),
      );
    });

    test('a própria conta suspensa encerra tudo e cobra a visita', () {
      // Pedido de exemplo: a Luiza já está a caminho.
      final e = suspenderContaCliente();
      expect(e.first.cobrado, 40);
      expect(conversas.emAndamento, isEmpty);
      expect(pedidos.andamento, isNull);
    });

    test('ainda combinando: nada é cobrado', () {
      atendimentoProfissional.aceitar(chamadoExemplo);
      final e = atendimentoProfissional.clienteSuspenso()!;
      expect(e.cobrado, 0);
      expect(e.mensagem, 'Este atendimento foi encerrado pelo Tatu.');
    });

    test('concluído: recebe o serviço', () {
      final e = RegrasSuspensao.clienteSuspenso(
        const AtendimentoAberto(
          ponto: PontoAtendimento.concluido,
          visita: 40,
          servico: 150,
        ),
      );
      expect(e.mensagem, contains('Você recebe o serviço de R\$ 190,00.'));
    });
  });

  testWidgets('RN-130/RN-132: chat só leitura e chamar outro profissional', (
    t,
  ) async {
    final c = conversas.conversas.first;
    profissionalSuspenso(c);
    await _abrir(t, ChatPage(conversa: c));
    expect(find.text('Conta indisponível'), findsOneWidget);
    expect(find.text('Esta conversa foi encerrada.'), findsOneWidget);
    expect(find.text('Oi! Vi o vazamento, posso hoje.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await t.tap(find.text('Chamar outro profissional'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProcurandoPage), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('RN-131/RN-132: chat do profissional só leitura', (t) async {
    atendimentoProfissional
      ..aceitar(chamadoExemplo)
      ..irAteCliente(const ServicoAceito());
    atendimentoProfissional.clienteSuspenso();
    await _abrir(t, const ChatProfissionalPage());
    expect(find.text('Conta indisponível'), findsOneWidget);
    expect(
      find.textContaining('Você recebe a visita de R\$ 40,00.'),
      findsOneWidget,
    );
    expect(find.text('Esta conversa foi encerrada.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
