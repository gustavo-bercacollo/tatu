import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/avaliacoes.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tela_interna.dart';
import 'avaliacao_page.dart';
import 'cartao_avaliacao.dart';

/// Minhas avaliações: as que o cliente recebeu e as que deu.
class MinhasAvaliacoesPage extends StatefulWidget {
  const MinhasAvaliacoesPage({super.key, this.aba = 0});

  /// 0 = Recebidas, 1 = Enviadas.
  final int aba;

  @override
  State<MinhasAvaliacoesPage> createState() => _MinhasAvaliacoesPageState();
}

class _MinhasAvaliacoesPageState extends State<MinhasAvaliacoesPage> {
  late int _aba = widget.aba;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: avaliacoes,
      builder: (context, _) {
        if (avaliacoes.vazio) {
          return TelaInterna(
            titulo: 'Minhas avaliações',
            corpo: const EstadoVazio(
              icone: TablerIcons.star,
              titulo: 'Nenhuma avaliação ainda',
              texto:
                  'Depois do seu primeiro serviço,\n'
                  'o profissional avalia você.\n'
                  'Boas notas ajudam a ser aceito mais rápido.',
            ),
            // Volta para a Home, onde se pede o serviço.
            rodape: FilledButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Pedir um serviço'),
            ),
          );
        }
        return TelaInterna(
          titulo: 'Minhas avaliações',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
            children: [
              Segmento(
                opcoes: const ['Recebidas', 'Enviadas'],
                selecionada: _aba,
                onMudar: (i) => setState(() => _aba = i),
              ),
              if (_aba == 0) ..._recebidas(context) else ..._enviadas(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _recebidas(BuildContext context) => [
    const SizedBox(height: 16),
    const _Resumo(),
    const SizedBox(height: 16),
    _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que dizem de você',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: TatuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in avaliacoes.tagsMaisCitadas)
                TatuChip(label: t, onTap: () {}),
            ],
          ),
        ],
      ),
    ),
    const _TituloSecao('Recentes'),
    for (final a in avaliacoes.recebidas) ...[
      CartaoAvaliacao(
        avaliacao: a,
        nome: a.nomeCurto,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => AvaliacaoPage(avaliacao: a))),
      ),
      const SizedBox(height: TatuMedidas.entreItens),
    ],
  ];

  List<Widget> _enviadas() => [
    const _TituloSecao('Avaliações que você deu'),
    for (final a in avaliacoes.enviadas) ...[
      CartaoAvaliacao(avaliacao: a, nome: a.nome),
      const SizedBox(height: TatuMedidas.entreItens),
    ],
  ];
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      16,
      TatuMedidas.entreSecoes,
      16,
      TatuMedidas.tituloSecao + 4,
    ),
    child: Text(texto.toUpperCase(), style: TatuTexto.secao),
  );
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: child,
  );
}

/// Média, estrelas, total e barras por nota.
class _Resumo extends StatelessWidget {
  const _Resumo();

  @override
  Widget build(BuildContext context) {
    final media = avaliacoes.media;
    final maior = avaliacoes.porNota.values.fold(1, (a, b) => a > b ? a : b);
    return _Cartao(
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.toStringAsFixed(1).replaceAll('.', ','),
                  style: const TextStyle(
                    fontSize: 48,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Estrelas(nota: media.round(), tamanho: 16),
                const SizedBox(height: 10),
                Text(
                  '${avaliacoes.total} avaliações',
                  style: TatuTexto.detalhe,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                for (final n in [5, 4, 3, 2, 1])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          child: Text('$n', style: TatuTexto.nota),
                        ),
                        Expanded(
                          child: _Barra(fracao: avaliacoes.porNota[n]! / maior),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.fracao});

  final double fracao;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: TatuColors.trilho,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Mesmo com zero, fica um pontinho, como no desenho.
          Container(
            height: 6,
            width: (c.maxWidth * fracao).clamp(6, c.maxWidth),
            decoration: BoxDecoration(
              color: TatuColors.action,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
