import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Badging API do navegador (só onde existe; senão, nada acontece).
void definir(int n) {
  try {
    final nav = globalContext['navigator'] as JSObject?;
    if (nav == null) return;
    if (n > 0 && nav.has('setAppBadge')) {
      nav.callMethod('setAppBadge'.toJS, n.toJS);
    } else if (n <= 0 && nav.has('clearAppBadge')) {
      nav.callMethod('clearAppBadge'.toJS);
    }
  } catch (_) {
    // Navegador sem a API: o contador continua na aba.
  }
}
