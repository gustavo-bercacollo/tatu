import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Seletor de abas em trilho cinza (ex.: Recebidas / Enviadas).
class Segmento extends StatelessWidget {
  const Segmento({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.onMudar,
    this.icones = const {},
    this.pequeno = false,
    this.posicao,
    this.destacar = false,
  });

  /// RN-228: contorno preto e brilho leve na opção escolhida (1 s, ao
  /// trocar o modo pela busca).
  final bool destacar;

  /// Posição contínua da marcação branca (0 = primeira aba, 1 = segunda…),
  /// para ela acompanhar o dedo ao deslizar o conteúdo (AbasDeslizantes).
  /// Nula: a marcação pula para [selecionada], como sempre.
  final double? posicao;

  /// Pílula menor, com texto de 13 (ex.: "No local | À distância").
  final bool pequeno;

  final List<String> opcoes;

  /// Ícone depois do texto, por posição (ex.: estrela em "Até 3 ★").
  final Map<int, IconData> icones;
  final int selecionada;
  final ValueChanged<int> onMudar;

  double get _raioMarcacao => pequeno
      ? TatuMedidas.alturaSegmentoPequeno
      : TatuMedidas.raioSegmento - 2;

  @override
  Widget build(BuildContext context) {
    final p = posicao;
    if (p != null) return _deslizante(p);
    return Container(
      height: pequeno
          ? TatuMedidas.alturaSegmentoPequeno
          : TatuMedidas.alturaSegmento,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: TatuColors.trilho,
        borderRadius: BorderRadius.circular(
          pequeno ? TatuMedidas.alturaSegmentoPequeno : TatuMedidas.raioSegmento,
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selecionada,
                child: GestureDetector(
                  onTap: () => onMudar(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: destacar && i == selecionada
                          ? Border.all(color: TatuColors.action, width: 1.5)
                          : null,
                      boxShadow: destacar && i == selecionada
                          ? const [
                              BoxShadow(
                                color: TatuColors.sombra,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                      color: i == selecionada
                          ? TatuColors.bg
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        pequeno
                            ? TatuMedidas.alturaSegmentoPequeno
                            : TatuMedidas.raioSegmento - 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              opcoes[i],
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: pequeno ? 13 : 15,
                                fontWeight: FontWeight.w600,
                                color: i == selecionada
                                    ? TatuColors.textPrimary
                                    : TatuColors.textSecondary,
                              ),
                            ),
                            if (icones[i] != null) ...[
                              const SizedBox(width: 4),
                              Icon(
                                icones[i],
                                size: 14,
                                color: i == selecionada
                                    ? TatuColors.textPrimary
                                    : TatuColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  /// A marcação branca anda junto com [p]; o texto escuro é o da aba mais
  /// perto.
  Widget _deslizante(double p) {
    final n = opcoes.length;
    final atual = p.round().clamp(0, n - 1);
    return Container(
      height: pequeno
          ? TatuMedidas.alturaSegmentoPequeno
          : TatuMedidas.alturaSegmento,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: TatuColors.trilho,
        borderRadius: BorderRadius.circular(
          pequeno ? TatuMedidas.alturaSegmentoPequeno : TatuMedidas.raioSegmento,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final largura = c.maxWidth / n;
          return Stack(
            children: [
              Positioned(
                left: p.clamp(0, n - 1) * largura,
                top: 0,
                bottom: 0,
                width: largura,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: TatuColors.bg,
                    borderRadius: BorderRadius.circular(_raioMarcacao),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == atual,
                        child: GestureDetector(
                          onTap: () => onMudar(i),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  opcoes[i],
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: pequeno ? 13 : 15,
                                    fontWeight: FontWeight.w600,
                                    color: i == atual
                                        ? TatuColors.textPrimary
                                        : TatuColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
