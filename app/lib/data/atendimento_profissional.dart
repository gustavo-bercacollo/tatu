import 'package:flutter/foundation.dart';

import 'package:clock/clock.dart';

import 'regras_distancia.dart';
import 'servico_profissional.dart';
import 'suspensao.dart';

/// Em que ponto está o chamado que o profissional aceitou.
enum EtapaAtendimento { combinando, aCaminho, noLocal, emServico }

extension EtapaAtendimentoTexto on EtapaAtendimento {
  /// Selo do cartão na Atividade.
  String get selo => switch (this) {
    EtapaAtendimento.combinando => 'Combinando',
    EtapaAtendimento.aCaminho => 'A caminho',
    EtapaAtendimento.noLocal => 'No local',
    EtapaAtendimento.emServico => 'Em serviço',
  };

  /// Quantas de [etapasAtendimento] já aconteceram.
  int get feitas => switch (this) {
    EtapaAtendimento.combinando => 1,
    EtapaAtendimento.aCaminho => 3,
    EtapaAtendimento.noLocal => 3,
    EtapaAtendimento.emServico => 4,
  };
}

/// Etapas na linha do tempo do cartão (profissional).
const etapasAtendimento = [
  'Aceito',
  'Combinado',
  'A caminho',
  'Serviço',
  'Pagamento',
];

/// Chamado em andamento do profissional (um por vez). Versão simulada.
class AtendimentoProfissionalRepo extends ChangeNotifier {
  ChamadoNovo? chamado;
  ServicoAceito? servico;
  EtapaAtendimento etapa = EtapaAtendimento.combinando;
  DateTime? inicio;

  /// RN-101: entregas enviadas neste valor (à distância).
  int entregas = 0;

  /// RN-99: prévias protegidas enviadas (sem limite).
  int previas = 0;

  /// RN-101: ainda pode mandar entrega?
  bool get podeEntregar => entregas < RegrasDistancia.maxEntregas;

  /// RN-103: o sinal é liberado na 1ª entrega.
  bool get sinalLiberado => entregas > 0;

  bool get ativo => chamado != null || servico != null;

  /// RN-131/RN-132: chats encerrados pelo Tatu porque o cliente foi
  /// suspenso, pelo nome do cliente. Só leitura; o histórico fica.
  final encerrados = <String, Encerramento>{};

  /// Ponto do atendimento atual (RN-131: a visita conta a partir do "a
  /// caminho").
  PontoAtendimento get ponto => switch (etapa) {
    EtapaAtendimento.combinando =>
      servico == null ? PontoAtendimento.combinando : PontoAtendimento.confirmado,
    EtapaAtendimento.aCaminho => PontoAtendimento.aCaminho,
    EtapaAtendimento.noLocal => PontoAtendimento.noLocal,
    EtapaAtendimento.emServico => PontoAtendimento.emServico,
  };

  AtendimentoAberto get _aberto {
    final s = servico;
    return AtendimentoAberto(
      ponto: ponto,
      visita: s?.visita ?? 0,
      servico: s?.valor ?? 0,
      sinal: s?.sinal ?? 0,
      entregas: entregas,
    );
  }

  /// RN-129/RN-131: o cliente deste atendimento foi suspenso. O Tatu
  /// encerra o atendimento; o profissional recebe pelo que já fez e pode
  /// ficar online de novo.
  Encerramento? clienteSuspenso() {
    final cliente = chamado?.cliente ?? servico?.cliente;
    if (cliente == null) return null;
    final e = RegrasSuspensao.clienteSuspenso(_aberto);
    _limpar();
    encerrados[cliente] = e;
    notifyListeners();
    return e;
  }

  /// RN-56/RN-129: [cliente] ficou suspenso por uma denúncia de assédio
  /// ou discriminação. Se é o atendimento atual, vale a RN-131; se não,
  /// a conversa só fica encerrada (nada a cobrar).
  Encerramento clienteSuspensoNo(String cliente) {
    if ((chamado?.cliente ?? servico?.cliente) == cliente) {
      return clienteSuspenso()!;
    }
    final e = RegrasSuspensao.clienteSuspenso(
      const AtendimentoAberto(ponto: PontoAtendimento.combinando),
    );
    encerrados[cliente] = e;
    notifyListeners();
    return e;
  }

  /// RN-129/RN-130: a conta deste profissional foi suspensa: o
  /// atendimento acaba na hora (reserva liberada, sinal sem entrega
  /// devolvido ao cliente).
  Encerramento? profissionalSuspenso({DateTime? agora}) {
    if (!ativo) return null;
    final e = RegrasSuspensao.profissionalSuspenso(
      _aberto,
      agora ?? clock.now(),
    );
    restaurar();
    return e;
  }

  void restaurar() {
    encerrados.clear();
    _limpar();
    notifyListeners();
  }

  /// Sem atendimento em andamento (os encerrados ficam).
  void _limpar() {
    chamado = null;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    entregas = 0;
    previas = 0;
  }

  /// RN-99: mandou uma prévia protegida.
  void enviarPrevia() {
    previas++;
    notifyListeners();
  }

  /// RN-101: mandou uma entrega (no máximo 2).
  void enviarEntrega() {
    if (!podeEntregar) return;
    entregas++;
    notifyListeners();
  }

  /// Aceitou o chamado: começa a combinar o valor no chat.
  void aceitar(ChamadoNovo c) {
    chamado = c;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    entregas = 0;
    previas = 0;
    notifyListeners();
  }

  /// Valor combinado: indo até o cliente.
  void irAteCliente(ServicoAceito s) {
    servico = s;
    etapa = EtapaAtendimento.aCaminho;
    notifyListeners();
  }

  void chegou() {
    etapa = EtapaAtendimento.noLocal;
    notifyListeners();
  }

  void iniciar(DateTime quando) {
    etapa = EtapaAtendimento.emServico;
    inicio = quando;
    notifyListeners();
  }

  /// Cancelou, saiu, não houve acordo ou terminou.
  void encerrar() {
    if (!ativo) return;
    _limpar();
    notifyListeners();
  }
}

final atendimentoProfissional = AtendimentoProfissionalRepo();
