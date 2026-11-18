import 'package:flutter/material.dart';

import 'core/som/som.dart';
import 'core/theme/tatu_theme.dart';
import 'features/entrada/boas_vindas_page.dart';
import 'data/documentos_legais.dart';

void main() {
  // Os assets só podem ser lidos depois que o Flutter inicia.
  WidgetsFlutterBinding.ensureInitialized();
  // RN-150/RN-151: Termos e Política vêm dos .md de docs/.
  documentosLegais.carregarTodos().ignore();
  runApp(const TatuApp());
}

class TatuApp extends StatelessWidget {
  const TatuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tatu',
      debugShowCheckedModeBanner: false,
      theme: tatuTheme(),
      home: const BoasVindasPage(),
      // O 1º toque na tela libera os sons no navegador do celular.
      builder: (_, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => destravarSons(),
        child: child,
      ),
    );
  }
}
