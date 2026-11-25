import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/plano_fixo.dart' show diaMes;
import '../../data/profissional.dart';
import '../../data/retorno.dart';
import '../../data/retorno_acoes.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/estado_vazio.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/retorno.dart';
import '../../shared/widgets/tela_interna.dart';

/// Painel interno do suporte (RN-190, RN-191): só os 3 casos de mediação,
/// mais a fila de revisões de decisões automáticas (RN-198).
/// Não é tela do cliente nem do profissional. No protótipo abre segurando
/// o nome "tatu" na tela de boas-vindas.
class PainelMediacaoPage extends StatelessWidget {
  const PainelMediacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: retornos,
      builder: (context, _) {
        final casos = [
          for (final r in retornos.retornos)
            if (r.situacao == SituacaoRetorno.emMediacao) r,
        ];
        final revisoes = retornos.revisoes;
        return TelaInterna(
          titulo: 'Mediações',
          fundoCinza: true,
          corpo: casos.isEmpty && revisoes.isEmpty
              ? const EstadoVazio(
                  icone: TablerIcons.shield_check,
                  titulo: 'Nenhuma mediação aberta',
                  texto: 'Os casos aparecem aqui quando o cliente\n'
                      'pede ajuda ao Tatu.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: TatuMedidas.entreSecoes,
                  ),
                  children: [
                    for (final r in casos) ...[
                      Material(
                        color: TatuColors.bg,
                        borderRadius: BorderRadius.circular(
                          TatuMedidas.raioOpcao,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          title: Text(
                            '${r.primeiroCliente} × ${r.primeiroProfissional}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${motivoMediacaoTexto(r.motivoMediacao!)} · '
                            'responder até '
                            '${diaMes(RegrasRetorno.prazoMediacao(r.mediacaoDesde!))}',
                            style: TatuTexto.nota,
                          ),
                          trailing: const Icon(TablerIcons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CasoMediacaoPage(retorno: r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: TatuMedidas.entreItens),
                    ],
                    // RN-198: revisões de decisões automáticas.
                    if (revisoes.isNotEmpty) ...[
                      const SizedBox(height: TatuMedidas.entreItens),
                      const Text('REVISÕES', style: TatuTexto.secao),
                      const SizedBox(height: 8),
                      for (final v in revisoes) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TatuColors.bg,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioOpcao,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${v.decisao.rotulo} · ${v.quem}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${v.servico ?? 'Conta'} · responder até '
                                '${dataCurta(v.respostaAte)}',
                                style: TatuTexto.nota,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens),
                      ],
                    ],
                  ],
                ),
        );
      },
    );
  }
}

/// RN-190: por que o caso chegou.
String motivoMediacaoTexto(MotivoMediacao m) => switch (m) {
  MotivoMediacao.contestouRecusa => 'Cliente contestou a recusa',
  MotivoMediacao.continuouProblema => 'Problema continuou depois do retorno',
  MotivoMediacao.contestouOutroProblema => 'Cliente contestou "outro problema"',
};

/// RN-191: decisão sugerida (no backend, pela IA; aqui, por regras).
DecisaoMediacao decisaoSugerida(PedidoRetorno r) {
  final recusa = r.motivoRecusa ?? '';
  if (r.motivoMediacao == MotivoMediacao.contestouRecusa &&
      recusa == 'Mau uso depois do serviço') {
    return DecisaoMediacao.naoProcede;
  }
  if (r.motivoMediacao == MotivoMediacao.continuouProblema) {
    return DecisaoMediacao.refazerComOutro;
  }
  return DecisaoMediacao.devolver100;
}

/// RN-191: resumo do caso (no backend, montado pela IA).
String resumoMediacao(PedidoRetorno r) {
  final partes = <String>[
    '${r.primeiroCliente} pediu retorno do serviço de ${r.diaServico} '
        '(${r.descricaoServico}, ${reais(r.valorServico)}): '
        '"${r.descricao}".',
    if (r.motivoRecusa != null)
      '${r.primeiroProfissional} recusou: ${r.motivoRecusa!.toLowerCase()}.',
    if (r.outroProblema != null)
      '${r.primeiroProfissional} disse que é outro problema: '
          '"${r.outroProblema}".',
    if (r.motivoMediacao == MotivoMediacao.continuouProblema)
      'O retorno foi feito, mas ${r.primeiroCliente} diz que o problema '
          'continua.',
    '${r.fotos.length} foto(s) do problema, tiradas na hora.',
  ];
  return partes.join(' ');
}

/// Um caso: resumo da IA, fotos, chat, histórico, sugestão e as 4
/// decisões fixas.
class CasoMediacaoPage extends StatelessWidget {
  const CasoMediacaoPage({super.key, required this.retorno});

  final PedidoRetorno retorno;

  Future<void> _decidir(BuildContext context, DecisaoMediacao d) async {
    final r = retorno;
    final sim = await confirmar(
      context,
      titulo: d.rotulo,
      texto:
          'A decisão vai pelo chat do Tatu aos dois e encerra o pedido, sem '
          'recurso.',
      confirmar: 'Decidir',
      cancelar: 'Voltar',
      iconeAviso: false,
    );
    if (!sim || !context.mounted) return;
    decidirRetorno(r, d);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final r = retorno;
    final sugerida = decisaoSugerida(r);
    final provas = retornos.provas[r.servico];
    final pronto = provas?.fotos.firstOrNull ?? retornos.fotoServicoPronto;
    final faltas = r.profissional == profissional.nome
        ? profissional.faltasRecentes
        : 0;
    return TelaInterna(
      titulo: 'Mediação',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.symmetric(vertical: TatuMedidas.entreSecoes),
        children: [
          _Bloco(
            // RN-199: a IA só resume e sugere; quem decide é a pessoa.
            titulo: 'RESUMO (IA) · SÓ SUGERE',
            filhos: [
              Text(resumoMediacao(r), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: TatuMedidas.entreItens),
              Text(
                'Sugestão da IA: ${sugerida.rotulo} · quem decide é você',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.verified,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prazo: até '
                '${diaMes(RegrasRetorno.prazoMediacao(r.mediacaoDesde!))} '
                '(${RegrasRetorno.mediacaoDiasUteis} dias úteis).',
                style: TatuTexto.nota,
              ),
            ],
          ),
          _Bloco(
            titulo: 'FOTOS',
            filhos: [
              Wrap(
                spacing: TatuMedidas.entreItens,
                runSpacing: TatuMedidas.entreItens,
                children: [
                  if (pronto != null) MiniaturaProva(foto: pronto),
                  for (final f in r.fotos) MiniaturaProva(foto: f),
                  if (r.fotoNoLocal != null)
                    MiniaturaProva(foto: r.fotoNoLocal!),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Serviço pronto · problema · no local (com data e hora). '
                'Acesso restrito ao suporte; apagadas depois de '
                '${RegrasRetorno.guardaFotos.inDays ~/ 365} anos.',
                style: TatuTexto.nota,
              ),
            ],
          ),
          _Bloco(
            titulo: 'CHAT',
            filhos: [
              if (provas == null || provas.chat.isEmpty)
                const Text('Sem mensagens guardadas.', style: TatuTexto.nota)
              else
                for (final m in provas.chat.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(m, style: TatuTexto.detalhe),
                  ),
            ],
          ),
          _Bloco(
            titulo: 'HISTÓRICO',
            filhos: [
              Text(
                '${r.primeiroProfissional}: $faltas falta(s) em '
                '${RegrasRetorno.janelaFaltas.inDays} dias',
                style: TatuTexto.detalhe,
              ),
              Text(
                '${r.primeiroCliente}: ${retornos.naoProcedeCliente.length} '
                '"não procede" em 6 meses',
                style: TatuTexto.detalhe,
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          for (final d in DecisaoMediacao.values) ...[
            FilledButton(
              style: d == sugerida ? null : tatuBotaoSecundario(),
              onPressed: () => _decidir(context, d),
              child: Text(d.rotulo),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.titulo, required this.filhos});

  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: TatuMedidas.entreItens + 4),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TatuTexto.secao),
          const SizedBox(height: 8),
          ...filhos,
        ],
      ),
    ),
  );
}
