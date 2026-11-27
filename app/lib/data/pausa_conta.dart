import 'limites.dart';
import 'plano_fixo.dart' show diaMes;

/// O que pausou a conta (RN-63, RN-79, RN-82, RN-106, RN-193).
enum CausaPausa { visitas, abandonos, sinais, faltas, ausencias }

/// RN-244: uma pausa da conta. A 1ª em 6 meses volta sozinha em 7 dias,
/// a 2ª em 30 dias; da 3ª em diante, fica parada até o suporte analisar.
class PausaConta {
  PausaConta({
    required this.inicio,
    required this.ordem,
    required this.causa,
    required this.motivo,
  });

  final DateTime inicio;

  /// Qual pausa é esta dentro da janela de 6 meses (1, 2, 3…).
  final int ordem;
  final CausaPausa causa;

  /// O motivo, do jeito que a pessoa vê ("3 chamados abandonados em 30
  /// dias.").
  final String motivo;

  /// A pessoa já tocou em "Entendi".
  bool entendida = false;

  /// Quando a conta volta sozinha (nulo = só depois da análise do
  /// suporte).
  DateTime? get voltaEm => switch (ordem) {
    1 => inicio.add(Limites.voltaPrimeiraPausa),
    2 => inicio.add(Limites.voltaSegundaPausa),
    _ => null,
  };

  bool get esperaSuporte => voltaEm == null;

  bool ativa(DateTime agora) => voltaEm == null || agora.isBefore(voltaEm!);

  /// "Sua conta volta sozinha em 3 dez." / "…até o suporte analisar."
  String get quandoVolta => voltaEm == null
      ? 'Sua conta fica parada até o suporte analisar.'
      : 'Sua conta volta sozinha em ${diaMes(voltaEm!)}.';
}

/// RN-244: histórico das pausas de uma conta.
class PausasConta {
  final _historico = <PausaConta>[];

  List<PausaConta> get historico => List.unmodifiable(_historico);

  PausaConta? get ultima => _historico.isEmpty ? null : _historico.last;

  /// A pausa que vale agora (nula = conta ativa).
  PausaConta? atual(DateTime agora) {
    final p = ultima;
    return p != null && p.ativa(agora) ? p : null;
  }

  /// Os eventos que contam para uma pausa nova são só os depois do início
  /// da última (quem volta começa do zero).
  DateTime? get contarDepois => ultima?.inicio;

  /// Abre uma pausa nova (se não houver uma valendo) e devolve a que vale.
  PausaConta abrir(DateTime agora, CausaPausa causa, String motivo) {
    final a = atual(agora);
    if (a != null) return a;
    final ordem =
        Limites.naJanela(
          _historico.map((p) => p.inicio),
          Limites.janelaPausas,
          agora,
        ) +
        1;
    final p = PausaConta(
      inicio: agora,
      ordem: ordem,
      causa: causa,
      motivo: motivo,
    );
    _historico.add(p);
    return p;
  }

  /// Demonstração e testes: pausas antigas na janela (a próxima vira a
  /// 2ª ou a 3ª).
  void antigas(List<DateTime> inicios, CausaPausa causa) {
    for (final i in inicios) {
      _historico.add(
        PausaConta(inicio: i, ordem: 1, causa: causa, motivo: '')
          ..entendida = true,
      );
    }
  }

  void limpar() => _historico.clear();
}
