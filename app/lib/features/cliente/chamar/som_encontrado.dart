import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Som de "achou!" quando um profissional aceita o pedido: arpejo subindo
/// com brilho, como achar um tesouro. Toca uma vez.
class SomEncontrado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  static const arquivo = 'sons/encontrado.wav';

  Future<void> tocar() async {
    if (!ativo) return;
    try {
      HapticFeedback.mediumImpact();
      final p = AudioPlayer();
      // Termina sozinho mesmo se a pessoa já tocou em Aceitar.
      p.onPlayerComplete.first.then((_) => p.dispose());
      await p.setReleaseMode(ReleaseMode.stop);
      await p.play(AssetSource(arquivo), volume: 1);
    } catch (_) {
      // Sem som (navegador bloqueou, sem plugin): a tela aparece igual.
    }
  }
}
