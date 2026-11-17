import 'package:clock/clock.dart';

import '../shared/formatadores.dart';

/// RN-110: o Tatu é só para maiores de 18 anos (cliente e profissional).
abstract final class RegrasIdade {
  static const idadeMinima = 18;

  /// Idade completa em [hoje] de quem nasceu em [nascimento].
  static int idade(DateTime nascimento, DateTime hoje) {
    var anos = hoje.year - nascimento.year;
    final fezAniversario =
        hoje.month > nascimento.month ||
        (hoje.month == nascimento.month && hoje.day >= nascimento.day);
    if (!fezAniversario) anos--;
    return anos;
  }

  /// RN-110: já fez 18 anos em [hoje]? (18 exatos entra.)
  static bool maiorDeIdade(DateTime nascimento, [DateTime? hoje]) =>
      idade(nascimento, hoje ?? clock.now()) >= idadeMinima;
}

/// RN-111/RN-114: descobre a data de nascimento pelo CPF (a idade é
/// verificada, não só declarada). Depois entra um serviço que consulta a
/// Receita (ex.: Consulta CPF do Serpro); decisão em aberto.
abstract class ConsultaCpf {
  /// Data de nascimento do dono do [cpf] (nulo se não achar).
  Future<DateTime?> nascimento(String cpf);
}

/// Versão simulada (sem backend). Todo CPF é de um adulto, menos os de
/// demonstração em [menores].
class ConsultaCpfMock implements ConsultaCpf {
  ConsultaCpfMock({this.demora = const Duration(milliseconds: 400)});

  final Duration demora;

  /// CPFs de demonstração de menores de idade (16 anos).
  static const menores = {'52998224725'};

  /// Datas fixas para os testes (CPF → nascimento).
  final Map<String, DateTime> fixos = {};

  @override
  Future<DateTime?> nascimento(String cpf) async {
    if (demora > Duration.zero) await Future<void>.delayed(demora);
    final d = soDigitos(cpf);
    final fixo = fixos[d];
    if (fixo != null) return fixo;
    if (menores.contains(d)) {
      final hoje = clock.now();
      return DateTime(hoje.year - 16, hoje.month, hoje.day);
    }
    return DateTime(1990, 5, 12);
  }
}

/// Consulta usada pelo app (trocada nos testes).
ConsultaCpf consultaCpf = ConsultaCpfMock();

/// RN-110 a RN-112: o dono do CPF já tem 18 anos? (Sem resposta da
/// consulta, deixa seguir: a verificação com documento confirma depois.)
Future<bool> cpfDeMaior(String cpf) async {
  final n = await consultaCpf.nascimento(cpf);
  return n == null || RegrasIdade.maiorDeIdade(n);
}
