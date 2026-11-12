import 'package:flutter/services.dart';

import '../../../core/som/som.dart';

/// Som de "achou!" quando um profissional aceita o pedido: arpejo subindo
/// com brilho, como achar um tesouro. Fica tocando até a pessoa agir
/// (Ver perfil, Aceitar, Ver outro ou fechar).
class SomEncontrado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  static const arquivo = 'sons/encontrado.wav';

  bool _tocando = false;

  Future<void> tocar() async {
    if (!ativo || _tocando) return;
    _tocando = true;
    HapticFeedback.mediumImpact();
    await tocarSom(arquivo, repetir: true);
  }

  Future<void> parar() async {
    if (!_tocando) return;
    _tocando = false;
    await pararSom(arquivo);
  }
}
