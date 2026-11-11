import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/mapa_falso.dart';

/// Região de atendimento: até onde o profissional aceita ir (2 a 20 km).
/// Só o profissional configura raio; o cliente nunca.
class RegiaoPage extends StatefulWidget {
  const RegiaoPage({super.key});

  static const minimo = 2;
  static const maximo = 20;

  @override
  State<RegiaoPage> createState() => _RegiaoPageState();
}

class _RegiaoPageState extends State<RegiaoPage> {
  double _km = profissional.raioKm.toDouble();

  void _salvar() {
    profissional.definirRaio(_km.round());
    Navigator.of(context).pop();
    mostrarAvisoTopo(
      context,
      titulo: 'Região salva',
      texto: 'Você recebe chamados até ${_km.round()} km.',
    );
  }

  @override
  Widget build(BuildContext context) {
    const margem = EdgeInsets.symmetric(horizontal: TatuMedidas.margemCadastro);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    TatuMedidas.margemCadastro,
                    TatuMedidas.topo,
                    TatuMedidas.margemCadastro,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: margem,
                  child: Text(
                    'Região de atendimento',
                    style: TextStyle(
                      fontSize: 30,
                      height: 36 / 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: margem,
                  child: Text(
                    'Até onde você aceita ir. Quanto maior, mais chamados.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 22 / 16,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
                SizedBox(
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: MapaFalso()),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 60 + _km * 9,
                        height: 60 + _km * 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TatuColors.verified.withValues(alpha: 0.12),
                          border: Border.all(
                            color: TatuColors.verified.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TatuColors.action,
                          border: Border.all(color: TatuColors.bg, width: 4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
                Padding(
                  padding: margem,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Text(
                          'Distância máxima',
                          style: TatuTexto.detalhe,
                        ),
                      ),
                      Text(
                        '${_km.round()} km',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: TatuColors.action,
                      inactiveTrackColor: TatuColors.trilho,
                      thumbColor: TatuColors.bg,
                      overlayColor: TatuColors.fill,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _km,
                      min: RegiaoPage.minimo.toDouble(),
                      max: RegiaoPage.maximo.toDouble(),
                      divisions: RegiaoPage.maximo - RegiaoPage.minimo,
                      label: '${_km.round()} km',
                      semanticFormatterCallback: (v) => '${v.round()} km',
                      onChanged: (v) => setState(() => _km = v),
                    ),
                  ),
                ),
                const Padding(
                  padding: margem,
                  child: Row(
                    children: [
                      Text('${RegiaoPage.minimo} km', style: TatuTexto.nota),
                      Spacer(),
                      Text('${RegiaoPage.maximo} km', style: TatuTexto.nota),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margemCadastro,
                    16,
                    TatuMedidas.margemCadastro,
                    TatuMedidas.base,
                  ),
                  child: FilledButton(
                    onPressed: _salvar,
                    child: const Text('Salvar'),
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
