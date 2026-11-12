import 'package:flutter/services.dart';

import '../../../core/som/som.dart';
import '../../../data/notificacoes_profissional.dart';

/// Toque do Tatu quando chega um chamado: o som escolhido em
/// "Som do novo chamado", repetindo até o profissional aceitar, recusar
/// ou o tempo acabar. Vibra se "Vibrar também" estiver ligado.
class ToqueChamado {
  /// Desligado nos testes e nas capturas (sem som de verdade).
  static bool ativo = true;

  String? _arquivo;

  /// Com [repetir] falso, toca uma vez só (prévia "Ouvir o som").
  Future<void> tocar({bool repetir = true}) async {
    if (!ativo) return;
    final n = notificacoesProfissional;
    if (n.vibrar) HapticFeedback.heavyImpact();
    _arquivo = n.som.arquivo;
    await tocarSom(n.som.arquivo, repetir: repetir);
  }

  Future<void> parar() async {
    final a = _arquivo;
    _arquivo = null;
    if (a != null) await pararSom(a);
  }
}
