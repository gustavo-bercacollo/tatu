import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/avaliacao_valida.dart';
import 'package:tatu/data/base_tecnica.dart';
import 'package:tatu/data/canal_tatu.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/data/limites.dart';
import 'package:tatu/data/limites_uso.dart';
import 'package:tatu/data/pagamentos.dart';
import 'package:tatu/data/pausa_conta.dart';
import 'package:tatu/data/plano_fixo.dart';
import 'package:tatu/data/profissional.dart';
import 'package:tatu/data/atendimento_profissional.dart';

/// Auditoria (v52): limites e base técnica (RN-237 a RN-249).
void main() {
  setUp(() {
    conversas.restaurar();
    pagamentos.restaurar();
    planosFixos.restaurar();
    canalTatu.restaurar();
    profissional.restaurar();
  });

  test('RN-237: "Pedir de novo" uma vez por card', () {
    final c = conversas.conversas.first;
    conversas.expirarPorCancelamento(c);
    expect(conversas.pedirValorDeNovo(c), isTrue);
    expect(conversas.pedirValorDeNovo(c), isFalse);
    expect(c.valor!.pedidoDeNovo, isTrue);
  });

  test('RN-238: "Sem acordo" bloqueia a mesma pessoa por 24 h', () {
    final c = conversas.conversas.first;
    final agora = DateTime(2026, 11, 26, 10);
    conversas.recusarValor(c, agora: agora);
    expect(
      conversas.chamarDeNovoEm(c.nome, agora: agora),
      agora.add(const Duration(hours: 24)),
    );
    expect(
      conversas.chamarDeNovoEm(
        c.nome,
        agora: agora.add(const Duration(hours: 25)),
      ),
      isNull,
    );
  });

  test('RN-240: um novo valor por vez; 2 recusados desativam', () {
    final a = atendimentoProfissional;
    expect(a.enviarNovoValor(), isTrue);
    expect(a.enviarNovoValor(), isFalse); // já tem um pendente
    a.respostaNovoValor(aceito: false);
    expect(a.enviarNovoValor(), isTrue);
    a.respostaNovoValor(aceito: false);
    expect(a.podeEnviarNovoValor, isFalse);
    expect(
      a.avisoNovoValor(cliente: 'Ana', feminino: true),
      'A Ana recusou 2 valores. Conclua o combinado ou encerre cobrando a '
      'visita.',
    );
    a.encerrar();
  });

  test('RN-244: 1ª pausa volta em 7 dias, 2ª em 30, 3ª espera o suporte', () {
    final p = PausasConta();
    final t0 = DateTime(2026, 1, 1);
    final a = p.abrir(t0, CausaPausa.abandonos, 'x');
    expect(a.voltaEm, t0.add(const Duration(days: 7)));
    final t1 = t0.add(const Duration(days: 20));
    final b = p.abrir(t1, CausaPausa.abandonos, 'x');
    expect(b.ordem, 2);
    expect(b.voltaEm, t1.add(const Duration(days: 30)));
    final t2 = t1.add(const Duration(days: 40));
    final c = p.abrir(t2, CausaPausa.abandonos, 'x');
    expect(c.ordem, 3);
    expect(c.esperaSuporte, isTrue);
    expect(c.quandoVolta, 'Sua conta fica parada até o suporte analisar.');
  });

  test('RN-244: a conta do profissional volta sozinha e começa do zero', () {
    final t0 = DateTime(2026, 11, 20, 9);
    withClock(Clock.fixed(t0), profissional.pausarPorAbandonosParaDemo);
    expect(withClock(Clock.fixed(t0), () => profissional.pausada), isTrue);
    expect(
      withClock(
        Clock.fixed(t0.add(const Duration(days: 8))),
        () => profissional.pausada,
      ),
      isFalse,
    );
  });

  test('RN-242: 2 semanas sem visita avisa; 3ª pausa; pausa até 60 dias', () {
    final agora = DateTime(2026, 11, 24, 8);
    withClock(Clock.fixed(agora), () {
      final p = planosFixos.pedir(
        cliente: 'Ana Martins',
        profissional: 'Júlia Costa',
        endereco: 'Rua das Flores, 120',
        frequencia: FrequenciaPlano.mensal,
        visitasPorSemana: 1,
        dias: [DateTime.tuesday],
        horario: '9:00',
        profissao: 'Diarista',
        agora: agora,
      )!;
      planosFixos
        ..enviarValor(p, 150)
        ..confirmar(p, cartao: 'Visa 4242', inicio: agora);
      final semanas = p.visitas.take(3).toList();
      planosFixos.naoVou(p, semanas[0]);
      planosFixos.naoVou(p, semanas[1]);
      expect(
        canalTatu.cliente.mensagens.last.resumo,
        'A Júlia não vem há 2 semanas',
      );
      expect(canalTatu.cliente.mensagens.last.cartao?.botao, 'Pausar plano');
      expect(canalTatu.cliente.mensagens.last.link?.texto, 'Encerrar plano');
      planosFixos.naoVou(p, semanas[2]);
      expect(p.status, StatusPlano.pausado);
      final fim = p.fimDaPausa!;
      planosFixos.conferirPausas(agora: fim.subtract(const Duration(days: 6)));
      expect(
        canalTatu.cliente.mensagens.last.resumo,
        'O plano pausado termina em ${diaMes(fim)}',
      );
      planosFixos.conferirPausas(agora: fim);
      expect(p.status, StatusPlano.cancelado);
    });
  });

  test('RN-248: código, cartões e pedidos', () {
    final t = DateTime(2026, 11, 26, 10);
    for (var i = 0; i < 3; i++) {
      expect(limitesUso.enviarCodigo('11999990000', agora: t), isTrue);
    }
    expect(limitesUso.enviarCodigo('11999990000', agora: t), isFalse);
    // Também por aparelho: outro número no mesmo aparelho.
    expect(limitesUso.enviarCodigo('11888880000', agora: t), isFalse);
    expect(
      limitesUso.enviarCodigo(
        '11999990000',
        agora: t.add(const Duration(minutes: 16)),
      ),
      isTrue,
    );
    for (var i = 0; i < 3; i++) {
      limitesUso.cartaoRecusado(agora: t);
    }
    expect(limitesUso.soPixAte(agora: t), DateTime(2026, 11, 27));
    for (var i = 0; i < 5; i++) {
      expect(limitesUso.registrarPedido(agora: t), isTrue);
    }
    expect(limitesUso.registrarPedido(agora: t), isFalse);
  });

  test('RN-249: só conta pago com código (ou entrega) e sem conta ligada', () {
    const boas = [
      AvaliacaoParaNota(nota: 5, atendimento: 'a', codigoNaPorta: true),
      AvaliacaoParaNota(
        nota: 3,
        atendimento: 'b',
        distancia: true,
        entregaAprovada: true,
      ),
    ];
    const ruins = [
      AvaliacaoParaNota(nota: 1, atendimento: 'c'), // sem código
      AvaliacaoParaNota(
        nota: 1,
        atendimento: 'd',
        codigoNaPorta: true,
        contaLigada: true,
      ),
    ];
    expect(RegrasAvaliacao.nota([...boas, ...ruins]), 4);
    expect(RegrasAvaliacao.noPerfil([...boas, ...ruins]), hasLength(2));
    // RN-236: uma por atendimento.
    expect(RegrasAvaliacao.podeAvaliar('a', boas), isFalse);
    expect(
      const DadosConta(cartoes: {'4242'})
          .ligadaA(const DadosConta(cartoes: {'4242'})),
      isTrue,
    );
  });

  test('RN-247: configuração remota muda os números', () {
    Limites.aplicar({'trocasPorPedido': 5, 'esperaSemAcordo': 60});
    expect(Limites.trocasPorPedido, 5);
    expect(Limites.esperaSemAcordo, const Duration(hours: 1));
    Limites.restaurar();
    expect(Limites.trocasPorPedido, 3);
  });

  test('RN-18: só o 1º aceite vale', () {
    expect(aceitesChamado.aceitar('p1', 'Luiza'), isTrue);
    expect(aceitesChamado.aceitar('p1', 'Carlos'), isFalse);
    expect(aceitesChamado.donoDe('p1'), 'Luiza');
  });

  test('pagamento idempotente: a mesma chave nunca cobra duas vezes', () {
    var cobrancas = 0;
    bool cobrar() {
      cobrancas++;
      return true;
    }

    idempotencia
      ..executar('cobranca:#TT-1', cobrar)
      ..executar('cobranca:#TT-1', cobrar);
    expect(cobrancas, 1);
  });

  test('RN-245/RN-246: linha do tempo só de inclusão, em UTC', () {
    final e = registroAtendimentos.registrar(
      '#TT-1',
      'valor enviado',
      quem: 'profissional',
      em: DateTime(2026, 11, 26, 10),
    );
    expect(e.em.isUtc, isTrue);
    expect(
      () => (registroAtendimentos.eventos as List).add(e),
      throwsUnsupportedError,
    );
    expect(registroAtendimentos.doAtendimento('#TT-1'), [e]);
  });
}
