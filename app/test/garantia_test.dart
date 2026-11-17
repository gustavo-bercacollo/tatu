import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/ajuda.dart';
import 'package:tatu/data/documentos.dart';

/// Garantia do Tatu de 24 horas (RN-45, RN-107, RN-108).
void main() {
  test('RN-108: termos dizem que o Tatu intermedia e a garantia é de 24 h', () {
    final texto = termosDeUso.secoes.map((s) => '${s.$1} ${s.$2}').join(' ');
    expect(texto, contains('O Tatu intermedia'));
    expect(texto, contains('A garantia do Tatu é de 24 horas'));
    expect(texto, contains('garantia legal do serviço é do profissional'));
    expect(texto, contains('Código de Defesa do Consumidor'));
  });

  test('RN-107: depois de 24 h, chama o profissional pelo mesmo chat', () {
    final secoes = {for (final s in artigoReembolso.secoes) s.$1: s.$2};
    expect(secoes.keys, ['Em até 24 horas', 'Depois de 24 horas']);
    expect(secoes['Depois de 24 horas'], contains('mesmo chat'));
    expect(secoes['Depois de 24 horas'], contains('outro profissional'));
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
              t.contains('24') || t.toLowerCase().contains('garantia legal');
          // Títulos de seção ("5. Garantia") não prometem nada.
          final titulo = RegExp(r'^\d+\. ').hasMatch(t);
          if (!temPrazo && !titulo) semPrazo.add('${f.path}: $t');
        }
      }
    }
    expect(semPrazo, isEmpty);
  });
}
