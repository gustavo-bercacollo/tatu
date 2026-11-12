import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

/// Um elemento de áudio por arquivo, criado e "destravado" num toque:
/// o navegador do celular só deixa tocar depois disso, e o mesmo
/// elemento continua liberado para tocar sozinho mais tarde.
final _elementos = <String, web.HTMLAudioElement>{};
bool _destravado = false;

web.HTMLAudioElement _elemento(String arquivo) =>
    _elementos.putIfAbsent(arquivo, () {
      final a = web.HTMLAudioElement()
        ..src = ui_web.assetManager.getAssetUrl('assets/$arquivo')
        ..preload = 'auto';
      return a;
    });

void destravar(List<String> arquivos) {
  if (_destravado) return;
  _destravado = true;
  for (final arquivo in arquivos) {
    final a = _elemento(arquivo);
    if (!a.paused) continue;
    a.muted = true;
    a.play().toDart.then(
      (_) {
        // Só para se ninguém pediu para tocar de verdade nesse meio tempo.
        if (a.muted) {
          a.pause();
          a.currentTime = 0;
        }
        a.muted = false;
      },
      onError: (Object _) {
        a.muted = false;
        _destravado = false; // tenta de novo no próximo toque
      },
    );
  }
}

Future<void> tocar(String arquivo, {required bool repetir}) async {
  final a = _elemento(arquivo);
  a
    ..loop = repetir
    ..muted = false
    ..volume = 1
    ..currentTime = 0;
  try {
    await a.play().toDart;
  } catch (_) {
    // Bloqueado pelo navegador: a tela aparece igual.
  }
}

Future<void> parar(String arquivo) async {
  final a = _elementos[arquivo];
  if (a == null) return;
  a
    ..pause()
    ..loop = false
    ..currentTime = 0;
}
