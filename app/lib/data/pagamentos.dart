import 'package:flutter/foundation.dart';

@immutable
class Cartao {
  const Cartao({
    required this.id,
    required this.bandeira,
    required this.final4,
    required this.validade,
    required this.nome,
  });

  final String id;
  final String bandeira;
  final String final4;

  /// MM/AA
  final String validade;

  /// Nome impresso no cartão.
  final String nome;

  String get titulo => '$bandeira final $final4';

  /// Forma curta, ex.: "Visa 4242" (valor no Perfil).
  String get curto => '$bandeira $final4';
}

/// Por que um cartão novo não foi salvo.
enum ErroCartao { recusado }

/// Formas de pagamento do cliente. Versão simulada (sem backend): cartões
/// em memória. O banco "recusa" cartões terminados em 0002, para a demo.
class PagamentosRepo extends ChangeNotifier {
  PagamentosRepo() {
    restaurar();
  }

  late List<Cartao> _cartoes;
  String? _padraoId;

  List<Cartao> get cartoes => List.unmodifiable(_cartoes);
  Cartao? get padrao => _cartoes.where((c) => c.id == _padraoId).firstOrNull;
  bool ePadrao(Cartao c) => c.id == _padraoId;

  /// Volta aos dados de exemplo (usado nos testes).
  void restaurar() {
    _cartoes = [
      const Cartao(
        id: 'visa',
        bandeira: 'Visa',
        final4: '4242',
        validade: '08/28',
        nome: 'ANA MARTINS',
      ),
      const Cartao(
        id: 'master',
        bandeira: 'Mastercard',
        final4: '1881',
        validade: '03/27',
        nome: 'ANA MARTINS',
      ),
    ];
    _padraoId = 'visa';
    notifyListeners();
  }

  static String bandeiraDe(String numero) =>
      switch (numero.isEmpty ? '' : numero[0]) {
        '4' => 'Visa',
        '5' => 'Mastercard',
        '3' => 'Amex',
        '6' => 'Elo',
        _ => 'Cartão',
      };

  /// Tenta salvar; devolve o erro se o banco recusar.
  ErroCartao? adicionar({
    required String numero,
    required String validade,
    required String nome,
    required bool padrao,
  }) {
    if (numero.endsWith('0002')) return ErroCartao.recusado;
    final c = Cartao(
      id: 'c${DateTime.now().microsecondsSinceEpoch}',
      bandeira: bandeiraDe(numero),
      final4: numero.substring(numero.length - 4),
      validade: validade,
      nome: nome.toUpperCase(),
    );
    _cartoes.add(c);
    if (padrao || _padraoId == null) _padraoId = c.id;
    notifyListeners();
    return null;
  }

  void definirPadrao(Cartao c, bool sim) {
    _padraoId = sim ? c.id : (_padraoId == c.id ? null : _padraoId);
    notifyListeners();
  }

  void remover(Cartao c) {
    _cartoes.removeWhere((x) => x.id == c.id);
    // O padrão saiu: o próximo cartão vira padrão.
    if (_padraoId == c.id) _padraoId = _cartoes.firstOrNull?.id;
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final pagamentos = PagamentosRepo();
