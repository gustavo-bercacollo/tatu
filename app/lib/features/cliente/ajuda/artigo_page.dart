import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_chip.dart';
import 'abrir_ajuda.dart';

/// Artigo da ajuda: título, resumo, seções, "Isso ajudou?" e suporte.
class ArtigoPage extends StatefulWidget {
  const ArtigoPage({
    super.key,
    required this.artigo,
    this.conteudo = conteudoCliente,
  });

  final Artigo artigo;
  final ConteudoAjuda conteudo;

  @override
  State<ArtigoPage> createState() => _ArtigoPageState();
}

class _ArtigoPageState extends State<ArtigoPage> {
  bool? _ajudou;

  static const _titulo = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) {
    final a = widget.artigo;
    return CadastroScaffold(
      titulo: a.titulo,
      subtitulo: a.resumo ?? '',
      botao: 'Falar com o suporte',
      botaoCinza: true,
      onBotao: () => abrirSuporte(context, widget.conteudo),
      children: [
        for (final (titulo, texto) in a.secoes) ...[
          Text(titulo, style: _titulo),
          const SizedBox(height: 6),
          Text(texto, style: TatuTexto.comentario),
          const SizedBox(height: TatuMedidas.entreSecoes + 4),
        ],
        const Divider(height: 0.5),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Text(
          _ajudou == null ? 'Isso ajudou?' : 'Obrigado pela resposta!',
          style: _titulo,
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        Row(
          children: [
            TatuChip(
              label: 'Sim',
              selecionado: _ajudou == true,
              onTap: () => setState(() => _ajudou = true),
            ),
            const SizedBox(width: 8),
            TatuChip(
              label: 'Não',
              selecionado: _ajudou == false,
              onTap: () => setState(() => _ajudou = false),
            ),
          ],
        ),
      ],
    );
  }
}
