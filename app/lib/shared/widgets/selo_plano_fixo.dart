import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../data/plano_fixo.dart';
import '../formatadores.dart';
import 'avatar_iniciais.dart';

/// RN-200: selo único "Plano fixo": pílula cinza com ícone de repetição,
/// igual para cliente e profissional. Vai embaixo do nome ou da última
/// mensagem (onde ficam "Valor combinado", "Proposta 2 de 3"), nunca ao
/// lado do nome.
class SeloPlanoFixo extends StatelessWidget {
  const SeloPlanoFixo(this.texto, {super.key, this.apagado = false});

  /// "Plano fixo", "Plano pausado", "Plano até 30 nov",
  /// "Plano fixo · visita 3 de 4", "Plano fixo · 4 visitas".
  final String texto;

  /// RN-205: pausado fica cinza apagado.
  final bool apagado;

  /// Selo do [plano] no estado atual (nulo = sem selo, RN-205).
  static Widget? de(PlanoFixo? plano, {String? complemento}) {
    final s = plano?.selo();
    if (s == null) return null;
    return SeloPlanoFixo(
      complemento == null ? s : '$s · $complemento',
      apagado: plano!.seloApagado,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cor = apagado ? TatuColors.textDisabled : TatuColors.textSecondary;
    return Semantics(
      label: texto,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: ShapeDecoration(
            color: apagado ? TatuColors.surfaceGrouped : TatuColors.fill,
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(TablerIcons.repeat, size: 13, color: cor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: apagado ? TatuColors.textDisabled : TatuColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RN-202/RN-205: barra fixa logo abaixo do topo do chat ("Plano fixo ·
/// toda terça, 9h · Próxima: 25 nov ›"). Toque abre a tela do plano.
class BarraPlanoFixo extends StatelessWidget {
  const BarraPlanoFixo({super.key, required this.barra, required this.onTap});

  final BarraPlano barra;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = barra.laranja ? TatuColors.warningTexto : TatuColors.textPrimary;
    return Semantics(
      button: true,
      label: '${barra.texto}${barra.direita == null ? '' : ' · ${barra.direita}'}',
      child: ExcludeSemantics(
        child: Material(
          color: barra.laranja ? TatuColors.warningSoft : TatuColors.surfaceGrouped,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Row(
                children: [
                  Icon(TablerIcons.repeat, size: 16, color: cor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      barra.texto,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cor,
                      ),
                    ),
                  ),
                  if (barra.direita != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      barra.direita!,
                      style: TextStyle(
                        fontSize: 13,
                        color: barra.laranja
                            ? TatuColors.warningTexto
                            : TatuColors.textSecondary,
                      ),
                    ),
                  ],
                  Icon(
                    TablerIcons.chevron_right,
                    size: 16,
                    color: barra.laranja
                        ? TatuColors.warningTexto
                        : TatuColors.textSecondary,
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

/// RN-201/RN-203: linha do plano na Atividade (visita de hoje, próxima
/// visita, cobrança do período): avatar, nome, detalhe e o selo embaixo.
class CartaoPlanoFixo extends StatelessWidget {
  const CartaoPlanoFixo({
    super.key,
    required this.nome,
    required this.detalhe,
    required this.selo,
    this.valor,
    this.onTap,
  });

  final String nome;
  final String detalhe;
  final Widget? selo;

  /// Cobrança do período ("R$ 600,00 · Pago").
  final double? valor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarIniciais(nome: nome, tamanho: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalhe,
                      style: const TextStyle(
                        fontSize: 13,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                    if (selo != null) ...[const SizedBox(height: 6), selo!],
                  ],
                ),
              ),
              if (valor != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      reais(valor!),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pago',
                      style: TextStyle(
                        fontSize: 13,
                        color: TatuColors.onlineTexto,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Terça, 2 dez · 9h".
String quandoVisita(PlanoFixo p, VisitaPlano v) {
  final d = diaLongo(v.dia.weekday);
  return '${d[0].toUpperCase()}${d.substring(1)}, ${diaMes(v.dia)} · '
      '${horaCurta(p.horario)}';
}

/// C223 · RN-204: faixa na Home do cliente no dia da visita ("A Júlia vem
/// hoje às 9h" · "Diarista · Plano fixo · ver plano").
class FaixaVisitaPlano extends StatelessWidget {
  const FaixaVisitaPlano({super.key, required this.plano, required this.onTap});

  final PlanoFixo plano;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = plano;
    return Semantics(
      button: true,
      child: Material(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                AvatarIniciais(nome: p.profissional, tamanho: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.feminino ? 'A' : 'O'} ${p.primeiroNome} vem hoje '
                        'às ${horaCurta(p.horario)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.profissao} · Plano fixo · ver plano',
                        style: const TextStyle(
                          fontSize: 13,
                          color: TatuColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 18,
                  color: TatuColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
