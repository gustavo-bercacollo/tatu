import 'package:clock/clock.dart';

/// RN-222 a RN-226: o que acontece quando o pagamento falha. Os números
/// são exemplos a confirmar (mude só aqui).
abstract final class RegrasPagamento {
  /// RN-223: tempo para pagar depois de o cartão ser recusado; depois o
  /// valor expira e o profissional fica livre, sem falta para ninguém.
  static const prazoPagar = Duration(minutes: 10);

  /// RN-224: validade do código Pix.
  static const validadePix = Duration(minutes: 30);

  /// RN-226: tentativas automáticas da cobrança ao concluir.
  static const tentativasCobranca = 3;

  /// RN-225: o cliente resolve a visita suspensa até a véspera, às 20h.
  static const horaLimiteVespera = 20;
}

/// RN-222 a RN-224: em que pé está o pagamento de um valor confirmado.
enum SituacaoPagamento {
  /// Reserva aprovada no cartão ou Pix pago: o profissional pode ir.
  garantido,

  /// RN-223: o cartão recusou a reserva (o profissional não sabe disso).
  recusado,

  /// RN-224: código Pix gerado, esperando o pagamento.
  pixAguardando,

  /// RN-223/RN-224: passou o prazo sem pagamento; nada foi cobrado.
  expirado,
}

/// RN-222 a RN-224: o pagamento de um valor.
class PagamentoValor {
  PagamentoValor({
    required this.situacao,
    DateTime? desde,
    this.cartaoRecusado,
    this.pixAte,
  }) : desde = desde ?? clock.now();

  SituacaoPagamento situacao;

  /// Quando ficou pendente (conta o prazo de 10 minutos).
  DateTime desde;

  /// "Visa final 4242" (só o cliente vê).
  String? cartaoRecusado;

  /// RN-224: até quando vale o código Pix.
  DateTime? pixAte;

  bool get garantido => situacao == SituacaoPagamento.garantido;
  bool get expirado => situacao == SituacaoPagamento.expirado;

  /// Ainda esperando o cliente pagar (cartão recusado ou Pix gerado).
  bool get pendente =>
      situacao == SituacaoPagamento.recusado ||
      situacao == SituacaoPagamento.pixAguardando;

  /// Até quando o cliente pode pagar.
  DateTime get prazo => situacao == SituacaoPagamento.pixAguardando
      ? (pixAte ?? desde.add(RegrasPagamento.validadePix))
      : desde.add(RegrasPagamento.prazoPagar);
}

/// RN-224: código Pix de exemplo (copia e cola).
String codigoPixDemo(double valor) =>
    '00020126580014BR.GOV.BCB.PIX0136tatu-pagamentos-demo'
    '52040000530398654${valor.toStringAsFixed(2).length.toString().padLeft(2, '0')}'
    '${valor.toStringAsFixed(2)}5802BR5904TATU6009SAO PAULO62070503***6304ABCD';
