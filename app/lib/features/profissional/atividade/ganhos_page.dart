import '../retorno/retorno_profissional.dart' show CartaoRepassePreso;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ganhos.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/segmento.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../abas.dart';

/// P30 · Ganhos: o dinheiro de hoje, da semana ou do mês. Total com a
/// comparação ao período anterior, barras da semana, próximo Pix (RN-35),
/// serviços, gorjetas (RN-141/RN-143) e média, de onde vem o dinheiro
/// (serviços, gorjetas, taxa do Tatu) e os últimos recebimentos.
class GanhosPage extends StatefulWidget {
  const GanhosPage({super.key, this.periodo = 1, this.comoAba = false});

  /// Aberta pela aba Ganhos (sem voltar, com a barra de abas). Pela Ajuda
  /// ou pelos Dados da conta, abre por cima, com voltar.
  final bool comoAba;

  /// 0 = Hoje, 1 = Semana, 2 = Mês.
  final int periodo;

  @override
  State<GanhosPage> createState() => _GanhosPageState();
}

class _GanhosPageState extends State<GanhosPage> {
  late int _periodo = widget.periodo;

  @override
  Widget build(BuildContext context) {
    final r = [ganhos.hoje, ganhos.semana, ganhos.mes][_periodo];
    final pix = ganhos.proximoPix;
    final recebidos = ganhos.concluidos;
    final d = r.diferenca;
    final chave = profissional.pixTipo;
    return Scaffold(
      bottomNavigationBar: widget.comoAba
          ? const AbasDoProfissional(ativa: AbaCliente.ganhos)
          : null,
      body: SafeArea(
        bottom: !widget.comoAba,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              children: [
                if (widget.comoAba)
                  const SizedBox(height: TatuMedidas.entreItens - 4)
                else ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                  const SizedBox(height: 18),
                ],
                const Text('Ganhos', style: TatuTexto.tituloGrande),
                const SizedBox(height: TatuMedidas.entreItens),
                Segmento(
                  opcoes: const ['Hoje', 'Semana', 'Mês'],
                  selecionada: _periodo,
                  onMudar: (i) => setState(() => _periodo = i),
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
                Text('Total ${r.nome}', style: TatuTexto.detalhe),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    reais(r.total),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Comparação com o período anterior.
                Row(
                  children: [
                    Icon(
                      d >= 0
                          ? TablerIcons.trending_up
                          : TablerIcons.trending_down,
                      size: 16,
                      color: d >= 0
                          ? TatuColors.onlineTexto
                          : TatuColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${reaisInteiros(d.abs())} a ${d >= 0 ? 'mais' : 'menos'} '
                        '${r.comparacao}',
                        style: TatuTexto.nota.copyWith(
                          color: d >= 0 ? TatuColors.onlineTexto : null,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.barras.isNotEmpty) ...[
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  _Barras(resumo: r),
                ],
                const SizedBox(height: TatuMedidas.entreSecoes),
                // P158 · RN-185: repasses presos por retorno aberto.
                CartaoRepassePreso(profissional: profissional.nome),
                // RN-35: quando o dinheiro cai.
                _Caixa(
                  child: Row(
                    children: [
                      const _Circulo(TablerIcons.building_bank),
                      const SizedBox(width: TatuMedidas.entreItens),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Próximo Pix: ${reais(pix.valor)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_maiuscula(pix.quando)}'
                              '${chave == null ? '' : ' · chave ${chave.rotulo}'}',
                              style: TatuTexto.nota,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                Row(
                  children: [
                    Expanded(
                      child: _Numero(
                        rotulo: 'Serviços',
                        valor: '${r.quantidade}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // RN-141: gorjetas em destaque.
                    Expanded(
                      child: _Numero(
                        rotulo: 'Gorjetas',
                        valor: reaisInteiros(r.gorjetas),
                        icone: TablerIcons.coffee,
                        verde: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Numero(
                        rotulo: 'Média',
                        valor: reaisInteiros(r.media.roundToDouble()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                _Caixa(
                  semRecuo: true,
                  child: Column(
                    children: [
                      _Linha('Serviços', reais(r.bruto)),
                      const Divider(height: 1),
                      // RN-143: a gorjeta é 100% do profissional.
                      _Linha(
                        'Gorjetas (100% suas)',
                        '+ ${reais(r.gorjetas)}',
                        verde: true,
                      ),
                      const Divider(height: 1),
                      // C86 · RN-232: tocar na linha explica a taxa.
                      _Linha(
                        'Taxa do Tatu (${(taxaTatu * 100).round()}%)',
                        '− ${reais(r.taxa)}',
                        onTap: () => mostrarTaxaDoTatu(context),
                      ),
                      const Divider(height: 1),
                      _Linha('Recebido', reais(r.total), destaque: true),
                      const Divider(height: 1),
                      // RN-171: serviço esperando o cliente confirmar.
                      _Linha(
                        r.esperandoCliente == 0
                            ? 'A receber'
                            : 'A receber · ${r.esperandoCliente} '
                                  'esperando',
                        reais(r.aReceber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
                // C85 · RN-232: "Ver todos" ao lado do título.
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Últimos recebimentos',
                        style: TatuTexto.grupo,
                      ),
                    ),
                    LinkAzul(
                      'Ver todos',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RecebimentosPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.tituloSecao),
                for (final s in recebidos.take(3)) LinhaRecebimento(s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _maiuscula(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// Caixa cinza clara (mesmo fundo do "Recebido" de antes).
class _Caixa extends StatelessWidget {
  const _Caixa({required this.child, this.semRecuo = false});

  final Widget child;
  final bool semRecuo;

  @override
  Widget build(BuildContext context) => Container(
    padding: semRecuo
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: child,
  );
}

class _Circulo extends StatelessWidget {
  const _Circulo(this.icone);

  final IconData icone;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: TatuColors.bg,
      shape: BoxShape.circle,
    ),
    child: Icon(icone, size: 20),
  );
}

/// Número rápido (Serviços, Gorjetas, Média).
class _Numero extends StatelessWidget {
  const _Numero({
    required this.rotulo,
    required this.valor,
    this.icone,
    this.verde = false,
  });

  final String rotulo;
  final String valor;
  final IconData? icone;
  final bool verde;

  @override
  Widget build(BuildContext context) {
    final cor = verde ? TatuColors.onlineTexto : null;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: verde ? TatuColors.onlineSoft : TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icone != null) ...[
                Icon(icone, size: 14, color: cor),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: TatuTexto.nota.copyWith(color: cor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(
    this.rotulo,
    this.valor, {
    this.destaque = false,
    this.verde = false,
    this.onTap,
  });

  final String rotulo;
  final String valor;
  final bool destaque;
  final bool verde;

  /// Com toque: ⓘ azul logo depois do rótulo (RN-232).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final texto = Text(
      rotulo,
      overflow: TextOverflow.ellipsis,
      style: destaque
          ? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
          : const TextStyle(fontSize: 16, color: TatuColors.textSecondary),
    );
    final linha = SizedBox(
      height: TatuMedidas.alturaLinha - 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: onTap == null
                  ? texto
                  : Row(
                      children: [
                        Flexible(child: texto),
                        const SizedBox(width: 6),
                        const Icon(
                          TablerIcons.info_circle,
                          size: 18,
                          color: TatuColors.verified,
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: destaque ? FontWeight.w700 : FontWeight.w400,
                color: verde ? TatuColors.onlineTexto : TatuColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
    return onTap == null ? linha : InkWell(onTap: onTap, child: linha);
  }
}

/// C86 · RN-232: folha "Taxa do Tatu", com o que a taxa cobre.
Future<void> mostrarTaxaDoTatu(BuildContext context) {
  final pct = '${(taxaTatu * 100).round()}%';
  final itens = [
    '$pct sobre o valor do serviço.',
    'A visita também tem $pct.',
    'Gorjetas são 100% suas, sem taxa.',
    'A taxa já sai descontada no Pix.',
  ];
  return mostrarFolha<void>(
    context,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          8,
          TatuMedidas.margemCadastro,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('Taxa do Tatu', style: TatuTexto.tituloFolha),
            const SizedBox(height: TatuMedidas.entreItens),
            for (final t in itens)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      TablerIcons.check,
                      size: 18,
                      color: TatuColors.onlineTexto,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t,
                        style: TatuTexto.corpo.copyWith(
                          color: TatuColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Um recebimento: cliente, quando, gorjeta e o valor (serviço + gorjeta).
class LinhaRecebimento extends StatelessWidget {
  const LinhaRecebimento(this.servico, {super.key});

  final ServicoFeito servico;

  @override
  Widget build(BuildContext context) {
    final s = servico;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TatuColors.hairline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          AvatarIniciais(nome: s.cliente, tamanho: 40),
          const SizedBox(width: TatuMedidas.entreItens),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.cliente, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: TatuTexto.nota,
                    children: [
                      TextSpan(text: _maiuscula(s.quando)),
                      if (s.gorjeta > 0)
                        TextSpan(
                          text: ' · + ${reaisInteiros(s.gorjeta)} de gorjeta',
                          style: const TextStyle(color: TatuColors.onlineTexto),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            reaisInteiros(s.recebido),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// "Ver todos": todos os recebimentos, com as gorjetas.
class RecebimentosPage extends StatelessWidget {
  const RecebimentosPage({super.key});

  @override
  Widget build(BuildContext context) => TelaInterna(
    titulo: 'Recebimentos',
    corpo: ListView(
      padding: const EdgeInsets.only(top: TatuMedidas.entreItens),
      children: [for (final s in ganhos.concluidos) LinhaRecebimento(s)],
    ),
  );
}

/// Barras dos dias da semana. Toque numa barra para ver quanto entrou
/// naquele dia; começa em hoje. A barra escolhida fica preta.
class _Barras extends StatefulWidget {
  const _Barras({required this.resumo});

  final ResumoGanhos resumo;

  @override
  State<_Barras> createState() => _BarrasState();
}

class _BarrasState extends State<_Barras> {
  static const _altura = 120.0;

  late int _escolhida = widget.resumo.atual;

  String _dia(int i) {
    final r = widget.resumo;
    final nome = i < r.dias.length ? r.dias[i] : r.rotulos[i];
    return i == r.atual ? '$nome (hoje)' : nome;
  }

  /// Dia que ainda não chegou não tem valor para mostrar.
  String _valor(int i) {
    final r = widget.resumo;
    if (r.atual >= 0 && i > r.atual) return 'Ainda não chegou';
    return reais(r.barras[i]);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resumo;
    final maior = r.barras.reduce((a, b) => a > b ? a : b);
    final e = _escolhida;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (e >= 0 && e < r.barras.length) ...[
          Row(
            children: [
              Expanded(child: Text(_dia(e), style: TatuTexto.detalhe)),
              Text(
                _valor(e),
                style: r.atual >= 0 && e > r.atual
                    ? TatuTexto.detalhe
                    : TatuTexto.detalhe.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TatuColors.textPrimary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < r.barras.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == e,
                  label: '${_dia(i)}: ${_valor(i)}',
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _escolhida = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Área de toque com a altura toda do gráfico.
                          SizedBox(
                            height: _altura,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: maior == 0 || r.barras[i] == 0
                                    ? 3
                                    : 3 + (_altura - 3) * r.barras[i] / maior,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: i == e
                                      ? TatuColors.action
                                      : TatuColors.fillStrong,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r.rotulos[i],
                            style: i == e
                                ? TatuTexto.nota.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: TatuColors.textPrimary,
                                  )
                                : TatuTexto.nota,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
