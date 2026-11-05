/// Serviços da Home, na ordem dos chips.
const servicosHome = [
  'Encanador',
  'Eletricista',
  'Pedreiro',
  'Pintor',
  'Montador',
];

/// IA que lê a descrição e sugere um serviço. `null` = sem confiança.
abstract class SugestaoServico {
  String? sugerir(String descricao);
}

/// Versão simulada (sem backend): procura palavras-chave na descrição.
class SugestaoServicoMock implements SugestaoServico {
  const SugestaoServicoMock();

  static const _palavras = {
    'Encanador': [
      'cano',
      'vaz',
      'pia',
      'torneira',
      'registro',
      'esgoto',
      'descarga',
      'entup',
      'água',
      'agua',
    ],
    'Eletricista': [
      'tomada',
      'luz',
      'chuveiro',
      'fio',
      'disjuntor',
      'lâmpada',
      'lampada',
      'energia',
      'curto',
    ],
    'Pedreiro': [
      'parede',
      'reboco',
      'piso',
      'azulejo',
      'muro',
      'rachadura',
      'cimento',
      'telhado',
    ],
    'Pintor': ['pintar', 'pintura', 'tinta', 'mofo'],
    'Montador': [
      'montar',
      'móvel',
      'movel',
      'armário',
      'armario',
      'estante',
      'cama',
      'guarda-roupa',
    ],
  };

  @override
  String? sugerir(String descricao) {
    final texto = descricao.toLowerCase();
    if (texto.trim().length < 8) return null;
    String? melhor;
    var pontos = 0;
    _palavras.forEach((servico, palavras) {
      final p = palavras.where(texto.contains).length;
      if (p > pontos) {
        pontos = p;
        melhor = servico;
      }
    });
    return melhor;
  }
}
