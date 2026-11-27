import 'package:flutter/foundation.dart';

import 'base_tecnica.dart';

import 'limites_uso.dart';
import 'pagamento.dart';

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

  /// RN-223/RN-225 (simulação do banco): recusa todas as reservas. Nos
  /// testes e para demonstrar. Cartões terminados em 0341 também recusam.
  static bool recusarReservas = false;

  /// RN-226 (simulação): a cobrança ao concluir falha mesmo nas novas
  /// tentativas.
  static bool falharCobranca = false;

  /// RN-226: valor que não foi cobrado depois das tentativas (nulo = nada
  /// pendente). Com pendência, o cliente não faz pedido novo.
  double? pendencia;

  bool get temPendencia => pendencia != null;

  /// RN-222/RN-223: o banco aprova a reserva no cartão?
  /// RN-248: com 3 cartões recusados em 24 horas, só Pix até o dia
  /// seguinte (o cartão nem é tentado).
  bool reservar(Cartao? c) {
    if (limitesUso.soPix) return false;
    final ok = c != null && !recusarReservas && c.final4 != '0341';
    if (!ok && c != null) limitesUso.cartaoRecusado();
    return ok;
  }

  /// RN-226: cobra ao concluir (a reserva já estava separada). Falha
  /// técnica: tenta de novo sozinho; o profissional recebe de qualquer
  /// jeito. Só se todas falharem, fica a pendência. Devolve se cobrou.
  /// [chave]: chave única da cobrança. Tentar de novo com a mesma chave
  /// nunca cobra duas vezes (devolve o resultado da 1ª vez).
  bool cobrarAoConcluir(double valor, {String? chave}) {
    bool cobrar() {
      for (var i = 0; i < RegrasPagamento.tentativasCobranca; i++) {
        if (!falharCobranca) return true;
      }
      pendencia = (pendencia ?? 0) + valor;
      notifyListeners();
      return false;
    }

    return chave == null ? cobrar() : idempotencia.executar(chave, cobrar);
  }

  /// RN-226: o cliente atualizou o cartão: cobra a pendência de novo.
  void _tentarPendencia() {
    if (pendencia == null || falharCobranca || !reservar(padrao)) return;
    pendencia = null;
  }

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
    pendencia = null;
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
    _tentarPendencia();
    notifyListeners();
    return null;
  }

  void definirPadrao(Cartao c, bool sim) {
    _padraoId = sim ? c.id : (_padraoId == c.id ? null : _padraoId);
    _tentarPendencia();
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
