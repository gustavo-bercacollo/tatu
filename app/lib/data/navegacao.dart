import 'package:flutter/foundation.dart';

/// App usado em "Abrir rota".
enum AppNavegacao { perguntar, google, waze, apple }

extension AppNavegacaoTexto on AppNavegacao {
  String get nome => switch (this) {
    AppNavegacao.perguntar => 'Perguntar sempre',
    AppNavegacao.google => 'Google Maps',
    AppNavegacao.waze => 'Waze',
    AppNavegacao.apple => 'Apple Mapas',
  };

  /// Link da rota até [endereco] no app (abre no navegador se não houver).
  Uri link(String endereco) {
    final e = Uri.encodeComponent(endereco);
    return switch (this) {
      AppNavegacao.waze => Uri.parse('https://waze.com/ul?q=$e&navigate=yes'),
      AppNavegacao.apple => Uri.parse('https://maps.apple.com/?daddr=$e'),
      _ => Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$e',
      ),
    };
  }

  /// Onde baixar o app.
  Uri get loja => switch (this) {
    AppNavegacao.waze => Uri.parse(
      'https://play.google.com/store/apps/details?id=com.waze',
    ),
    AppNavegacao.apple => Uri.parse('https://apps.apple.com/app/id915056765'),
    _ => Uri.parse(
      'https://play.google.com/store/apps/details?id=com.google.android.apps.maps',
    ),
  };
}

/// Rota e localização do profissional. Versão simulada (sem GPS real).
class NavegacaoRepo extends ChangeNotifier {
  NavegacaoRepo() {
    restaurar();
    // Na demo, a 1ª ida até o cliente pede para ativar a localização.
    localizacaoAtiva = false;
  }

  AppNavegacao preferido = AppNavegacao.perguntar;

  /// Apps instalados no celular (simulado: sem o Waze).
  Set<AppNavegacao> instalados = {AppNavegacao.google, AppNavegacao.apple};

  bool localizacaoAtiva = true;

  void restaurar() {
    preferido = AppNavegacao.perguntar;
    instalados = {AppNavegacao.google, AppNavegacao.apple};
    localizacaoAtiva = true;
    notifyListeners();
  }

  void escolher(AppNavegacao a) {
    preferido = a;
    notifyListeners();
  }

  void ativarLocalizacao([bool ativa = true]) {
    localizacaoAtiva = ativa;
    notifyListeners();
  }
}

final navegacao = NavegacaoRepo();
