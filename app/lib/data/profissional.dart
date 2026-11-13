import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../shared/formatadores.dart';

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

@immutable
class ProfissaoEscolhida {
  const ProfissaoEscolhida(this.nome, [this.especialidades = const []]);

  final String nome;
  final List<String> especialidades;

  ProfissaoEscolhida com(List<String> esp) => ProfissaoEscolhida(nome, esp);
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

  /// A dica "Pronta para começar?" já foi vista.
  bool dicaVista = false;

  /// Últimas visitas, a mais recente no fim (true = terminou sem serviço,
  /// só a visita cobrada).
  final List<bool> visitas = [];

  /// Visitas sem serviço entre as últimas [janelaVisitas].
  int get visitasSemServico =>
      visitas.reversed.take(janelaVisitas).where((v) => v).length;

  /// Muitas visitas sem serviço pausam a conta (até falar com o suporte).
  bool get pausada => visitasSemServico >= limiteVisitasSemServico;

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
    ];
    pixTipo = comPix ? TipoPix.cpf : null;
    pixChave = comPix ? cpf : null;
    verificacao = aprovada ? Verificacao.aprovada : Verificacao.emAnalise;
    online = false;
    dicaVista = true;
    visitas.clear();
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
    notifyListeners();
  }

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
