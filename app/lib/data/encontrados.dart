import 'package:flutter/foundation.dart';

/// Profissional que aceitou o pedido (tela "Profissional encontrado").
@immutable
class ProfissionalEncontrado {
  const ProfissionalEncontrado({
    required this.nome,
    required this.profissao,
    required this.feminino,
    required this.nota,
    required this.servicos,
    required this.chegaEm,
  });

  final String nome;

  /// "Encanadora", "Encanador".
  final String profissao;
  final bool feminino;
  final String nota;
  final int servicos;

  /// Previsão de chegada ("12 min").
  final String chegaEm;

  String get primeiroNome => nome.split(' ').first;
  String get artigo => feminino ? 'a' : 'o';
}

/// Fila simulada de quem aceita o pedido (sem backend). "Ver outro" e o
/// prazo acabando passam para o próximo; depois do último, a busca volta.
const filaEncontrados = [
  ProfissionalEncontrado(
    nome: 'Luiza Souza',
    profissao: 'Encanadora',
    feminino: true,
    nota: '4,9',
    servicos: 312,
    chegaEm: '12 min',
  ),
  ProfissionalEncontrado(
    nome: 'Carlos Pereira',
    profissao: 'Encanador',
    feminino: false,
    nota: '4,8',
    servicos: 187,
    chegaEm: '15 min',
  ),
  ProfissionalEncontrado(
    nome: 'Roberto Alves',
    profissao: 'Encanador',
    feminino: false,
    nota: '4,7',
    servicos: 95,
    chegaEm: '18 min',
  ),
];

/// Estimativa da plataforma para o serviço na região (sempre rotulada
/// como estimativa).
String estimativaDe(String servico) => switch (servico.toLowerCase()) {
  'eletricista' => r'R$ 90 a R$ 280',
  'pintor' => r'R$ 150 a R$ 600',
  _ => r'R$ 80 a R$ 250',
};
