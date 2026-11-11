import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/estrelas.dart';
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
    listenable: pedidos,
    builder: (context, _) => _lista(context),
  );

  Widget _lista(BuildContext context) {
    if (pedidos.semNadaEmAndamento) {
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
    final p = pedidos.andamento;
    final b = pedidos.busca;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: TatuMedidas.entreSecoes),
      children: [
        if (p != null) _CartaoAndamento(pedido: p),
        if (p != null && b != null)
          const SizedBox(height: TatuMedidas.entreSecoes - 4),
        if (b != null)
          p == null ? _NinguemAceitou(busca: b) : _BuscaCompacta(busca: b),
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

class _CartaoAndamento extends StatelessWidget {
  const _CartaoAndamento({required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) {
    return _Cartao(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PedidoAndamentoPage())),
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
                      '${pedido.servico} · ${pedido.descricao}',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SeloPreto(pedido.chegaEm),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          LinhaDoTempoHorizontal(
            etapas: etapasCurtas,
            feitas: pedido.etapasFeitas,
          ),
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
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: TatuColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Buscando em segundo plano',
                    maxLines: 1,
                    style: TatuTexto.comentario.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text('Outro pedido · ${busca.servico}', style: TatuTexto.nota),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: TatuColors.danger,
              padding: const EdgeInsets.only(left: 8),
              minimumSize: Size.zero,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: pedidos.cancelarBusca,
            child: const Text('Cancelar'),
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
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProcurandoPage(
                      servico: busca.servico,
                      endereco: busca.endereco,
                    ),
                  ),
                ),
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
                onPressed: pedidos.cancelarBusca,
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
    listenable: pedidos,
    builder: (context, _) => _lista(context),
  );

  Widget _lista(BuildContext context) {
    final lista = pedidos.concluidos;
    if (lista.isEmpty) {
      return const EstadoVazio(
        icone: TablerIcons.clock,
        titulo: 'Nada por aqui ainda',
        texto: 'Seus pedidos concluídos\nficam guardados aqui.',
      );
    }
    final itens = <Widget>[];
    String? mes;
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
                    Text('${p.profissao} · ${p.dia}', style: TatuTexto.nota),
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
