import 'icone_app_nativo.dart'
    if (dart.library.js_interop) 'icone_app_web.dart'
    as impl;

/// RN-155: número no ícone do app (badge do sistema). No navegador usa a
/// Badging API (app instalado na tela inicial); no Android/iOS entra um
/// plugin depois (TODO), atrás desta mesma função.
abstract final class IconeDoApp {
  /// Último número enviado (os testes conferem).
  static int valor = 0;

  /// Desligado nos testes e capturas (não chama o sistema).
  static bool ativo = true;

  static void definir(int n) {
    if (n == valor) return;
    valor = n;
    if (ativo) impl.definir(n);
  }
}
