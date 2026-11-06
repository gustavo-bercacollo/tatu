import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/ajuda.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'abrir_ajuda.dart';

/// Assunto da ajuda: lista dos artigos (ex.: Pagamento e valores).
class AssuntoPage extends StatelessWidget {
  const AssuntoPage({super.key, required this.assunto});

  final AssuntoAjuda assunto;

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: assunto.titulo,
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          GrupoCartao(
            linhas: [
              for (final a in assunto.artigos)
                LinhaSimples(
                  texto: a.titulo,
                  onTap: () => abrirArtigo(context, a),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
