/// Tamanho máximo do texto "Sobre você".
const maxSobre = 300;

/// IA que reescreve o "Sobre você" do profissional.
abstract class MelhoriaTexto {
  Future<String> melhorar(String texto);
}

/// Versão simulada (sem backend): arruma maiúsculas, pontuação e algumas
/// palavras comuns. O texto do desenho tem a resposta pronta.
class MelhoriaTextoMock implements MelhoriaTexto {
  const MelhoriaTextoMock({this.espera = const Duration(milliseconds: 900)});

  final Duration espera;

  static const _trocas = {
    'tbm': 'também',
    'vc': 'você',
    'pq': 'porque',
    'eletrica': 'elétrica',
    'sabado': 'sábado',
    'sabados': 'sábados',
    'servico': 'serviço',
    'servicos': 'serviços',
    'manutencao': 'manutenção',
    'instalacao': 'instalação',
    'experiencia': 'experiência',
    'orcamento': 'orçamento',
    'rapido': 'rápido',
  };

  @override
  Future<String> melhorar(String texto) async {
    await Future<void>.delayed(espera);
    final t = texto.trim();
    if (t.toLowerCase().contains('faz 9 anos')) {
      return 'Encanadora e eletricista há 9 anos. Resolvo vazamentos, '
          'troco chuveiros e faço instalações elétricas. Atendo a zona sul '
          'de SP, inclusive aos sábados.';
    }
    final palavras = t
        .split(RegExp(r'\s+'))
        .map((p) => _trocas[p.toLowerCase()] ?? p);
    final frases = palavras
        .join(' ')
        .split(RegExp(r'(?<=[.!?])\s+|,\s+(?=sou |faço |atendo |trabalho )'))
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .map((f) {
          final frase = f[0].toUpperCase() + f.substring(1);
          return RegExp(r'[.!?]$').hasMatch(frase) ? frase : '$frase.';
        });
    final novo = frases.join(' ');
    return novo.length > maxSobre ? novo.substring(0, maxSobre) : novo;
  }
}

/// Telefone, e-mail, @usuário, links e nomes de redes sociais: não podem
/// aparecer no perfil (o contato é pelo chat do Tatu).
final contatoProibido = RegExp(
  r'(\(?\d{2}\)?[\s.-]?9?\d{4}[\s.-]?\d{4})' // telefone
  r'|([\w.+-]+@[\w-]+\.[\w.]+)' // e-mail
  r'|(@\w{2,})' // @usuario
  r'|(\b(?:https?://|www\.)\S+)' // link
  r'|(\b\w+\.com(?:\.br)?\b)'
  r'|(\b(?:whats\s?app|whats|zap|zapzap|instagram|insta|facebook|face|'
  r'tiktok|telegram)\b)',
  caseSensitive: false,
);
