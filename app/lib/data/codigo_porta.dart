import 'dart:math';

/// RN-39/RN-167: código de 4 dígitos que o cliente passa ao profissional,
/// pessoalmente, na chegada. O profissional digita e o serviço começa
/// sozinho. Só atendimento no local (à distância não tem, RN-95).
abstract final class RegrasCodigo {
  static const digitos = 4;

  /// RN-167: erros até bloquear.
  static const tentativas = 3;

  /// Protótipo: sorteio do código. Nulo = sempre o do desenho ("4821"),
  /// para as capturas e os testes.
  static Random? sorteio = Random();

  /// RN-39: cada atendimento no local gera um código novo.
  static String gerar() {
    final r = sorteio;
    if (r == null) return '4821';
    return [for (var i = 0; i < digitos; i++) r.nextInt(10)].join();
  }
}

enum ResultadoCodigo { certo, errado, bloqueado }

/// RN-167: conferência do código digitado pelo profissional.
class ConferenciaCodigo {
  ConferenciaCodigo(this.codigo);

  final String codigo;
  int erros = 0;
  bool conferido = false;

  int get restam => RegrasCodigo.tentativas - erros;
  bool get bloqueado => erros >= RegrasCodigo.tentativas;

  ResultadoCodigo conferir(String digitado) {
    if (bloqueado) return ResultadoCodigo.bloqueado;
    if (digitado == codigo) {
      conferido = true;
      return ResultadoCodigo.certo;
    }
    erros++;
    return bloqueado ? ResultadoCodigo.bloqueado : ResultadoCodigo.errado;
  }
}
