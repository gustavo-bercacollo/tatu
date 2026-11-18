import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// RN-150: mostra o markdown simples dos documentos legais (parágrafos,
/// "8.1. **Título.** texto", "### subtítulo", listas, tabelas, citações e
/// **negrito**). Links viram texto (o documento é lido dentro do app).
class TextoMarkdown extends StatelessWidget {
  const TextoMarkdown(this.texto, {super.key});

  final String texto;

  static const _corpo = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: TatuColors.textSecondary,
  );
  static const _titulo = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: TatuColors.textPrimary,
  );

  /// "**a** b [c](d)" → trechos com negrito.
  static List<InlineSpan> trechos(String s, {TextStyle? negrito}) {
    final semLinks = s.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m.group(1)!,
    );
    final partes = semLinks.split('**');
    return [
      for (final (i, p) in partes.indexed)
        if (p.isNotEmpty)
          TextSpan(
            text: p,
            style: i.isOdd
                ? (negrito ??
                      const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TatuColors.textPrimary,
                      ))
                : null,
          ),
    ];
  }

  /// Blocos separados por linha em branco.
  static List<String> blocos(String texto) => [
    for (final b in texto.split(RegExp(r'\n\s*\n')))
      if (b.trim().isNotEmpty) b.trim(),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, b) in blocos(texto).indexed) ...[
        if (i > 0) const SizedBox(height: TatuMedidas.entreItens + 6),
        _bloco(b),
      ],
    ],
  );

  Widget _bloco(String b) {
    if (b.startsWith('### ')) {
      return Text(b.substring(4), style: _titulo);
    }
    if (b.startsWith('> ')) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TatuColors.warningSoft,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
        ),
        child: Text.rich(
          TextSpan(children: trechos(b.replaceAll(RegExp(r'^> ?', multiLine: true), ''))),
          style: _corpo.copyWith(color: TatuColors.warningTexto),
        ),
      );
    }
    final linhas = b.split('\n');
    if (linhas.every((l) => l.trimLeft().startsWith('|'))) {
      return _tabela(linhas);
    }
    if (linhas.every((l) => l.trimLeft().startsWith('- '))) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final l in linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(2, 9, 10, 0),
                    child: CircleAvatar(
                      radius: 2.5,
                      backgroundColor: TatuColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: trechos(l.trimLeft().substring(2))),
                      style: _corpo,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    // "8.1. **Valor combinado.** O profissional…" → título + texto.
    final m = RegExp(r'^(\d+(?:\.\d+)+\.)\s+\*\*([^*]+?)\.?\*\*\s*(.*)$', dotAll: true)
        .firstMatch(b);
    if (m != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${m.group(1)} ${m.group(2)}', style: _titulo),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: trechos(m.group(3)!)), style: _corpo),
        ],
      );
    }
    return Text.rich(
      TextSpan(children: trechos(b.replaceAll('\n', ' '))),
      style: _corpo,
    );
  }

  Widget _tabela(List<String> linhas) {
    final linhasValidas = [
      for (final l in linhas)
        if (!RegExp(r'^\|\s*-').hasMatch(l.trim()))
          l.trim().split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList(),
    ];
    if (linhasValidas.isEmpty) return const SizedBox.shrink();
    final cabecalho = linhasValidas.first;
    return Container(
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in linhasValidas.skip(1).indexed) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.isNotEmpty)
                    Text.rich(
                      TextSpan(children: trechos(c.first)),
                      style: _corpo.copyWith(
                        color: TatuColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  for (final (j, v) in c.skip(1).indexed)
                    Text.rich(
                      TextSpan(
                        children: [
                          if (j + 1 < cabecalho.length)
                            TextSpan(text: '${cabecalho[j + 1]}: '),
                          ...trechos(v),
                        ],
                      ),
                      style: TatuTexto.nota,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
