import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Toque do Tatu quando chega um chamado: marimba curta e animada,
/// repetindo até o profissional aceitar, recusar ou o tempo acabar.
class ToqueChamado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  AudioPlayer? _player;

  Future<void> tocar() async {
    if (!ativo) return;
    try {
      HapticFeedback.heavyImpact();
      final p = AudioPlayer();
      _player = p;
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource('sons/chamado.wav'), volume: 1);
    } catch (_) {
      // Sem som (navegador bloqueou, sem plugin): o chamado aparece igual.
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
