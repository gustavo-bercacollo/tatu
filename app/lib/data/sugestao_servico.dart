/// Serviços da Home, na ordem dos chips.
const servicosHome = [
  'Encanador',
  'Eletricista',
  'Pedreiro',
  'Pintor',
];

/// RN-92: serviços da Home no modo "À distância" (exemplos: decisão em
/// aberto sobre as profissões do lançamento).
const servicosDistanciaHome = [
  'Designer',
  'Programador',
  'Professor',
  'Advogado',
];

/// IA que lê a descrição e sugere um serviço. `null` = sem confiança.
/// Com [distancia], só entre os serviços à distância (RN-92).
abstract class SugestaoServico {
  String? sugerir(String descricao, {bool distancia = false});
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

  static const _palavrasDistancia = {
    'Designer': ['logo', 'design', 'arte', 'banner', 'identidade', 'cardápio'],
    'Programador': ['site', 'aplicativo', 'app', 'sistema', 'planilha'],
    'Professor': ['aula', 'prova', 'reforço', 'inglês', 'matemática'],
    'Contador': ['imposto', 'nota fiscal', 'mei', 'declaração', 'contab'],
    'Advogado': ['processo', 'contrato', 'jurídic', 'trabalhista', 'advog'],
  };

  @override
  String? sugerir(String descricao, {bool distancia = false}) {
    final texto = descricao.toLowerCase();
    if (texto.trim().length < 8) return null;
    String? melhor;
    var pontos = 0;
    (distancia ? _palavrasDistancia : _palavras).forEach((servico, palavras) {
      final p = palavras.where(texto.contains).length;
      if (p > pontos) {
        pontos = p;
        melhor = servico;
      }
    });
    return melhor;
  }
}
