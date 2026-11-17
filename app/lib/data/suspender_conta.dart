import 'atendimento_profissional.dart';
import 'conversas.dart';
import 'pedidos.dart';
import 'suspensao.dart';

/// Em que ponto está o pedido em andamento do cliente.
PontoAtendimento pontoDoPedido(PedidoAndamento p) {
  // RN-95: à distância não há visita; vale só a reserva e o sinal.
  if (p.distancia) {
    return p.etapasFeitas >= 5
        ? PontoAtendimento.concluido
        : p.etapasFeitas >= 2
        ? PontoAtendimento.confirmado
        : PontoAtendimento.combinando;
  }
  return switch (p.etapasFeitas) {
    <= 1 => PontoAtendimento.combinando,
    2 => PontoAtendimento.confirmado,
    3 when p.chegouEm != null => PontoAtendimento.noLocal,
    3 => PontoAtendimento.aCaminho,
    4 => PontoAtendimento.emServico,
    _ => PontoAtendimento.concluido,
  };
}

/// RN-129/RN-130: o profissional da conversa [c] foi suspenso (no app de
/// verdade, isso chega do backend). Encerra o atendimento dele no chat e
/// no pedido em andamento.
Encerramento profissionalSuspenso(Conversa c, {DateTime? agora}) {
  final p = pedidos.andamento;
  final doPedido = p != null && p.profissional == c.nome;
  final e = conversas.profissionalSuspenso(
    c,
    ponto: doPedido ? pontoDoPedido(p) : null,
    agora: agora,
  );
  if (doPedido) pedidos.cancelarAndamento();
  return e;
}

/// RN-129/RN-131: a conta do cliente (esta) foi suspensa: todos os
/// atendimentos em andamento acabam na hora. Ele passa a ver só "Conta
/// suspensa".
List<Encerramento> suspenderContaCliente() {
  final p = pedidos.andamento;
  final r = conversas.clienteSuspenso(
    pontos: {if (p != null) p.profissional: pontoDoPedido(p)},
  );
  pedidos.cancelarAndamento();
  return r;
}

/// RN-129/RN-130: a conta do profissional (esta) foi suspensa: o
/// atendimento em andamento acaba na hora. O dinheiro do cliente é
/// tratado do lado dele ([profissionalSuspenso]).
Encerramento? suspenderContaProfissional({DateTime? agora}) =>
    atendimentoProfissional.profissionalSuspenso(agora: agora);
