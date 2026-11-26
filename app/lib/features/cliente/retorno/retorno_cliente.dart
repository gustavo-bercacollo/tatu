import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conta.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../data/plano_fixo.dart' show diaMes, diaLongo;
import '../../../data/retorno.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/campo_texto_longo.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/horarios_retorno.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../../shared/widgets/retorno.dart';
import '../../entrada/camera_prova_page.dart';
import '../atividade/contestar_page.dart';
import '../chamar/procurando_page.dart';
import '../mensagens/chat_page.dart';
import '../../../shared/widgets/icone_profissao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../data/profissional.dart' show profissaoNoGenero;

/// Protótipo: o profissional aceita o retorno sozinho depois disso (nulo
/// nos testes, que controlam cada resposta).
Duration? simularAceiteRetorno = const Duration(seconds: 4);

/// Protótipo: depois do aceite, o profissional sai para o retorno (RN-207:
/// o card da Atividade muda para "a caminho").
Duration simularSaidaRetorno = const Duration(seconds: 20);

/// RN-45/RN-184: o cliente pede o retorno de [p]. Nas primeiras 24 horas
/// o valor continua retido (RN-46). Devolve nulo se já houver um pedido.
PedidoRetorno? pedirRetornoCliente(
  PedidoConcluido p, {
  required String descricao,
  required List<FotoProva> fotos,
  String? motivo,
  List<OpcaoHorario> horarios = const [],
  bool urgente = false,
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
      horarios: horarios,
      urgente: urgente,
    ),
  );
  // Protótipo: a profissional aceita o 1º horário que ainda dá (1 hora
  // depois do começo do período) ou, sem horários, a próxima sexta 14h.
  final espera = simularAceiteRetorno;
  if (r != null && espera != null) {
    Timer(espera, () {
      final agora = clock.now();
      final opcao = r.horarios.where((o) => !o.passou(agora)).firstOrNull;
      retornos.aceitar(
        r,
        opcao == null
            ? _proximaSexta(agora)
            : opcao.as(opcao.periodo.inicio + 1),
      );
      Timer(simularSaidaRetorno, () => retornos.saiuParaRetorno(r));
    });
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
  SituacaoRetorno.outroProblema =>
    'É outro problema, segundo ${r.oProfissional}',
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

  /// RN-213: passo 2 de 2: até 3 horários; aí o pedido sai.
  Future<void> _continuar() async {
    final p = widget.pedido;
    final e = await Navigator.of(context).push<(List<OpcaoHorario>, bool)>(
      MaterialPageRoute(
        builder: (_) => EscolherHorariosRetornoPage(
          nome: p.primeiroNome,
          feminino: p.feminino,
          contador: '2 de 2',
        ),
      ),
    );
    if (e == null || !mounted) return;
    final r = pedirRetornoCliente(
      p,
      descricao: _texto.text.trim(),
      fotos: _fotos,
      horarios: e.$1,
      urgente: e.$2,
    );
    if (r == null) return;
    abrirChatDoRetorno(context, p, substituir: true);
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
      contador: '1 de 2',
      botao: 'Continuar',
      onBotao: _texto.text.trim().isEmpty ? null : _continuar,
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
    case SituacaoRetorno.aceito when r.sugerido != null:
      // C241 · RN-213: a profissional sugeriu outro horário.
      linha = SituacaoCartaoRetorno(
        TablerIcons.check,
        'Aceito · falta combinar o horário',
        TatuColors.onlineTexto,
      );
      depois.add(
        CartaoHorarioSugerido(
          retorno: r,
          onConfirmar: () => retornos.confirmarSugerido(r),
          onEscolherOutro: () => escolherOutrosHorarios(context, r),
        ),
      );
    case SituacaoRetorno.aceito when r.marcadoPara == null:
      linha = SituacaoCartaoRetorno(
        TablerIcons.check,
        'Aceito · falta combinar o horário',
        TatuColors.onlineTexto,
      );
    // RN-231: sem bloco verde solto; o card diz o que falta.
    case SituacaoRetorno.aceito:
      // RN-231: data, código e "Sem custo" ficam no próprio card.
      // RN-214: a profissional pediu para remarcar; você escolhe a hora.
      final rem = r.remarcacao;
      if (rem != null) {
        depois.add(
          rem.doCliente
              ? CartaoSituacaoRetorno(
                  aviso: true,
                  titulo: 'Remarcação pedida',
                  nota:
                      '${textoOpcao(rem.opcao, clock.now())}. '
                      '${_maiuscula(r.oProfissional)} escolhe a hora e '
                      'confirma.',
                )
              : CartaoConfirmarRemarcar(
                  titulo: '${_maiuscula(r.oProfissional)} pediu para remarcar',
                  remarcacao: rem,
                  onConfirmar: (h) => retornos.confirmarRemarcar(r, h),
                ),
        );
      }
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
          titulo:
              '${r.oProfissional[0].toUpperCase()}'
              '${r.oProfissional.substring(1)} fez o retorno',
          texto: 'O problema foi resolvido?',
          botao: 'Sim, resolveu',
          onBotao: () => retornos.resolveu(r, true),
          segundo: 'Não, continua o problema',
          onSegundo: () =>
              pedirAjudaAoTatu(context, r, MotivoMediacao.continuouProblema),
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
      linha = SituacaoCartaoRetorno(TablerIcons.x, switch (r.falha) {
        FalhaProfissional.naoMarcou =>
          '$nome não marcou o retorno em ${RegrasRetorno.marcarEm.inDays} dias',
        FalhaProfissional.naoVeio => '$nome não veio no retorno',
        _ =>
          '$nome não respondeu em '
              '${RegrasRetorno.respostaProfissional.inHours} horas',
      }, TatuColors.danger);
      final servico = r.servicoNome.toLowerCase();
      depois.add(
        r.resolucao == ResolucaoAutomatica.devolucao
            ? CartaoTatuRetorno(
                verde: true,
                titulo: 'Devolvemos ${reais(r.valorServico)}',
                texto:
                    'No ${r.pagamento}, em até 7 dias.\n'
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
    // C250/C252 · RN-231: um card só, que muda de estado.
    CartaoRetornoChat(
      retorno: r,
      linha: linha,
      onRemarcar: retornos.podeRemarcar(r, cliente: true)
          ? () => remarcarRetorno(context, r, cliente: true)
          : null,
    ),
    for (final w in depois) ...[const SizedBox(height: 18), w],
  ];
}

String _maiuscula(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _minuscula(String s) =>
    s.isEmpty ? s : '${s[0].toLowerCase()}${s.substring(1)}';

/// C239 · RN-213: "Quando você pode receber a [nome]?": até 3 horários
/// nos próximos 7 dias (manhã, tarde, noite) e "É urgente?". Devolve os
/// horários e se é urgente.
class EscolherHorariosRetornoPage extends StatefulWidget {
  const EscolherHorariosRetornoPage({
    super.key,
    required this.nome,
    required this.feminino,
    this.contador,
    this.botao = 'Pedir retorno',
    this.iniciais = const [],
    this.urgente = false,
  });

  final String nome;
  final bool feminino;

  /// "2 de 2" no pedido; nulo ao escolher de novo.
  final String? contador;
  final String botao;
  final List<OpcaoHorario> iniciais;
  final bool urgente;

  @override
  State<EscolherHorariosRetornoPage> createState() =>
      _EscolherHorariosRetornoPageState();
}

class _EscolherHorariosRetornoPageState
    extends State<EscolherHorariosRetornoPage> {
  late final _agora = clock.now();
  late var _escolhidos = [
    for (final o in widget.iniciais)
      if (!o.passou(_agora)) o,
  ];
  late var _urgente = widget.urgente;

  @override
  Widget build(BuildContext context) {
    final n = _escolhidos.length;
    final resumo = n == 0
        ? 'Escolha até ${RegrasRetorno.maxHorarios} horários'
        : '$n de ${RegrasRetorno.maxHorarios} · '
              '${_escolhidos.map((o) => textoOpcao(o, _agora)).join(' · ')}';
    return CadastroScaffold(
      contador: widget.contador,
      titulo:
          'Quando você pode receber ${widget.feminino ? 'a' : 'o'} '
          '${widget.nome}?',
      subtitulo:
          'Escolha até ${RegrasRetorno.maxHorarios} horários nos próximos '
          '7 dias.',
      botao: widget.botao,
      onBotao: n == 0
          ? null
          : () => Navigator.of(context).pop((_escolhidos, _urgente)),
      acimaBotao: Text(
        resumo,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      children: [
        // RN-213/RN-215: pedido urgente aparece em destaque para ela.
        _ChaveUrgente(
          valor: _urgente,
          onMudar: (v) => setState(() => _urgente = v),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        GradeHorarios(
          agora: _agora,
          escolhidos: _escolhidos,
          onMudar: (l) => setState(() => _escolhidos = l),
        ),
      ],
    );
  }
}

/// C239 · RN-213/RN-215: caixa cinza com raio laranja, "É urgente?",
/// "Pedir para hoje, se der" e o interruptor.
class _ChaveUrgente extends StatelessWidget {
  const _ChaveUrgente({required this.valor, required this.onMudar});

  final bool valor;
  final ValueChanged<bool> onMudar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'É urgente? Pedir para hoje, se der',
      toggled: valor,
      child: ExcludeSemantics(
        child: Material(
          color: TatuColors.surfaceGrouped,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
          child: InkWell(
            borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
            onTap: () => onMudar(!valor),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    TablerIcons.bolt,
                    size: 20,
                    color: TatuColors.warningTexto,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'É urgente?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pedir para hoje, se der',
                          style: TatuTexto.legenda,
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: valor,
                    activeTrackColor: TatuColors.online,
                    inactiveTrackColor: TatuColors.trilho,
                    onChanged: onMudar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// C241 · RN-213: "Escolher outro" volta para a grade; os novos horários
/// vão para a profissional.
Future<void> escolherOutrosHorarios(
  BuildContext context,
  PedidoRetorno r,
) async {
  final e = await Navigator.of(context).push<(List<OpcaoHorario>, bool)>(
    MaterialPageRoute(
      builder: (_) => EscolherHorariosRetornoPage(
        nome: r.primeiroProfissional,
        feminino: r.profissionalFeminino,
        botao: 'Enviar horários',
        urgente: r.urgente,
      ),
    ),
  );
  if (e == null) return;
  retornos.novosHorarios(r, e.$1, urgente: e.$2);
}

/// C241 · RN-213: card "[nome] sugeriu outro horário" no chat.
class CartaoHorarioSugerido extends StatelessWidget {
  const CartaoHorarioSugerido({
    super.key,
    required this.retorno,
    required this.onConfirmar,
    required this.onEscolherOutro,
  });

  final PedidoRetorno retorno;
  final VoidCallback onConfirmar;
  final VoidCallback onEscolherOutro;

  @override
  Widget build(BuildContext context) {
    final r = retorno;
    final seus = r.horarios.map(textoOpcaoCurto).join(', ');
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: 0.91,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          border: Border.all(color: TatuColors.action, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${r.primeiroProfissional} sugeriu outro horário',
              style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(TablerIcons.calendar, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quandoRetorno(r.sugerido!),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (seus.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Seus horários ($seus) não serviam para '
                '${r.profissionalFeminino ? 'ela' : 'ele'}.',
                style: TatuTexto.legenda,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onConfirmar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  TatuMedidas.alturaBotaoCartao,
                ),
              ),
              child: const Text('Confirmar horário'),
            ),
            const SizedBox(height: 8),
            Center(child: LinkAzul('Escolher outro', onTap: onEscolherOutro)),
          ],
        ),
      ),
    );
  }
}

/// RN-214: o outro lado pediu para remarcar: escolha a hora e confirme.
class CartaoConfirmarRemarcar extends StatefulWidget {
  const CartaoConfirmarRemarcar({
    super.key,
    required this.titulo,
    required this.remarcacao,
    required this.onConfirmar,
  });

  final String titulo;
  final Remarcacao remarcacao;
  final ValueChanged<int> onConfirmar;

  @override
  State<CartaoConfirmarRemarcar> createState() =>
      _CartaoConfirmarRemarcarState();
}

class _CartaoConfirmarRemarcarState extends State<CartaoConfirmarRemarcar> {
  int? _hora;

  @override
  Widget build(BuildContext context) {
    final rem = widget.remarcacao;
    final h = _hora;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: 0.91,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          border: Border.all(color: TatuColors.action, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.titulo,
              style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              textoOpcao(rem.opcao, clock.now()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            const Text('Que horas?', style: TatuTexto.nota),
            const SizedBox(height: 8),
            SeletorHora(
              horas: rem.periodo.horas,
              selecionada: h,
              onEscolher: (v) => setState(() => _hora = v),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: h == null ? null : () => widget.onConfirmar(h),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  TatuMedidas.alturaBotaoCartao,
                ),
              ),
              child: Text(
                h == null
                    ? 'Confirmar'
                    : 'Confirmar · ${quandoCurto(rem.opcao.as(h))}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// C244 · RN-214: "Remarcar retorno" (uma vez, até 12 horas antes):
/// quem pede escolhe o dia e o período; o outro escolhe a hora.
Future<void> remarcarRetorno(
  BuildContext context,
  PedidoRetorno r, {
  required bool cliente,
}) async {
  final e = await mostrarFolha<(DateTime, PeriodoDia)>(
    context,
    builder: (_) => _FolhaRemarcar(retorno: r, cliente: cliente),
  );
  if (e == null) return;
  final ok = retornos.pedirRemarcar(
    r,
    cliente: cliente,
    dia: e.$1,
    periodo: e.$2,
  );
  // Protótipo: a outra pessoa escolhe a hora (1 hora depois do começo).
  final espera = simularAceiteRetorno;
  if (ok && espera != null) {
    Timer(espera, () => retornos.confirmarRemarcar(r, e.$2.inicio + 1));
  }
}

class _FolhaRemarcar extends StatefulWidget {
  const _FolhaRemarcar({required this.retorno, required this.cliente});

  final PedidoRetorno retorno;
  final bool cliente;

  @override
  State<_FolhaRemarcar> createState() => _FolhaRemarcarState();
}

class _FolhaRemarcarState extends State<_FolhaRemarcar> {
  late final _agora = clock.now();
  DateTime? _dia;
  PeriodoDia? _periodo;

  @override
  Widget build(BuildContext context) {
    final r = widget.retorno;
    final ate = r.marcarAte;
    final dias = [
      for (var i = 1; i <= RegrasRetorno.marcarEm.inDays; i++)
        DateTime(_agora.year, _agora.month, _agora.day + i),
    ].where((d) => !d.isAfter(ate)).toList();
    final outro = widget.cliente ? r.oProfissional : r.oCliente;
    final pronto =
        _dia != null &&
        _periodo != null &&
        !OpcaoHorario(_dia!, _periodo!).passou(_agora);
    final limite = '${diaLongo(ate.weekday)}, ${diaMes(ate)}';
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('Remarcar retorno', style: TatuTexto.tituloFolha),
            const SizedBox(height: 6),
            Text(
              'Marcado: ${_minuscula(quandoRetorno(r.marcadoPara!))}',
              style: TatuTexto.detalhe,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            CaixaAviso(
              'Dá para remarcar uma vez, até '
              '${RegrasRetorno.antecedenciaRemarcar.inHours} horas antes. '
              'Novo dia até $limite.',
              icone: TablerIcons.info_circle,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            SeletorDiasRetorno(
              dias: dias,
              selecionado: _dia,
              onEscolher: (d) => setState(() => _dia = d),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            SeletorPeriodo(
              selecionado: _periodo,
              onEscolher: (p) => setState(() => _periodo = p),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: pronto
                  ? () => Navigator.of(context).pop((_dia!, _periodo!))
                  : null,
              child: const Text('Pedir para remarcar'),
            ),
            const SizedBox(height: 10),
            Text(
              '${_maiuscula(outro)} escolhe a hora e confirma.',
              textAlign: TextAlign.center,
              style: TatuTexto.nota,
            ),
          ],
        ),
      ),
    );
  }
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
  await Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => AnaliseTatuPage(pedido: r)));
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
                style: TatuTexto.corpo.copyWith(
                  color: TatuColors.textSecondary,
                ),
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

/// C250/C252 · RN-231: o pedido de retorno no chat do cliente, num card
/// só que muda de estado. Topo: ícone do serviço, "Pedido de retorno",
/// profissão e data do serviço e a pílula de status. Meio: a descrição
/// entre aspas e as fotos. Embaixo: o que vale agora. Contorno preto
/// enquanto aguarda; cinza depois.
class CartaoRetornoChat extends StatelessWidget {
  const CartaoRetornoChat({
    super.key,
    required this.retorno,
    this.linha,
    this.onRemarcar,
  });

  final PedidoRetorno retorno;

  /// Linha dos outros estados (recusado, outro problema, mediação…).
  final SituacaoCartaoRetorno? linha;
  final VoidCallback? onRemarcar;

  /// (texto, cor do texto, fundo) da pílula.
  (String, Color, Color) get _pilula => switch (retorno.situacao) {
    SituacaoRetorno.aguardando => (
      'Aguardando',
      TatuColors.warningTexto,
      TatuColors.warningSoft,
    ),
    SituacaoRetorno.aceito => (
      'Aceito',
      TatuColors.onlineTexto,
      TatuColors.onlineSoft,
    ),
    SituacaoRetorno.feito => (
      'Feito',
      TatuColors.onlineTexto,
      TatuColors.onlineSoft,
    ),
    SituacaoRetorno.recusado => (
      'Recusado',
      TatuColors.textSecondary,
      TatuColors.fill,
    ),
    SituacaoRetorno.resolvidoAutomatico
        when retorno.falha == FalhaProfissional.naoRespondeu =>
      ('Sem resposta', TatuColors.textSecondary, TatuColors.fill),
    SituacaoRetorno.emMediacao => (
      'Em análise',
      TatuColors.textSecondary,
      TatuColors.fill,
    ),
    SituacaoRetorno.outroProblema => (
      'Outro problema',
      TatuColors.textSecondary,
      TatuColors.fill,
    ),
    _ => ('Encerrado', TatuColors.textSecondary, TatuColors.fill),
  };

  @override
  Widget build(BuildContext context) {
    final r = retorno;
    final (txt, cor, fundo) = _pilula;
    final aguardando = r.situacao == SituacaoRetorno.aguardando;
    final marcado = r.situacao == SituacaoRetorno.aceito ? r.marcadoPara : null;
    final cinza = const TextStyle(
      fontSize: 13,
      color: TatuColors.textSecondary,
    );
    final embaixo = <Widget>[
      if (aguardando) ...[
        Text(
          '${_maiuscula(r.oProfissional)} responde até '
          '${diaHora(r.respondaAte)}',
          style: cinza,
        ),
        if (r.horarios.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Você pode: ${r.horarios.map(textoOpcaoCurto).join(' · ')}',
            style: cinza,
          ),
        ],
      ] else if (marcado != null) ...[
        Text(
          quandoRetorno(marcado),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: cinza,
            children: [
              const TextSpan(text: 'Código '),
              TextSpan(
                text: r.codigo,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TatuColors.textPrimary,
                ),
              ),
              const TextSpan(text: ' · passe na hora'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SeloVerde('Sem custo', pequeno: true),
            const Spacer(),
            if (onRemarcar != null)
              GestureDetector(
                onTap: onRemarcar,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Remarcar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.verified,
                  ),
                ),
              ),
          ],
        ),
      ] else if (r.semHorario) ...[
        Text(
          r.sugerido != null
              ? 'Aceito · falta combinar o horário'
              : r.horarios.isEmpty
              ? '${_maiuscula(r.oProfissional)} vai marcar o dia até '
                    '${diaMes(r.marcarAte)}.'
              : '${_maiuscula(r.oProfissional)} vai escolher um dos seus '
                    'horários.',
          style: cinza,
        ),
      ] else if (linha case final l?)
        Text(l.texto, style: cinza),
    ];
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.91,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: TatuColors.bg,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: Border.all(
              color: aguardando ? TatuColors.action : TatuColors.chevron,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconeProfissaoCirculo(r.servicoNome),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pedido de retorno',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${profissaoNoGenero(r.servicoNome, feminino: r.profissionalFeminino)}'
                          ' · serviço de ${r.diaServico}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TatuTexto.legenda,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: ShapeDecoration(
                      color: fundo,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      txt,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('“${r.descricao}”', style: const TextStyle(fontSize: 14)),
              if (r.fotos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final f in r.fotos)
                      MiniaturaProva(foto: f, pequena: true),
                  ],
                ),
              ],
              if (embaixo.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: TatuColors.trilho),
                const SizedBox(height: 12),
                ...embaixo,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
