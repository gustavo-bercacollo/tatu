import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../shared/formatadores.dart';
import 'consulta_registro.dart';
import 'prazos.dart';
import 'profissoes_reguladas.dart';
import 'regras_distancia.dart';

/// Profissões que aparecem como atalho no cadastro ("Outros" abre a lista).
const profissoesPrincipais = [
  'Encanador',
  'Eletricista',
  'Pedreiro',
  'Pintor',
  'Montador',
  'Chaveiro',
  'Ar-condicionado',
  'Jardinagem',
  'Limpeza',
];

/// No máximo 3 profissões e 3 especialidades por profissão.
const maxProfissoes = 3;
const maxEspecialidades = 3;

/// Taxa do Tatu sobre o que o cliente paga pelo app.
/// Provisória: comissão ainda é decisão em aberto.
const taxaTatu = 0.10;

/// Conta pausada: [limiteVisitasSemServico] das últimas [janelaVisitas]
/// visitas terminaram sem serviço (só a visita cobrada). Provisório.
const janelaVisitas = 8;
const limiteVisitasSemServico = 5;

const _especialidades = {
  'Encanador': [
    'Reparos',
    'Instalações',
    'Esgoto',
    'Vazamentos',
    'Desentupimento',
    "Caixa d'água",
    'Chuveiros e aquecedores',
    'Torneiras e pias',
  ],
  'Eletricista': [
    'Reparos',
    'Instalações',
    'Quadro de luz',
    'Tomadas e interruptores',
    'Chuveiros',
    'Iluminação',
  ],
  'Pedreiro': [
    'Reformas',
    'Alvenaria',
    'Pisos e revestimentos',
    'Reboco',
    'Telhados',
  ],
  'Pintor': [
    'Paredes internas',
    'Fachadas',
    'Textura',
    'Massa corrida',
    'Portas e janelas',
  ],
  'Montador': [
    'Móveis',
    'Armários',
    'Prateleiras',
    'Cortinas e persianas',
    'Suportes de TV',
  ],
  'Chaveiro': [
    'Abertura de portas',
    'Cópias de chave',
    'Troca de fechadura',
    'Chave de carro',
  ],
  'Ar-condicionado': ['Instalação', 'Limpeza', 'Manutenção', 'Recarga de gás'],
  'Jardinagem': ['Corte de grama', 'Poda', 'Paisagismo', 'Limpeza de terreno'],
  'Limpeza': ['Residencial', 'Pós-obra', 'Vidros', 'Estofados'],
  'Designer': ['Logos', 'Identidade visual', 'Posts', 'Cardápios', 'Embalagens'],
  'Programador': ['Sites', 'Aplicativos', 'Planilhas', 'Automação'],
  'Professor': ['Reforço escolar', 'Inglês', 'Matemática', 'Redação'],
  'Contador': ['MEI', 'Imposto de renda', 'Abertura de empresa', 'Folha'],
  'Advogado': ['Contratos', 'Trabalhista', 'Família', 'Consumidor'],
};

/// Especialidades que dá para escolher em cada profissão.
List<String> especialidadesDe(String profissao) =>
    _especialidades[profissao] ??
    const ['Reparos', 'Instalações', 'Manutenção', 'Emergências'];

/// "Encanador" → "Encanadora" quando [feminino].
String profissaoNoGenero(String p, {required bool feminino}) {
  if (!feminino) return p;
  if (p.endsWith('or')) return '${p}a';
  if (p.endsWith('eiro')) return '${p.substring(0, p.length - 1)}a';
  return p;
}

/// RN-97: como o profissional atende em cada profissão.
enum ModoAtendimento { local, distancia, ambos }

extension ModoAtendimentoTexto on ModoAtendimento {
  String get nome => switch (this) {
    ModoAtendimento.local => 'No local',
    ModoAtendimento.distancia => 'À distância',
    ModoAtendimento.ambos => 'Os dois',
  };

  bool get local => this != ModoAtendimento.distancia;
  bool get remoto => this != ModoAtendimento.local;
}

/// Profissões que costumam ser à distância (escolha inicial em "Como você
/// atende?"; exemplos, decisão em aberto).
const profissoesDistancia = [
  'Designer',
  'Programador',
  'Professor',
  'Contador',
  'Advogado',
  'Tradutor',
  'Redator',
  'Editor de vídeo',
  'Social media',
];

/// RN-125: profissões de tecnologia: só nelas a entrega pode ter programa
/// pronto (.apk, .exe) e script/código-fonte.
const profissoesTecnologia = {'Programador'};

bool ehTecnologia(String profissao) =>
    profissoesTecnologia.contains(profissao) ||
    profissoesTecnologia.contains(profissao.replaceFirst(RegExp(r'a$'), ''));

/// Modo sugerido para uma profissão nova.
ModoAtendimento modoSugerido(String profissao) =>
    profissoesDistancia.contains(profissao)
    ? ModoAtendimento.distancia
    : ModoAtendimento.local;

@immutable
class ProfissaoEscolhida {
  const ProfissaoEscolhida(
    this.nome, [
    this.especialidades = const [],
    this.modo = ModoAtendimento.local,
  ]);

  final String nome;
  final List<String> especialidades;

  /// RN-97: no local, à distância ou os dois.
  final ModoAtendimento modo;

  ProfissaoEscolhida com(List<String> esp) =>
      ProfissaoEscolhida(nome, esp, modo);

  ProfissaoEscolhida comModo(ModoAtendimento m) =>
      ProfissaoEscolhida(nome, especialidades, m);
}

/// RN-157: situação do registro de uma profissão regulada.
enum StatusRegistro { emAnalise, conferido, naoEncontrado, suspenso }

/// Documento usado na verificação (lido pela foto; RN-156: a CNH serve
/// de registro para frete e motorista).
enum DocumentoVerificacao { rg, cnh }

/// RN-156 a RN-160: prazos e números de exemplo do registro.
abstract final class RegrasRegistro {
  /// RN-157: o Tatu confere em até 2 dias úteis (exemplo).
  static const diasUteisConferencia = 2;

  /// RN-160: confere de novo de tempos em tempos (exemplo).
  static const rechecarACada = Duration(days: 90);

  /// RN-160: e antes do vencimento (exemplo).
  static const antesDoVencimento = Duration(days: 30);

  static const ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO',
  ];
}

String _nomeComparavel(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// RN-156: registro informado para uma profissão regulada.
class RegistroProfissional {
  RegistroProfissional({
    required this.profissao,
    required this.conselho,
    required this.uf,
    required this.numero,
  });

  final String profissao;
  final String conselho;
  String uf;
  String numero;
  StatusRegistro status = StatusRegistro.emAnalise;

  /// Por que não conferiu (não achado, nome diferente, cancelado…).
  String? motivo;
  DateTime? conferidoEm;
  DateTime? validade;

  /// RN-159: "CREF 012345-G/SP".
  String get rotulo => '$conselho $numero/$uf';

  /// CNH ainda sem número (documento da verificação foi o RG).
  bool get faltaNumero => numero.trim().isEmpty;
}

enum TipoPix { cpf, celular, email, aleatoria }

extension TipoPixTexto on TipoPix {
  String get nome => switch (this) {
    TipoPix.cpf => 'CPF',
    TipoPix.celular => 'Celular',
    TipoPix.email => 'E-mail',
    TipoPix.aleatoria => 'Chave aleatória',
  };

  /// Dentro do campo: "Sua chave (celular)".
  String get rotulo => switch (this) {
    TipoPix.cpf => 'CPF',
    TipoPix.celular => 'celular',
    TipoPix.email => 'e-mail',
    TipoPix.aleatoria => 'chave aleatória',
  };
}

enum Verificacao { naoEnviada, emAnalise, refazer, reprovada, aprovada }

/// Avaliação que o profissional recebeu (prévia do perfil).
@immutable
class AvaliacaoRecebida {
  const AvaliacaoRecebida(
    this.cliente,
    this.servico,
    this.quando,
    this.texto, {
    this.nota = 5,
  });

  final String cliente;
  final String servico;
  final String quando;
  final String texto;
  final int nota;
}

/// Cadastro e estado do profissional. Versão simulada (sem backend).
class ProfissionalRepo extends ChangeNotifier {
  ProfissionalRepo() {
    restaurar();
  }

  String nome = '';
  String cpf = ''; // só dígitos

  /// Do documento (lido na verificação).
  String nascimento = '';
  String celular = ''; // só dígitos
  bool feminino = false;
  List<ProfissaoEscolhida> profissoes = [];
  TipoPix? pixTipo;
  String? pixChave;
  Verificacao verificacao = Verificacao.naoEnviada;

  /// Fotos da verificação (só câmera, nunca galeria).
  Uint8List? fotoFrente;
  Uint8List? fotoVerso;
  Uint8List? selfie;

  /// Abre a câmera do celular e devolve a foto (null se a pessoa
  /// desistir). Trocável nos testes.
  Future<Uint8List?> Function({required bool frontal}) tirarFoto =
      _tirarComCamera;

  /// O app sempre abre offline.
  bool online = false;

  /// RN-156/RN-157: registro de cada profissão regulada, pelo nome.
  final registros = <String, RegistroProfissional>{};

  /// Documento da verificação (mock: o app ainda não lê a foto).
  DocumentoVerificacao documentoVerificacao = DocumentoVerificacao.rg;

  /// RN-156: número da CNH lido no documento (quando foi a CNH).
  String? cnhDoDocumento;

  /// A dica "Pronta para começar?" já foi vista.
  bool dicaVista = false;

  /// Últimas visitas, a mais recente no fim (true = terminou sem serviço,
  /// só a visita cobrada).
  final List<bool> visitas = [];

  /// Visitas sem serviço entre as últimas [janelaVisitas].
  int get visitasSemServico =>
      visitas.reversed.take(janelaVisitas).where((v) => v).length;

  /// Muitas visitas sem serviço pausam a conta (até falar com o suporte).
  bool get pausadaPorVisitas => visitasSemServico >= limiteVisitasSemServico;

  /// RN-77: chamados que ele aceitou e não foi (devolvidos à busca).
  final List<DateTime> abandonos = [];

  /// RN-79: abandonos dentro de [Prazos.janelaAbandonos].
  int get abandonosRecentes {
    final desde = clock.now().subtract(Prazos.janelaAbandonos);
    return abandonos.where((d) => d.isAfter(desde)).length;
  }

  /// RN-79: três abandonos em 30 dias pausam a conta.
  bool get pausadaPorAbandonos =>
      abandonosRecentes >= Prazos.abandonosParaPausar;

  /// RN-106: sinais à distância que voltaram ao cliente sem entrega.
  final List<DateTime> sinaisSemEntrega = [];

  int get sinaisSemEntregaRecentes {
    final desde = clock.now().subtract(RegrasDistancia.janelaSinais);
    return sinaisSemEntrega.where((d) => d.isAfter(desde)).length;
  }

  /// RN-106: 3 sinais sem entrega em 30 dias pausam a conta.
  bool get pausadaPorSinais =>
      sinaisSemEntregaRecentes >= RegrasDistancia.sinaisParaPausar;

  /// RN-106: um sinal voltou ao cliente sem entrega.
  void registrarSinalSemEntrega() {
    sinaisSemEntrega.add(clock.now());
    if (pausada) online = false;
    notifyListeners();
  }

  /// Simula a conta pausada por sinais sem entrega (RN-106).
  void pausarPorSinaisParaDemo() {
    final agora = clock.now();
    sinaisSemEntrega
      ..clear()
      ..addAll([
        for (var i = 0; i < RegrasDistancia.sinaisParaPausar; i++)
          agora.subtract(Duration(days: 2 + i * 7)),
      ]);
    online = false;
    notifyListeners();
  }

  /// Conta pausada (por visitas sem serviço ou por abandonos): não fica
  /// online até falar com o suporte.
  bool get pausada =>
      pausadaPorVisitas || pausadaPorAbandonos || pausadaPorSinais;

  /// RN-77: registra um abandono (chamado devolvido à busca).
  void registrarAbandono() {
    abandonos.add(clock.now());
    if (pausada) online = false;
    notifyListeners();
  }

  /// Simula a conta pausada por 3 abandonos em 30 dias (RN-79).
  void pausarPorAbandonosParaDemo() {
    final agora = clock.now();
    abandonos
      ..clear()
      ..addAll([
        agora.subtract(const Duration(days: 20)),
        agora.subtract(const Duration(days: 6)),
        agora.subtract(const Duration(hours: 2)),
      ]);
    online = false;
    notifyListeners();
  }

  void registrarVisita({required bool semServico}) {
    visitas.add(semServico);
    if (pausada) online = false;
    notifyListeners();
  }

  /// Simula a conta pausada (5 das últimas 8 visitas sem serviço).
  void pausarParaDemo() {
    visitas
      ..clear()
      ..addAll([false, true, false, true, false, true, true, true]);
    online = false;
    notifyListeners();
  }

  int raioKm = 10;
  double nota = 4.9;
  int servicosFeitos = 29;
  int desdeAno = 2025;
  String sobre =
      'Encanadora com experiência em instalação, manutenção e reparo de '
      'sistemas hidráulicos residenciais e comerciais. Atendo casas, '
      'apartamentos e pequenos comércios.';

  final avaliacoes = const [
    AvaliacaoRecebida(
      'Geovanna Berçacollo',
      'Vazamento',
      'há 5 dias',
      'Excelente serviço! Profissional pontual, educada e resolveu o '
          'problema rapidamente. Recomendo!',
    ),
    AvaliacaoRecebida(
      'Cezar Lima',
      'Chuveiro',
      'há 2 semanas',
      'Resolveu tudo no mesmo dia. Trabalho limpo e caprichado.',
    ),
    AvaliacaoRecebida(
      'Marina Souza',
      'Torneira',
      'há 1 mês',
      'Muito atenciosa, explicou o que estava errado.',
      nota: 4,
    ),
  ];

  /// Distribuição das notas (5, 4, 3) em fração.
  final barrasNotas = const [0.92, 0.06, 0.02];

  String get primeiroNome => nome.trim().split(' ').first;
  bool get temPix => pixChave != null;
  String get profissaoPrincipal =>
      profissoes.isEmpty ? '' : profissoes.first.nome;

  /// "•••.456.789-••"
  String get cpfMascarado {
    final d = cpf.padRight(11, '0');
    return '•••.${d.substring(3, 6)}.${d.substring(6, 9)}-••';
  }

  /// Volta ao começo (sem cadastro).
  void restaurar() {
    nome = '';
    cpf = '';
    nascimento = '';
    celular = '';
    feminino = false;
    profissoes = [];
    _chamadosDe = null;
    registros.clear();
    documentoVerificacao = DocumentoVerificacao.rg;
    cnhDoDocumento = null;
    pixTipo = null;
    pixChave = null;
    verificacao = Verificacao.naoEnviada;
    fotoFrente = null;
    fotoVerso = null;
    selfie = null;
    tirarFoto = _tirarComCamera;
    online = false;
    dicaVista = false;
    raioKm = 10;
    visitas.clear();
    abandonos.clear();
    sinaisSemEntrega.clear();
    notifyListeners();
  }

  /// Cadastro pronto e aprovado (Luiza Vilela), para demonstrações.
  void demo({bool comPix = true, bool aprovada = true}) {
    nome = 'Luiza Vilela';
    cpf = '12345678909';
    nascimento = '12/04/1990';
    celular = '11977776666';
    feminino = true;
    profissoes = const [
      ProfissaoEscolhida('Encanador', ['Reparos', 'Instalações', 'Esgoto']),
      // RN-97: uma profissão à distância para a demonstração.
      ProfissaoEscolhida(
        'Designer',
        ['Logos', 'Identidade visual', 'Posts'],
        ModoAtendimento.distancia,
      ),
    ];
    _chamadosDe = null;
    pixTipo = comPix ? TipoPix.cpf : null;
    pixChave = comPix ? cpf : null;
    verificacao = aprovada ? Verificacao.aprovada : Verificacao.emAnalise;
    online = false;
    dicaVista = true;
    visitas.clear();
    abandonos.clear();
    sinaisSemEntrega.clear();
    notifyListeners();
  }

  void salvarDados({
    required String nome,
    required String cpf,
    required String celular,
  }) {
    this.nome = nome.trim();
    this.cpf = soDigitos(cpf);
    this.celular = soDigitos(celular);
    notifyListeners();
  }

  void definirProfissoes(List<ProfissaoEscolhida> lista) {
    profissoes = List.of(lista);
    // Profissão que saiu leva o registro junto.
    registros.removeWhere((k, _) => !profissoes.any((p) => p.nome == k));
    notifyListeners();
  }

  // ---------- Profissões reguladas (RN-156 a RN-160) ----------

  /// RN-156: a profissão exige registro?
  bool exigeRegistro(String profissao) =>
      profissoesReguladas.regulada(profissao);

  /// RN-157: só a profissão regulada com registro conferido recebe
  /// chamados; as livres recebem sempre.
  bool podeReceberChamadosDe(String profissao) =>
      !exigeRegistro(profissao) ||
      registros[profissao]?.status == StatusRegistro.conferido;

  /// RN-156: informa conselho, estado e número (sem foto). Fica em análise.
  RegistroProfissional enviarRegistro({
    required String profissao,
    required String conselho,
    required String uf,
    required String numero,
  }) {
    final r = RegistroProfissional(
      profissao: profissao,
      conselho: conselho,
      uf: uf,
      numero: numero.trim(),
    );
    registros[profissao] = r;
    notifyListeners();
    return r;
  }

  /// RN-156: CNH (frete, motorista): lida do documento da verificação; se
  /// o documento foi o RG, fica esperando o número.
  RegistroProfissional registrarCnh(String profissao) {
    final doc = documentoVerificacao == DocumentoVerificacao.cnh
        ? (cnhDoDocumento ?? '')
        : '';
    return enviarRegistro(
      profissao: profissao,
      conselho: 'CNH',
      uf: 'BR',
      numero: doc,
    );
  }

  /// RN-157/RN-158/RN-160: confere na consulta pública. O nome do
  /// registro precisa ser o mesmo do documento; cancelado, suspenso ou
  /// vencido não confere.
  Future<StatusRegistro> conferirRegistro(
    String profissao, {
    DateTime? agora,
  }) async {
    final r = registros[profissao];
    if (r == null || r.faltaNumero) return StatusRegistro.emAnalise;
    final c = consultaRegistro;
    if (c is ConsultaRegistroMock) c.nomePadrao = nome;
    final res = await c.consultar(
      conselho: r.conselho,
      uf: r.uf,
      numero: r.numero,
    );
    final hoje = agora ?? clock.now();
    if (!res.encontrado) {
      r
        ..status = StatusRegistro.naoEncontrado
        ..motivo = 'não encontrado';
    } else if (_nomeComparavel(res.nome ?? '') != _nomeComparavel(nome)) {
      r
        ..status = StatusRegistro.naoEncontrado
        ..motivo = 'nome diferente do documento';
    } else if (res.situacao != SituacaoRegistro.ativo ||
        (res.validade != null && res.validade!.isBefore(hoje))) {
      r
        ..status = StatusRegistro.suspenso
        ..motivo = res.situacao == SituacaoRegistro.ativo
            ? 'vencido'
            : res.situacao.name;
    } else {
      r
        ..status = StatusRegistro.conferido
        ..motivo = null
        ..conferidoEm = hoje
        ..validade = res.validade;
    }
    notifyListeners();
    return r.status;
  }

  /// RN-158: corrigir o número ou o estado volta para "em análise".
  void corrigirRegistro(String profissao, {required String uf, required String numero}) {
    final r = registros[profissao];
    if (r == null) return;
    r
      ..uf = uf
      ..numero = numero.trim()
      ..status = StatusRegistro.emAnalise
      ..motivo = null;
    notifyListeners();
  }

  /// RN-160: registros conferidos que precisam de nova conferência
  /// (periódica ou perto do vencimento).
  List<RegistroProfissional> paraRechecar([DateTime? agora]) {
    final hoje = agora ?? clock.now();
    return [
      for (final r in registros.values)
        if (r.status == StatusRegistro.conferido &&
            ((r.conferidoEm != null &&
                    hoje.difference(r.conferidoEm!) >=
                        RegrasRegistro.rechecarACada) ||
                (r.validade != null &&
                    r.validade!.difference(hoje) <=
                        RegrasRegistro.antesDoVencimento)))
          r,
    ];
  }

  /// RN-160: confere de novo; cancelado, suspenso ou vencido pausa só
  /// aquela profissão.
  Future<void> rechecarRegistros([DateTime? agora]) async {
    for (final r in paraRechecar(agora)) {
      await conferirRegistro(r.profissao, agora: agora);
    }
  }

  /// RN-97: muda como atende numa profissão.
  void definirModo(String profissao, ModoAtendimento modo) {
    profissoes = [
      for (final p in profissoes) p.nome == profissao ? p.comModo(modo) : p,
    ];
    notifyListeners();
  }

  /// RN-11: profissões em que recebe chamados agora (nulo = todas).
  List<String>? _chamadosDe;

  /// RN-157: profissão regulada sem registro conferido fica de fora.
  List<String> get chamadosDe => [
    for (final p in profissoes)
      if ((_chamadosDe == null || _chamadosDe!.contains(p.nome)) &&
          podeReceberChamadosDe(p.nome))
        p.nome,
  ];

  /// Liga ou desliga uma profissão; pelo menos uma continua ligada.
  void alternarChamadosDe(String profissao) {
    final atual = chamadosDe;
    if (atual.contains(profissao)) {
      if (atual.length == 1) return;
      _chamadosDe = [...atual]..remove(profissao);
    } else {
      _chamadosDe = [...atual, profissao];
    }
    notifyListeners();
  }

  /// Profissões ligadas em que atende no local / à distância (RN-93).
  bool get recebeNoLocal => profissoes.any(
    (p) => chamadosDe.contains(p.nome) && p.modo.local,
  );
  bool get recebeDistancia => profissoes.any(
    (p) => chamadosDe.contains(p.nome) && p.modo.remoto,
  );

  void definirEspecialidades(String profissao, List<String> esp) {
    profissoes = [
      for (final p in profissoes) p.nome == profissao ? p.com(esp) : p,
    ];
    notifyListeners();
  }

  void adicionarProfissao(ProfissaoEscolhida p) {
    profissoes = [...profissoes, p];
    notifyListeners();
  }

  /// Simula a checagem do nome do dono da chave. Devolve o erro ou null.
  /// Regra do protótipo: celular diferente do cadastrado é de outra pessoa.
  String? conferirPix(TipoPix tipo, String chave) {
    final t = chave.trim();
    switch (tipo) {
      case TipoPix.cpf:
        return null;
      case TipoPix.celular:
        if (soDigitos(t).length != 11) return 'Digite o celular com DDD.';
        if (soDigitos(t) != celular) {
          return 'Essa chave está no nome de outra pessoa. '
              'Use uma chave em nome de $nome.';
        }
        return null;
      case TipoPix.email:
        return emailValido(t) ? null : 'Digite um e-mail válido.';
      case TipoPix.aleatoria:
        return t.length >= 8 ? null : 'Cole a chave aleatória completa.';
    }
  }

  void salvarPix(TipoPix tipo, String chave) {
    pixTipo = tipo;
    pixChave = tipo == TipoPix.cpf ? cpf : chave.trim();
    notifyListeners();
  }

  void enviarVerificacao() {
    verificacao = Verificacao.emAnalise;
    notifyListeners();
  }

  void definirVerificacao(Verificacao v) {
    verificacao = v;
    notifyListeners();
  }

  void ficarOnline(bool v) {
    if (v && pausada) return;
    online = v;
    notifyListeners();
  }

  void verDica() {
    dicaVista = true;
    notifyListeners();
  }

  void definirSobre(String texto) {
    sobre = texto.trim();
    notifyListeners();
  }

  void definirRaio(int km) {
    raioKm = km;
    notifyListeners();
  }
}

/// A câmera foi negada nas permissões do celular.
class CameraDoDocumentoNegada implements Exception {}

Future<Uint8List?> _tirarComCamera({required bool frontal}) async {
  try {
    final arquivo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: frontal ? CameraDevice.front : CameraDevice.rear,
      maxWidth: 1600,
    );
    return await arquivo?.readAsBytes();
  } on Exception catch (e) {
    if ('$e'.contains('access_denied')) throw CameraDoDocumentoNegada();
    rethrow;
  }
}

/// CPF com dígitos verificadores certos.
bool cpfValido(String texto) {
  final d = soDigitos(texto);
  if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;
  int digito(int n) {
    var soma = 0;
    for (var i = 0; i < n; i++) {
      soma += int.parse(d[i]) * (n + 1 - i);
    }
    final r = (soma * 10) % 11;
    return r == 10 ? 0 : r;
  }

  return digito(9) == int.parse(d[9]) && digito(10) == int.parse(d[10]);
}

/// Instância única usada pelo app enquanto não há backend.
final profissional = ProfissionalRepo();
