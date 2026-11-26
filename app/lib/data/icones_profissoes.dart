import 'dart:convert';

import 'package:flutter/services.dart';

import 'catalogo_servicos.dart';
import 'profissoes_reguladas.dart' show normalizarProfissao;

/// RN-227: ícone de cada profissão. A fonte única é
/// `assets/icones-profissoes/icones-profissoes.json` (cópia de
/// `design/icones-profissoes/`): nenhum nome de arquivo fica no código.
///
/// Sem ícone próprio (profissão nova ou sugerida): o do segmento; sem
/// segmento, o crachá. Nunca um espaço vazio.
class IconesProfissoes {
  static const pasta = 'assets/icones-profissoes/';
  static const mapa = '${pasta}icones-profissoes.json';

  /// Profissão (normalizada, sem gênero) → arquivo.
  final _profissoes = <String, String>{};

  /// Profissão (normalizada) → segmento (para a alternativa).
  final _segmentoDe = <String, String>{};

  /// Segmento → arquivo.
  final _segmentos = <String, String>{};

  /// Nomes curtos da Home ("Montador") → arquivo.
  final _apelidos = <String, String>{};

  String _semSegmento = 'generico-cracha.svg';
  String _outros = 'outros.svg';

  bool get carregado => _profissoes.isNotEmpty;

  Future<void> carregar({AssetBundle? bundle}) async {
    if (carregado) return;
    final texto = await (bundle ?? rootBundle).loadString(mapa);
    ler(texto);
  }

  /// Lê o JSON (separado para os testes).
  void ler(String texto) {
    final j = jsonDecode(texto) as Map<String, dynamic>;
    final profs = j['profissoes'] as Map<String, dynamic>;
    for (final e in profs.entries) {
      final v = e.value as Map<String, dynamic>;
      final chave = normalizarProfissao(e.key);
      _profissoes[chave] = v['arquivo'] as String;
      final seg = v['segmento'] as String?;
      if (seg != null) _segmentoDe[chave] = seg;
    }
    for (final e in (j['segmentos'] as Map<String, dynamic>).entries) {
      _segmentos[e.key] = e.value as String;
    }
    for (final e in (j['apelidos_na_home'] as Map<String, dynamic>).entries) {
      _apelidos[normalizarProfissao(e.key)] = e.value as String;
    }
    _semSegmento = j['sem_segmento'] as String? ?? _semSegmento;
    _outros = j['botao_outros'] as String? ?? _outros;
  }

  /// Caminho do ícone de [profissao] ("Encanadora", "Professor", "Psicólogo
  /// (a)"…). Sempre devolve um arquivo que existe.
  String de(String profissao) {
    final n = normalizarProfissao(profissao);
    final direto = _apelidos[n] ?? _profissoes[n];
    if (direto != null) return '$pasta$direto';
    // Pelo catálogo (sinônimos e feminino: "Diarista", "bombeiro
    // hidráulico"…).
    final c = catalogoServicos.encontrar(profissao);
    if (c != null) {
      final porCatalogo = _profissoes[normalizarProfissao(c.nome)];
      if (porCatalogo != null) return '$pasta$porCatalogo';
      final seg = _segmentos[c.segmento];
      if (seg != null) return '$pasta$seg';
    }
    final seg = _segmentos[_segmentoDe[n] ?? ''];
    if (seg != null) return '$pasta$seg';
    return '$pasta$_semSegmento';
  }

  /// Ícone de um segmento ("Aulas"); sem ícone, o crachá.
  String doSegmento(String segmento) =>
      '$pasta${_segmentos[segmento] ?? _semSegmento}';

  /// RN-227: o botão "Outros".
  String get outros => '$pasta$_outros';

  /// Tem ícone próprio (não é a alternativa)?
  bool temProprio(String profissao) {
    final n = normalizarProfissao(profissao);
    if (_apelidos.containsKey(n) || _profissoes.containsKey(n)) return true;
    final c = catalogoServicos.encontrar(profissao);
    return c != null && _profissoes.containsKey(normalizarProfissao(c.nome));
  }
}

/// Instância única do app.
final iconesProfissoes = IconesProfissoes();
