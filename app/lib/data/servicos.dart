import 'package:flutter/foundation.dart';

import 'catalogo_servicos.dart';
import 'profissoes_reguladas.dart';

/// Serviço do catálogo "Outros serviços".
@immutable
class ServicoCatalogo {
  const ServicoCatalogo(this.nome, {this.detalhe, this.palavras = const []});

  /// O ícone vem do mapa de ícones (RN-227, `IconeProfissao`).
  final String nome;

  /// Linha cinza nos resultados da busca.
  final String? detalhe;

  /// Outras palavras que levam a este serviço na busca.
  final List<String> palavras;
}

/// Escolha "Não sei qual serviço": a gente descobre pela descrição.
const naoSeiServico = 'Não sei';

/// RN-161: uma profissão do catálogo como item da lista.
ServicoCatalogo _item(ProfissaoCatalogo p, {String? detalhe}) =>
    ServicoCatalogo(
      p.nome,
      detalhe: detalhe ?? p.especialidades.take(3).join(', '),
      palavras: p.sinonimos,
    );

/// RN-92/RN-161: o "Outros" do cliente, com todas as profissões do modo
/// escolhido ("No local" ou "À distância"), separadas pelos segmentos de
/// `docs/catalogo-de-servicos.md` (Casa e reformas, Aulas, Tecnologia e
/// criação…). Profissão L/D aparece nos dois modos.
List<(String, List<ServicoCatalogo>)> gruposDoModo({required bool distancia}) =>
    [
      for (final (nome, lista) in catalogoServicos.segmentos)
        if (lista.any((p) => distancia ? p.remoto : p.local))
          (
            nome,
            [
              for (final p in lista)
                if (distancia ? p.remoto : p.local) _item(p),
            ],
          ),
    ];

/// RN-161: segmentos do "Outros" no local.
List<(String, List<ServicoCatalogo>)> get gruposServicos =>
    gruposDoModo(distancia: false);

/// RN-161: no cadastro, todos os segmentos (no local e à distância).
List<(String, List<ServicoCatalogo>)> get gruposProfissoes => [
  for (final (nome, lista) in catalogoServicos.segmentos)
    (nome, [for (final p in lista) _item(p)]),
];

/// Atalhos "Mais pedidos perto de você".
const maisPedidos = ['Chaveiro', 'Limpeza', 'Vidraceiro'];

/// Atalhos "Mais pedidos à distância" (RN-92).
const maisPedidosDistancia = [
  'Designer gráfico',
  'Professor particular',
  'Psicólogo',
];

/// Atalhos "Mais procuradas" no cadastro do profissional (C11).
const maisProcuradas = ['Diarista', 'Faz-tudo', 'Vidraceiro'];

String _simples(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString();
}

/// RN-156: profissões reguladas aceitas, para a lista do profissional.
List<ServicoCatalogo> get servicosRegulados => [
  for (final p in profissoesReguladas.reguladasAceitas)
    ServicoCatalogo(
      p.nome,
      detalhe: 'Exige registro no ${p.conselho}',
      palavras: [for (final a in p.apelidos) a.toLowerCase()],
    ),
];

/// RN-161: busca por nome e sinônimos, sem acento e sem diferenciar
/// maiúsculas. Achou pelo sinônimo: "Também chamado de …". Com
/// [profissional], inclui as profissões reguladas (RN-156) e nunca mostra
/// as "fora do Tatu" (RN-160).
///
/// Com [distancia] (cliente), só o que atende no modo escolhido (RN-92):
/// nulo = todos.
List<ServicoCatalogo> buscarServicos(
  String termo, {
  bool profissional = false,
  bool? distancia,
}) {
  final t = _simples(termo.trim());
  if (t.isEmpty) return const [];
  final achados = <String, ServicoCatalogo>{};
  void ver(
    ServicoCatalogo s, {
    List<String>? sinonimos,
    List<String> especialidades = const [],
  }) {
    if (!profissoesReguladas.permitida(s.nome)) return;
    final chave = normalizarProfissao(s.nome);
    if (_simples(s.nome).contains(t)) {
      achados[chave] = s;
      return;
    }
    final sin = (sinonimos ?? s.palavras).where(
      (p) => _simples(p).contains(t) || t.startsWith(_simples(p)),
    );
    if (sin.isNotEmpty) {
      achados[chave] = ServicoCatalogo(
        s.nome,
        detalhe: 'Também chamado de ${sin.first}',
        palavras: s.palavras,
      );
      return;
    }
    // Pela especialidade ("desentup" → Encanador · Desentupimento).
    final esp = especialidades.where((e) => _simples(e).contains(t));
    if (esp.isNotEmpty && t.length >= 4) {
      achados[chave] = ServicoCatalogo(
        s.nome,
        detalhe: esp.first,
        palavras: s.palavras,
      );
    }
  }

  for (final p in catalogoServicos.todas) {
    if (distancia != null && (distancia ? !p.remoto : !p.local)) continue;
    ver(_item(p), especialidades: p.especialidades);
  }
  if (profissional) {
    for (final s in servicosRegulados) {
      if (!achados.containsKey(normalizarProfissao(s.nome))) ver(s);
    }
  }
  return achados.values.toList();
}
