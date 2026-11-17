import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';

/// RN-99: bloqueia print e gravação enquanto a prévia protegida está
/// aberta. Android: FLAG_SECURE (print e gravação saem pretos). iPhone: o
/// conteúdo some no print e na gravação, e [onGravando] avisa para
/// esconder a imagem enquanto a tela está sendo gravada. No navegador não
/// há como bloquear (vale a marca d'água).
abstract final class ProtecaoTela {
  /// Desligado nos testes e nas capturas (não há plataforma de verdade).
  static bool ativa = true;

  /// Quantas vezes foi ligada (para os testes conferirem).
  static int ligacoes = 0;

  static bool get _plataforma =>
      ativa &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> ligar({void Function(bool gravando)? onGravando}) async {
    ligacoes++;
    if (!_plataforma) return;
    try {
      await ScreenProtector.preventScreenshotOn();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await ScreenProtector.protectDataLeakageWithBlur();
        ScreenProtector.addListener(null, onGravando);
        if (onGravando != null && await ScreenProtector.isRecording()) {
          onGravando(true);
        }
      }
    } on MissingPluginException {
      // Sem o plugin (ex.: testes de integração): segue com a marca d'água.
    } on PlatformException {
      // Idem.
    }
  }

  static Future<void> desligar() async {
    if (!_plataforma) return;
    try {
      await ScreenProtector.preventScreenshotOff();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await ScreenProtector.protectDataLeakageWithBlurOff();
        ScreenProtector.removeListener();
      }
    } on MissingPluginException {
      // Ver [ligar].
    } on PlatformException {
      // Idem.
    }
  }
}
