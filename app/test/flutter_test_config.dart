import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/data/catalogo_servicos.dart';
import 'package:tatu/data/retorno.dart';
import 'package:tatu/features/cliente/retorno/retorno_cliente.dart';
import 'package:tatu/features/entrada/camera_prova_page.dart';

/// RN-161: o catálogo de serviços vem de docs/ e é carregado antes dos testes.
/// RN-184: sem câmera de verdade nos testes (a foto de prova sai na hora) e
/// sem o aceite simulado do retorno (cada teste controla a resposta).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await catalogoServicos.carregar();
  CameraProvaPage.aoVivo = false;
  CameraProvaPage.semCameraAoVivo = () async =>
      FotoProva(tiradaEm: clock.now());
  simularAceiteRetorno = null;
  await testMain();
}
