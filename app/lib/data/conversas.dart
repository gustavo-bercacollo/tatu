import 'package:flutter/foundation.dart';

import 'regras_valor.dart';

/// Situação de uma mensagem enviada pela pessoa.
enum EnvioMensagem { enviada, falhou }

/// Mensagem do chat com o profissional: texto ou foto.
class MensagemChat {
  MensagemChat({
    this.texto,
    this.minha = false,
    this.foto = false,
    this.imagem,
    this.hora,
    this.envio = EnvioMensagem.enviada,
    this.concluido,
    this.dia,
    this.arquivo,
    this.arquivoDetalhe,
  });

  /// RN-96: arquivo enviado (entrega à distância), ex.: "logo.pdf".
  final String? arquivo;

  /// "PDF · 2,4 MB".
  final String? arquivoDetalhe;

  /// RN-42: marco "Serviço concluído · R$ 190,00 · 04 nov" no meio da
  /// conversa, que continua aberta depois dele.
  MensagemChat.concluido(String this.concluido)
    : texto = null,
      minha = false,
      foto = false,
      imagem = null,
      hora = null,
      envio = EnvioMensagem.enviada,
      dia = null,
      arquivo = null,
      arquivoDetalhe = null;

  /// Separador de dia ("12 nov").
  MensagemChat.dia(String this.dia)
    : texto = null,
      minha = false,
      foto = false,
      imagem = null,
      hora = null,
      envio = EnvioMensagem.enviada,
      concluido = null,
      arquivo = null,
      arquivoDetalhe = null;

  /// Texto do marco de serviço concluído (RN-42).
  final String? concluido;

  /// Texto do separador de dia.
  final String? dia;

  final String? texto;
  final bool minha;

  /// Mensagem de foto ([imagem] pode ser nula enquanto carrega ou na demo).
  final bool foto;
  final Uint8List? imagem;
  final String? hora;
  EnvioMensagem envio;
}

/// Conversa com um profissional sobre um pedido.
/// Em que ponto está o valor que o profissional enviou.
enum SituacaoValor { aguardandoVoce, pediuOutro, confirmado }

/// Valor enviado pelo profissional: visita + serviço. [rodada] é qual
/// dos 3 valores possíveis este é.
class ValorProposta {
  ValorProposta({
    required this.visita,
    required this.servico,
    this.rodada = 1,
    this.situacao = SituacaoValor.aguardandoVoce,
    this.pedido,
    this.descricao,
    this.novo = false,
    this.distancia = false,
    this.parcelas = 1,
  });

  /// O que este valor cobre ("troca da tubulação"), quando não é o
  /// primeiro serviço da conversa.
  final String? descricao;

  /// RN-87: valor novo numa conversa que já teve serviço concluído.
  final bool novo;

  /// RN-95: serviço à distância (só Serviço, sem visita).
  final bool distancia;

  /// RN-91: em quantas vezes o cliente vai pagar (1 = à vista).
  int parcelas;

  double visita;
  double servico;
  int rodada;
  SituacaoValor situacao;

  /// Valor que o cliente pediu (quando pediu outro).
  double? pedido;

  double get total => visita + servico;
}

class Conversa {
  Conversa({
    required this.nome,
    required this.profissao,
    required this.feminino,
    required this.servico,
    required this.descricao,
    required this.rua,
    required this.quando,
    required this.mensagens,
    this.emAndamento = false,
    this.online = false,
    this.naoLidas = 0,
    this.concluidoEm,
    this.valor,
    this.distancia = false,
  });

  /// RN-92: pedido à distância.
  final bool distancia;

  /// Valor enviado pelo profissional (null = ainda não enviou).
  ValorProposta? valor;

  final String nome;
  final String profissao;

  /// Para os textos "a Luiza" / "Ela não vê que foi você".
  final bool feminino;
  final String servico;
  final String descricao;
  final String rua;
  final String quando;
  final List<MensagemChat> mensagens;
  final bool emAndamento;
  final bool online;
  int naoLidas;

  /// Data em que o último serviço terminou. RN-42: a conversa não fecha;
  /// só vai para "Anteriores".
  final String? concluidoEm;

  String get primeiroNome => nome.split(' ').first;
  bool get concluida => concluidoEm != null;
  String get artigo => feminino ? 'a' : 'o';

  String get ultima {
    final m = mensagens.lastWhere(
      (m) => m.concluido == null && m.dia == null,
      orElse: () => mensagens.last,
    );
    return m.foto ? 'Foto' : (m.texto ?? m.concluido ?? '');
  }
}

/// Conversas do cliente. Versão simulada (sem backend nem internet real).
class ConversasRepo extends ChangeNotifier {
  ConversasRepo() {
    restaurar();
  }

  late List<Conversa> conversas;

  /// Cobrança do pedido em andamento esperando o pagamento.
  bool cobrancaPendente = false;

  /// Simula ficar sem internet: as mensagens novas não são enviadas.
  bool semInternet = false;

  Iterable<Conversa> get emAndamento => conversas.where((c) => c.emAndamento);
  Iterable<Conversa> get anteriores => conversas.where((c) => !c.emAndamento);

  void restaurar() {
    conversas = [
      Conversa(
        nome: 'Luiza Souza',
        profissao: 'Encanadora',
        feminino: true,
        servico: 'Encanador',
        descricao: 'Vazamento na pia da cozinha',
        rua: 'Rua das Flores',
        quando: 'agora',
        emAndamento: true,
        online: true,
        naoLidas: 2,
        mensagens: [
          MensagemChat(texto: 'Oi! Vi o vazamento, posso hoje.'),
          MensagemChat(texto: 'Ótimo, pode vir agora?', minha: true),
          MensagemChat(texto: 'Chego em 12 min.'),
        ],
        valor: ValorProposta(visita: 40, servico: 150),
      ),
      Conversa(
        nome: 'Rafael Lima',
        profissao: 'Eletricista',
        feminino: false,
        servico: 'Eletricista',
        descricao: 'Tomada sem energia',
        rua: 'Rua das Flores',
        quando: 'ontem',
        concluidoEm: '02 nov',
        // RN-42 e RN-87: a conversa continua depois do serviço e o
        // Rafael manda um novo valor (RN-91: dá para parcelar).
        mensagens: [
          MensagemChat(texto: 'Tomada trocada. Qualquer coisa, me chama.'),
          MensagemChat.concluido('Serviço concluído · R\$ 220,00 · 02 nov'),
          MensagemChat.dia('12 nov'),
          MensagemChat(
            texto: 'O quadro de luz está desarmando toda hora.',
            minha: true,
          ),
          MensagemChat(texto: 'Consigo passar aí hoje. Já te mando o valor.'),
        ],
        valor: ValorProposta(
          visita: 0,
          servico: 1200,
          descricao: 'troca do quadro de luz',
          novo: true,
        ),
      ),
      Conversa(
        nome: 'Marcos Dias',
        profissao: 'Pintor',
        feminino: false,
        servico: 'Pintor',
        descricao: 'Parede da sala',
        rua: 'Rua das Flores',
        quando: '28 out',
        concluidoEm: '28 out',
        mensagens: [MensagemChat(texto: 'Posso passar amanhã.')],
      ),
    ];
    cobrancaPendente = false;
    semInternet = false;
    notifyListeners();
  }

  /// Conversa nova com quem a pessoa acabou de aceitar (fica no topo).
  Conversa comecar({
    required String nome,
    required String profissao,
    required bool feminino,
    required String servico,
    required String rua,
    bool distancia = false,
  }) {
    conversas.removeWhere((c) => c.nome == nome && c.emAndamento);
    final c = Conversa(
      nome: nome,
      profissao: profissao,
      feminino: feminino,
      servico: servico,
      descricao: servico,
      rua: rua,
      quando: 'agora',
      emAndamento: true,
      online: true,
      distancia: distancia,
      mensagens: [
        MensagemChat(
          texto: distancia
              ? 'Oi! Aceitei seu pedido. Me conta o que você imagina?'
              : 'Oi! Aceitei seu pedido. Posso ir agora.',
          hora: horaAgora(),
        ),
      ],
      // RN-26: o profissional manda o valor (visita + serviço) pelo chat;
      // o cliente confirma o total uma vez. Protótipo: já chega enviado.
      // RN-95: à distância, só o serviço.
      valor: distancia
          ? ValorProposta(visita: 0, servico: 250, distancia: true)
          : ValorProposta(visita: 40, servico: 150),
    );
    conversas = [c, ...conversas];
    notifyListeners();
    return c;
  }

  /// O cliente confirma o valor: fica reservado e só é cobrado no fim.
  void confirmarValor(Conversa c) {
    c.valor?.situacao = SituacaoValor.confirmado;
    notifyListeners();
  }

  /// RN-96: protótipo da entrega à distância: o profissional manda o
  /// arquivo pelo chat.
  void receberEntrega(Conversa c) {
    c.mensagens
      ..add(
        MensagemChat(
          arquivo: 'entrega-v1.pdf',
          arquivoDetalhe: 'PDF · 2,4 MB',
          hora: horaAgora(),
        ),
      )
      ..add(MensagemChat(texto: 'Segue a primeira versão!'));
    notifyListeners();
  }

  /// RN-91: o cliente escolhe em quantas vezes paga.
  void escolherParcelas(Conversa c, int parcelas) {
    final v = c.valor;
    if (v == null) return;
    v.parcelas = parcelas.clamp(1, RegrasValor.maxParcelas);
    notifyListeners();
  }

  /// O cliente pede outro valor (total que ele quer pagar).
  void pedirOutroValor(Conversa c, double total) {
    final v = c.valor;
    if (v == null) return;
    v
      ..pedido = total
      ..situacao = SituacaoValor.pediuOutro;
    notifyListeners();
  }

  /// Resposta simulada do profissional: um novo valor no meio do caminho
  /// (a visita continua a mesma).
  void profissionalResponde(Conversa c) {
    final v = c.valor;
    if (v == null || v.situacao != SituacaoValor.pediuOutro) return;
    final meio = ((v.total + (v.pedido ?? v.total)) / 2 / 10).round() * 10.0;
    v
      ..servico = (meio - v.visita).clamp(0, double.infinity).toDouble()
      ..rodada += 1
      ..pedido = null
      ..situacao = SituacaoValor.aguardandoVoce;
    notifyListeners();
  }

  void marcarLida(Conversa c) {
    if (c.naoLidas == 0) return;
    c.naoLidas = 0;
    notifyListeners();
  }

  void enviar(Conversa c, MensagemChat m) {
    if (semInternet) m.envio = EnvioMensagem.falhou;
    c.mensagens.add(m);
    notifyListeners();
  }

  /// "Tentar de novo": envia se a internet voltou.
  void reenviar(MensagemChat m) {
    if (!semInternet) m.envio = EnvioMensagem.enviada;
    notifyListeners();
  }

  void definirSemInternet(bool valor) {
    semInternet = valor;
    notifyListeners();
  }

  void definirCobranca(bool valor) {
    cobrancaPendente = valor;
    notifyListeners();
  }

  /// Para a demo do estado vazio.
  void limpar() {
    conversas = [];
    cobrancaPendente = false;
    notifyListeners();
  }
}

/// Hora atual no formato 14:32.
String horaAgora() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:'
      '${n.minute.toString().padLeft(2, '0')}';
}

/// Instância única usada pelo app enquanto não há backend.
final conversas = ConversasRepo();
