import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/catalogo_servicos.dart';

/// RN-161: o catálogo de serviços vem de docs/ e é carregado antes dos testes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await catalogoServicos.carregar();
  await testMain();
}
