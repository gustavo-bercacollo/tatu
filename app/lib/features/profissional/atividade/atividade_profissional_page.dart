import '../plano_fixo/plano_fixo_profissional.dart'
    show PlanoFixoProfissionalPage;
import '../../../shared/widgets/selo_plano_fixo.dart';
import '../../../data/plano_fixo.dart';
import '../../../data/profissional.dart';
import '../../../data/retorno.dart';
import '../../../shared/widgets/retorno.dart' show CartaoRetornoAtividade;
import '../retorno/retorno_profissional.dart' show abrirChatRetornoProfissional;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ganhos.dart';
import '../servico/andamento_page.dart';
import '../chamado/chat_profissional_page.dart';
import '../../../data/servico_profissional.dart';
import '../../../data/atendimento_profissional.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/abas_deslizantes.dart';
import '../abas.dart';

/// P29 · Atividade do profissional: os serviços (em andamento e
/// concluídos). Os ganhos ficam na aba Ganhos.
class AtividadeProfissionalPage extends StatefulWidget {
  const AtividadeProfissionalPage({super.key, this.aba = 0});

  /// 0 = Em andamento (padrão: os serviços ativos primeiro), 1 = Concluídos.
  final int aba;

  @override
  State<AtividadeProfissionalPage> createState() =>
      _AtividadeProfissionalPageState();
}

class _AtividadeProfissionalPageState extends State<AtividadeProfissionalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      bottomNavigationBar: const AbasDoProfissional(
        ativa: AbaCliente.atividade,
      ),
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
                  // Troca tocando na aba ou deslizando para os lados.
                  Expanded(
                    child: AbasDeslizantes(
                      opcoes: const ['Em andamento', 'Concluídos'],
                      inicial: widget.aba,
                      paginas: [
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            atendimentoProfissional,
                            retornos,
                            planosFixos,
                          ]),
                          builder: (_, _) =>
                              atendimentoProfissional.ativo ||
                                  _retornosMarcados.isNotEmpty ||
                                  _planos.isNotEmpty
                              ? ListView(
                                  padding: const EdgeInsets.only(top: 16),
                                  children: [
                                    if (atendimentoProfissional.ativo)
                                      // Sem const: refaz a cada etapa.
                                      // ignore: prefer_const_constructors
                                      _CartaoAtendimento(),
                                    // RN-201/RN-203: visita do plano de
                                    // hoje, sem valor.
                                    for (final p in _planos)
                                      if (p.visitaDeHoje() case final v?) ...[
                                        const SizedBox(
                                          height: TatuMedidas.entreItens,
                                        ),
                                        CartaoPlanoFixo(
                                          nome: '${p.cliente} · ${p.profissao}',
                                          detalhe:
                                              'Hoje às ${horaCurta(p.horario)}',
                                          selo: SeloPlanoFixo.de(
                                            p,
                                            complemento:
                                                'visita ${p.numeroDa(v)} de '
                                                '${p.visitas.length}',
                                          ),
                                          onTap: () => _verPlano(context, p),
                                        ),
                                      ],
                                    // RN-187: retorno aceito, sem custo.
                                    for (final r in _retornosMarcados) ...[
                                      const SizedBox(
                                        height: TatuMedidas.entreItens,
                                      ),
                                      CartaoRetornoAtividade(
                                        retorno: r,
                                        profissional: true,
                                        onTap: () =>
                                            abrirChatRetornoProfissional(
                                              context,
                                              r,
                                            ),
                                      ),
                                    ],
                                    // RN-204: "Próximas visitas do plano".
                                    if (_planos.isNotEmpty) ...[
                                      const SizedBox(
                                        height: TatuMedidas.entreSecoes,
                                      ),
                                      const Text(
                                        'PRÓXIMAS VISITAS DO PLANO',
                                        style: TatuTexto.secao,
                                      ),
                                      for (final p in _planos) ...[
                                        const SizedBox(
                                          height: TatuMedidas.entreItens,
                                        ),
                                        CartaoPlanoFixo(
                                          nome: p.cliente,
                                          detalhe: _detalheProxima(p),
                                          selo: SeloPlanoFixo.de(p),
                                          onTap: () => _verPlano(context, p),
                                        ),
                                      ],
                                    ],
                                  ],
                                )
                              : const EstadoVazio(
                                  icone: TablerIcons.clock,
                                  titulo: 'Nenhum serviço agora',
                                  texto:
                                      'Quando você aceitar um chamado,\n'
                                      'ele aparece aqui.',
                                ),
                        ),
                        const _Concluidos(),
                      ],
                    ),
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

/// RN-201: planos deste profissional que ainda aparecem (com selo).
List<PlanoFixo> get _planos => [
  for (final p in planosFixos.planos)
    if (p.profissional == profissional.nome && p.selo() != null) p,
];

/// "Terça, 2 dez · 9h", "Pausado" ou "Termina em 30 nov".
String _detalheProxima(PlanoFixo p) {
  final v = p.proximaVisita;
  return switch (p.estado()) {
    EstadoPlano.pausado => 'Pausado',
    EstadoPlano.cancelado =>
      'Termina em ${diaMes(p.proximaCobranca ?? DateTime.now())}',
    _ => v == null ? 'Sem visita marcada' : quandoVisita(p, v),
  };
}

void _verPlano(BuildContext context, PlanoFixo p) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (_) => PlanoFixoProfissionalPage(plano: p)));

/// RN-187: retornos aceitos deste profissional.
List<PedidoRetorno> get _retornosMarcados => [
  for (final r in retornos.retornos)
    if (r.profissional == profissional.nome &&
        r.situacao == SituacaoRetorno.aceito)
      r,
];

/// Chamado aceito: cliente, o que é, etapa e linha do tempo. Toque abre
/// a tela da etapa (chat, a caminho ou serviço em andamento).
class _CartaoAtendimento extends StatelessWidget {
  const _CartaoAtendimento();

  void _abrir(BuildContext context) {
    final a = atendimentoProfissional;
    final s = a.servico;
    final Widget tela = switch (a.etapa) {
      EtapaAtendimento.combinando => ChatProfissionalPage(
        chamado: a.chamado ?? chamadoExemplo,
      ),
      EtapaAtendimento.aCaminho => ACaminhoPage(servico: s ?? servicoExemplo),
      EtapaAtendimento.noLocal => ACaminhoPage(
        servico: s ?? servicoExemplo,
        chegou: true,
      ),
      EtapaAtendimento.emServico => EmAndamentoPage(
        servico: s ?? servicoExemplo,
        inicio: a.inicio ?? DateTime.now(),
      ),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final a = atendimentoProfissional;
    final cliente = a.servico?.cliente ?? a.chamado?.cliente ?? '';
    final descricao = a.servico?.descricao ?? a.chamado?.resumo ?? '';
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrir(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarIniciais(nome: cliente, tamanho: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TatuTexto.nota,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SeloPreto(a.etapa.selo),
                ],
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              LinhaDoTempoHorizontal(
                etapas: etapasAtendimento,
                feitas: a.etapa.feitas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Concluidos extends StatelessWidget {
  const _Concluidos();

  @override
  Widget build(BuildContext context) {
    final aguardando = ganhos.aguardando;
    final concluidos = ganhos.concluidos;
    if (aguardando.isEmpty && concluidos.isEmpty) {
      return const EstadoVazio(
        icone: TablerIcons.checks,
        titulo: 'Nenhum serviço ainda',
        texto: 'Os serviços que você fizer\naparecem aqui.',
      );
    }
    return ListView(
      padding: const EdgeInsets.only(
        top: TatuMedidas.entreItens + 4,
        bottom: TatuMedidas.entreSecoes,
      ),
      children: [
        if (aguardando.isNotEmpty) ...[
          const _Grupo('Aguardando pagamento'),
          _Lista(aguardando),
          const SizedBox(height: TatuMedidas.entreItens + 4),
        ],
        if (concluidos.isNotEmpty) ...[
          const _Grupo('Concluídos'),
          _Lista(concluidos),
        ],
      ],
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, TatuMedidas.tituloSecao),
    child: Text(texto, style: TatuTexto.grupo),
  );
}

class _Lista extends StatelessWidget {
  const _Lista(this.itens);

  final List<ServicoFeito> itens;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Column(
      children: [
        for (var i = 0; i < itens.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _Linha(itens[i]),
        ],
      ],
    ),
  );
}

class _Linha extends StatelessWidget {
  const _Linha(this.s);

  final ServicoFeito s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AvatarIniciais(nome: s.cliente, tamanho: 44),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.cliente,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${s.profissao} · ${s.quando}',
                  overflow: TextOverflow.ellipsis,
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${s.valor.round()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              switch (s.situacao) {
                SituacaoGanho.aguardando => const SeloVerde(
                  'Aguardando',
                  aviso: true,
                  pequeno: true,
                ),
                SituacaoGanho.pago => const SeloVerde('Pago', pequeno: true),
              },
            ],
          ),
        ],
      ),
    );
  }
}
