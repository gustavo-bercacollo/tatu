import 'package:flutter/foundation.dart';

import 'pedidos.dart';
import 'retorno.dart';

/// RN-197: termo de garantia do recibo (CDC, art. 50, parágrafo único).
/// O mesmo texto vai na tela, no PDF e no e-mail do recibo.
@immutable
class GarantiaRecibo {
  const GarantiaRecibo({required this.retorno, required this.dias});

  /// Até quando vale o retorno sem custo (nulo = pedido sem conclusão).
  final DateTime? retorno;

  /// 30 ou 90 dias, pela profissão (RN-183).
  final int dias;

  static const titulo = 'Garantia';
  static const comoPedir = 'Como pedir: Atividade → serviço → Algo errado?';
  static const direitos = 'Seus direitos pelo Código do Consumidor continuam.';
  static const link = 'Ver termo de garantia';

  /// "Retorno sem custo até 02 fev (90 dias)".
  String get linhaRetorno => retorno == null
      ? 'Retorno sem custo por $dias dias depois do serviço'
      : 'Retorno sem custo até ${dataCurta(retorno!)} ($dias dias)';

  List<String> get linhas => [titulo, linhaRetorno, comoPedir, direitos];
}

GarantiaRecibo garantiaDe(PedidoConcluido p) => GarantiaRecibo(
  retorno: p.retornoAte,
  dias: RegrasRetorno.prazoDias(p.servico),
);

/// Texto do recibo (PDF e e-mail): dados do pagamento e a garantia.
List<String> conteudoRecibo(PedidoConcluido p) => [
  'Recibo Tatu · ${p.numero}',
  '${p.servico} · ${p.dia} ${p.ano}, ${p.hora}',
  'Total: ${p.valor} · Pago · ${p.pagamento}',
  'Serviço: ${p.descricao}',
  'Profissional: ${p.profissional}',
  'Endereço: ${p.endereco}',
  '',
  ...garantiaDe(p).linhas,
  'Termo de garantia: seção 11 dos Termos de Uso.',
];

/// Recibos gerados. Versão simulada: guarda o que iria no PDF e no e-mail.
class RecibosRepo extends ChangeNotifier {
  final pdfs = <String, List<String>>{};
  final emails = <(String, List<String>)>[];

  /// "Baixar PDF".
  List<String> gerarPdf(PedidoConcluido p) {
    final c = conteudoRecibo(p);
    pdfs[p.numero] = c;
    notifyListeners();
    return c;
  }

  /// "Enviar por e-mail".
  void enviarEmail(PedidoConcluido p, String email) {
    emails.add((email, conteudoRecibo(p)));
    notifyListeners();
  }

  void restaurar() {
    pdfs.clear();
    emails.clear();
    notifyListeners();
  }
}

final recibos = RecibosRepo();
