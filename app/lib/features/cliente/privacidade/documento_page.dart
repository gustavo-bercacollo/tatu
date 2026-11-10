import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/documentos.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'seus_dados_page.dart';

/// Termos de uso ou Política de privacidade: título, data e seções.
class DocumentoPage extends StatelessWidget {
  const DocumentoPage({
    super.key,
    required this.documento,
    this.linkSeusDados = false,
  });

  final Documento documento;

  /// Link "Ver seus dados e direitos" no fim (Política de privacidade).
  final bool linkSeusDados;

  static const _titulo = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: documento.titulo,
      subtitulo: documento.atualizado,
      subtituloNota: true,
      children: [
        for (final (titulo, texto) in documento.secoes) ...[
          Text(titulo, style: _titulo),
          const SizedBox(height: 6),
          Text(texto, style: TatuTexto.comentario),
          const SizedBox(height: TatuMedidas.entreSecoes),
        ],
        if (linkSeusDados)
          Align(
            alignment: Alignment.centerLeft,
            child: LinkAzul(
              'Ver seus dados e direitos',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SeusDadosPage())),
            ),
          ),
      ],
    );
  }
}
