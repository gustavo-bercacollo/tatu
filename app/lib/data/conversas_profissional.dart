import 'package:flutter/foundation.dart';

import 'servico_profissional.dart';

/// Selo da conversa na lista: verde (valor combinado) ou laranja
/// (proposta em andamento).
enum SeloConversa { nenhum, combinado, proposta }

/// Conversa do profissional com um cliente.
class ConversaProfissional {
  ConversaProfissional({
    required this.chamado,
    required this.ultima,
    required this.quando,
    this.naoLidas = 0,
    this.selo = SeloConversa.nenhum,
    this.textoSelo = '',
    this.concluidaPor,
  });

  final ChamadoNovo chamado;
  final String ultima;
  final String quando;
  int naoLidas;
  final SeloConversa selo;
  final String textoSelo;

  /// Valor do serviço concluído (conversa encerrada); null = em andamento.
  final double? concluidaPor;

  bool get encerrada => concluidaPor != null;
  String get nome => chamado.cliente;
}

/// Conversas do profissional. Versão simulada (sem backend).
class ConversasProfissionalRepo extends ChangeNotifier {
  ConversasProfissionalRepo() {
    restaurar();
  }

  final conversas = <ConversaProfissional>[];

  List<ConversaProfissional> get emAndamento => [
    for (final c in conversas)
      if (!c.encerrada) c,
  ];

  List<ConversaProfissional> get anteriores => [
    for (final c in conversas)
      if (c.encerrada) c,
  ];

  void restaurar() {
    conversas
      ..clear()
      ..addAll([
        ConversaProfissional(
          chamado: chamadoExemplo,
          ultima: 'Ok, pode vir!',
          quando: 'agora',
          naoLidas: 1,
          selo: SeloConversa.combinado,
          textoSelo: 'Valor combinado · R\$ 150',
        ),
        ConversaProfissional(
          chamado: const ChamadoNovo(
            cliente: 'Carlos Pereira',
            feminino: false,
            resumo: 'Tomada da sala sem energia',
            profissao: 'Eletricista',
            bairro: 'Moema',
            distanciaKm: 2.4,
          ),
          ultima: 'Consegue fazer por 200?',
          quando: '5 min',
          naoLidas: 2,
          selo: SeloConversa.proposta,
          textoSelo: 'Proposta 2 de 3',
        ),
        ConversaProfissional(
          chamado: const ChamadoNovo(
            cliente: 'Júlia Costa',
            resumo: 'Troca de torneira',
            bairro: 'Saúde',
            distanciaKm: 3.1,
          ),
          ultima: 'Obrigada, ficou ótimo!',
          quando: 'ontem',
          concluidaPor: 120,
        ),
        ConversaProfissional(
          chamado: const ChamadoNovo(
            cliente: 'Roberto Alves',
            feminino: false,
            resumo: 'Desentupir a pia',
            bairro: 'Ipiranga',
            distanciaKm: 4.0,
          ),
          ultima: 'Combinado então.',
          quando: '02 nov',
          concluidaPor: 150,
        ),
      ]);
    notifyListeners();
  }

  void limpar() {
    conversas.clear();
    notifyListeners();
  }

  void marcarLida(ConversaProfissional c) {
    c.naoLidas = 0;
    notifyListeners();
  }

  /// Cancelou o atendimento: a conversa sai da lista.
  void cancelar(ChamadoNovo chamado) {
    conversas.removeWhere((c) => c.chamado.cliente == chamado.cliente);
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final conversasProfissional = ConversasProfissionalRepo();
