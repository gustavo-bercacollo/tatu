import 'dart:async';

/// RN-137/RN-138: ditado (acessibilidade). A fala vira texto em pt-BR,
/// que aparece enquanto a pessoa fala. Nenhum áudio é guardado nem
/// enviado: o resultado é sempre texto.
abstract class Ditado {
  /// Permissão do microfone. Só pergunta ao celular no primeiro toque;
  /// depois devolve a resposta já dada.
  Future<bool> permitir();

  /// Começa a ouvir. Cada evento é o texto inteiro até agora.
  Stream<String> ouvir({String idioma = 'pt-BR'});

  /// Para de ouvir; o último texto fica valendo.
  Future<void> parar();
}

/// Versão simulada: "fala" uma frase de exemplo, palavra por palavra.
class DitadoMock implements Ditado {
  DitadoMock({
    this.frase = 'Minha pia da cozinha tá vazando embaixo e molhou tudo.',
    this.passo = const Duration(milliseconds: 280),
    this.permitido = true,
  });

  String frase;
  Duration passo;

  /// Resposta da pessoa ao pedido do microfone.
  bool permitido;

  /// Quantas vezes o celular perguntou (RN-137: só no primeiro toque).
  int perguntas = 0;
  bool? _resposta;

  Timer? _timer;
  StreamController<String>? _saida;

  @override
  Future<bool> permitir() async {
    if (_resposta != null) return _resposta!;
    perguntas++;
    return _resposta = permitido;
  }

  @override
  Stream<String> ouvir({String idioma = 'pt-BR'}) {
    _timer?.cancel();
    final palavras = frase.split(' ');
    var n = 0;
    final saida = _saida = StreamController<String>();
    _timer = Timer.periodic(passo, (t) {
      n++;
      saida.add(palavras.take(n).join(' '));
      if (n >= palavras.length) t.cancel();
    });
    return saida.stream;
  }

  @override
  Future<void> parar() async {
    _timer?.cancel();
    // Sem esperar: quem ouvia já cancelou a escuta.
    unawaited(_saida?.close());
    _saida = null;
  }
}

/// Trocado nos testes.
Ditado ditado = DitadoMock();
