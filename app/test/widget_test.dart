import 'package:flutter_test/flutter_test.dart';

import 'package:tatu/main.dart';

void main() {
  testWidgets('Boas-vindas mostra as duas opções e o Entrar', (tester) async {
    await tester.pumpWidget(const TatuApp());

    expect(find.text('Como você quer usar o Tatu?'), findsOneWidget);
    expect(find.text('Preciso de um serviço'), findsOneWidget);
    expect(find.text('Quero trabalhar'), findsOneWidget);
    expect(find.textContaining('Entrar', findRichText: true), findsOneWidget);
  });
}
