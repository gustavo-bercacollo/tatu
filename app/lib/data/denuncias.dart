import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// RN-133: motivos para denunciar a pessoa (menu do chat, os dois lados).
const motivosDenunciaPessoa = [
  'Comportamento inadequado',
  'Assédio ou discriminação',
  'Golpe ou pagamento por fora',
  'Perfil falso',
  'Outro motivo',
];

/// RN-134: motivos para denunciar uma mensagem.
const motivosDenunciaMensagem = [
  'Assédio ou ofensa',
  'Conteúdo sexual',
  'Ameaça ou chantagem',
  'Golpe ou pagamento por fora',
  'Outro motivo',
];

/// O que foi denunciado.
enum TipoDenuncia {
  /// RN-133: a pessoa, pelo menu do chat.
  pessoa,

  /// RN-134: uma mensagem, segurando o dedo.
  mensagem,

  /// RN-123: um arquivo (prioridade máxima).
  arquivo,
}

/// Resultado da análise do suporte (RN-135).
enum AnaliseDenuncia {
  emAnalise,

  /// O suporte confirmou: conta para pausa ou suspensão (RN-128 a RN-132).
  confirmada,

  /// Não foi possível confirmar (sem punição para ninguém).
  naoConfirmada,

  /// Falsa e de propósito: conta contra quem denunciou.
  falsa,
}

/// Uma denúncia na fila do suporte. Nunca é mostrada ao denunciado
/// (RN-133).
class Denuncia {
  Denuncia({
    required this.tipo,
    required this.motivo,
    required this.denunciante,
    required this.em,
    this.denunciado,
    this.texto,
    this.mensagem,
    this.contexto = const [],
    this.arquivo,
  });

  final TipoDenuncia tipo;
  final String motivo;

  /// Quem denunciou (para o contador de denúncias falsas).
  final String denunciante;

  /// Quem foi denunciado (nulo quando não se sabe, ex.: arquivo).
  final String? denunciado;

  /// RN-133: "Contar mais" (opcional).
  final String? texto;

  /// RN-134: a mensagem denunciada e as mensagens em volta.
  final String? mensagem;
  final List<String> contexto;

  /// RN-123: nome do arquivo denunciado.
  final String? arquivo;
  final DateTime em;

  AnaliseDenuncia analise = AnaliseDenuncia.emAnalise;

  /// RN-123: arquivo vai na frente da fila.
  bool get prioridadeMaxima => tipo == TipoDenuncia.arquivo;

  /// RN-135: assédio ou discriminação segue a RN-56.
  bool get bloqueiaNaHora => RegrasDenuncia.bloqueiaNaHora(motivo);
}

abstract final class RegrasDenuncia {
  /// RN-134: quantas mensagens antes e depois vão junto como contexto.
  static const mensagensEmVolta = 3;

  /// RN-56/RN-135: denúncia de assédio ou discriminação bloqueia os dois
  /// na hora e suspende o acusado enquanto o caso é analisado. (A
  /// mensagem com "Assédio ou ofensa" só vai para o suporte: no desenho
  /// C137 a conversa continua.)
  static bool bloqueiaNaHora(String motivo) =>
      motivo == 'Assédio ou discriminação';

  /// RN-134: a mensagem [i] de [mensagens] com as que estão em volta.
  static List<String> contexto(List<String> mensagens, int i) {
    final de = (i - mensagensEmVolta).clamp(0, mensagens.length);
    final ate = (i + mensagensEmVolta + 1).clamp(0, mensagens.length);
    return mensagens.sublist(de, ate);
  }
}

/// Fila única do suporte (pessoa, mensagem e arquivo) e contadores.
/// Versão simulada, sem backend.
class DenunciasRepo extends ChangeNotifier {
  final _fila = <Denuncia>[];

  /// RN-56: pares bloqueados um para o outro ("a|b", em ordem).
  final _bloqueios = <String>{};

  /// RN-135: denúncias confirmadas por conta denunciada.
  final confirmadas = <String, int>{};

  /// RN-135: denúncias falsas (de propósito) por quem denunciou.
  final falsas = <String, int>{};

  /// Fila do suporte: arquivos (prioridade máxima) primeiro, depois por
  /// ordem de chegada.
  List<Denuncia> get fila => List.unmodifiable([
    ..._fila.where((d) => d.prioridadeMaxima),
    ..._fila.where((d) => !d.prioridadeMaxima),
  ]);

  void restaurar() {
    _fila.clear();
    _bloqueios.clear();
    confirmadas.clear();
    falsas.clear();
    notifyListeners();
  }

  static String _par(String a, String b) =>
      ([a, b]..sort()).join('|');

  /// RN-56: [a] e [b] estão bloqueados um para o outro?
  bool bloqueados(String a, String b) => _bloqueios.contains(_par(a, b));

  Denuncia _registrar(Denuncia d) {
    _fila.add(d);
    // RN-56/RN-135: assédio ou discriminação bloqueia os dois na hora.
    if (d.bloqueiaNaHora && d.denunciado != null) {
      _bloqueios.add(_par(d.denunciante, d.denunciado!));
    }
    notifyListeners();
    return d;
  }

  /// RN-133: denúncia da pessoa pelo menu do chat.
  Denuncia denunciarPessoa({
    required String denunciante,
    required String denunciado,
    required String motivo,
    String? texto,
  }) => _registrar(
    Denuncia(
      tipo: TipoDenuncia.pessoa,
      motivo: motivo,
      denunciante: denunciante,
      denunciado: denunciado,
      texto: (texto?.trim().isEmpty ?? true) ? null : texto!.trim(),
      em: clock.now(),
    ),
  );

  /// RN-134: denúncia de uma mensagem, com o contexto da conversa.
  Denuncia denunciarMensagem({
    required String denunciante,
    required String denunciado,
    required String motivo,
    required String mensagem,
    required List<String> contexto,
  }) => _registrar(
    Denuncia(
      tipo: TipoDenuncia.mensagem,
      motivo: motivo,
      denunciante: denunciante,
      denunciado: denunciado,
      mensagem: mensagem,
      contexto: List.unmodifiable(contexto),
      em: clock.now(),
    ),
  );

  /// RN-123: denúncia de arquivo (entra na mesma fila, na frente).
  Denuncia denunciarArquivo({
    required String arquivo,
    required String motivo,
    String denunciante = '',
    String? denunciado,
  }) => _registrar(
    Denuncia(
      tipo: TipoDenuncia.arquivo,
      motivo: motivo,
      denunciante: denunciante,
      denunciado: denunciado,
      arquivo: arquivo,
      em: clock.now(),
    ),
  );

  /// RN-135: o suporte decide. Confirmada conta contra o denunciado;
  /// falsa de propósito conta contra quem denunciou. Os limites para
  /// pausar ou suspender ainda não foram decididos.
  void analisar(Denuncia d, AnaliseDenuncia resultado) {
    if (d.analise != AnaliseDenuncia.emAnalise) return;
    d.analise = resultado;
    switch (resultado) {
      case AnaliseDenuncia.confirmada when d.denunciado != null:
        confirmadas.update(d.denunciado!, (n) => n + 1, ifAbsent: () => 1);
      case AnaliseDenuncia.falsa:
        falsas.update(d.denunciante, (n) => n + 1, ifAbsent: () => 1);
      default:
        break;
    }
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final denuncias = DenunciasRepo();
