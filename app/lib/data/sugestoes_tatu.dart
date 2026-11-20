
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import 'arquivos_seguros.dart';
import 'canal_tatu.dart';

/// RN-173: sugestão ao Tatu (Perfil → Enviar sugestão), do cliente ou do
/// profissional.

enum TipoSugestao { ideia, algoNaoFunciona, outro }

extension TipoSugestaoTexto on TipoSugestao {
  String get rotulo => switch (this) {
    TipoSugestao.ideia => 'Ideia',
    TipoSugestao.algoNaoFunciona => 'Algo não funciona',
    TipoSugestao.outro => 'Outro',
  };
}

/// De qual modo do app veio.
enum ModoConta { cliente, profissional }

abstract final class RegrasSugestaoTatu {
  /// RN-173: texto obrigatório, até 500 caracteres.
  static const maxCaracteres = 500;

  /// Versão do app que vai junto (igual ao pubspec).
  static const versaoApp = '1.0.0+1';

  /// Texto pronto para enviar?
  static bool textoValido(String texto) {
    final t = texto.trim();
    return t.isNotEmpty && t.length <= maxCaracteres;
  }
}

/// Aparelho que vai junto com a sugestão ("web · android").
String aparelhoAtual() =>
    '${kIsWeb ? 'web · ' : ''}${defaultTargetPlatform.name}';

@immutable
class Sugestao {
  const Sugestao({
    required this.conta,
    required this.modo,
    required this.tipo,
    required this.texto,
    required this.em,
    required this.versao,
    required this.aparelho,
    this.print,
  });

  /// Quem enviou (nome da conta).
  final String conta;
  final ModoConta modo;
  final TipoSugestao tipo;
  final String texto;
  final DateTime em;
  final String versao;
  final String aparelho;

  /// Print opcional (já verificado, RN-120).
  final Uint8List? print;
}

/// Por que não enviou.
enum ErroSugestao { semTipo, semTexto, textoLongo }

/// RN-173: fila de sugestões para o time do Tatu. Versão simulada (no
/// servidor, uma tabela simples).
class SugestoesTatuRepo extends ChangeNotifier {
  final _fila = <Sugestao>[];

  /// Fila do time (mais novas primeiro).
  List<Sugestao> get fila => List.unmodifiable(_fila);

  void restaurar() {
    _fila.clear();
    notifyListeners();
  }

  /// RN-120: o print passa pela mesma verificação de arquivos do chat.
  Future<ResultadoEnvio> verificarPrint(ArquivoEnviado a) =>
      segurancaConteudo.enviarNoChat(a);

  /// Confere tipo e texto; nulo se pode enviar.
  static ErroSugestao? conferir(TipoSugestao? tipo, String texto) {
    if (tipo == null) return ErroSugestao.semTipo;
    if (texto.trim().isEmpty) return ErroSugestao.semTexto;
    if (texto.trim().length > RegrasSugestaoTatu.maxCaracteres) {
      return ErroSugestao.textoLongo;
    }
    return null;
  }

  /// RN-173: grava a sugestão com conta, modo, tipo, texto, print, versão
  /// do app e aparelho. Devolve o erro (nulo = enviada).
  ErroSugestao? enviar({
    required String conta,
    required ModoConta modo,
    required TipoSugestao? tipo,
    required String texto,
    Uint8List? print,
  }) {
    final erro = conferir(tipo, texto);
    if (erro != null) return erro;
    _fila.insert(
      0,
      Sugestao(
        conta: conta,
        modo: modo,
        tipo: tipo!,
        texto: texto.trim(),
        em: clock.now(),
        versao: RegrasSugestaoTatu.versaoApp,
        aparelho: aparelhoAtual(),
        print: print,
      ),
    );
    notifyListeners();
    return null;
  }

  /// RN-173/RN-117: a sugestão virou novidade: o aviso sai pelo canal
  /// oficial do Tatu, para quem estiver no mesmo modo.
  void virouNovidade(Sugestao s, MensagemTatu aviso) {
    final canal = s.modo == ModoConta.cliente
        ? canalTatu.cliente
        : canalTatu.profissional;
    canal.receber(aviso);
  }
}

/// Instância única usada pelo app enquanto não há backend.
final sugestoesTatu = SugestoesTatuRepo();
