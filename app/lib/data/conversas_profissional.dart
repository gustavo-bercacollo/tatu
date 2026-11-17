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
    this.concluidaEm,
    this.depois = const [],
    this.diaDepois,
  });

  /// Dia em que o serviço foi concluído ("04 nov").
  final String? concluidaEm;

  /// RN-42: mensagens trocadas depois do serviço (texto, minha).
  final List<(String, bool)> depois;

  /// Dia dessas mensagens ("12 nov").
  final String? diaDepois;

  final ChamadoNovo chamado;
  final String ultima;
  final String quando;
  int naoLidas;
  final SeloConversa selo;
  final String textoSelo;

  /// Valor do último serviço concluído; null = em andamento. RN-42: a
  /// conversa continua aberta, só vai para "Anteriores".
  final double? concluidaPor;

  bool get concluida => concluidaPor != null;
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
      if (!c.concluida) c,
  ];

  List<ConversaProfissional> get anteriores => [
    for (final c in conversas)
      if (c.concluida) c,
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
          ultima: 'A torneira do banheiro começou a pingar.',
          quando: 'ontem',
          concluidaPor: 120,
          concluidaEm: '04 nov',
          diaDepois: '12 nov',
          depois: const [
            ('A torneira do banheiro começou a pingar.', false),
            ('Consigo passar aí hoje. Já te mando o valor.', true),
          ],
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
