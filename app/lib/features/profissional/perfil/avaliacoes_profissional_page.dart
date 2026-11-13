import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/avaliacoes_profissional.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// Minhas avaliações do profissional: média, barras, elogios mais
/// citados e as avaliações recentes (Todas · Com comentário · Até 3 ★).
/// Notas de 1 ou 2 estrelas podem ser contestadas.
class AvaliacoesProfissionalPage extends StatefulWidget {
  const AvaliacoesProfissionalPage({super.key, this.filtro = 0});

  /// Aba inicial (capturas de tela).
  final int filtro;

  @override
  State<AvaliacoesProfissionalPage> createState() =>
      _AvaliacoesProfissionalPageState();
}

class _AvaliacoesProfissionalPageState
    extends State<AvaliacoesProfissionalPage> {
  late int _filtro = widget.filtro;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: avaliacoesProfissional,
      builder: (context, _) {
        final r = avaliacoesProfissional;
        if (r.vazio) {
          return const TelaInterna(
            titulo: 'Minhas avaliações',
            fundoCinza: true,
            corpo: EstadoVazio(
              icone: TablerIcons.star,
              titulo: 'Nenhuma avaliação ainda',
              texto:
                  'Depois do seu primeiro serviço, os clientes podem avaliar '
                  'você. Elas aparecem aqui.',
            ),
          );
        }
        final lista = switch (_filtro) {
          1 => [for (final a in r.recentes) if (a.comentario.isNotEmpty) a],
          2 => [for (final a in r.recentes) if (a.nota <= 3) a],
          _ => r.recentes,
        };
        return TelaInterna(
          titulo: 'Minhas avaliações',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
            children: [
              if (_filtro == 0) ...[
                const _Resumo(),
                const SizedBox(height: TatuMedidas.entreSecoes),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('MAIS ELOGIADO', style: TatuTexto.secao),
                ),
                const SizedBox(height: TatuMedidas.tituloSecao + 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (texto, n) in r.elogios)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: const ShapeDecoration(
                          color: TatuColors.fill,
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          '$texto · $n',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
              ],
              Segmento(
                opcoes: const ['Todas', 'Com comentário', 'Até 3'],
                icones: const {2: TablerIcons.star_filled},
                selecionada: _filtro,
                onMudar: (i) => setState(() => _filtro = i),
              ),
              const SizedBox(height: 16),
              if (_filtro == 2 && r.queixa != null) ...[
                _DicaIa(
                  'Clientes citaram “${r.queixa}” ${r.vezesQueixa} vezes. '
                  'Avisar o horário no chat ajuda.',
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
              ],
              for (final a in lista) ...[
                _CartaoAvaliacao(
                  avaliacao: a,
                  onContestar: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContestarAvaliacaoPage(avaliacao: a),
                    ),
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Cartão branco: média grande, estrelas, total, variação do mês e
/// barras laranja por nota.
class _Resumo extends StatelessWidget {
  const _Resumo();

  @override
  Widget build(BuildContext context) {
    final r = avaliacoesProfissional;
    final subiu = r.variacaoMes >= 0;
    final variacao = r.variacaoMes.abs().toStringAsFixed(1).replaceAll('.', ',');
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.media.toStringAsFixed(1).replaceAll('.', ','),
                  style: const TextStyle(
                    fontSize: 52,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Estrelas(nota: r.media.round(), tamanho: 16),
                const SizedBox(height: 12),
                Text('${r.total} avaliações', style: TatuTexto.detalhe),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      subiu
                          ? TablerIcons.trending_up
                          : TablerIcons.trending_down,
                      size: 16,
                      color: subiu ? TatuColors.onlineTexto : TatuColors.danger,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${subiu ? 'Subiu' : 'Caiu'} $variacao este mês',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: subiu
                              ? TatuColors.onlineTexto
                              : TatuColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                for (final n in [5, 4, 3, 2, 1])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          child: Text('$n', style: TatuTexto.nota),
                        ),
                        Expanded(child: _Barra(fracao: r.porNota[n] ?? 0)),
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: TatuColors.trilho,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (fracao > 0)
          Container(
            height: 8,
            width: (c.maxWidth * fracao).clamp(4, c.maxWidth),
            decoration: BoxDecoration(
              color: TatuColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    ),
  );
}

/// Dica azul da IA (✦) sobre as notas baixas.
class _DicaIa extends StatelessWidget {
  const _DicaIa(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.verifiedSoft,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Row(
      children: [
        const Icon(TablerIcons.sparkles, size: 22, color: TatuColors.verified),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 15, color: TatuColors.verified),
          ),
        ),
      ],
    ),
  );
}

class _CartaoAvaliacao extends StatelessWidget {
  const _CartaoAvaliacao({required this.avaliacao, required this.onContestar});

  final AvaliacaoDeCliente avaliacao;
  final VoidCallback onContestar;

  @override
  Widget build(BuildContext context) {
    final a = avaliacao;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarIniciais(nome: a.cliente),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.cliente,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(a.data, style: TatuTexto.nota),
                  ],
                ),
                const SizedBox(height: 2),
                Text(a.servico, style: TatuTexto.detalhe),
                const SizedBox(height: 8),
                Estrelas(nota: a.nota),
                if (a.comentario.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(a.comentario, style: TatuTexto.comentario),
                ],
                if (a.contestavel) ...[
                  const SizedBox(height: 4),
                  LinkAzul('Contestar', onTap: onContestar),
                ] else if (a.contestada) ...[
                  const SizedBox(height: 8),
                  const Text('Em revisão pela equipe', style: TatuTexto.nota),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contestar uma avaliação injusta: motivo e relato opcional.
class ContestarAvaliacaoPage extends StatefulWidget {
  const ContestarAvaliacaoPage({
    super.key,
    required this.avaliacao,
    this.motivo,
  });

  final AvaliacaoDeCliente avaliacao;

  /// Motivo já marcado (capturas de tela).
  final int? motivo;

  @override
  State<ContestarAvaliacaoPage> createState() => _ContestarAvaliacaoPageState();
}

class _ContestarAvaliacaoPageState extends State<ContestarAvaliacaoPage> {
  late int? _motivo = widget.motivo;
  final _relato = TextEditingController();

  @override
  void dispose() {
    _relato.dispose();
    super.dispose();
  }

  void _enviar() {
    FocusScope.of(context).unfocus();
    avaliacoesProfissional.contestar(widget.avaliacao);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ContestacaoRecebidaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.avaliacao;
    final estrelas = a.nota == 1 ? '1 estrela' : '${a.nota} estrelas';
    return CadastroScaffold(
      titulo: 'Contestar avaliação',
      subtitulo:
          '${a.cliente} · $estrelas · ${a.data}\n'
          'Nossa equipe revisa em até 3 dias úteis.',
      botao: 'Enviar para revisão',
      onBotao: _motivo == null ? null : _enviar,
      children: [
        for (var i = 0; i < motivosContestacao.length; i++) ...[
          OpcaoSelecionavel(
            selecionado: _motivo == i,
            rotulo: motivosContestacao[i],
            onTap: () => setState(() => _motivo = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  BolinhaEscolha(selecionado: _motivo == i),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      motivosContestacao[i],
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
        ],
        const SizedBox(height: 4),
        TatuField(
          label: 'Conte o que aconteceu (opcional)',
          controller: _relato,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

/// Contestação enviada.
class ContestacaoRecebidaPage extends StatelessWidget {
  const ContestacaoRecebidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const Icon(
        TablerIcons.check,
        size: 44,
        color: TatuColors.online,
      ),
      titulo: 'Recebemos sua contestação',
      texto:
          'Se a avaliação for injusta, ela sai da sua nota. Avisamos em até '
          '3 dias úteis.',
      principal: 'Voltar para avaliações',
      onPrincipal: () => Navigator.of(context).maybePop(),
    );
  }
}
