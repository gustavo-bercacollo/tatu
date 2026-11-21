import 'package:flutter/foundation.dart';

/// RN-41: ao concluir, os dois se avaliam. Aqui ficam as avaliações que o
/// profissional deu aos clientes.
@immutable
class AvaliacaoDoCliente {
  const AvaliacaoDoCliente({
    required this.cliente,
    required this.nota,
    this.elogios = const [],
    this.comentario = '',
  });

  final String cliente;

  /// 1 a 5 estrelas.
  final int nota;
  final List<String> elogios;
  final String comentario;
}

/// Elogios que o profissional pode dar ao cliente.
List<String> elogiosDoCliente({required bool feminino}) => [
  feminino ? 'Educada' : 'Educado',
  'Pagou rápido',
  'Local organizado',
];

/// Avaliações enviadas pelo profissional. Versão simulada (sem backend).
class AvaliacoesDeClientesRepo extends ChangeNotifier {
  final _enviadas = <AvaliacaoDoCliente>[];

  List<AvaliacaoDoCliente> get enviadas => List.unmodifiable(_enviadas);

  /// Já avaliou este cliente (neste atendimento)?
  bool avaliou(String cliente) => _enviadas.any((a) => a.cliente == cliente);

  void restaurar() {
    _enviadas.clear();
    notifyListeners();
  }

  /// RN-41: guarda a avaliação (nota obrigatória, de 1 a 5).
  bool avaliar(AvaliacaoDoCliente a) {
    if (a.nota < 1 || a.nota > 5) return false;
    _enviadas
      ..removeWhere((x) => x.cliente == a.cliente)
      ..add(a);
    notifyListeners();
    return true;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final avaliacoesDeClientes = AvaliacoesDeClientesRepo();
