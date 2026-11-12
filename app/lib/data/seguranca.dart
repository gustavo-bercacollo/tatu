import 'package:flutter/foundation.dart';

/// Pessoa que recebe o alerta silencioso do profissional.
@immutable
class ContatoConfianca {
  const ContatoConfianca({
    required this.nome,
    required this.relacao,
    required this.celular,
  });

  final String nome;

  /// "irmã", "marido"…
  final String relacao;

  /// Já mascarado: "(11) 9••••-1234".
  final String celular;
}

/// Segurança do profissional durante o atendimento. Versão simulada
/// (o alerta não chega a ninguém de verdade).
class SegurancaRepo extends ChangeNotifier {
  SegurancaRepo() {
    restaurar();
  }

  static const maxContatos = 5;

  late List<ContatoConfianca> contatos;

  /// Contatos acompanham todo atendimento ao vivo, não só no alerta.
  bool compartilharTudo = true;

  /// Alerta silencioso disparado no atendimento atual.
  bool alertaAtivo = false;

  /// Preferências de atendimento: só clientes mulheres (para
  /// profissionais mulheres) e só clientes verificados.
  bool soMulheres = false;
  bool soVerificados = false;

  void restaurar() {
    contatos = const [
      ContatoConfianca(
        nome: 'Mariana Souza',
        relacao: 'irmã',
        celular: '(11) 9••••-1234',
      ),
      ContatoConfianca(
        nome: 'João Vieira',
        relacao: 'marido',
        celular: '(11) 9••••-5678',
      ),
    ];
    compartilharTudo = true;
    alertaAtivo = false;
    soMulheres = false;
    soVerificados = false;
    notifyListeners();
  }

  void definirSoMulheres(bool v) {
    soMulheres = v;
    notifyListeners();
  }

  void definirSoVerificados(bool v) {
    soVerificados = v;
    notifyListeners();
  }

  void acionarAlerta() {
    alertaAtivo = true;
    notifyListeners();
  }

  void encerrarAlerta() {
    alertaAtivo = false;
    notifyListeners();
  }

  void remover(ContatoConfianca c) {
    contatos = [for (final x in contatos) if (x != c) x];
    notifyListeners();
  }

  void definirCompartilhar(bool v) {
    compartilharTudo = v;
    notifyListeners();
  }
}

final seguranca = SegurancaRepo();
