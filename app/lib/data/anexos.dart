import 'package:flutter/foundation.dart';

import 'arquivos_seguros.dart';

/// RN-139: anexos da descrição do pedido.
abstract final class RegrasAnexo {
  /// Até quantos anexos (fotos + arquivos) por pedido. Exemplo.
  static const maxPorPedido = 5;
}

/// Foto ou arquivo anexado à descrição do pedido.
@immutable
class AnexoPedido {
  const AnexoPedido(this.nome, {this.imagem});

  final String nome;

  /// Bytes da foto (nulo para arquivo, ou foto de exemplo sem imagem).
  final Uint8List? imagem;

  bool get foto => tipoDe(nome) == TipoArquivo.imagem;

  /// "PDF", para a miniatura do arquivo.
  String get etiqueta => extensaoDe(nome).toUpperCase();
}

/// O que aconteceu ao tentar anexar.
enum ResultadoAnexo {
  anexado,

  /// RN-139: já tem [RegrasAnexo.maxPorPedido].
  limite,

  /// RN-119: tipo que não vale no chat (ex.: .apk).
  tipoNaoPermitido,

  /// RN-119: maior que o limite do chat.
  grandeDemais,

  /// RN-120: barrado pela moderação (vírus, nudez).
  barrado,

  /// RN-122: conta suspensa ou banida.
  contaSuspensa,
}

/// RN-139: escolher um arquivo do celular (PDF, documento). Versão
/// simulada: devolve um arquivo de exemplo.
abstract class SeletorArquivo {
  Future<ArquivoEnviado?> escolher();
}

class SeletorArquivoMock implements SeletorArquivo {
  SeletorArquivoMock([this.arquivo = const ArquivoEnviado('orcamento.pdf')]);

  /// O que o "celular" devolve (os testes trocam).
  ArquivoEnviado? arquivo;

  @override
  Future<ArquivoEnviado?> escolher() async => arquivo;
}

/// Trocado nos testes.
SeletorArquivo seletorArquivo = SeletorArquivoMock();

/// Anexos do pedido que está sendo descrito na Home.
class AnexosPedido extends ChangeNotifier {
  final _itens = <AnexoPedido>[];

  List<AnexoPedido> get itens => List.unmodifiable(_itens);
  bool get cheio => _itens.length >= RegrasAnexo.maxPorPedido;

  /// RN-139: mesmos tipos e verificações do chat (RN-119 a RN-122).
  Future<ResultadoAnexo> adicionar(
    ArquivoEnviado arquivo, {
    Uint8List? imagem,
  }) async {
    if (cheio) return ResultadoAnexo.limite;
    final r = await segurancaConteudo.enviarNoChat(arquivo);
    // Pode ter enchido enquanto esperava a moderação.
    if (r == ResultadoEnvio.entregue && cheio) return ResultadoAnexo.limite;
    final resultado = switch (r) {
      ResultadoEnvio.entregue => ResultadoAnexo.anexado,
      ResultadoEnvio.tipoNaoPermitido => ResultadoAnexo.tipoNaoPermitido,
      ResultadoEnvio.grandeDemais => ResultadoAnexo.grandeDemais,
      ResultadoEnvio.barrado => ResultadoAnexo.barrado,
      ResultadoEnvio.contaSuspensa ||
      ResultadoEnvio.contaBanida => ResultadoAnexo.contaSuspensa,
    };
    if (resultado == ResultadoAnexo.anexado) {
      _itens.add(AnexoPedido(arquivo.nome, imagem: imagem));
      notifyListeners();
    }
    return resultado;
  }

  void remover(int i) {
    _itens.removeAt(i);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }
}
