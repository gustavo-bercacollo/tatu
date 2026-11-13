import 'package:flutter/foundation.dart';

@immutable
class Avaliacao {
  const Avaliacao({
    required this.id,
    required this.nome,
    required this.profissao,
    required this.data,
    required this.quando,
    required this.nota,
    required this.comentario,
    this.comentarioCompleto,
    this.hora,
    this.tags = const [],
    this.servico,
    this.valor,
  });

  final String id;

  /// Nome completo de quem avaliou ou foi avaliado.
  final String nome;
  final String profissao;

  /// Ex.: "02 nov".
  final String data;

  /// Ex.: "há 3 dias".
  final String quando;
  final int nota;
  final String comentario;
  final String? comentarioCompleto;
  final String? hora;
  final List<String> tags;

  /// Ex.: "vazamento na pia" / "R$ 150,00 · pago pelo app".
  final String? servico;
  final String? valor;

  /// Nome com o sobrenome abreviado (ex.: "Marcos D."), usado nas recebidas.
  String get nomeCurto {
    final p = nome.trim().split(RegExp(r'\s+'));
    return p.length < 2 ? nome : '${p.first} ${p.last[0]}.';
  }
}

/// Avaliações do cliente. Versão simulada (sem backend).
class AvaliacoesRepo extends ChangeNotifier {
  AvaliacoesRepo() {
    restaurar();
  }

  late List<Avaliacao> _recebidas;
  late List<Avaliacao> _enviadas;

  /// Quantas avaliações recebidas por nota (5, 4, 3, 2, 1).
  late Map<int, int> _porNota;

  List<Avaliacao> get recebidas => List.unmodifiable(_recebidas);
  List<Avaliacao> get enviadas => List.unmodifiable(_enviadas);
  Map<int, int> get porNota => Map.unmodifiable(_porNota);
  bool get vazio => _recebidas.isEmpty && _enviadas.isEmpty;

  int get total => _porNota.values.fold(0, (a, b) => a + b);

  double get media {
    if (total == 0) return 0;
    final soma = _porNota.entries.fold(0, (a, e) => a + e.key * e.value);
    return soma / total;
  }

  /// O que mais aparece nas recebidas.
  List<String> get tagsMaisCitadas => const [
    'Educada',
    'Pagou rápido',
    'Local organizado',
  ];

  void restaurar() {
    _porNota = {5: 19, 4: 3, 3: 1, 2: 0, 1: 0};
    _recebidas = const [
      Avaliacao(
        id: 'r1',
        nome: 'Marcos Dias',
        profissao: 'Eletricista',
        data: '02 nov',
        hora: '14:32',
        quando: 'há 3 dias',
        nota: 5,
        comentario: 'Cliente educada e local organizado.',
        comentarioCompleto:
            'Cliente educada e local organizado. Pagou na hora. '
            'Voltaria a atender.',
        tags: ['Educada', 'Pagou rápido'],
        servico: 'vazamento na pia',
        valor: 'R\$ 150,00 · pago pelo app',
      ),
      Avaliacao(
        id: 'r2',
        nome: 'Luiza Souza',
        profissao: 'Encanadora',
        data: '28 out',
        hora: '10:05',
        quando: 'há 1 semana',
        nota: 5,
        comentario: 'Tudo certo, pagou na hora.',
        tags: ['Pagou rápido'],
        servico: 'troca de registro',
        valor: 'R\$ 120,00 · Pix',
      ),
    ].toList();
    _enviadas = const [
      Avaliacao(
        id: 'e1',
        nome: 'Luiza Souza',
        profissao: 'Encanador',
        data: '04 nov',
        quando: 'há 1 dia',
        nota: 5,
        comentario: 'Chegou rápido e resolveu na hora.',
      ),
      Avaliacao(
        id: 'e2',
        nome: 'Marcos Dias',
        profissao: 'Eletricista',
        data: '02 nov',
        quando: 'há 3 dias',
        nota: 4,
        comentario: 'Bom serviço, atrasou um pouco.',
      ),
      Avaliacao(
        id: 'e3',
        nome: 'Rafael Lima',
        profissao: 'Pintor',
        data: '20 out',
        quando: 'há 2 semanas',
        nota: 5,
        comentario: 'Ficou perfeito.',
      ),
    ].toList();
    notifyListeners();
  }

  /// Sem nenhuma avaliação (estado vazio; usado na demo e nos testes).
  void limpar() {
    _recebidas = [];
    _enviadas = [];
    _porNota = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final avaliacoes = AvaliacoesRepo();
