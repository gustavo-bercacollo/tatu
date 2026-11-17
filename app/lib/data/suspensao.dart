import '../shared/formatadores.dart';

/// RN-128/RN-129: situação de uma conta.
enum EstadoConta {
  ativa,

  /// RN-128: pausa (abandonos, ausências, sinais sem entrega…): só impede
  /// novos pedidos ou chamados; o que está em andamento continua.
  pausada,

  /// RN-129: casos graves (abuso, violência, golpe, vírus): encerra na
  /// hora tudo que está em andamento e a pessoa só vê "Conta suspensa".
  suspensa,
}

/// Junta as pausas e suspensões que já existem num estado só.
EstadoConta estadoDaConta({required bool pausada, required bool suspensa}) =>
    suspensa
    ? EstadoConta.suspensa
    : (pausada ? EstadoConta.pausada : EstadoConta.ativa);

/// Em que ponto está um atendimento quando a outra conta é suspensa.
enum PontoAtendimento {
  /// Ainda combinando o valor (nada reservado).
  combinando,

  /// Valor confirmado e reservado; profissional ainda não saiu.
  confirmado,

  aCaminho,
  noLocal,
  emServico,

  /// Serviço concluído (o valor já foi cobrado).
  concluido,
}

/// Dinheiro de um atendimento no momento da suspensão.
class AtendimentoAberto {
  const AtendimentoAberto({
    required this.ponto,
    this.visita = 0,
    this.servico = 0,
    this.sinal = 0,
    this.entregas = 0,
    this.parcelas = 1,
    this.concluidoEm,
    this.feminino = true,
  });

  final PontoAtendimento ponto;
  final double visita;
  final double servico;

  /// RN-102/RN-103: sinal cobrado ao confirmar (à distância).
  final double sinal;

  /// RN-103: o sinal vai para o profissional na 1ª entrega.
  final int entregas;

  /// RN-91: em quantas vezes o cliente ia pagar.
  final int parcelas;

  /// Quando o serviço foi concluído (RN-130: repasse de menos de 24 h).
  final DateTime? concluidoEm;

  /// O profissional é mulher ("A profissional" / "O profissional").
  final bool feminino;

  double get total => visita + servico;

  /// Valor confirmado ainda reservado no cartão (o sinal já foi cobrado).
  double get reservado => switch (ponto) {
    PontoAtendimento.combinando || PontoAtendimento.concluido => 0,
    _ => total - sinal,
  };

  /// RN-103: sinal ainda guardado pelo Tatu (sem entrega).
  bool get sinalGuardado => sinal > 0 && entregas == 0;
}

/// O que acontece com o dinheiro e o chat quando o Tatu encerra.
class Encerramento {
  const Encerramento({
    required this.mensagem,
    this.nota,
    this.liberado = 0,
    this.sinalDevolvido = 0,
    this.cobrado = 0,
    this.repasseEmAnalise = false,
    this.parcelasCanceladas = 0,
    this.chamarOutro = false,
  });

  /// Mensagem do Tatu no chat de quem continua.
  final String mensagem;

  /// Nota cinza abaixo do cartão.
  final String? nota;

  /// Reserva solta de volta ao cartão do cliente.
  final double liberado;

  /// Sinal guardado que volta ao cliente (RN-130).
  final double sinalDevolvido;

  /// Tirado da reserva do cliente para pagar o profissional (RN-131).
  final double cobrado;

  /// RN-130: repasse preso, "em análise" até o suporte decidir.
  final bool repasseEmAnalise;

  /// RN-132: parcelas futuras canceladas.
  final int parcelasCanceladas;

  /// RN-130: botão "Chamar outro profissional".
  final bool chamarOutro;
}

abstract final class RegrasSuspensao {
  /// RN-130: repasse de serviço concluído há menos disso fica preso.
  static const repassePreso = Duration(hours: 24);

  /// RN-128/RN-129: só a suspensão encerra o que está em andamento.
  static bool encerraAtendimentos(EstadoConta e) => e == EstadoConta.suspensa;

  /// RN-132: parcelas de um serviço que não terminou são canceladas; o
  /// que já foi pago pelo trabalho feito continua valendo.
  static int _parcelasCanceladas(AtendimentoAberto a) =>
      a.ponto == PontoAtendimento.concluido || a.reservado <= 0
      ? 0
      : a.parcelas;

  /// RN-130: o profissional foi suspenso. Reserva liberada, sinal sem
  /// entrega de volta, repasse de concluído há menos de 24 h preso.
  static Encerramento profissionalSuspenso(
    AtendimentoAberto a,
    DateTime agora,
  ) {
    final concluido = a.ponto == PontoAtendimento.concluido;
    final devolvido = a.sinalGuardado ? a.sinal : 0.0;
    final quem = a.feminino ? 'A profissional' : 'O profissional';
    // Com sinal já liberado (houve entrega) ou serviço concluído, algo
    // foi cobrado: não dá para dizer "Nada foi cobrado".
    final nadaCobrado = !concluido && (a.sinal == 0 || a.sinalGuardado);
    return Encerramento(
      mensagem:
          '$quem não pode mais continuar este atendimento.'
          '${nadaCobrado ? ' Nada foi cobrado.' : ''}',
      nota: 'Seu pedido já vai preenchido.',
      liberado: a.reservado,
      sinalDevolvido: devolvido,
      repasseEmAnalise:
          concluido &&
          a.concluidoEm != null &&
          agora.difference(a.concluidoEm!) < repassePreso,
      parcelasCanceladas: _parcelasCanceladas(a),
      chamarOutro: true,
    );
  }

  /// RN-131: o cliente foi suspenso. O profissional recebe pelo que já
  /// fez, tirado da reserva do cliente: a visita se já saiu (a caminho,
  /// no local ou em serviço), o serviço se já concluiu. O resto é solto.
  /// O Tatu não paga nada.
  static Encerramento clienteSuspenso(AtendimentoAberto a) {
    final cobrado = switch (a.ponto) {
      PontoAtendimento.aCaminho ||
      PontoAtendimento.noLocal ||
      PontoAtendimento.emServico => a.visita,
      _ => 0.0,
    };
    // Concluído: o serviço já tinha sido cobrado e segue com ele.
    final recebe = a.ponto == PontoAtendimento.concluido
        ? 'o serviço de ${reais(a.total)}'
        : cobrado > 0
        ? 'a visita de ${reais(cobrado)}'
        : a.sinal > 0 && !a.sinalGuardado
        ? 'o sinal de ${reais(a.sinal)}'
        : null;
    return Encerramento(
      mensagem:
          'Este atendimento foi encerrado pelo Tatu.'
          '${recebe == null ? '' : ' Você recebe $recebe.'}',
      nota: 'Pode ficar online para novos chamados.',
      cobrado: cobrado,
      liberado: a.reservado - cobrado,
      // RN-103: sem entrega, o sinal ainda estava guardado e volta.
      sinalDevolvido: a.sinalGuardado ? a.sinal : 0,
      parcelasCanceladas: _parcelasCanceladas(a),
    );
  }
}
