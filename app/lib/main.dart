import 'package:flutter/material.dart';

import 'core/som/som.dart';
import 'core/theme/tatu_theme.dart';
import 'features/entrada/boas_vindas_page.dart';
import 'data/catalogo_servicos.dart';
import 'data/demo_plano_fixo.dart';
import 'data/documentos_legais.dart';
import 'data/pedidos.dart';
import 'data/profissoes_reguladas.dart';

void main() {
  // Os assets só podem ser lidos depois que o Flutter inicia.
  WidgetsFlutterBinding.ensureInitialized();
  // RN-150/RN-151: Termos e Política vêm dos .md de docs/.
  documentosLegais.carregarTodos().ignore();
  // RN-156: lista de profissões reguladas de docs/.
  profissoesReguladas.carregar().ignore();
  catalogoServicos.carregar().ignore();
  // RN-200 a RN-205: planos fixos de demonstração (selo "Plano fixo").
  // O cliente abre sem nada em andamento: a visita da Júlia é amanhã.
  sementeDemoPlanoFixo(visitaHojeDoCliente: false);
  // Sem pedido a caminho nem busca: a demonstração (aceite e
  // deslocamento) começa no primeiro chamado do cliente.
  pedidos.comecarSemAndamento();
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
