import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../shared/formatadores.dart';

/// RN-141 a RN-143: gorjeta ("pagar um café") na avaliação.
abstract final class RegrasGorjeta {
  /// RN-141: valores prontos.
  static const opcoes = [2.0, 5.0, 10.0];

  /// RN-141: valor máximo da gorjeta. Exemplo.
  static const maximo = 100.0;

  /// RN-142: taxa do cartão descontada da gorjeta. Exemplo (depende do
  /// meio de pagamento escolhido; decisão em aberto).
  static const taxaCartao = 0.04;

  /// RN-142: o Tatu não cobra comissão sobre a gorjeta.
  static const comissaoTatu = 0.0;

  static bool valida(double valor) => valor > 0 && valor <= maximo;

  /// RN-142: só a taxa do cartão sai da gorjeta.
  static double taxa(double valor) =>
      (valor * taxaCartao * 100).roundToDouble() / 100;

  /// RN-142: 100% para o profissional, menos a taxa do cartão.
  static double repasse(double valor) =>
      valor - taxa(valor) - valor * comissaoTatu;
}

/// Gorjeta cobrada junto com a avaliação.
@immutable
class Gorjeta {
  const Gorjeta({
    required this.cliente,
    required this.profissional,
    required this.valor,
    required this.cartao,
    required this.em,
  });

  final String cliente;
  final String profissional;
  final double valor;

  /// "Visa 4242": o cartão padrão (RN-142).
  final String cartao;
  final DateTime em;

  double get repasse => RegrasGorjeta.repasse(valor);

  /// RN-143: o único aviso que o profissional recebe.
  String get aviso => '$cliente deixou ${reaisInteiros(valor)} de gorjeta';
}

/// Gorjetas cobradas. Versão simulada (sem backend nem cobrança real).
class GorjetasRepo extends ChangeNotifier {
  final _cobradas = <Gorjeta>[];

  /// RN-143: notificações enviadas ao profissional.
  final avisos = <String>[];

  List<Gorjeta> get cobradas => List.unmodifiable(_cobradas);

  /// RN-142: vai no Pix junto com o próximo repasse.
  double proximoRepasse(String profissional) => _cobradas
      .where((g) => g.profissional == profissional)
      .fold(0.0, (t, g) => t + g.repasse);

  void restaurar() {
    _cobradas.clear();
    avisos.clear();
    notifyListeners();
  }

  /// RN-141/RN-142: cobra no cartão padrão, no mesmo toque da avaliação.
  /// Só depois do serviço concluído; acima do máximo, não cobra nada.
  Gorjeta? cobrar({
    required String cliente,
    required String profissional,
    required double valor,
    required String? cartao,
    required bool servicoConcluido,
  }) {
    if (!servicoConcluido || cartao == null) return null;
    if (!RegrasGorjeta.valida(valor)) return null;
    final g = Gorjeta(
      cliente: cliente,
      profissional: profissional,
      valor: valor,
      cartao: cartao,
      em: clock.now(),
    );
    _cobradas.add(g);
    avisos.add(g.aviso);
    notifyListeners();
    return g;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final gorjetas = GorjetasRepo();
