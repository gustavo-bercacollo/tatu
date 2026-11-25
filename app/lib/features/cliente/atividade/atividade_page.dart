import '../plano_fixo/plano_fixo.dart' show PlanoFixoPage;
import '../../../shared/widgets/selo_plano_fixo.dart';
import '../../../data/plano_fixo.dart';
import '../../../data/retorno.dart';
import '../../../data/conta.dart';
import '../../../data/conversas.dart';
import '../mensagens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../data/servicos.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../abas.dart';
import '../chamar/procurando_page.dart';
import 'pedido_andamento_page.dart';
import 'avaliar_page.dart';
import 'pedido_concluido_page.dart';
import 'pedir_de_novo_sheet.dart';
import 'recibo_page.dart';

/// Volta para a Home ("Pedir um serviço", "Pedir de novo").
void voltarParaHome(BuildContext context) =>
    irParaAba(context, AbaCliente.inicio);

/// Aba Atividade: pedidos em andamento e concluídos.
class AtividadePage extends StatefulWidget {
  const AtividadePage({super.key, this.aba = 0});

  /// 0 = Em andamento, 1 = Concluídos.
  final int aba;

  @override
  State<AtividadePage> createState() => _AtividadePageState();
}

class _AtividadePageState extends State<AtividadePage> {
  late int _aba = widget.aba;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      bottomNavigationBar: const AbasDoCliente(ativa: AbaCliente.atividade),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.entreSecoes + 8,
                TatuMedidas.margem,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Atividade', style: TatuTexto.tituloGrande),
                  const SizedBox(height: TatuMedidas.entreItens),
                  Segmento(
                    opcoes: const ['Em andamento', 'Concluídos'],
                    selecionada: _aba,
                    onMudar: (i) => setState(() => _aba = i),
                  ),
                  Expanded(
                    child: _aba == 0
                        ? const _EmAndamento()
                        : const _Concluidos(),
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

class _EmAndamento extends StatelessWidget {
  const _EmAndamento();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([pedidos, retornos, planosFixos]),
    builder: (context, _) => _lista(context),
  );

  /// RN-201/RN-203: visitas do plano marcadas para hoje.
  List<(PlanoFixo, VisitaPlano)> get _visitasHoje => [
    for (final p in planosFixos.planos)
      if (p.cliente == conta.nomeCompleto)
        if (p.visitaDeHoje() case final v?) (p, v),
  ];

  /// RN-187: retornos aceitos do cliente (card "Retorno · sem custo").
  List<PedidoRetorno> get _retornos => [
    for (final r in retornos.retornos)
      if (r.cliente == conta.nomeCompleto &&
          r.situacao == SituacaoRetorno.aceito)
        r,
  ];

  Widget _lista(BuildContext context) {
    final retornosMarcados = _retornos;
    final visitas = _visitasHoje;
    if (pedidos.semNadaEmAndamento &&
        retornosMarcados.isEmpty &&
        visitas.isEmpty) {
      return EstadoVazio(
        icone: TablerIcons.clock,
        titulo: 'Nenhum pedido agora',
        texto: 'Quando você pedir um serviço,\nele aparece aqui.',
        acao: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, TatuMedidas.alturaBusca),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          onPressed: () => voltarParaHome(context),
          child: const Text('Pedir um serviço'),
        ),
      );
    }
    // RN-90: todos os pedidos em andamento e todas as buscas.
    final lista = pedidos.andamentos;
    final buscas = pedidos.buscas;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: TatuMedidas.entreSecoes),
      children: [
        // C222/C223 · RN-206: visita do plano, no mesmo formato dos outros
        // cards (sem valor).
        for (final (p, v) in visitas) ...[
          _CartaoVisitaPlano(plano: p, visita: v),
          const SizedBox(height: TatuMedidas.entreItens),
        ],
        for (final (i, p) in lista.indexed) ...[
          if (i > 0) const SizedBox(height: TatuMedidas.entreItens),
          _CartaoAndamento(pedido: p),
        ],
        for (final (i, b) in buscas.indexed) ...[
          if (lista.isNotEmpty || i > 0)
            SizedBox(
              height: i == 0
                  ? TatuMedidas.entreSecoes - 4
                  : TatuMedidas.entreItens,
            ),
          lista.isEmpty ? _NinguemAceitou(busca: b) : _BuscaCompacta(busca: b),
        ],
        for (final r in retornosMarcados) ...[
          const SizedBox(height: TatuMedidas.entreItens),
          // C234/C235 · RN-207: mesmo formato dos outros cards.
          _CartaoRetornoCliente(
            retorno: r,
            onTap: () {
              final c = conversas.conversas
                  .where((c) => c.nome == r.profissional)
                  .firstOrNull;
              if (c == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatPage(conversa: c)),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Cartão branco padrão desta aba.
class _Cartao extends StatelessWidget {
  const _Cartao({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}

/// C222/C223 · RN-206: card da visita do plano. Agendada: pílula clara
/// "Hoje, 9h" e a barra do mês. A caminho em diante: pílula escura com o
/// tempo e as etapas Agendada → A caminho → Serviço → Feita. A parte de
/// baixo tem a mesma altura nos dois estados.
class _CartaoVisitaPlano extends StatelessWidget {
  const _CartaoVisitaPlano({required this.plano, required this.visita});

  final PlanoFixo plano;
  final VisitaPlano visita;

  @override
  Widget build(BuildContext context) {
    final p = plano;
    final v = visita;
    final agendada = v.situacao == SituacaoVisita.agendada;
    final feitas = switch (v.situacao) {
      SituacaoVisita.aCaminho => 2,
      SituacaoVisita.emServico => 3,
      SituacaoVisita.feita => 4,
      _ => 1,
    };
    return _Cartao(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: p)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FotoComSeloPlano(nome: p.profissional),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.profissional,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      agendada
                          ? '${p.profissao} · Plano fixo'
                          : '${p.profissao} · visita ${p.numeroDa(v)} de '
                                '${p.visitas.length}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (agendada)
                SeloPreto('Hoje, ${horaCurta(p.horario)}', claro: true)
              else
                SeloPreto(
                  v.situacao == SituacaoVisita.aCaminho
                      ? '${v.minutosParaChegar} min'
                      : 'Trabalhando',
                ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes - 4),
          SizedBox(
            height: TatuMedidas.progressoCartao,
            child: agendada
                ? BarraVisitasDoMes(plano: p, hoje: v)
                : LinhaDoTempoHorizontal(
                    etapas: etapasVisitaPlano,
                    feitas: feitas,
                  ),
          ),
        ],
      ),
    );
  }
}

/// C234/C235 · RN-207: card do retorno (cliente). Agendado: selo verde
/// "Retorno · sem custo", data e hora completas e a dica do código. A
/// caminho em diante: pílula escura com o tempo e as etapas Agendado → A
/// caminho → Retorno → Feito. A parte de baixo tem a mesma altura.
class _CartaoRetornoCliente extends StatelessWidget {
  const _CartaoRetornoCliente({required this.retorno, required this.onTap});

  final PedidoRetorno retorno;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = retorno;
    final caminho = r.aCaminho;
    final m = r.marcadoPara;
    const verde = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: TatuColors.onlineTexto,
    );
    return _Cartao(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarIniciais(nome: r.profissional, tamanho: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.profissional,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (caminho)
                      // Uma linha só (o card tem a mesma altura sempre).
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            style: TatuTexto.nota,
                            children: [
                              TextSpan(text: '${r.servicoNome} · '),
                              const TextSpan(
                                text: 'Retorno · sem custo',
                                style: verde,
                              ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      )
                    else
                      Text(
                        '${r.servicoNome} · ${r.descricaoServico}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TatuTexto.nota,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (caminho)
                SeloPreto('${r.minutosParaChegar} min')
              else
                const SeloVerde('Retorno · sem custo', pequeno: true),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          SizedBox(
            height: TatuMedidas.progressoRetorno,
            child: caminho
                ? Center(
                    child: LinhaDoTempoHorizontal(
                      etapas: etapasRetorno,
                      feitas: 2,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Row(
                        children: [
                          const Icon(TablerIcons.calendar, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m == null ? 'Dia a combinar' : quandoRetorno(m),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Na hora, passe o código para '
                        '${r.profissionalFeminino ? 'a' : 'o'} '
                        '${r.primeiroProfissional}.',
                        style: TatuTexto.nota,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CartaoAndamento extends StatelessWidget {
  const _CartaoAndamento({required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) {
    return _Cartao(
      onTap: () {
        pedidos.abrir(pedido);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PedidoAndamentoPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarIniciais(nome: pedido.profissional, tamanho: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.profissional,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // RN-203: com plano fixo, o serviço do chat é avulso.
                      planosFixos.ultimoCom(profissional: pedido.profissional)
                                  ?.selo() ==
                              null
                          ? '${pedido.servico} · ${pedido.descricao}'
                          : '${pedido.servico} · avulso · ${pedido.descricao}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SeloPreto(pedido.distancia ? 'À distância' : pedido.chegaEm),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          LinhaDoTempoHorizontal(
            etapas: pedido.etapasCurtasDoPedido,
            feitas: pedido.etapasFeitas,
          ),
          // RN-45: contestação enviada: o problema está em análise.
          if (pedido.emAnalise) ...[
            const SizedBox(height: TatuMedidas.entreItens + 4),
            const Row(
              children: [
                Icon(
                  TablerIcons.clock,
                  size: 18,
                  color: TatuColors.warningTexto,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Analisando o problema',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.warningTexto,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // RN-172: a conclusão espera o cliente; o toque abre a tela.
          if (pedido.aguardandoConfirmacao) ...[
            const SizedBox(height: TatuMedidas.entreItens + 4),
            const Row(
              children: [
                Icon(
                  TablerIcons.circle_check,
                  size: 18,
                  color: TatuColors.onlineTexto,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Aguardando sua confirmação',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.onlineTexto,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BuscaCompacta extends StatelessWidget {
  const _BuscaCompacta({required this.busca});

  final BuscaSegundoPlano busca;

  @override
  Widget build(BuildContext context) {
    return _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconeCirculo(iconeServico(busca.servico)),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      busca.servico,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      busca.descricao.isEmpty
                          ? busca.endereco
                          : busca.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const SeloVerde('Buscando', aviso: true, pequeno: true),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          Row(
            children: [
              const Icon(
                TablerIcons.loader_2,
                size: 16,
                color: TatuColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Procurando em segundo plano · ${busca.haQuanto}',
                  style: TatuTexto.nota,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: TatuColors.textSecondary,
                textStyle: TatuTexto.corpo.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => pedidos.cancelarBusca(busca),
              child: const Text('Cancelar pedido'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NinguemAceitou extends StatelessWidget {
  const _NinguemAceitou({required this.busca});

  final BuscaSegundoPlano busca;

  @override
  Widget build(BuildContext context) {
    final pequeno = FilledButton.styleFrom(
      minimumSize: const Size(0, TatuMedidas.alturaChip),
      padding: const EdgeInsets.symmetric(horizontal: 24),
    );
    return _Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CirculoRelogio(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ninguém aceitou ainda',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${busca.servico} · ${busca.endereco}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          const Divider(height: 0.5),
          const SizedBox(height: TatuMedidas.entreItens),
          const Text(
            'Continuamos buscando em segundo plano.\nAvisamos assim que alguém aceitar.',
            style: TatuTexto.corpo,
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton(
                style: pequeno,
                // A busca volta para a tela (e, se sair, para cá de novo).
                onPressed: () {
                  pedidos.cancelarBusca(busca);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProcurandoPage(
                        servico: busca.servico,
                        endereco: busca.endereco,
                      ),
                    ),
                  );
                },
                child: const Text('Tentar de novo'),
              ),
              FilledButton(
                style: tatuBotaoSecundario()
                    .merge(pequeno)
                    .copyWith(
                      foregroundColor: const WidgetStatePropertyAll(
                        TatuColors.danger,
                      ),
                    ),
                onPressed: () => pedidos.cancelarBusca(busca),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CirculoRelogio extends StatelessWidget {
  const _CirculoRelogio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: TatuColors.warningSoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(TablerIcons.clock, size: 22, color: TatuColors.warning),
    );
  }
}

class _Concluidos extends StatelessWidget {
  const _Concluidos();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([pedidos, planosFixos]),
    builder: (context, _) => _lista(context),
  );

  Widget _lista(BuildContext context) {
    final lista = pedidos.concluidos;
    // RN-201/RN-203: cobranças do plano fixo ("Plano fixo · N visitas").
    final cobrancas = [
      for (final p in planosFixos.planos)
        if (p.cliente == conta.nomeCompleto)
          for (final c in p.cobrancas.reversed) (p, c),
    ];
    if (lista.isEmpty && cobrancas.isEmpty) {
      return const EstadoVazio(
        icone: TablerIcons.clock,
        titulo: 'Nada por aqui ainda',
        texto: 'Seus pedidos concluídos\nficam guardados aqui.',
      );
    }
    final itens = <Widget>[];
    String? mes;
    if (cobrancas.isNotEmpty) {
      mes = lista.firstOrNull?.mes ?? 'Este mês';
      itens.add(
        Padding(
          padding: const EdgeInsets.only(
            top: TatuMedidas.entreSecoes,
            bottom: TatuMedidas.entreItens,
          ),
          child: Text(mes, style: TatuTexto.grupo),
        ),
      );
      for (final (i, (p, c)) in cobrancas.indexed) {
        if (i > 0) itens.add(const SizedBox(height: TatuMedidas.entreItens + 4));
        itens.add(
          CartaoPlanoFixo(
            nome: p.profissional,
            detalhe: p.profissao,
            selo: SeloPlanoFixo(
              'Plano fixo · ${c.visitasFeitas} '
              '${c.visitasFeitas == 1 ? 'visita' : 'visitas'}',
            ),
            valor: c.total,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PlanoFixoPage(plano: p)),
            ),
          ),
        );
      }
      if (lista.isNotEmpty) {
        itens.add(const SizedBox(height: TatuMedidas.entreItens + 4));
      }
    }
    for (final p in lista) {
      if (p.mes != mes) {
        mes = p.mes;
        itens.add(
          Padding(
            padding: const EdgeInsets.only(
              top: TatuMedidas.entreSecoes,
              bottom: TatuMedidas.entreItens,
            ),
            child: Text(p.mes, style: TatuTexto.grupo),
          ),
        );
      } else {
        itens.add(const SizedBox(height: TatuMedidas.entreItens + 4));
      }
      itens.add(_CartaoConcluido(pedido: p));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
      children: itens,
    );
  }
}

class _CartaoConcluido extends StatelessWidget {
  const _CartaoConcluido({required this.pedido});

  final PedidoConcluido pedido;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    void abrir(Widget tela) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
    final nota = p.avaliacao;
    return _Cartao(
      onTap: p.cancelado ? null : () => abrir(PedidoConcluidoPage(pedido: p)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarIniciais(nome: p.profissional, tamanho: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.profissional,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // RN-203: com plano fixo, o serviço do chat é avulso.
                      planosFixos.ultimoCom(profissional: p.profissional) ==
                              null
                          ? '${p.profissao} · ${p.dia}'
                          : '${p.profissao} · avulso · ${p.dia}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.cancelado ? '—' : p.valor,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (p.cancelado)
                    const Text('Cancelado', style: TatuTexto.detalhe)
                  else
                    const _Pago(),
                ],
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          const Divider(height: 0.5),
          const SizedBox(height: TatuMedidas.entreItens),
          Row(
            children: [
              // Uma linha só; em telas estreitas os botões encolhem um pouco.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    spacing: 8,
                    children: [
                      TatuChip(
                        label: 'Pedir de novo',
                        iconeFixo: TablerIcons.refresh,
                        selecionado: true,
                        pequeno: true,
                        onTap: () => abrirPedirDeNovo(context, p),
                      ),
                      if (!p.cancelado)
                        TatuChip(
                          label: 'Recibo',
                          iconeFixo: TablerIcons.receipt,
                          pequeno: true,
                          onTap: () => abrir(ReciboPage(pedido: p)),
                        ),
                      if (!p.cancelado && nota == null)
                        TatuChip(
                          label: 'Avaliar',
                          iconeFixo: TablerIcons.star,
                          pequeno: true,
                          onTap: () => abrir(AvaliarPage(pedido: p)),
                        ),
                    ],
                  ),
                ),
              ),
              if (!p.cancelado && nota != null) const SizedBox(width: 8),
              if (!p.cancelado && nota != null)
                Semantics(
                  button: true,
                  label: 'Sua avaliação',
                  child: GestureDetector(
                    onTap: () => abrir(SuaAvaliacaoPage(pedido: p)),
                    child: Estrelas(nota: nota),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pago extends StatelessWidget {
  const _Pago();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: TatuColors.online,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'Pago',
          style: TextStyle(fontSize: 15, color: TatuColors.onlineTexto),
        ),
      ],
    );
  }
}
