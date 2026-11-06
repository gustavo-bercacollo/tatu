import 'package:flutter/foundation.dart';

import '../shared/formatadores.dart';

/// Dados da conta da pessoa logada. Versão simulada (sem backend).
class ContaRepo extends ChangeNotifier {
  ContaRepo() {
    restaurar();
  }

  late String nome;
  late String sobrenome;

  /// Celular só com dígitos (DDD + número), ex.: 11988887777.
  late String celular;
  late String email;

  /// Pedido em andamento impede excluir a conta.
  bool pedidoEmAndamento = false;

  String get nomeCompleto => '$nome $sobrenome'.trim();

  /// "+55 (11) 98888-7777".
  String get celularFormatado => '+55 ${formatarCelular(celular)}';

  void restaurar() {
    nome = 'Ana';
    sobrenome = 'Martins';
    celular = '11988887777';
    email = 'ana@email.com';
    pedidoEmAndamento = false;
    notifyListeners();
  }

  void definirNome(String n, String s) {
    nome = n.trim();
    sobrenome = s.trim();
    notifyListeners();
  }

  void definirCelular(String digitos) {
    celular = soDigitos(digitos);
    notifyListeners();
  }

  void definirEmail(String e) {
    email = e.trim();
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final conta = ContaRepo();
