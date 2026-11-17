import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// RN-117: as mensagens do Tatu são dados (título, texto, cartão com botão
/// e link), para o servidor mandar novidades sem atualizar o app. Por
/// enquanto chegam de mocks; depois, de [MensagemTatu.fromJson].

/// Destinos que um botão ou link do Tatu pode abrir no app.
abstract final class DestinoTatu {
  static const dicas = 'tatu://dicas';
  static const distancia = 'tatu://distancia';
}

/// Cartão dentro da mensagem ("Dicas Tatu · Ver dicas").
@immutable
class CartaoTatu {
  const CartaoTatu({
    required this.titulo,
    required this.botao,
    required this.link,
    this.detalhe,
    this.introducao,
  });

  factory CartaoTatu.fromJson(Map<String, dynamic> j) => CartaoTatu(
    titulo: j['titulo'] as String,
    botao: j['botao'] as String,
    link: j['link'] as String,
    detalhe: j['detalhe'] as String?,
    introducao: j['introducao'] as String?,
  );

  final String titulo;
  final String? detalhe;

  /// Balão antes do cartão ("Separamos dicas para…").
  final String? introducao;
  final String botao;

  /// Destino no app (ver [DestinoTatu]).
  final String link;
}

/// Link azul no fim da mensagem ("Ver como funciona").
@immutable
class LinkTatu {
  const LinkTatu(this.texto, this.destino);

  factory LinkTatu.fromJson(Map<String, dynamic> j) =>
      LinkTatu(j['texto'] as String, j['destino'] as String);

  final String texto;
  final String destino;
}

/// Uma mensagem do Tatu no canal oficial (RN-115 a RN-117).
@immutable
class MensagemTatu {
  const MensagemTatu({
    required this.id,
    required this.em,
    required this.resumo,
    required this.texto,
    this.titulo,
    this.destaque,
    this.cartao,
    this.textoDepois,
    this.link,
  });

  factory MensagemTatu.fromJson(Map<String, dynamic> j) => MensagemTatu(
    id: j['id'] as String,
    em: DateTime.parse(j['em'] as String),
    resumo: j['resumo'] as String,
    texto: j['texto'] as String,
    titulo: j['titulo'] as String?,
    destaque: j['destaque'] as String?,
    cartao: j['cartao'] == null
        ? null
        : CartaoTatu.fromJson(j['cartao'] as Map<String, dynamic>),
    textoDepois: j['textoDepois'] as String?,
    link: j['link'] == null
        ? null
        : LinkTatu.fromJson(j['link'] as Map<String, dynamic>),
  );

  final String id;
  final DateTime em;

  /// Linha na lista de Mensagens ("Novidade: profissionais à distância").
  final String resumo;

  /// Faixa escura no topo ("Novidade"); nulo = balão comum.
  final String? titulo;

  /// Frase em negrito antes do texto.
  final String? destaque;
  final String texto;
  final CartaoTatu? cartao;

  /// Balão depois do cartão.
  final String? textoDepois;
  final LinkTatu? link;

  /// Quantos balões a mensagem ocupa (para "+ 2 mensagens").
  int get baloes => 1 + (cartao == null ? 0 : 1) + (textoDepois == null ? 0 : 1);
}

/// RN-116: boas-vindas do cliente (primeira mensagem do app).
MensagemTatu boasVindasCliente(String nome, {DateTime? em}) => MensagemTatu(
  id: 'boas-vindas',
  em: em ?? clock.now(),
  resumo: 'Oi, $nome! Boas-vindas ao Tatu.',
  texto:
      'Oi, $nome! Boas-vindas ao Tatu.\n'
      'Aqui você acha profissionais perto de você, rápido e sem '
      'complicação.',
  cartao: _dicas,
  textoDepois: _novidades,
);

/// RN-116: boas-vindas do profissional.
MensagemTatu boasVindasProfissional(String nome, {DateTime? em}) =>
    MensagemTatu(
      id: 'boas-vindas',
      em: em ?? clock.now(),
      resumo: 'Oi, $nome! Boas-vindas ao Tatu.',
      texto:
          'Oi, $nome! Boas-vindas ao Tatu.\n'
          'Fique online e receba chamados de clientes perto de você.',
      cartao: _dicas,
      textoDepois: _novidades,
    );

/// RN-118: atalho para as Dicas Tatu.
const _dicas = CartaoTatu(
  introducao:
      'Separamos dicas para uma boa convivência e boas negociações:',
  titulo: 'Dicas Tatu',
  detalhe: 'Convivência e negociação',
  botao: 'Ver dicas',
  link: DestinoTatu.dicas,
);

const _novidades =
    'Por aqui também avisamos as novidades do Tatu. Fique de olho!';

/// Novidade de exemplo para o cliente (mock do servidor).
MensagemTatu novidadeDistanciaCliente(DateTime em) => MensagemTatu(
  id: 'novidade-distancia',
  em: em,
  titulo: 'Novidade',
  resumo: 'Novidade: profissionais à distância',
  destaque: 'Agora você pode chamar profissionais',
  texto: 'à distância: designer, professor e mais.',
  link: const LinkTatu('Ver como funciona', DestinoTatu.distancia),
);

/// Novidade de exemplo para o profissional (mock do servidor).
MensagemTatu novidadeDistanciaProfissional(DateTime em) => MensagemTatu(
  id: 'novidade-distancia',
  em: em,
  titulo: 'Novidade',
  resumo: 'Novidade: atenda à distância',
  destaque: 'Agora você pode atender à distância',
  texto: 'clientes de qualquer cidade, sem visita.',
  link: const LinkTatu('Ver como funciona', DestinoTatu.distancia),
);

/// Canal oficial do Tatu de um perfil (RN-115): fixado, com selo, não
/// pode ser apagado e só o Tatu envia (RN-117).
class CanalTatu extends ChangeNotifier {
  List<MensagemTatu> mensagens = [];
  int naoLidas = 0;

  MensagemTatu? get ultima => mensagens.isEmpty ? null : mensagens.last;

  /// RN-116: conta nova: só as boas-vindas, não lida.
  void comecar(MensagemTatu boasVindas) {
    mensagens = [boasVindas];
    naoLidas = 1;
    notifyListeners();
  }

  /// RN-117: chega uma mensagem nova do Tatu.
  void receber(MensagemTatu m) {
    if (mensagens.any((x) => x.id == m.id)) return;
    mensagens = [...mensagens, m];
    naoLidas++;
    notifyListeners();
  }

  void marcarLido() {
    if (naoLidas == 0) return;
    naoLidas = 0;
    notifyListeners();
  }
}

/// Canais do cliente e do profissional. Versão simulada.
class CanaisTatu {
  final cliente = CanalTatu();
  final profissional = CanalTatu();

  /// Demonstração: boas-vindas em 02 nov e uma novidade hoje às 10:02.
  void restaurar() {
    final hoje = clock.now();
    final novidade = DateTime(hoje.year, hoje.month, hoje.day, 10, 2);
    cliente
      ..comecar(boasVindasCliente('Ana', em: DateTime(hoje.year, 11, 2)))
      ..receber(novidadeDistanciaCliente(novidade))
      ..naoLidas = 1;
    profissional
      ..comecar(
        boasVindasProfissional('Luiza', em: DateTime(hoje.year, 11, 2)),
      )
      ..receber(novidadeDistanciaProfissional(novidade))
      ..naoLidas = 1;
  }
}

/// Instância única usada pelo app enquanto não há backend.
final canalTatu = CanaisTatu()..restaurar();
