import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/plano_fixo.dart' show diaCurto, diaMes;
import '../../data/retorno.dart';

/// RN-213/RN-214: caixa de escolha das folhas do retorno (dia, período,
/// hora): cinza, preta quando escolhida.
class CaixaHorario extends StatelessWidget {
  const CaixaHorario({
    super.key,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
    this.detalhe,
    this.altura = TatuMedidas.alturaCaixaHora,
    this.largura,
  });

  final String titulo;
  final String? detalhe;
  final bool selecionado;
  final VoidCallback onTap;
  final double altura;
  final double? largura;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: detalhe == null ? titulo : '$titulo, $detalhe',
      child: ExcludeSemantics(
        child: Material(
          color: selecionado ? TatuColors.action : TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCaixaHora),
          child: InkWell(
            borderRadius: BorderRadius.circular(TatuMedidas.raioCaixaHora),
            onTap: onTap,
            child: SizedBox(
              height: altura,
              width: largura,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: detalhe == null ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: selecionado
                          ? TatuColors.onAction
                          : TatuColors.textPrimary,
                    ),
                  ),
                  if (detalhe != null)
                    Text(
                      detalhe!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: selecionado
                            ? TatuColors.textoTerciario
                            : TatuColors.textSecondary,
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

/// RN-213/RN-214: dias para escolher ("Sáb / 28"), lado a lado.
class SeletorDiasRetorno extends StatelessWidget {
  const SeletorDiasRetorno({
    super.key,
    required this.dias,
    required this.selecionado,
    required this.onEscolher,
  });

  final List<DateTime> dias;
  final DateTime? selecionado;
  final ValueChanged<DateTime> onEscolher;

  static bool _mesmoDia(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, d) in dias.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            CaixaHorario(
              titulo: diaCurto(d.weekday),
              detalhe: '${d.day}',
              altura: TatuMedidas.alturaCaixaDia,
              largura: TatuMedidas.larguraCaixaDia,
              selecionado: _mesmoDia(d, selecionado),
              onTap: () => onEscolher(d),
            ),
          ],
        ],
      ),
    );
  }
}

/// RN-214: Manhã / Tarde / Noite com a faixa de horas.
class SeletorPeriodo extends StatelessWidget {
  const SeletorPeriodo({
    super.key,
    required this.selecionado,
    required this.onEscolher,
  });

  final PeriodoDia? selecionado;
  final ValueChanged<PeriodoDia> onEscolher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, p) in PeriodoDia.values.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: CaixaHorario(
              titulo: p.nome,
              detalhe: p.faixa,
              altura: TatuMedidas.alturaCaixaDia,
              selecionado: p == selecionado,
              onTap: () => onEscolher(p),
            ),
          ),
        ],
      ],
    );
  }
}

/// RN-213/RN-214: horas cheias em 4 colunas ("8h", "9h"…).
class SeletorHora extends StatelessWidget {
  const SeletorHora({
    super.key,
    required this.horas,
    required this.selecionada,
    required this.onEscolher,
  });

  final List<int> horas;
  final int? selecionada;
  final ValueChanged<int> onEscolher;

  @override
  Widget build(BuildContext context) {
    const colunas = 4;
    final linhas = <List<int>>[
      for (var i = 0; i < horas.length; i += colunas)
        horas.sublist(i, (i + colunas).clamp(0, horas.length)),
    ];
    return Column(
      children: [
        for (final (i, linha) in linhas.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var c = 0; c < colunas; c++) ...[
                if (c > 0) const SizedBox(width: 8),
                Expanded(
                  child: c < linha.length
                      ? CaixaHorario(
                          titulo: '${linha[c]}h',
                          selecionado: linha[c] == selecionada,
                          onTap: () => onEscolher(linha[c]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// C239 · RN-213: grade dos próximos 7 dias × manhã, tarde e noite. Até
/// [maximo] quadradinhos; os que já passaram ficam apagados.
class GradeHorarios extends StatelessWidget {
  const GradeHorarios({
    super.key,
    required this.agora,
    required this.escolhidos,
    required this.onMudar,
    this.maximo = RegrasRetorno.maxHorarios,
    this.dias = 7,
  });

  final DateTime agora;
  final List<OpcaoHorario> escolhidos;
  final ValueChanged<List<OpcaoHorario>> onMudar;
  final int maximo;
  final int dias;

  void _tocar(OpcaoHorario o) {
    final lista = List.of(escolhidos);
    if (lista.contains(o)) {
      lista.remove(o);
    } else if (lista.length < maximo) {
      lista.add(o);
    } else {
      return;
    }
    // Na ordem do calendário.
    lista.sort(
      (a, b) => a.as(a.periodo.inicio).compareTo(b.as(b.periodo.inicio)),
    );
    onMudar(lista);
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: TatuMedidas.larguraDiaGrade),
            for (final p in PeriodoDia.values) ...[
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      p.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(p.faixa, style: TatuTexto.legenda),
                  ],
                ),
              ),
            ],
          ],
        ),
        for (var i = 0; i < dias; i++) ...[
          const SizedBox(height: 8),
          _linha(DateTime(hoje.year, hoje.month, hoje.day + i)),
        ],
      ],
    );
  }

  Widget _linha(DateTime dia) {
    return Row(
      children: [
        SizedBox(
          width: TatuMedidas.larguraDiaGrade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomeDoDia(dia, agora),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(diaMes(dia), style: TatuTexto.legenda),
            ],
          ),
        ),
        for (final p in PeriodoDia.values) ...[
          const SizedBox(width: 6),
          Expanded(child: _celula(OpcaoHorario(dia, p))),
        ],
      ],
    );
  }

  Widget _celula(OpcaoHorario o) {
    final passou = o.passou(agora);
    final sel = escolhidos.contains(o);
    final rotulo = '${textoOpcao(o, agora)}${passou ? ', já passou' : ''}';
    return Semantics(
      button: !passou,
      selected: sel,
      enabled: !passou,
      label: rotulo,
      child: ExcludeSemantics(
        child: Material(
          color: passou
              ? TatuColors.surfaceGrouped
              : sel
              ? TatuColors.action
              : TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioHorario),
          child: InkWell(
            borderRadius: BorderRadius.circular(TatuMedidas.raioHorario),
            onTap: passou ? null : () => _tocar(o),
            child: SizedBox(
              height: TatuMedidas.alturaHorario,
              child: Center(
                child: passou
                    ? const Text(
                        '–',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: TatuColors.chevron,
                        ),
                      )
                    : sel
                    ? const Icon(
                        TablerIcons.check,
                        size: 18,
                        color: TatuColors.onAction,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
