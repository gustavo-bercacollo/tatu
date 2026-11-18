import 'package:flutter/foundation.dart';

/// RN-140: ligação só pelo app e só durante o atendimento.
abstract final class RegrasLigacao {
  /// O botão de ligar existe do valor confirmado até o serviço ser
  /// concluído. Antes ou depois disso, não existe (nem no menu).
  static bool disponivel({
    required bool valorConfirmado,
    required bool concluido,
    bool encerrado = false,
  }) => valorConfirmado && !concluido && !encerrado;
}

/// RN-140: a ligação nunca mostra o número de ninguém. Como fazer
/// (pela internet ou por número intermediário) ainda está em aberto;
/// o app só conhece esta interface.
abstract class Ligacao {
  /// Liga para [pessoa] pelo Tatu (nome, nunca o número).
  Future<void> ligar(String pessoa);
  Future<void> desligar();
  void mudo(bool ligado);
  void vivaVoz(bool ligado);
}

/// Versão simulada: só registra o que aconteceu.
class LigacaoMock extends ChangeNotifier implements Ligacao {
  final chamadas = <String>[];
  bool emLigacao = false;
  bool emMudo = false;
  bool emVivaVoz = false;

  @override
  Future<void> ligar(String pessoa) async {
    chamadas.add(pessoa);
    emLigacao = true;
    notifyListeners();
  }

  @override
  Future<void> desligar() async {
    emLigacao = false;
    emMudo = false;
    emVivaVoz = false;
    notifyListeners();
  }

  @override
  void mudo(bool ligado) {
    emMudo = ligado;
    notifyListeners();
  }

  @override
  void vivaVoz(bool ligado) {
    emVivaVoz = ligado;
    notifyListeners();
  }
}

/// Trocado nos testes.
Ligacao ligacao = LigacaoMock();
