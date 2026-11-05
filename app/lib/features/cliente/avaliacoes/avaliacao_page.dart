import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/avaliacoes.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Detalhe de uma avaliação recebida, com o serviço e a opção de contestar.
class AvaliacaoPage extends StatelessWidget {
  const AvaliacaoPage({super.key, required this.avaliacao});

  final Avaliacao avaliacao;

  @override
  Widget build(BuildContext context) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));
    final a = avaliacao;

    return TelaInterna(
      titulo: 'Avaliação',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          Container(
            padding: const EdgeInsets.all(TatuMedidas.margem),
            decoration: BoxDecoration(
              color: TatuColors.bg,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarIniciais(nome: a.nome, tamanho: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.nome,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            [
                              a.profissao,
                              [a.data, ?a.hora].join(', '),
                            ].join(' · '),
                            style: TatuTexto.detalhe,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Estrelas(nota: a.nota, tamanho: 24),
                const SizedBox(height: 16),
                Text(
                  '“${a.comentarioCompleto ?? a.comentario}”',
                  style: const TextStyle(fontSize: 17, height: 1.4),
                ),
                if (a.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in a.tags) TatuChip(label: t, onTap: () {}),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (a.servico != null) ...[
            const SizedBox(height: TatuMedidas.entreSecoes - 4),
            Material(
              color: TatuColors.bg,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => emBreve('Recibo do serviço'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(TablerIcons.file_text, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serviço: ${a.servico}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (a.valor != null)
                              Text(a.valor!, style: TatuTexto.detalhe),
                          ],
                        ),
                      ),
                      const Icon(
                        TablerIcons.chevron_right,
                        size: 16,
                        color: TatuColors.chevron,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: TatuMedidas.entreSecoes),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Acha que essa nota foi injusta?\n'
              'Nossa equipe analisa e responde por aqui.',
              style: TatuTexto.nota,
            ),
          ),
        ],
      ),
      rodape: FilledButton(
        style: tatuBotaoSecundario(),
        onPressed: () => emBreve('Contestar avaliação'),
        child: const Text('Contestar avaliação'),
      ),
    );
  }
}
