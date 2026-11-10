import 'package:flutter/foundation.dart';

import '../shared/formatadores.dart';

/// Dados da conta da pessoa logada. Versão simulada (sem backend).
///
/// Quem se cadastra pelo e-mail fica sem celular (pedimos ao chamar um
/// profissional); quem se cadastra pelo celular fica sem e-mail (pedimos
/// quando ele faz falta: recibos, cópia dos dados).
class ContaRepo extends ChangeNotifier {
  ContaRepo() {
    restaurar();
  }

  late String nome;
  late String sobrenome;

  /// Celular só com dígitos (DDD + número), ex.: 11988887777.
  String? celular;
  String? email;

  /// Pedido em andamento impede excluir a conta.
  bool pedidoEmAndamento = false;

  String get nomeCompleto => '$nome $sobrenome'.trim();

  /// "+55 (11) 98888-7777" (null sem celular).
  String? get celularFormatado =>
      celular == null ? null : '+55 ${formatarCelular(celular!)}';

  void restaurar() {
    nome = 'Ana';
    sobrenome = 'Martins';
    celular = '11988887777';
    email = 'ana@email.com';
    pedidoEmAndamento = false;
    notifyListeners();
  }

  /// Cadastro novo: guarda só o contato usado para entrar.
  void cadastrou({String? celular, String? email}) {
    this.celular = celular == null ? null : soDigitos(celular);
    this.email = email?.trim();
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
