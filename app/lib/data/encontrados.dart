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
    this.registros = const [],
  });

  /// RN-159: registros conferidos pelo Tatu.
  final List<String> registros;

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
    nome: 'Fernanda Lima',
    profissao: 'Encanadora',
    feminino: true,
    nota: '4,8',
    servicos: 143,
    chegaEm: '16 min',
    distancia: '2,1 km',
    resposta: '4 min',
    especialidades: ['Vazamentos', 'Torneiras', 'Caixa d’água'],
    sobre:
        'Encanadora há 6 anos. Atendo vazamentos e troca de torneiras '
        'com capricho.',
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

/// RN-94: fila à distância, sem distância nem chegada; vêm primeiro os
/// mais bem avaliados que estão online.
const filaDistancia = [
  ProfissionalEncontrado(
    nome: 'Marina Reis',
    profissao: 'Designer',
    feminino: true,
    nota: '4,9',
    servicos: 128,
    chegaEm: '',
    distancia: '',
    resposta: '5 min',
    especialidades: ['Logos', 'Identidade visual', 'Posts'],
    sobre:
        'Designer há 7 anos. Faço logos, cardápios e artes para pequenos '
        'negócios.',
  ),
  ProfissionalEncontrado(
    nome: 'Tiago Santos',
    profissao: 'Designer',
    feminino: false,
    nota: '4,8',
    servicos: 96,
    chegaEm: '',
    distancia: '',
    resposta: '8 min',
    especialidades: ['Logos', 'Embalagens', 'Ilustração'],
    sobre: 'Crio identidades visuais e embalagens.',
  ),
  ProfissionalEncontrado(
    nome: 'Julia Prado',
    profissao: 'Designer',
    feminino: true,
    nota: '4,8',
    servicos: 74,
    chegaEm: '',
    distancia: '',
    resposta: '10 min',
    especialidades: ['Posts', 'Apresentações', 'Logos'],
    sobre: 'Artes para redes sociais e apresentações.',
  ),
  ProfissionalEncontrado(
    nome: 'Carla Lima',
    profissao: 'Designer',
    feminino: true,
    nota: '4,7',
    servicos: 51,
    chegaEm: '',
    distancia: '',
    resposta: '12 min',
    especialidades: ['Cardápios', 'Convites', 'Logos'],
    sobre: 'Cardápios, convites e logos com prazo curto.',
  ),
];

/// Protótipo: cada chamada começa a fila numa pessoa diferente, para
/// pedidos seguidos (RN-90) não caírem sempre na mesma profissional.
int _chamadas = 0;

/// Onde a fila começa nesta chamada (e avança para a próxima).
int inicioDaFila() => _chamadas++;

/// Volta a fila ao começo (testes e capturas).
void reiniciarFila() => _chamadas = 0;

/// Fila que vale para o cliente: com "Preferir profissionais mulheres",
/// só profissionais mulheres. Com [distancia], a fila à distância.
List<ProfissionalEncontrado> filaPara({
  required bool soMulheres,
  bool distancia = false,
}) => [
  for (final p in distancia ? filaDistancia : filaEncontrados)
    if (!soMulheres || p.feminino) p,
];

/// Estimativa da plataforma para o serviço na região (sempre rotulada
/// como estimativa).
String estimativaDe(String servico) => switch (servico.toLowerCase()) {
  'eletricista' => r'R$ 90 a R$ 280',
  'pintor' => r'R$ 150 a R$ 600',
  'designer' => r'R$ 150 a R$ 600',
  'programador' => r'R$ 300 a R$ 2.000',
  'professor' => r'R$ 60 a R$ 150',
  'contador' => r'R$ 150 a R$ 500',
  'advogado' => r'R$ 200 a R$ 800',
  _ => r'R$ 80 a R$ 250',
};

/// Perfil que o cliente vê em "Ver perfil" (dados simulados).
PerfilPublico perfilDe(ProfissionalEncontrado p) => PerfilPublico(
  nome: p.nome,
  subtitulo: p.distancia.isEmpty
      ? '${p.profissao} · à distância'
      : '${p.profissao} · ${p.distancia} de você',
  nota: p.nota,
  servicos: p.servicos,
  resposta: p.resposta,
  especialidades: p.especialidades,
  sobre: p.sobre,
  verificado: true,
  feminino: p.feminino,
  registros: p.registros,
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
