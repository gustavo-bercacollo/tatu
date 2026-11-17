import 'package:flutter/foundation.dart';

import 'regras_distancia.dart';
import 'servico_profissional.dart';

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

  void restaurar() {
    chamado = null;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    entregas = 0;
    previas = 0;
    notifyListeners();
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
    restaurar();
  }
}

final atendimentoProfissional = AtendimentoProfissionalRepo();
