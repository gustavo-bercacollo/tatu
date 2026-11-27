import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'limites.dart';

/// RN-248: limites contra robôs e teste de cartão. No backend, o servidor
/// conta por número, por aparelho e por conta; aqui, o protótipo conta no
/// próprio aparelho.
class LimitesUsoRepo extends ChangeNotifier {
  /// Envios do código de acesso, por número ou e-mail.
  final _codigos = <String, List<DateTime>>{};

  /// Envios do código deste aparelho (qualquer número).
  final _codigosAparelho = <DateTime>[];

  /// Cartões recusados na conta.
  final _cartoesRecusados = <DateTime>[];

  /// Pedidos novos da conta.
  final _pedidos = <DateTime>[];

  /// RN-248: até quando não dá para pedir outro código para [destino]
  /// (nulo = pode). Vale o limite de 15 minutos e o do dia, por número e
  /// por aparelho.
  DateTime? codigoLiberadoEm(String destino, {DateTime? agora}) {
    final hoje = agora ?? clock.now();
    DateTime? libera;
    for (final lista in [
      _codigos[destino] ?? const <DateTime>[],
      _codigosAparelho,
    ]) {
      final janela = lista
          .where((d) => hoje.difference(d) < Limites.janelaCodigos)
          .toList();
      if (janela.length >= Limites.codigosPorJanela) {
        final l = janela.first.add(Limites.janelaCodigos);
        if (libera == null || l.isAfter(libera)) libera = l;
      }
      final dia = lista
          .where((d) => hoje.difference(d) < const Duration(days: 1))
          .toList();
      if (dia.length >= Limites.codigosPorDia) {
        final l = dia.first.add(const Duration(days: 1));
        if (libera == null || l.isAfter(libera)) libera = l;
      }
    }
    return libera;
  }

  /// RN-248: manda o código (devolve falso se passou do limite).
  bool enviarCodigo(String destino, {DateTime? agora}) {
    final hoje = agora ?? clock.now();
    if (codigoLiberadoEm(destino, agora: hoje) != null) return false;
    (_codigos[destino] ??= []).add(hoje);
    _codigosAparelho.add(hoje);
    notifyListeners();
    return true;
  }

  /// RN-248: o banco recusou um cartão desta conta.
  void cartaoRecusado({DateTime? agora}) {
    _cartoesRecusados.add(agora ?? clock.now());
    notifyListeners();
  }

  /// RN-248: com 3 cartões recusados em 24 horas, só Pix até o dia
  /// seguinte. Devolve até quando (nulo = cartão liberado).
  DateTime? soPixAte({DateTime? agora}) {
    final hoje = agora ?? clock.now();
    final recentes = _cartoesRecusados
        .where((d) => hoje.difference(d) < Limites.janelaCartoes)
        .toList();
    if (recentes.length < Limites.cartoesRecusados) return null;
    final ultimo = recentes.last;
    return DateTime(ultimo.year, ultimo.month, ultimo.day + 1);
  }

  bool get soPix => soPixAte() != null;

  /// RN-248: até quando não dá para fazer pedido novo (nulo = pode).
  DateTime? pedidoLiberadoEm({DateTime? agora}) {
    final hoje = agora ?? clock.now();
    final hora = _pedidos
        .where((d) => hoje.difference(d) < const Duration(hours: 1))
        .toList();
    if (hora.length < Limites.pedidosPorHora) return null;
    return hora.first.add(const Duration(hours: 1));
  }

  /// RN-248: conta um pedido novo (devolve falso se passou do limite).
  bool registrarPedido({DateTime? agora}) {
    final hoje = agora ?? clock.now();
    if (pedidoLiberadoEm(agora: hoje) != null) return false;
    _pedidos.add(hoje);
    return true;
  }

  void restaurar() {
    _codigos.clear();
    _codigosAparelho.clear();
    _cartoesRecusados.clear();
    _pedidos.clear();
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final limitesUso = LimitesUsoRepo();
