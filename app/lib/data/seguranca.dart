import 'package:flutter/foundation.dart';

import 'pedidos.dart';
import 'servico_profissional.dart';

/// O atendimento em curso, do ponto de vista de quem usa o app
/// (cliente ou profissional): quem é a outra pessoa e onde é.
@immutable
class Atendimento {
  const Atendimento({
    required this.doCliente,
    required this.outro,
    required this.outroFeminino,
    required this.rua,
    this.complemento = '',
    this.bairro = 'Jardim Primavera, São Paulo',
    this.celularOutro = '(11) 9••••-7777',
    this.pedido = 'TT-48213',
    this.chegouAs = '',
    this.descricao = '',
  });

  /// Quem usa o app é o cliente (senão, o profissional).
  final bool doCliente;

  /// Nome da outra pessoa (cliente ou profissional).
  final String outro;
  final bool outroFeminino;
  final String rua;
  final String complemento;
  final String bairro;
  final String celularOutro;
  final String pedido;

  /// Hora em que o profissional chegou (vazio = ainda não).
  final String chegouAs;
  final String descricao;

  String get primeiroNome => outro.split(' ').first;

  /// "a cliente", "o profissional"…
  String get papel => doCliente
      ? (outroFeminino ? 'a profissional' : 'o profissional')
      : (outroFeminino ? 'a cliente' : 'o cliente');

  static const exemplo = Atendimento(
    doCliente: false,
    outro: 'Ana Martins',
    outroFeminino: true,
    rua: 'Rua das Flores, 120',
    complemento: 'Apto 4',
    chegouAs: '14:32',
  );

  factory Atendimento.doServico(ServicoAceito s, {String chegouAs = ''}) =>
      Atendimento(
        doCliente: false,
        outro: s.cliente,
        outroFeminino: s.feminino,
        rua: s.rua,
        complemento: s.referencia.split(' · ').first,
        bairro: s.bairro,
        celularOutro: s.celularCliente,
        pedido: s.pedido,
        chegouAs: chegouAs,
        descricao: s.descricao,
      );

  factory Atendimento.doPedido(PedidoAndamento p) => Atendimento(
    doCliente: true,
    outro: p.profissional,
    outroFeminino: p.profissao.endsWith('a'),
    rua: p.endereco,
    celularOutro: '(11) 9••••-4321',
    descricao: p.descricao,
  );
}

/// Como o cliente se identifica (só o Tatu vê).
enum Identidade { naoInformado, mulher, homem, outro, prefiroNaoDizer }

extension IdentidadeTexto on Identidade {
  String get nome => switch (this) {
    Identidade.naoInformado => 'Não informado',
    Identidade.mulher => 'Mulher',
    Identidade.homem => 'Homem',
    Identidade.outro => 'Outro',
    Identidade.prefiroNaoDizer => 'Prefiro não dizer',
  };
}

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

  /// Alerta silencioso disparado no atendimento atual, separado por modo
  /// (cliente e profissional). Acaba junto com o atendimento.
  bool alertaCliente = false;
  bool alertaProfissional = false;

  bool alertaAtivoPara({required bool cliente}) =>
      cliente ? alertaCliente : alertaProfissional;

  /// Preferências do cliente: como se identifica e se prefere
  /// profissionais mulheres (só para quem se identifica como mulher).
  Identidade identidade = Identidade.naoInformado;
  bool preferirMulheres = false;

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
    alertaCliente = false;
    alertaProfissional = false;
    identidade = Identidade.naoInformado;
    preferirMulheres = false;
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

  void acionarAlerta({required bool cliente}) {
    if (cliente) {
      alertaCliente = true;
    } else {
      alertaProfissional = true;
    }
    notifyListeners();
  }

  /// Fim do atendimento: o alerta não passa para o próximo pedido.
  void encerrarAlerta({required bool cliente}) {
    if (!alertaAtivoPara(cliente: cliente)) return;
    if (cliente) {
      alertaCliente = false;
    } else {
      alertaProfissional = false;
    }
    notifyListeners();
  }

  void definirIdentidade(Identidade i) {
    identidade = i;
    if (i != Identidade.mulher) preferirMulheres = false;
    notifyListeners();
  }

  void definirPreferirMulheres(bool v) {
    preferirMulheres = v && identidade == Identidade.mulher;
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
