/// RN-124: filtro de palavras em pedidos, descrições e perfis, para
/// impedir anúncio de venda ou troca de arquivos. A lista é configurável
/// (depois vem do servidor).
abstract final class FiltroPalavras {
  /// Expressões barradas (sem acento e em minúsculas).
  static List<String> lista = [
    'vendo pack',
    'pack',
    'nudes',
    'conteudo adulto',
    'conteudo +18',
    'troco fotos',
    'troca de fotos',
    'troco videos',
    'link na bio',
    'chama no privado',
    'mega link',
  ];

  static String _simples(String s) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = de.indexOf(ch);
      b.write(i < 0 ? ch : para[i]);
    }
    return b.toString();
  }

  /// A primeira expressão barrada que aparece em [texto] (nulo se nenhuma).
  static String? barrada(String texto) {
    final t = ' ${_simples(texto)} ';
    for (final p in lista) {
      final e = _simples(p);
      if (RegExp('(^|[^a-z0-9])${RegExp.escape(e)}([^a-z0-9]|\$)').hasMatch(t)) {
        return p;
      }
    }
    return null;
  }

  /// Aviso padrão quando o texto é barrado.
  static const aviso =
      'Esse texto não segue as regras do Tatu. Não anuncie venda ou troca '
      'de arquivos.';
}
