import 'package:flutter/foundation.dart';

/// Avaliação que um cliente deu ao profissional.
class AvaliacaoDeCliente {
  AvaliacaoDeCliente({
    required this.cliente,
    required this.servico,
    required this.nota,
    required this.data,
    this.comentario = '',
    this.contestada = false,
  });

  final String cliente;

  /// "Encanadora · Vazamento".
  final String servico;
  final int nota;

  /// "04 nov".
  final String data;
  final String comentario;

  /// Já mandou para revisão da equipe.
  bool contestada;

  /// Notas muito baixas (1 ou 2 estrelas) podem ser contestadas.
  bool get contestavel => nota <= 2 && !contestada;
}

/// Motivos para contestar uma avaliação.
const motivosContestacao = [
  'Ofensa ou preconceito',
  'Avaliou outro serviço',
  'Tentou pagar menos',
  'Outro motivo',
];

/// Avaliações recebidas pelo profissional. Versão simulada (sem backend):
/// as 312 da conta resumidas em média, barras e elogios; a lista mostra
/// as mais recentes.
class AvaliacoesProfissionalRepo extends ChangeNotifier {
  AvaliacoesProfissionalRepo() {
    restaurar();
  }

  late List<AvaliacaoDeCliente> recentes;
  int total = 312;
  double media = 4.9;

  /// Variação da média no mês (positivo = subiu).
  double variacaoMes = 0.1;

  /// Fração de avaliações com cada nota (5 a 1).
  Map<int, double> porNota = const {5: 0.86, 4: 0.1, 3: 0.03, 2: 0.01, 1: 0};

  /// Elogios mais citados com a contagem.
  List<(String, int)> elogios = const [('Pontual', 128), ('Educada', 97)];

  /// Palavra que mais aparece nas notas baixas (dica da IA).
  String? queixa = 'demora';
  int vezesQueixa = 3;

  bool get vazio => recentes.isEmpty;

  void restaurar() {
    total = 312;
    media = 4.9;
    variacaoMes = 0.1;
    recentes = [
      AvaliacaoDeCliente(
        cliente: 'Ana Martins',
        servico: 'Encanadora · Vazamento',
        nota: 5,
        data: '04 nov',
        comentario: 'Chegou rápido e deixou tudo limpo.',
      ),
      AvaliacaoDeCliente(
        cliente: 'Carlos Pereira',
        servico: 'Eletricista · Tomada',
        nota: 4,
        data: '28 out',
        comentario: 'Resolveu, mas demorou um pouco.',
      ),
      AvaliacaoDeCliente(
        cliente: 'Marina Lopes',
        servico: 'Encanadora · Torneira',
        nota: 5,
        data: '25 out',
      ),
      AvaliacaoDeCliente(
        cliente: 'Roberto Alves',
        servico: 'Encanador · Registro',
        nota: 3,
        data: '20 out',
        comentario: 'Atrasou 40 minutos sem avisar.',
      ),
      AvaliacaoDeCliente(
        cliente: 'Júlia Costa',
        servico: 'Eletricista · Chuveiro',
        nota: 1,
        data: '12 out',
        comentario: 'Não gostei do jeito dela.',
      ),
    ];
    notifyListeners();
  }

  /// Para a demo do estado vazio (profissional novo).
  void limpar() {
    recentes = [];
    total = 0;
    notifyListeners();
  }

  void contestar(AvaliacaoDeCliente a) {
    a.contestada = true;
    notifyListeners();
  }
}

final avaliacoesProfissional = AvaliacoesProfissionalRepo();
