import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conta.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../data/plano_fixo.dart' show diaMes;
import '../../../data/retorno.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/campo_texto_longo.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/retorno.dart';
import '../../entrada/camera_prova_page.dart';
import '../atividade/contestar_page.dart';
import '../chamar/procurando_page.dart';
import '../mensagens/chat_page.dart';

/// Protótipo: o profissional aceita o retorno sozinho depois disso (nulo
/// nos testes, que controlam cada resposta).
Duration? simularAceiteRetorno = const Duration(seconds: 4);

/// RN-45/RN-184: o cliente pede o retorno de [p]. Nas primeiras 24 horas
/// o valor continua retido (RN-46). Devolve nulo se já houver um pedido.
PedidoRetorno? pedirRetornoCliente(
  PedidoConcluido p, {
  required String descricao,
  required List<FotoProva> fotos,
  String? motivo,
}) {
  final agora = clock.now();
  final concluido = p.concluidoEm;
  final r = retornos.pedir(
    PedidoRetorno(
      servico: p.numero,
      servicoNome: p.servico,
      descricaoServico: p.descricao,
      diaServico: p.dia,
      profissional: p.profissional,
      profissionalFeminino: p.feminino,
      cliente: conta.nomeCompleto,
      // Protótipo: a conta não guarda gênero; a demo é a Ana.
      clienteFeminina: true,
      valorServico: p.servicoParaDevolver,
      descricao: descricao,
      fotos: List.of(fotos),
      pedidoEm: agora,
      retido:
          concluido == null || RegrasRetorno.protegidoAgora(concluido, agora),
      motivo: motivo,
      pagamento: p.pagamento.isEmpty ? 'Visa 4242' : p.pagamento,
    ),
  );
  // Protótipo: a profissional responde e marca a próxima sexta às 14h.
  final espera = simularAceiteRetorno;
  if (r != null && espera != null) {
    Timer(espera, () => retornos.aceitar(r, _proximaSexta(clock.now())));
  }
  return r;
}

DateTime _proximaSexta(DateTime agora) {
  var d = DateTime(agora.year, agora.month, agora.day, 14);
  do {
    d = d.add(const Duration(days: 1));
  } while (d.weekday != DateTime.friday);
  return d;
}

/// Abre o chat com o profissional do retorno (ou volta, se não houver).
void abrirChatDoRetorno(
  BuildContext context,
  PedidoConcluido p, {
  bool substituir = false,
}) {
  final c = conversas.conversas
      .where((c) => c.nome == p.profissional)
      .firstOrNull;
  final nav = Navigator.of(context);
  if (c == null) {
    mostrarAvisoTopo(
      context,
      titulo: 'Pedido de retorno enviado',
      texto: '${p.feminino ? 'Ela' : 'Ele'} tem 48 horas para responder.',
    );
    if (substituir) nav.pop();
    return;
  }
  final rota = MaterialPageRoute(builder: (_) => ChatPage(conversa: c));
  substituir ? nav.pushReplacement(rota) : nav.push(rota);
}

/// C223/C224 · RN-45/RN-183: cartão no detalhe do pedido concluído.
/// Nas primeiras 24 horas, "Pagamento protegido"; depois, "O problema
/// voltou?" até o fim do prazo. Com pedido aberto, mostra a situação.
class CartaoAlgoErrado extends StatelessWidget {
  const CartaoAlgoErrado({super.key, required this.pedido});

  final PedidoConcluido pedido;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: retornos,
      builder: (context, _) {
        final p = pedido;
        final concluido = p.concluidoEm;
        if (p.cancelado || concluido == null) return const SizedBox.shrink();
        final agora = clock.now();
        final r = retornos.doServico(p.numero);
        Widget cartao;
        if (r != null) {
          cartao = CartaoAcao(
            icone: const IconeCirculo(TablerIcons.refresh),
            titulo: 'Pedido de retorno',
            detalhe: textoSituacaoCliente(r),
            onTap: () => abrirChatDoRetorno(context, p),
          );
        } else if (RegrasRetorno.protegidoAgora(concluido, agora)) {
          final ate = concluido.add(RegrasRetorno.protegido);
          final hoje = ate.day == agora.day && ate.month == agora.month;
          cartao = CartaoAcao(
            icone: const IconeCirculo(
              TablerIcons.shield_check,
              cor: TatuColors.onlineTexto,
              fundo: TatuColors.onlineSoft,
            ),
            titulo: 'Pagamento protegido por 24h',
            detalhe:
                'Algo errado? Avise até ${hoje ? 'hoje' : diaMes(ate)}, '
                '${ate.hour.toString().padLeft(2, '0')}:'
                '${ate.minute.toString().padLeft(2, '0')}.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContestarServicoPage(pedido: p),
              ),
            ),
          );
        } else if (agora.isBefore(p.retornoAte!)) {
          // RN-193: sem retorno mediado por um tempo; segue pela Ajuda.
          final semAte = retornos.semRetornoMediadoAte(agora);
          cartao = semAte != null
              ? CartaoAcao(
                  icone: const IconeCirculo(TablerIcons.refresh),
                  titulo: 'Retorno pelo app suspenso',
                  detalhe: 'Até ${diaMes(semAte)}. Fale com a Ajuda.',
                  onTap: () {},
                )
              : CartaoAcao(
                  icone: const IconeCirculo(TablerIcons.refresh),
                  titulo: 'O problema voltou?',
                  detalhe:
                      'Peça um retorno sem custo até ${dataCurta(p.retornoAte!)}.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PedirRetornoPage(pedido: p),
                    ),
                  ),
                );
        } else {
          // RN-183: depois do prazo, vício oculto vai pela Ajuda.
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: TatuMedidas.entreItens + 4),
          child: cartao,
        );
      },
    );
  }
}

/// Uma linha com a situação do retorno (cartão do detalhe).
String textoSituacaoCliente(PedidoRetorno r) => switch (r.situacao) {
  SituacaoRetorno.aguardando =>
    'Aguardando ${r.oProfissional} · até ${diaHora(r.respondaAte)}',
  SituacaoRetorno.aceito when r.marcadoPara != null =>
    'Retorno marcado · ${quandoRetorno(r.marcadoPara!)}',
  SituacaoRetorno.aceito => 'Retorno aceito · sem custo',
  SituacaoRetorno.outroProblema => 'É outro problema, segundo ${r.oProfissional}',
  SituacaoRetorno.recusado => 'Recusado: “${r.motivoRecusa!.toLowerCase()}”',
  SituacaoRetorno.feito => 'Retorno feito · o problema foi resolvido?',
  SituacaoRetorno.cumpridoAusente => 'Retorno dado como cumprido',
  SituacaoRetorno.resolvidoAutomatico =>
    r.resolucao == ResolucaoAutomatica.devolucao
        ? 'Devolvemos ${reais(r.valorServico)}'
        : 'O Tatu paga outro ${r.servicoNome.toLowerCase()}',
  SituacaoRetorno.emMediacao => 'O Tatu está analisando',
  SituacaoRetorno.encerrado => 'Encerrado',
};

/// C225 · RN-184: "O que voltou a dar problema?" com descrição e fotos
/// tiradas na hora (galeria não).
class PedirRetornoPage extends StatefulWidget {
  const PedirRetornoPage({super.key, required this.pedido});

  final PedidoConcluido pedido;

  @override
  State<PedirRetornoPage> createState() => _PedirRetornoPageState();
}

class _PedirRetornoPageState extends State<PedirRetornoPage> {
  final _texto = TextEditingController();
  final _fotos = <FotoProva>[];

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _camera() async {
    final f = await tirarFotoProva(context);
    if (f != null && mounted) setState(() => _fotos.add(f));
  }

  void _pedir() {
    final r = pedirRetornoCliente(
      widget.pedido,
      descricao: _texto.text.trim(),
      fotos: _fotos,
    );
    if (r == null) return;
    abrirChatDoRetorno(context, widget.pedido, substituir: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final ela = p.feminino ? 'a' : 'o';
    return CadastroScaffold(
      titulo: 'O que voltou a dar problema?',
      subtitulo:
          'Vamos pedir para $ela ${p.primeiroNome} voltar, sem custo.\n'
          '${p.feminino ? 'Ela' : 'Ele'} tem '
          '${RegrasRetorno.respostaProfissional.inHours} horas para responder.',
      botao: 'Pedir retorno',
      onBotao: _texto.text.trim().isEmpty ? null : _pedir,
      children: [
        CampoTextoLongo(
          controller: _texto,
          hint: 'Conte o que aconteceu',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const Text('Tire fotos do problema agora', style: TatuTexto.nota),
        const SizedBox(height: TatuMedidas.entreItens),
        FotosProva(fotos: _fotos, onCamera: _camera),
        const SizedBox(height: TatuMedidas.entreSecoes),
        NotaIcone(
          icone: TablerIcons.clock,
          texto:
              'Se ${p.feminino ? 'ela' : 'ele'} recusar ou não responder, '
              'o Tatu resolve com você.',
        ),
      ],
    );
  }
}

/// C226 a C231 · o retorno dentro do chat do cliente.
List<Widget> secaoRetornoCliente(
  BuildContext context,
  PedidoRetorno r, {
  required String endereco,
}) {
  final nome = r.primeiroProfissional;
  SituacaoCartaoRetorno? linha;
  final depois = <Widget>[];
  switch (r.situacao) {
    case SituacaoRetorno.aguardando:
      linha = SituacaoCartaoRetorno(
        TablerIcons.clock,
        'Aguardando ${r.oProfissional} · até ${diaHora(r.respondaAte)}',
        TatuColors.warningTexto,
      );
    case SituacaoRetorno.aceito:
      depois.add(
        CartaoSituacaoRetorno(
          titulo: 'Retorno aceito · sem custo',
          linha: r.marcadoPara == null ? null : quandoRetorno(r.marcadoPara!),
          nota: r.marcadoPara == null
              ? '${r.oProfissional} vai marcar o dia em até '
                    '${RegrasRetorno.marcarEm.inDays} dias.'
              : 'Na hora, passe o código ${r.codigo} para ${r.oProfissional}.',
        ),
      );
    case SituacaoRetorno.recusado:
      linha = SituacaoCartaoRetorno(
        TablerIcons.x,
        'Recusado: “${r.motivoRecusa!.toLowerCase()}”',
        TatuColors.danger,
      );
      depois.add(
        CartaoTatuRetorno(
          escudo: true,
          titulo: 'Quer ajuda do Tatu?',
          texto: 'Vamos olhar a conversa, as fotos e o serviço.',
          botao: 'Pedir ajuda ao Tatu',
          onBotao: () =>
              pedirAjudaAoTatu(context, r, MotivoMediacao.contestouRecusa),
          segundo: 'Ok, entendi',
          onSegundo: () => retornos.okEntendi(r),
        ),
      );
    case SituacaoRetorno.outroProblema:
      linha = SituacaoCartaoRetorno(
        TablerIcons.alert_circle,
        '$nome diz que é outro problema',
        TatuColors.warningTexto,
      );
      depois.add(
        CartaoTatuRetorno(
          escudo: true,
          titulo: 'Não é outro problema?',
          texto:
              '${r.outroProblema ?? ''}\n${r.profissionalFeminino ? 'Ela' : 'Ele'}'
              ' vai mandar um valor. Se for o mesmo problema, o Tatu analisa.',
          botao: 'Pedir ajuda ao Tatu',
          onBotao: () => pedirAjudaAoTatu(
            context,
            r,
            MotivoMediacao.contestouOutroProblema,
          ),
        ),
      );
    case SituacaoRetorno.feito:
      depois.add(
        CartaoTatuRetorno(
          escudo: true,
          titulo: '${r.oProfissional[0].toUpperCase()}'
              '${r.oProfissional.substring(1)} fez o retorno',
          texto: 'O problema foi resolvido?',
          botao: 'Sim, resolveu',
          onBotao: () => retornos.resolveu(r, true),
          segundo: 'Não, continua o problema',
          onSegundo: () => pedirAjudaAoTatu(
            context,
            r,
            MotivoMediacao.continuouProblema,
          ),
        ),
      );
    case SituacaoRetorno.cumpridoAusente:
      linha = SituacaoCartaoRetorno(
        TablerIcons.calendar,
        'Retorno marcado · ${quandoRetorno(r.marcadoPara!)}',
        TatuColors.textSecondary,
      );
      final m = r.marcadoPara!;
      depois.add(
        CartaoSituacaoRetorno(
          aviso: true,
          titulo: 'Você não estava no retorno',
          nota:
              '${r.oProfissional[0].toUpperCase()}${r.oProfissional.substring(1)}'
              ' veio às ${m.hour}h e esperou '
              '${RegrasRetorno.esperaNaPorta.inMinutes} min.\n'
              'O retorno foi dado como cumprido.',
        ),
      );
    case SituacaoRetorno.resolvidoAutomatico:
      linha = SituacaoCartaoRetorno(
        TablerIcons.x,
        switch (r.falha) {
          FalhaProfissional.naoMarcou =>
            '$nome não marcou o retorno em ${RegrasRetorno.marcarEm.inDays} dias',
          FalhaProfissional.naoVeio => '$nome não veio no retorno',
          _ =>
            '$nome não respondeu em '
                '${RegrasRetorno.respostaProfissional.inHours} horas',
        },
        TatuColors.danger,
      );
      final servico = r.servicoNome.toLowerCase();
      depois.add(
        r.resolucao == ResolucaoAutomatica.devolucao
            ? CartaoTatuRetorno(
                verde: true,
                titulo: 'Devolvemos ${reais(r.valorServico)}',
                texto: 'No ${r.pagamento}, em até 7 dias.\n'
                    'O pedido foi encerrado.',
              )
            : CartaoTatuRetorno(
                titulo: 'O Tatu paga outro $servico',
                texto:
                    'Até ${reais(r.valorServico)}, sem custo para você.\n'
                    'Chamamos alguém perto para resolver.',
                botao: 'Chamar outro $servico',
                onBotao: () {
                  // RN-188: quem falhou não volta para este pedido.
                  pedidos.recusados.add(r.profissional);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProcurandoPage(
                        servico: r.servicoNome,
                        endereco: endereco,
                        descricao: r.descricao,
                      ),
                    ),
                  );
                },
              ),
      );
    case SituacaoRetorno.emMediacao:
      depois.add(
        CartaoTatuRetorno(
          escudo: true,
          titulo: 'O Tatu está analisando',
          texto:
              'Respondemos até ${diaMes(RegrasRetorno.prazoMediacao(r.mediacaoDesde!))}, '
              'pelo chat do Tatu.',
        ),
      );
    case SituacaoRetorno.encerrado:
      linha = SituacaoCartaoRetorno(
        TablerIcons.check,
        r.decisao != null
            ? 'Decisão do Tatu: ${r.decisao!.rotulo.toLowerCase()}'
            : r.resolvidoSemResposta
            ? 'Dado como resolvido · sem resposta em '
                  '${RegrasRetorno.resolveuEm.inHours} horas'
            : 'Encerrado',
        TatuColors.onlineTexto,
      );
  }
  // C231 · RN-198: decisão só do sistema pode ser revista em 7 dias.
  final automatica = r.decisaoAutomatica;
  if (automatica != null && r.decididoEm != null) {
    depois.add(
      PedirRevisao(
        decisao: automatica,
        quem: r.cliente,
        decididoEm: r.decididoEm!,
        servico: r.servico,
      ),
    );
  }
  return [
    const SizedBox(height: 18),
    if (r.situacao == SituacaoRetorno.feito) ...[
      MarcoConcluido(
        'Retorno feito · ${diaMes(r.feitoEm!)} · sem custo',
        nota: false,
      ),
      const SizedBox(height: 18),
    ],
    CartaoPedidoRetorno(pedido: r, meu: true, situacao: linha),
    for (final w in depois) ...[const SizedBox(height: 18), w],
  ];
}

/// C234 · RN-187: folha "A Luiza fez o retorno · O problema foi resolvido?".
Future<void> perguntarResolveu(BuildContext context, PedidoRetorno r) async {
  final sim = await perguntar(
    context,
    icone: TablerIcons.refresh,
    iconeAviso: false,
    titulo:
        '${r.oProfissional[0].toUpperCase()}${r.oProfissional.substring(1)} '
        'fez o retorno',
    texto: 'O problema foi resolvido?',
    confirmar: 'Sim, resolveu',
    cancelar: 'Não, continua o problema',
    nota:
        'Sem resposta em ${RegrasRetorno.resolveuEm.inHours} horas, damos '
        'como resolvido.',
  );
  if (sim == null || !context.mounted) return;
  if (sim) return retornos.resolveu(r, true);
  await pedirAjudaAoTatu(context, r, MotivoMediacao.continuouProblema);
}

/// RN-190: abre a mediação (uma por serviço) e mostra "O Tatu vai
/// analisar".
Future<void> pedirAjudaAoTatu(
  BuildContext context,
  PedidoRetorno r,
  MotivoMediacao motivo,
) async {
  if (!retornos.mediar(r, motivo)) {
    mostrarAvisoTopo(
      context,
      titulo: 'Não dá para pedir de novo',
      texto: 'Este serviço já teve uma análise do Tatu.',
    );
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => AnaliseTatuPage(pedido: r)),
  );
}

/// C232 · RN-190/RN-191: "O Tatu vai analisar".
class AnaliseTatuPage extends StatelessWidget {
  const AnaliseTatuPage({super.key, required this.pedido});

  final PedidoRetorno pedido;

  @override
  Widget build(BuildContext context) {
    final r = pedido;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margemCadastro,
            TatuMedidas.topo,
            TatuMedidas.margemCadastro,
            TatuMedidas.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: TatuColors.fill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(TablerIcons.shield_check, size: 40),
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              const Text(
                'O Tatu vai analisar',
                textAlign: TextAlign.center,
                style: TatuTexto.tituloGrande,
              ),
              const SizedBox(height: 8),
              Text(
                'Respondemos em até ${RegrasRetorno.mediacaoDiasUteis} dias '
                'úteis,\npelo chat do Tatu.',
                textAlign: TextAlign.center,
                style: TatuTexto.corpo.copyWith(color: TatuColors.textSecondary),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: TatuColors.surfaceGrouped,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                ),
                child: Column(
                  children: [
                    _ItemAnalise(
                      TablerIcons.message_circle,
                      'A conversa com ${r.oProfissional}',
                    ),
                    const Divider(height: 1, indent: 36),
                    const _ItemAnalise(
                      TablerIcons.photo,
                      'As fotos do serviço e do problema',
                    ),
                    const Divider(height: 1, indent: 36),
                    const _ItemAnalise(
                      TablerIcons.star,
                      'O histórico de vocês dois',
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemAnalise extends StatelessWidget {
  const _ItemAnalise(this.icone, this.texto);

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TatuMedidas.alturaLinha,
    child: Row(
      children: [
        Icon(icone, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}
