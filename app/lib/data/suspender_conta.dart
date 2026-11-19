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
  final p = pedidos.doProfissional(c.nome);
  final e = conversas.profissionalSuspenso(
    c,
    ponto: p != null ? pontoDoPedido(p) : null,
    agora: agora,
  );
  if (p != null) {
    pedidos
      ..abrir(p)
      ..cancelarAndamento();
  }
  return e;
}

/// RN-129/RN-131: a conta do cliente (esta) foi suspensa: todos os
/// atendimentos em andamento acabam na hora. Ele passa a ver só "Conta
/// suspensa".
List<Encerramento> suspenderContaCliente() {
  final todos = pedidos.andamentos;
  final r = conversas.clienteSuspenso(
    pontos: {for (final p in todos) p.profissional: pontoDoPedido(p)},
  );
  // RN-131: todos os atendimentos acabam.
  while (pedidos.andamento != null) {
    pedidos.cancelarAndamento();
  }
  return r;
}

/// RN-129/RN-130: a conta do profissional (esta) foi suspensa: o
/// atendimento em andamento acaba na hora. O dinheiro do cliente é
/// tratado do lado dele ([profissionalSuspenso]).
Encerramento? suspenderContaProfissional({DateTime? agora}) =>
    atendimentoProfissional.profissionalSuspenso(agora: agora);
