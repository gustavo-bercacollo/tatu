import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ganhos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/segmento.dart';
import '../cadastro/taxas_sheet.dart';

/// P30 · Ganhos: o dinheiro de hoje, da semana ou do mês.
class GanhosPage extends StatefulWidget {
  const GanhosPage({super.key, this.periodo = 1});

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
    return Scaffold(
      body: SafeArea(
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BackCircleButton(),
                ),
                const SizedBox(height: 18),
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
                if (r.barras.isNotEmpty) ...[
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  _Barras(resumo: r),
                ],
                const SizedBox(height: TatuMedidas.entreSecoes),
                Container(
                  decoration: BoxDecoration(
                    color: TatuColors.fill,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                  ),
                  child: Column(
                    children: [
                      LinhaRotuloValor(
                        rotulo: 'Recebido pelo app',
                        valor: reais(r.peloApp),
                      ),
                      const Divider(height: 1),
                      LinhaRotuloValor(
                        rotulo: 'Recebido por fora',
                        valor: reais(r.porFora),
                      ),
                      const Divider(height: 1),
                      LinhaRotuloValor(
                        rotulo: 'A receber',
                        valor: reais(r.aReceber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: LinkAzul(
                    'Ver taxas do Tatu',
                    onTap: () => mostrarTaxas(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barras dos dias da semana; hoje fica preto.
class _Barras extends StatelessWidget {
  const _Barras({required this.resumo});

  final ResumoGanhos resumo;

  static const _altura = 120.0;

  @override
  Widget build(BuildContext context) {
    final maior = resumo.barras.reduce((a, b) => a > b ? a : b);
    return Semantics(
      label: 'Ganhos por dia da semana',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < resumo.barras.length; i++)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: maior == 0 || resumo.barras[i] == 0
                          ? 3
                          : 3 + (_altura - 3) * resumo.barras[i] / maior,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: i == resumo.atual
                            ? TatuColors.action
                            : TatuColors.fillStrong,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      resumo.rotulos[i],
                      style: i == resumo.atual
                          ? TatuTexto.nota.copyWith(
                              fontWeight: FontWeight.w700,
                              color: TatuColors.textPrimary,
                            )
                          : TatuTexto.nota,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
