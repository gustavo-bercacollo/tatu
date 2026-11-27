import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../shared/formatadores.dart';
import 'pausa_conta.dart';
import 'prazos.dart';

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

  /// RN-111: CPF (só dígitos); a idade vem dele.
  String? cpf;

  void definirCpf(String texto) {
    cpf = soDigitos(texto);
    notifyListeners();
  }

  /// Pedido em andamento impede excluir a conta.
  bool pedidoEmAndamento = false;

  /// RN-82: quando o cliente não apareceu (profissional esperou e
  /// cobrou a visita).
  List<DateTime> ausencias = [];

  /// Ausências dentro de [Prazos.janelaAusencias] (só as depois da
  /// última pausa: quem volta começa do zero, RN-244).
  int get ausenciasRecentes {
    final desde = clock.now().subtract(Prazos.janelaAusencias);
    final depois = pausas.contarDepois;
    return ausencias
        .where((d) => d.isAfter(desde) && (depois == null || d.isAfter(depois)))
        .length;
  }

  /// RN-244: histórico das pausas da conta.
  final pausas = PausasConta();

  /// RN-82/RN-244: a pausa que vale agora (abre uma se passou do limite).
  PausaConta? get pausa {
    final agora = clock.now();
    final a = pausas.atual(agora);
    if (a != null) return a;
    if (ausenciasRecentes < Prazos.ausenciasParaPausar) return null;
    return pausas.abrir(
      agora,
      CausaPausa.ausencias,
      '$ausenciasRecentes ausências em ${Prazos.janelaAusencias.inDays} dias.',
    );
  }

  /// RN-82: conta pausada; não chama ninguém (RN-244: volta sozinha na
  /// 1ª e na 2ª pausa).
  bool get pausadaPorAusencias => pausa != null;

  /// RN-244: "Entendi" no aviso da pausa.
  void entenderPausa() {
    final p = pausa;
    if (p == null || p.entendida) return;
    p.entendida = true;
    notifyListeners();
  }

  void registrarAusencia() {
    ausencias = [...ausencias, clock.now()];
    notifyListeners();
  }

  /// Simula a conta pausada por ausências (RN-82), para a demo.
  void pausarPorAusenciasParaDemo() {
    final agora = clock.now();
    ausencias = [
      for (var i = 0; i < Prazos.ausenciasParaPausar; i++)
        agora.subtract(Duration(days: 3 + i * 6)),
    ];
    notifyListeners();
  }

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
    ausencias = [];
    pausas.limpar();
    cpf = null;
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
