import 'package:flutter/foundation.dart';

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

  bool get ativo => chamado != null || servico != null;

  void restaurar() {
    chamado = null;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
    notifyListeners();
  }

  /// Aceitou o chamado: começa a combinar o valor no chat.
  void aceitar(ChamadoNovo c) {
    chamado = c;
    servico = null;
    etapa = EtapaAtendimento.combinando;
    inicio = null;
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
