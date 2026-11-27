import 'package:flutter/foundation.dart';

/// RN-236/RN-249: que avaliação existe e qual conta para a nota.
/// Enquanto não há backend, as telas mostram a nota da demonstração; o
/// servidor calcula com estas regras.

/// Dados que ligam duas contas (RN-218 e RN-249).
@immutable
class DadosConta {
  const DadosConta({
    this.cpf,
    this.cartoes = const {},
    this.aparelhos = const {},
    this.enderecos = const {},
  });

  final String? cpf;
  final Set<String> cartoes;
  final Set<String> aparelhos;
  final Set<String> enderecos;

  /// RN-249: mesmo CPF, cartão, aparelho ou endereço.
  bool ligadaA(DadosConta o) =>
      (cpf != null && cpf == o.cpf) ||
      cartoes.any(o.cartoes.contains) ||
      aparelhos.any(o.aparelhos.contains) ||
      enderecos.any(o.enderecos.contains);
}

/// Uma avaliação recebida, como o servidor vê.
@immutable
class AvaliacaoParaNota {
  const AvaliacaoParaNota({
    required this.nota,
    required this.atendimento,
    this.pagaPeloApp = true,
    this.codigoNaPorta = false,
    this.distancia = false,
    this.entregaAprovada = false,
    this.contaLigada = false,
  });

  final int nota;

  /// RN-236: o atendimento (o card da Atividade; no plano fixo, o mês).
  final String atendimento;
  final bool pagaPeloApp;
  final bool codigoNaPorta;
  final bool distancia;
  final bool entregaAprovada;
  final bool contaLigada;

  /// RN-249: conta para a nota e aparece no perfil? Só atendimento pago
  /// pelo app, com código na porta (à distância: entrega aprovada), entre
  /// contas que não são ligadas.
  bool get conta =>
      pagaPeloApp &&
      (distancia ? entregaAprovada : codigoNaPorta) &&
      !contaLigada;
}

abstract final class RegrasAvaliacao {
  /// RN-236: uma avaliação por atendimento. Novo valor no mesmo
  /// atendimento (RN-32) não abre outra.
  static bool podeAvaliar(
    String atendimento,
    Iterable<AvaliacaoParaNota> feitas,
  ) => !feitas.any((a) => a.atendimento == atendimento);

  /// RN-236: no plano fixo, o atendimento avaliado é o mês
  /// ("plano:Júlia Costa:2026-11").
  static String atendimentoDoPlano(String profissional, DateTime mes) =>
      'plano:$profissional:${mes.year}-${mes.month.toString().padLeft(2, '0')}';

  /// RN-236/RN-249: a nota é a média só das avaliações que contam (nula
  /// sem nenhuma).
  static double? nota(Iterable<AvaliacaoParaNota> todas) {
    final validas = todas.where((a) => a.conta).toList();
    if (validas.isEmpty) return null;
    return validas.fold<int>(0, (s, a) => s + a.nota) / validas.length;
  }

  /// RN-249: as que aparecem no perfil.
  static List<AvaliacaoParaNota> noPerfil(Iterable<AvaliacaoParaNota> todas) =>
      [
        for (final a in todas)
          if (a.conta) a,
      ];
}
