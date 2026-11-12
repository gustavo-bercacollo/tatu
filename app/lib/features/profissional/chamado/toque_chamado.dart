import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../../../data/notificacoes_profissional.dart';

/// Toque do Tatu quando chega um chamado: o som escolhido em
/// "Som do novo chamado", repetindo até o profissional aceitar, recusar
/// ou o tempo acabar. Vibra se "Vibrar também" estiver ligado.
class ToqueChamado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  AudioPlayer? _player;

  /// Com [repetir] falso, toca uma vez só (prévia "Ouvir o som").
  Future<void> tocar({bool repetir = true}) async {
    if (!ativo) return;
    final n = notificacoesProfissional;
    try {
      if (n.vibrar) HapticFeedback.heavyImpact();
      final p = AudioPlayer();
      _player = p;
      await p.setReleaseMode(repetir ? ReleaseMode.loop : ReleaseMode.stop);
      await p.play(AssetSource(n.som.arquivo), volume: 1);
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
