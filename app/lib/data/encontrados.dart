import 'package:flutter/foundation.dart';

import 'perfil_publico.dart';
import 'profissional.dart' show AvaliacaoRecebida;

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
    this.distancia = '1,2 km',
    this.resposta = '5 min',
    this.especialidades = const ['Vazamentos', 'Registros', 'Pias'],
    this.sobre = '',
  });

  /// Distância até o cliente ("1,2 km").
  final String distancia;

  /// Tempo médio de resposta ("5 min").
  final String resposta;
  final List<String> especialidades;
  final String sobre;

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
    sobre:
        'Encanadora há 9 anos. Atendo vazamentos, troca de registros e '
        'instalação de louças.',
  ),
  ProfissionalEncontrado(
    nome: 'Carlos Pereira',
    profissao: 'Encanador',
    feminino: false,
    nota: '4,8',
    servicos: 187,
    chegaEm: '15 min',
    distancia: '1,8 km',
    resposta: '3 min',
    especialidades: ['Vazamentos', 'Desentupimento', 'Caixa d’água'],
    sobre:
        'Trabalho com encanamento há 12 anos. Resolvo vazamentos e '
        'desentupimentos no mesmo dia.',
  ),
  ProfissionalEncontrado(
    nome: 'Roberto Alves',
    profissao: 'Encanador',
    feminino: false,
    nota: '4,7',
    servicos: 95,
    chegaEm: '18 min',
    distancia: '2,4 km',
    resposta: '6 min',
    especialidades: ['Registros', 'Chuveiros', 'Aquecedores'],
    sobre:
        'Encanador e instalador. Troco registros, chuveiros e faço '
        'manutenção de aquecedores.',
  ),
];

/// Estimativa da plataforma para o serviço na região (sempre rotulada
/// como estimativa).
String estimativaDe(String servico) => switch (servico.toLowerCase()) {
  'eletricista' => r'R$ 90 a R$ 280',
  'pintor' => r'R$ 150 a R$ 600',
  _ => r'R$ 80 a R$ 250',
};

/// Perfil que o cliente vê em "Ver perfil" (dados simulados).
PerfilPublico perfilDe(ProfissionalEncontrado p) => PerfilPublico(
  nome: p.nome,
  subtitulo: '${p.profissao} · ${p.distancia} de você',
  nota: p.nota,
  servicos: p.servicos,
  resposta: p.resposta,
  especialidades: p.especialidades,
  sobre: p.sobre,
  verificado: true,
  feminino: p.feminino,
  fotos: const [null, null, null, null],
  barrasNotas: const [0.9, 0.08, 0.02],
  avaliacoes: const [
    AvaliacaoRecebida(
      'Marcos P.',
      'Vazamento',
      'há 3 dias',
      'Chegou rápido e resolveu o vazamento na hora.',
    ),
    AvaliacaoRecebida(
      'Camila R.',
      'Troca de registro',
      'há 1 semana',
      'Muito educada e deixou tudo limpo.',
    ),
    AvaliacaoRecebida(
      'Paulo T.',
      'Instalação de pia',
      'há 2 semanas',
      'Preço justo, recomendo.',
      nota: 4,
    ),
  ],
);
