import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'canal_tatu.dart';
import 'documentos_legais.dart';

/// RN-150/RN-151: aceite ativo dos Termos de Uso e da Política de
/// Privacidade, registrado com as versões e a data.

/// Quem aceitou.
enum TipoAceite { cliente, profissional }

@immutable
class Aceite {
  const Aceite({
    required this.conta,
    required this.tipo,
    required this.versaoTermos,
    required this.versaoPolitica,
    required this.em,
  });

  /// Identificação da conta (CPF; nome enquanto não há CPF).
  final String conta;
  final TipoAceite tipo;
  final String versaoTermos;
  final String versaoPolitica;

  /// Data e hora do aceite.
  final DateTime em;
}

/// Versão de cada documento que vale hoje. Se uma versão nova ainda não
/// começou a valer, vale a anterior (RN-151).
String versaoVigente(DocumentoLegal d, [DateTime? agora]) =>
    d.versaoEm(agora ?? clock.now());

/// Aceites registrados. Versão simulada (sem backend).
class AceitesRepo extends ChangeNotifier {
  final _aceites = <Aceite>[];

  /// RN-151: avisos de versão futura já mandados pelo canal do Tatu.
  final _avisados = <String>{};

  List<Aceite> get todos => List.unmodifiable(_aceites);

  /// Demonstração: a conta da Ana já aceitou as versões atuais (Termos
  /// 1.1, Política 1.1) nos dois modos.
  void restaurar({bool comDemo = true}) {
    _aceites.clear();
    _avisados.clear();
    if (comDemo) {
      for (final t in TipoAceite.values) {
        _aceites.add(
          Aceite(
            conta: demoConta,
            tipo: t,
            versaoTermos: '1.1',
            versaoPolitica: '1.1',
            em: DateTime(2026, 11, 2, 10),
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Conta da demonstração (Ana Martins).
  static const demoConta = 'Ana Martins';

  /// RN-150: registra o aceite com as versões vigentes e a data e hora.
  Aceite registrar({
    required String conta,
    required TipoAceite tipo,
    required DocumentoLegal termos,
    required DocumentoLegal politica,
    DateTime? agora,
  }) {
    final em = agora ?? clock.now();
    final a = Aceite(
      conta: conta,
      tipo: tipo,
      versaoTermos: versaoVigente(termos, em),
      versaoPolitica: versaoVigente(politica, em),
      em: em,
    );
    _aceites.add(a);
    notifyListeners();
    return a;
  }

  Aceite? ultimo(String conta, TipoAceite tipo) =>
      _aceites.where((a) => a.conta == conta && a.tipo == tipo).lastOrNull;

  /// RN-151: a versão que vale hoje ainda não foi aceita por esta conta?
  /// (Conta sem nenhum aceite é cadastro antigo da demo: também pede.)
  bool precisaAceitar({
    required String conta,
    required TipoAceite tipo,
    required DocumentoLegal termos,
    required DocumentoLegal politica,
    DateTime? agora,
  }) {
    final a = ultimo(conta, tipo);
    if (a == null) return true;
    return a.versaoTermos != versaoVigente(termos, agora) ||
        a.versaoPolitica != versaoVigente(politica, agora);
  }

  /// RN-151: versão nova com data futura é avisada pelo canal oficial
  /// (com antecedência; uma vez por versão).
  void avisarVersaoFutura(
    DocumentoLegal d, {
    required CanalTatu canal,
    DateTime? agora,
  }) {
    final hoje = agora ?? clock.now();
    if (!d.vigencia.isAfter(hoje)) return;
    final chave = '${d.tipo.name}-${d.versao}';
    if (!_avisados.add(chave)) return;
    final o = d.desta;
    canal.receber(
      MensagemTatu(
        id: 'documento-$chave',
        em: hoje,
        resumo: 'Atualizamos os ${d.titulo}',
        titulo: 'Atualização',
        destaque: 'Atualizamos os ${d.titulo}.',
        texto:
            '${o == null ? '' : '${o.mudou} '}Vale a partir de '
            '${dataPorExtenso(d.vigencia)}.',
      ),
    );
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final aceites = AceitesRepo()..restaurar();
