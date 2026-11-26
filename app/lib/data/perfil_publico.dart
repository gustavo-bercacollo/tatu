import 'package:flutter/foundation.dart';

import 'profissional.dart' show AvaliacaoRecebida;
import 'selos.dart';

/// O que o cliente vê no perfil de um profissional.
@immutable
class PerfilPublico {
  const PerfilPublico({
    required this.nome,
    required this.subtitulo,
    required this.nota,
    required this.servicos,
    required this.resposta,
    required this.especialidades,
    required this.sobre,
    required this.verificado,
    required this.fotos,
    required this.barrasNotas,
    required this.avaliacoes,
    this.feminino = true,
    this.registros = const [],
    this.selos = const [],
  });

  /// RN-217/RN-219: selos calculados (Pontual, Resolve de primeira,
  /// Clientes voltam). Verificado e Registro vêm de [verificado] e
  /// [registros].
  final List<Selo> selos;

  /// RN-219: todos os selos, na ordem de exibição.
  List<Selo> get todosOsSelos => emOrdem({
    if (verificado) Selo.verificado,
    if (registros.isNotEmpty) Selo.registroConferido,
    ...selos,
  });

  /// RN-159: registros conferidos ("CREF 012345-G/SP").
  final List<String> registros;

  /// Para "Bem avaliada" / "Bem avaliado".
  final bool feminino;

  final String nome;

  /// "Encanadora · 1,2 km de você".
  final String subtitulo;

  /// "4,9".
  final String nota;
  final int servicos;

  /// Tempo médio de resposta ("5 min").
  final String resposta;
  final List<String> especialidades;
  final String sobre;
  final bool verificado;

  /// Fotos de trabalhos aprovadas (nula = sem imagem na demo).
  final List<Uint8List?> fotos;

  /// Distribuição das notas (5, 4, 3) em fração.
  final List<double> barrasNotas;

  /// As 3 mais recentes aparecem no carrossel.
  final List<AvaliacaoRecebida> avaliacoes;
}
