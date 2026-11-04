import 'package:flutter/material.dart';

import 'core/theme/tatu_theme.dart';
import 'features/entrada/boas_vindas_page.dart';

void main() {
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
    );
  }
}
