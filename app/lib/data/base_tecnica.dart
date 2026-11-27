import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// Base técnica pedida na auditoria (RN-18, RN-245, RN-246 e pagamento
/// idempotente). No protótipo tudo roda no aparelho; no backend, cada
/// parte vira uma tabela ou uma transação (ver docs/auditoria-ponta-a-
/// ponta.md).

// ---------------------------------------------------------------------
// RN-245: fuso horário.
// ---------------------------------------------------------------------

/// RN-245: todo prazo é guardado como um instante único (UTC).
DateTime instante(DateTime d) => d.toUtc();

/// RN-245: e aparece no fuso do aparelho de quem está vendo.
DateTime noAparelho(DateTime d) => d.toLocal();

/// RN-245: as faixas do retorno (manhã, tarde, noite) usam o fuso do
/// endereço do serviço. [deslocamento] é o fuso do endereço (ex.: -3 h em
/// São Paulo, -4 h em Manaus).
DateTime noEndereco(DateTime d, Duration deslocamento) =>
    d.toUtc().add(deslocamento);

// ---------------------------------------------------------------------
// RN-246: linha do tempo do atendimento (só inclusão).
// ---------------------------------------------------------------------

/// Uma etapa do atendimento: evento, quando (UTC) e quem fez.
@immutable
class EventoAtendimento {
  const EventoAtendimento({
    required this.atendimento,
    required this.evento,
    required this.em,
    required this.quem,
  });

  /// Número do atendimento ou o nome da conversa no protótipo.
  final String atendimento;

  /// "valor enviado", "confirmado", "código", "novo valor", "retorno"…
  final String evento;
  final DateTime em;

  /// "cliente", "profissional", "sistema" ou "suporte".
  final String quem;
}

/// RN-246: tabela só de inclusão. Não tem editar nem apagar; é a prova
/// da RN-194 e da mediação (RN-191). Guardada pelo prazo das fotos
/// (RN-199).
class RegistroAtendimentos {
  final _eventos = <EventoAtendimento>[];

  /// Só leitura.
  List<EventoAtendimento> get eventos => List.unmodifiable(_eventos);

  List<EventoAtendimento> doAtendimento(String atendimento) =>
      List.unmodifiable(_eventos.where((e) => e.atendimento == atendimento));

  /// A única escrita: acrescenta no fim, com o instante em UTC.
  EventoAtendimento registrar(
    String atendimento,
    String evento, {
    required String quem,
    DateTime? em,
  }) {
    final e = EventoAtendimento(
      atendimento: atendimento,
      evento: evento,
      em: instante(em ?? clock.now()),
      quem: quem,
    );
    _eventos.add(e);
    return e;
  }

  /// Só para os testes do protótipo (no servidor não existe).
  @visibleForTesting
  void limparParaTeste() => _eventos.clear();
}

final registroAtendimentos = RegistroAtendimentos();

// ---------------------------------------------------------------------
// RN-18: aceite atômico.
// ---------------------------------------------------------------------

/// RN-18: o pedido vai a todos ao mesmo tempo, mas só o 1º aceite vale.
/// No backend é uma transação (atualiza o pedido só se ainda não tem
/// dono); aqui, o mapa faz o mesmo papel.
class AceitesChamado {
  final _donos = <String, String>{};

  static const textoOutroAceitou = 'Outro profissional aceitou';

  /// Devolve se [profissional] ficou com o chamado.
  bool aceitar(String chamado, String profissional) =>
      _donos.putIfAbsent(chamado, () => profissional) == profissional;

  String? donoDe(String chamado) => _donos[chamado];

  void restaurar() => _donos.clear();
}

final aceitesChamado = AceitesChamado();

// ---------------------------------------------------------------------
// Pagamento idempotente.
// ---------------------------------------------------------------------

/// Toda reserva, cobrança e devolução leva uma chave única. Tentar de
/// novo com a mesma chave devolve o resultado da 1ª vez: nunca cobra
/// duas vezes.
class Idempotencia {
  final _feitas = <String, Object?>{};

  T executar<T>(String chave, T Function() operacao) {
    if (_feitas.containsKey(chave)) return _feitas[chave] as T;
    final r = operacao();
    _feitas[chave] = r;
    return r;
  }

  bool jaFeita(String chave) => _feitas.containsKey(chave);

  void restaurar() => _feitas.clear();
}

final idempotencia = Idempotencia();
