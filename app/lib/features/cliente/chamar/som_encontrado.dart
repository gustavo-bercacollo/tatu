import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Som de "achou!" quando um profissional aceita o pedido: arpejo subindo
/// com brilho, como achar um tesouro. Fica tocando até a pessoa agir
/// (Ver perfil, Aceitar, Ver outro ou fechar).
class SomEncontrado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  static const arquivo = 'sons/encontrado.wav';

  AudioPlayer? _player;

  Future<void> tocar() async {
    if (!ativo || _player != null) return;
    try {
      HapticFeedback.mediumImpact();
      final p = AudioPlayer();
      _player = p;
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource(arquivo), volume: 1);
    } catch (_) {
      // Sem som (navegador bloqueou, sem plugin): a tela aparece igual.
    }
  }

  Future<void> parar() async {
    final p = _player;
    _player = null;
    if (p == null) return;
    try {
      await p.stop();
      await p.dispose();
    } catch (_) {}
  }
}
