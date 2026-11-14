/// RN-75/RN-85: telefone, e-mail, endereço, @ de rede social e links não
/// passam pelo chat. Quem envia é barrado; quem recebe vê "contato oculto".
library;

enum TipoContato { telefone, email, endereco, rede, link }

extension TipoContatoTexto on TipoContato {
  /// "Telefone não é enviado pelo chat".
  String get aviso => switch (this) {
    TipoContato.telefone => 'Telefone não é enviado pelo chat',
    TipoContato.email => 'E-mail não é enviado pelo chat',
    TipoContato.endereco => 'Endereço não é enviado pelo chat',
    TipoContato.rede || TipoContato.link => 'Contato não é enviado pelo chat',
  };
}

/// Trecho do texto que é um contato.
class TrechoContato {
  const TrechoContato(this.inicio, this.fim, this.tipo);

  final int inicio;
  final int fim;
  final TipoContato tipo;
}

final _email = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+');
final _link = RegExp(
  r'(https?://\S+|www\.\S+|\b[\w-]+\.(com|net|org|me|ly|io|app)(\.br)?\b(/\S*)?)',
  caseSensitive: false,
);
final _rede = RegExp(r'(?<![\w.])@[A-Za-z0-9_.]{2,}');
final _endereco = RegExp(
  r'\b(rua|r\.|avenida|av\.?|alameda|al\.|travessa|tv\.|estrada|rodovia|'
  r'praça|pça\.?)\s+[^\d\n,]{2,40},?\s*(n[º°o]\.?\s*)?\d+',
  caseSensitive: false,
);
// 8 dígitos ou mais, com espaços, traços, pontos ou parênteses no meio.
final _telefone = RegExp(r'\+?\(?\d[\d\s().-]{6,}\d');

/// Contatos encontrados em [texto], em ordem e sem sobreposição.
List<TrechoContato> acharContatos(String texto) {
  final achados = <TrechoContato>[];
  void juntar(RegExp r, TipoContato tipo, [bool Function(String)? vale]) {
    for (final m in r.allMatches(texto)) {
      if (vale != null && !vale(m[0]!)) continue;
      final sobrepoe = achados.any((a) => m.start < a.fim && m.end > a.inicio);
      if (!sobrepoe) achados.add(TrechoContato(m.start, m.end, tipo));
    }
  }

  juntar(_email, TipoContato.email);
  juntar(_link, TipoContato.link);
  juntar(_rede, TipoContato.rede);
  juntar(_endereco, TipoContato.endereco);
  juntar(
    _telefone,
    TipoContato.telefone,
    (s) => s.replaceAll(RegExp(r'\D'), '').length >= 8,
  );
  achados.sort((a, b) => a.inicio.compareTo(b.inicio));
  return achados;
}

/// O primeiro contato no texto (nulo se não há).
TipoContato? contatoNoTexto(String texto) {
  final a = acharContatos(texto);
  return a.isEmpty ? null : a.first.tipo;
}
