import 'package:flutter/foundation.dart';

/// RN-157: consulta pública do conselho (CNA da OAB, CONFEF/CREF, etc.).
/// O app só conhece esta interface; as consultas de verdade entram
/// depois, uma por conselho.

/// Situação do registro no conselho.
enum SituacaoRegistro { ativo, cancelado, suspenso }

@immutable
class ResultadoRegistro {
  const ResultadoRegistro({
    required this.encontrado,
    this.nome,
    this.situacao = SituacaoRegistro.ativo,
    this.validade,
  });

  const ResultadoRegistro.naoEncontrado() : this(encontrado: false);

  final bool encontrado;

  /// Nome do titular no conselho (RN-157: tem de bater com o documento).
  final String? nome;
  final SituacaoRegistro situacao;

  /// Validade (ex.: CNH, credenciamento); nula = sem validade.
  final DateTime? validade;
}

abstract class ConsultaRegistro {
  Future<ResultadoRegistro> consultar({
    required String conselho,
    required String uf,
    required String numero,
  });
}

/// Versão simulada. Número que começa com "000" não existe; os testes
/// marcam resultados por número em [respostas].
class ConsultaRegistroMock implements ConsultaRegistro {
  ConsultaRegistroMock({this.nomeTitular});

  /// Nome que o "conselho" devolve (nulo = o nome do documento, passado
  /// pelo repositório na hora da consulta).
  String? nomeTitular;
  final respostas = <String, ResultadoRegistro>{};

  /// Usado quando [nomeTitular] é nulo.
  String nomePadrao = '';

  @override
  Future<ResultadoRegistro> consultar({
    required String conselho,
    required String uf,
    required String numero,
  }) async {
    final marcada = respostas[numero];
    if (marcada != null) return marcada;
    if (numero.replaceAll(RegExp(r'\D'), '').startsWith('000')) {
      return const ResultadoRegistro.naoEncontrado();
    }
    return ResultadoRegistro(
      encontrado: true,
      nome: nomeTitular ?? nomePadrao,
    );
  }
}

/// Trocado nos testes.
ConsultaRegistro consultaRegistro = ConsultaRegistroMock();
