import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/ajuda.dart';
import 'package:tatu/data/documentos_legais.dart';

/// "Algo errado?" e garantia legal (RN-45, RN-107, RN-108, RN-183).
void main() {
  test('RN-108: termos dizem que o Tatu intermedia e mantêm a garantia legal', () {
    // RN-150: o texto vem de docs/termos-de-uso.md.
    final d = DocumentoLegal.ler(
      TipoDocumento.termos,
      File('../docs/termos-de-uso.md').readAsStringSync(),
    );
    final texto = [
      ...d.essencial,
      for (final s in d.secoes) '${s.titulo} ${s.corpo}',
    ].join(' ').replaceAll('**', '');
    expect(texto, contains('plataforma de intermediação'));
    expect(texto, contains('24 horas'));
    expect(texto, contains('Garantia legal'));
    expect(texto, contains('nada nestes Termos a reduz'));
    expect(texto, isNot(contains('A garantia do Tatu é esse prazo de 24 horas')));
  });

  test('RN-107: depois de 24 h, o Tatu continua no caso (retorno)', () {
    final secoes = {for (final s in artigoReembolso.secoes) s.$1: s.$2};
    expect(secoes.keys, [
      'Nas primeiras 24 horas',
      'Até o fim do prazo de retorno',
      'Depois do prazo',
    ]);
    expect(secoes['Até o fim do prazo de retorno'], contains('retorno sem custo'));
    expect(secoes['Até o fim do prazo de retorno'], contains('outro profissional'));
    expect(secoes['Depois do prazo'], contains('garantia legal'));
  });

  test('RN-107: nenhum texto do app promete garantia sem prazo', () {
    final semPrazo = <String>[];
    final aspas = RegExp(r"'([^']*garantia[^']*)'", caseSensitive: false);
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      for (final linha in f.readAsLinesSync()) {
        if (linha.trimLeft().startsWith('//')) continue;
        for (final m in aspas.allMatches(linha)) {
          final t = m.group(1)!;
          final temPrazo =
              t.contains('24') ||
              t.toLowerCase().contains('garantia legal') ||
              // RN-197: o termo de garantia do recibo (com a data).
              t.toLowerCase().contains('termo de garantia') ||
              t == 'Garantia';
          // Títulos de seção ("5. Garantia") não prometem nada.
          final titulo = RegExp(r'^\d+\. ').hasMatch(t);
          if (!temPrazo && !titulo) semPrazo.add('${f.path}: $t');
        }
      }
    }
    expect(semPrazo, isEmpty);
  });
}
