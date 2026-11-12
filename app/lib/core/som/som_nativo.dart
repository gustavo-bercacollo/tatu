import 'package:audioplayers/audioplayers.dart';

final _players = <String, AudioPlayer>{};

void destravar(List<String> arquivos) {}

Future<void> tocar(String arquivo, {required bool repetir}) async {
  try {
    await parar(arquivo);
    final p = AudioPlayer();
    _players[arquivo] = p;
    await p.setReleaseMode(repetir ? ReleaseMode.loop : ReleaseMode.stop);
    await p.play(AssetSource(arquivo), volume: 1);
  } catch (_) {
    // Sem som: a tela aparece igual.
  }
}

Future<void> parar(String arquivo) async {
  final p = _players.remove(arquivo);
  if (p == null) return;
  try {
    await p.stop();
    await p.dispose();
  } catch (_) {}
}
