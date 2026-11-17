import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// RN-119 a RN-127: o que pode ser enviado no chat, na prévia e na
/// entrega, e o que acontece quando um arquivo é barrado.

/// Tipo do arquivo pela extensão.
enum TipoArquivo { imagem, video, documento, compactado, programa, script, outro }

const _imagem = {'jpg', 'jpeg', 'png', 'heic', 'webp', 'gif'};
const _video = {'mp4', 'mov', 'm4v', '3gp'};
const _documento = {'pdf'};
const _compactado = {'zip', 'rar', '7z'};
const _programa = {'apk', 'exe', 'bat', 'msi', 'dmg', 'ipa', 'app', 'cmd'};
const _script = {
  'sh', 'js', 'py', 'php', 'ps1', 'vbs', 'jar', 'html', 'dart', 'ts', 'rb',
};

String extensaoDe(String nome) {
  final i = nome.lastIndexOf('.');
  return i < 0 ? '' : nome.substring(i + 1).toLowerCase();
}

TipoArquivo tipoDe(String nome) {
  final e = extensaoDe(nome);
  if (_imagem.contains(e)) return TipoArquivo.imagem;
  if (_video.contains(e)) return TipoArquivo.video;
  if (_documento.contains(e)) return TipoArquivo.documento;
  if (_compactado.contains(e)) return TipoArquivo.compactado;
  if (_programa.contains(e)) return TipoArquivo.programa;
  if (_script.contains(e)) return TipoArquivo.script;
  return TipoArquivo.outro;
}

/// Programa pronto ou script: o app nunca abre nem roda (RN-126).
bool executavel(String nome) {
  final t = tipoDe(nome);
  return t == TipoArquivo.programa || t == TipoArquivo.script;
}

/// Números de exemplo dos arquivos. Mudou um, muda só aqui.
abstract final class RegrasArquivo {
  /// RN-119: limite de um arquivo no chat.
  static const limiteChatMb = 25;

  /// RN-119/RN-125: limite de um arquivo de entrega (maior que o do chat).
  static const limiteEntregaMb = 100;

  /// RN-119: no chat, só foto, vídeo curto e documento (PDF, imagem).
  static bool permitidoNoChat(String nome) => switch (tipoDe(nome)) {
    TipoArquivo.imagem || TipoArquivo.video || TipoArquivo.documento => true,
    _ => false,
  };

  /// RN-127: na prévia protegida, só imagem, vídeo ou PDF (ou link de
  /// teste, ver [permitidoNaPreviaLink]).
  static bool permitidoNaPrevia(String nome) => permitidoNoChat(nome);
  static const permitidoNaPreviaLink = true;

  /// RN-125: na entrega, programa e script só em profissão de tecnologia.
  static bool permitidoNaEntrega(String nome, {required bool tecnologia}) =>
      !executavel(nome) || tecnologia;

  static bool cabeNoChat(double mb) => mb <= limiteChatMb;
  static bool cabeNaEntrega(double mb) => mb <= limiteEntregaMb;
}

/// Arquivo que alguém quer enviar.
@immutable
class ArquivoEnviado {
  const ArquivoEnviado(this.nome, {this.mb = 1});

  final String nome;
  final double mb;

  TipoArquivo get tipo => tipoDe(nome);

  /// "ZIP · 8 MB".
  String get detalhe {
    final e = extensaoDe(nome).toUpperCase();
    final tamanho = mb >= 1
        ? '${mb.round()} MB'
        : '${(mb * 1024).round()} KB';
    return '$e · $tamanho';
  }
}

/// Resultado da moderação de um arquivo (RN-120 a RN-122).
enum ResultadoModeracao { aprovado, virus, nudez, abusoInfantil }

/// RN-120/RN-121: antivírus, detecção de nudez e comparação com bancos de
/// abuso infantil (ex.: PhotoDNA, Safer). Fornecedores: decisão em aberto.
abstract class ModeracaoArquivo {
  Future<ResultadoModeracao> analisar(ArquivoEnviado arquivo);
}

/// Versão simulada: decide pelo nome (protótipo e testes).
class ModeracaoArquivoMock implements ModeracaoArquivo {
  /// Nomes marcados em cada resultado (ex.: "virus.apk").
  final Map<String, ResultadoModeracao> marcados = {};

  @override
  Future<ResultadoModeracao> analisar(ArquivoEnviado arquivo) async {
    final marcado = marcados[arquivo.nome];
    if (marcado != null) return marcado;
    final n = arquivo.nome.toLowerCase();
    if (n.contains('virus')) return ResultadoModeracao.virus;
    if (n.contains('nudez')) return ResultadoModeracao.nudez;
    return ResultadoModeracao.aprovado;
  }
}

/// RN-126: verificação de site perigoso em todo link de entrega.
abstract class VerificaLink {
  Future<bool> seguro(String link);
}

/// Versão simulada: barra domínios de uma lista.
class VerificaLinkMock implements VerificaLink {
  final perigosos = <String>{'site-perigoso.com', 'baixe-gratis.net'};

  @override
  Future<bool> seguro(String link) async {
    final l = link.toLowerCase();
    return !perigosos.any(l.contains) && !l.contains('malware');
  }
}

ModeracaoArquivo moderacao = ModeracaoArquivoMock();
VerificaLink verificaLink = VerificaLinkMock();

/// RN-122: prova guardada em área separada e protegida (não apaga).
@immutable
class ProvaGuardada {
  const ProvaGuardada({
    required this.arquivo,
    required this.motivo,
    required this.em,
  });

  final String arquivo;
  final ResultadoModeracao motivo;
  final DateTime em;
}

/// RN-122: registro para o suporte comunicar às autoridades (PF).
@immutable
class RegistroAutoridade {
  const RegistroAutoridade({required this.arquivo, required this.em});

  final String arquivo;
  final DateTime em;
}

/// RN-123: denúncia de arquivo, com prioridade máxima no suporte.
@immutable
class DenunciaArquivo {
  const DenunciaArquivo({
    required this.arquivo,
    required this.motivo,
    required this.em,
  });

  final String arquivo;
  final String motivo;
  final DateTime em;
  bool get prioridadeMaxima => true;
}

/// Motivos da denúncia de arquivo (RN-123).
const motivosDenunciaArquivo = [
  'Nudez ou conteúdo sexual',
  'Envolve menor de idade',
  'Arquivo suspeito ou vírus',
  'Outro motivo',
];

/// O que o app faz depois da moderação.
enum ResultadoEnvio {
  /// Chegou ao outro lado.
  entregue,

  /// Tipo não permitido aqui (ex.: .apk no chat): nem é enviado.
  tipoNaoPermitido,

  /// Maior que o limite.
  grandeDemais,

  /// RN-120: barrado (vírus ou nudez); quem enviou vê o aviso.
  barrado,

  /// RN-122: suspeita de abuso infantil; conta suspensa na hora.
  contaSuspensa,

  /// RN-122/RN-126: reincidência de nudez ou vírus na entrega.
  contaBanida,
}

/// Situação da conta e guarda das provas. Versão simulada.
class SegurancaConteudoRepo extends ChangeNotifier {
  bool suspensa = false;
  bool banida = false;

  /// RN-122: nudez de adulto já barrada (reincidência bane).
  int nudezBarrada = 0;

  final List<ProvaGuardada> _provas = [];
  final List<RegistroAutoridade> registros = [];
  final List<DenunciaArquivo> denuncias = [];

  /// Provas só para leitura: não há como apagar (RN-122).
  List<ProvaGuardada> get provas => List.unmodifiable(_provas);

  bool get bloqueada => suspensa || banida;

  /// Só para a demonstração e os testes começarem do zero (as provas de
  /// verdade ficam no servidor e nunca são apagadas).
  void restaurar() {
    suspensa = false;
    banida = false;
    nudezBarrada = 0;
    _provas.clear();
    registros.clear();
    denuncias.clear();
    notifyListeners();
  }

  /// RN-119 a RN-122: confere tipo, tamanho e moderação de um arquivo do
  /// chat ou da prévia.
  Future<ResultadoEnvio> enviarNoChat(ArquivoEnviado a) async {
    if (!RegrasArquivo.permitidoNoChat(a.nome)) {
      return ResultadoEnvio.tipoNaoPermitido;
    }
    if (!RegrasArquivo.cabeNoChat(a.mb)) return ResultadoEnvio.grandeDemais;
    return _moderar(a, entrega: false);
  }

  /// RN-125/RN-126: confere um arquivo de entrega à distância.
  Future<ResultadoEnvio> enviarEntrega(
    ArquivoEnviado a, {
    required bool tecnologia,
  }) async {
    if (!RegrasArquivo.permitidoNaEntrega(a.nome, tecnologia: tecnologia)) {
      return ResultadoEnvio.tipoNaoPermitido;
    }
    if (!RegrasArquivo.cabeNaEntrega(a.mb)) {
      return ResultadoEnvio.grandeDemais;
    }
    return _moderar(a, entrega: true);
  }

  /// RN-126: confere um link de entrega.
  Future<ResultadoEnvio> enviarLink(String link) async =>
      await verificaLink.seguro(link)
      ? ResultadoEnvio.entregue
      : ResultadoEnvio.barrado;

  Future<ResultadoEnvio> _moderar(
    ArquivoEnviado a, {
    required bool entrega,
  }) async {
    final r = await moderacao.analisar(a);
    switch (r) {
      case ResultadoModeracao.aprovado:
        return ResultadoEnvio.entregue;
      case ResultadoModeracao.abusoInfantil:
        // RN-122: bloqueia, suspende na hora, guarda a prova e registra
        // para as autoridades.
        _provas.add(ProvaGuardada(arquivo: a.nome, motivo: r, em: clock.now()));
        registros.add(RegistroAutoridade(arquivo: a.nome, em: clock.now()));
        suspensa = true;
        notifyListeners();
        return ResultadoEnvio.contaSuspensa;
      case ResultadoModeracao.nudez:
        // RN-122: nudez de adulto bloqueia; se repetir, bane.
        nudezBarrada++;
        if (nudezBarrada >= 2) {
          banida = true;
          notifyListeners();
          return ResultadoEnvio.contaBanida;
        }
        notifyListeners();
        return ResultadoEnvio.barrado;
      case ResultadoModeracao.virus:
        // RN-126: entrega com vírus bane; no chat, só barra.
        if (entrega) {
          banida = true;
          notifyListeners();
          return ResultadoEnvio.contaBanida;
        }
        return ResultadoEnvio.barrado;
    }
  }

  /// RN-123: denúncia de um arquivo recebido.
  void denunciar(String arquivo, String motivo) {
    denuncias.add(
      DenunciaArquivo(arquivo: arquivo, motivo: motivo, em: clock.now()),
    );
    notifyListeners();
  }
}

/// Instância única usada pelo app enquanto não há backend.
final segurancaConteudo = SegurancaConteudoRepo();
