import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/ajuda.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'abrir_ajuda.dart';
import 'busca_ajuda_page.dart';

/// Ajuda: busca, "Falar com o suporte", assuntos e perguntas frequentes.
class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Ajuda',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          CampoBusca(
            hint: 'Buscar na ajuda',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const BuscaAjudaPage())),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          CartaoAcao(
            icone: const IconeSuporte(),
            titulo: 'Falar com o suporte',
            detalhe: 'Respondemos em poucos minutos',
            onTap: () => abrirSuporte(context),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          GrupoLista(
            titulo: 'Assuntos',
            itens: [
              for (final a in assuntosAjuda)
                ItemLista(
                  icone: a.icone,
                  texto: a.titulo,
                  onTap: () => abrirAssunto(context, a),
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          GrupoCartao(
            titulo: 'Perguntas frequentes',
            linhas: [
              for (final p in perguntasFrequentes)
                LinhaSimples(
                  texto: p.titulo,
                  onTap: () => abrirArtigo(context, p),
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
        ],
      ),
    );
  }
}

/// Círculo preto com o balão de conversa (marca do suporte).
class IconeSuporte extends StatelessWidget {
  const IconeSuporte({super.key, this.tamanho = 40});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: const BoxDecoration(
        color: TatuColors.action,
        shape: BoxShape.circle,
      ),
      child: Icon(
        TablerIcons.message_circle,
        size: tamanho * 0.5,
        color: TatuColors.onAction,
      ),
    );
  }
}
