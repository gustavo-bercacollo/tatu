import 'package:flutter/material.dart';

import '../../data/profissional.dart';
import 'cadastro/boas_vindas_profissional_page.dart';
import 'cadastro/resultado_page.dart';

/// "Trocar para modo profissional" (Perfil do cliente): sem cadastro,
/// abre as boas-vindas do profissional; com cadastro, a Home dele.
void trocarParaModoProfissional(BuildContext context) {
  if (profissional.verificacao == Verificacao.naoEnviada) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BoasVindasProfissionalPage()),
    );
  } else {
    profissional.ficarOnline(false); // o app sempre abre offline
    abrirHomeProfissional(context);
  }
}
