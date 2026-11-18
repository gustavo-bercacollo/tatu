import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// RN-162: profissão sugerida pelo profissional ("Não achei a minha").

enum StatusSugestao { emAnalise, aprovada, recusada }

abstract final class RegrasSugestao {
  /// RN-162: análise em até 2 dias úteis (exemplo).
  static const diasUteis = 2;

  static const minimoLetras = 3;
}

class SugestaoProfissao {
  SugestaoProfissao({
    required this.nome,
    required this.profissional,
    required this.em,
  });

  final String nome;

  /// Quem sugeriu.
  final String profissional;
  final DateTime em;
  StatusSugestao status = StatusSugestao.emAnalise;
}

/// Sugestões. A fila do suporte é a mesma lista (o suporte aprova e, aí,
/// a profissão entra no catálogo para todos com nova versão do `.md`).
class SugestoesProfissaoRepo extends ChangeNotifier {
  final _fila = <SugestaoProfissao>[];

  /// Fila do suporte (mais antigas primeiro).
  List<SugestaoProfissao> get filaSuporte => List.unmodifiable(_fila);

  /// RN-162: as sugestões deste profissional (aparecem no perfil dele).
  List<SugestaoProfissao> de(String profissional) => [
    for (final s in _fila)
      if (s.profissional == profissional) s,
  ];

  void restaurar() {
    _fila.clear();
    notifyListeners();
  }

  /// RN-162: envia a sugestão; fica em análise. Nula se o nome for curto
  /// ou já sugerido por esta pessoa.
  SugestaoProfissao? sugerir(String nome, {required String profissional}) {
    final n = nome.trim();
    if (n.length < RegrasSugestao.minimoLetras) return null;
    if (de(profissional).any((s) => s.nome.toLowerCase() == n.toLowerCase())) {
      return null;
    }
    final s = SugestaoProfissao(
      nome: n,
      profissional: profissional,
      em: clock.now(),
    );
    _fila.add(s);
    notifyListeners();
    return s;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final sugestoesProfissao = SugestoesProfissaoRepo();
