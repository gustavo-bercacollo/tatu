import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ganhos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/segmento.dart';
import '../abas.dart';
import 'ganhos_page.dart';

/// P29 · Atividade do profissional: ganhos da semana no topo e os
/// serviços (em andamento e concluídos).
class AtividadeProfissionalPage extends StatefulWidget {
  const AtividadeProfissionalPage({super.key, this.aba = 1});

  /// 0 = Em andamento, 1 = Concluídos.
  final int aba;

  @override
  State<AtividadeProfissionalPage> createState() =>
      _AtividadeProfissionalPageState();
}

class _AtividadeProfissionalPageState extends State<AtividadeProfissionalPage> {
  late int _aba = widget.aba;

  @override
  Widget build(BuildContext context) {
    final semana = ganhos.semana;
    final n = ganhos.concluidos.length;
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
                  _CartaoGanhos(
                    total: reais(semana.total),
                    detalhe:
                        '$n ${n == 1 ? 'serviço' : 'serviços'} · '
                        '${reais(semana.aReceber)} a receber',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GanhosPage()),
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  Segmento(
                    opcoes: const ['Em andamento', 'Concluídos'],
                    selecionada: _aba,
                    onMudar: (i) => setState(() => _aba = i),
                  ),
                  Expanded(
                    child: _aba == 0
                        ? const EstadoVazio(
                            icone: TablerIcons.clock,
                            titulo: 'Nenhum serviço agora',
                            texto:
                                'Quando você aceitar um chamado,\n'
                                'ele aparece aqui.',
                          )
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

/// Cartão preto com o ganho da semana; abre "Ganhos".
class _CartaoGanhos extends StatelessWidget {
  const _CartaoGanhos({
    required this.total,
    required this.detalhe,
    required this.onTap,
  });

  final String total;
  final String detalhe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final claro = TatuColors.onAction.withValues(alpha: 0.75);
    return Semantics(
      button: true,
      label: 'Ver ganhos',
      child: Material(
        color: TatuColors.action,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Esta semana',
                        style: TextStyle(fontSize: 14, color: claro),
                      ),
                    ),
                    Icon(TablerIcons.chevron_right, size: 20, color: claro),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: TatuColors.onAction,
                  ),
                ),
                const SizedBox(height: 4),
                Text(detalhe, style: TextStyle(fontSize: 14, color: claro)),
              ],
            ),
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
                SituacaoGanho.porFora => const SeloVerde(
                  'Por fora',
                  cinza: true,
                  pequeno: true,
                ),
              },
            ],
          ),
        ],
      ),
    );
  }
}
