import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../data/regras_distancia.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';

/// Valor que o profissional envia: visita + serviço.
@immutable
class ValorProposto {
  const ValorProposto({
    required this.visita,
    required this.servico,
    this.sinal = 0,
  });

  /// RN-102: sinal pedido à distância (0 = sem sinal).
  final double sinal;

  /// Fica com o profissional mesmo se o serviço não acontecer.
  final double visita;
  final double servico;

  double get total => visita + servico;

  /// "Visita R$ 40 · Serviço R$ 150".
  String get detalhe => [
    if (visita > 0) 'Visita ${reaisInteiros(visita)}',
    if (servico > 0) 'Serviço ${reaisInteiros(servico)}',
  ].join(' · ');
}

/// P24 · Folha "Quanto vai custar?". [rodada] é qual dos 3 valores
/// possíveis este é. Com [distancia] (P110, RN-95), só o Serviço.
/// Devolve null se fechar sem enviar.
Future<ValorProposto?> pedirValor(
  BuildContext context, {
  required String cliente,
  required int rodada,
  bool distancia = false,
}) => mostrarFolha<ValorProposto>(
  context,
  builder: (_) =>
      _FolhaValor(cliente: cliente, rodada: rodada, distancia: distancia),
);


class _FolhaValor extends StatefulWidget {
  const _FolhaValor({
    required this.cliente,
    required this.rodada,
    this.distancia = false,
  });

  final String cliente;
  final int rodada;
  final bool distancia;

  @override
  State<_FolhaValor> createState() => _FolhaValorState();
}

class _FolhaValorState extends State<_FolhaValor> {
  /// RN-102: "Pedir sinal" (só à distância).
  bool _sinal = false;
  final _visita = TextEditingController();
  final _servico = TextEditingController();
  final _focoVisita = FocusNode();
  final _focoServico = FocusNode();

  @override
  void initState() {
    super.initState();
    _focoVisita.addListener(() => setState(() {}));
    _focoServico.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _visita.dispose();
    _servico.dispose();
    _focoVisita.dispose();
    _focoServico.dispose();
    super.dispose();
  }

  double _ler(TextEditingController c) =>
      (int.tryParse(soDigitos(c.text)) ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    final d = widget.distancia;
    final valor = ValorProposto(
      // RN-95: à distância não tem visita.
      visita: d ? 0 : _ler(_visita),
      servico: _ler(_servico),
      sinal: d && _sinal ? RegrasDistancia.sinalDe(_ler(_servico)) : 0,
    );
    final total = valor.total;
    final taxa = total * taxaTatu;
    final pct = (taxaTatu * 100).round();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margemCadastro,
            10,
            TatuMedidas.margemCadastro,
            TatuMedidas.base,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AlcaFolha(),
                const SizedBox(height: 22),
                const Text('Quanto vai custar?', style: TatuTexto.tituloFolha),
                const SizedBox(height: 6),
                Text(
                  d
                      ? 'À distância não tem visita.'
                      : 'A ${widget.cliente} pode aceitar ou propor outro valor.',
                  style: TatuTexto.corpo,
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                if (d) ...[
                  _CampoValor(
                    rotulo: 'Serviço',
                    controller: _servico,
                    foco: _focoServico,
                    autofocus: true,
                    onMudar: () => setState(() {}),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens),
                  // RN-102/RN-103: sinal de até 30%, liberado na 1ª entrega.
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
                    decoration: BoxDecoration(
                      color: TatuColors.fill,
                      borderRadius: BorderRadius.circular(
                        TatuMedidas.raioCampo,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pedir sinal', style: TatuTexto.nota),
                              Text(
                                reaisInteiros(
                                  RegrasDistancia.sinalDe(_ler(_servico)),
                                ),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _sinal
                                      ? TatuColors.textPrimary
                                      : TatuColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _sinal,
                          activeTrackColor: TatuColors.online,
                          inactiveTrackColor: TatuColors.trilho,
                          onChanged: (v) => setState(() => _sinal = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Até ${(RegrasDistancia.sinalMaximo * 100).round()}% do '
                    'valor. Você recebe o sinal ao mandar a 1ª entrega, '
                    'mesmo se a ${widget.cliente} não aprovar.',
                    style: TatuTexto.nota,
                  ),
                ]
                else ...[
                Row(
                  children: [
                    Expanded(
                      child: _CampoValor(
                        rotulo: 'Visita',
                        controller: _visita,
                        foco: _focoVisita,
                        autofocus: true,
                        onMudar: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: TatuMedidas.entreItens),
                    Expanded(
                      child: _CampoValor(
                        rotulo: 'Serviço',
                        controller: _servico,
                        foco: _focoServico,
                        onMudar: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreItens),
                const Text(
                  'A visita é sua mesmo se o serviço não acontecer.',
                  style: TatuTexto.nota,
                ),
                ],
                const SizedBox(height: TatuMedidas.entreItens),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TatuColors.surfaceGrouped,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Você recebe',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!d) ...[
                        _Recebe('Total · visita + serviço', reais(total)),
                        const SizedBox(height: 6),
                      ],
                      _Recebe('Taxa do Tatu ($pct%)', '– ${reais(taxa)}'),
                      const SizedBox(height: 6),
                      _Recebe('No seu Pix', reais(total - taxa), forte: true),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                if (!d) ...[
                  Text('Valor ${widget.rodada} de 3', style: TatuTexto.detalhe),
                  const SizedBox(height: TatuMedidas.entreItens),
                ],
                FilledButton(
                  onPressed: total > 0
                      ? () => Navigator.of(context).pop(valor)
                      : null,
                  child: Text('Enviar para ${widget.cliente}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Caixa cinza com rótulo e valor grande; borda preta quando em foco.
class _CampoValor extends StatelessWidget {
  const _CampoValor({
    required this.rotulo,
    required this.controller,
    required this.foco,
    required this.onMudar,
    this.autofocus = false,
  });

  final String rotulo;
  final TextEditingController controller;
  final FocusNode foco;
  final VoidCallback onMudar;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
    );
    return GestureDetector(
      onTap: foco.requestFocus,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
          border: Border.all(
            color: foco.hasFocus ? TatuColors.textPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo, style: TatuTexto.nota),
            TextField(
              controller: controller,
              focusNode: foco,
              autofocus: autofocus,
              keyboardType: TextInputType.number,
              inputFormatters: [ReaisFormatter()],
              onChanged: (_) => onMudar(),
              cursorColor: TatuColors.textPrimary,
              style: estilo,
              decoration: InputDecoration.collapsed(
                hintText: 'R\$ 0',
                hintStyle: estilo.copyWith(color: TatuColors.textDisabled),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recebe extends StatelessWidget {
  const _Recebe(this.rotulo, this.valor, {this.forte = false});

  final String rotulo;
  final String valor;
  final bool forte;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          rotulo,
          style: forte
              ? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)
              : TatuTexto.detalhe,
        ),
      ),
      Text(
        valor,
        style: TextStyle(
          fontSize: 15,
          fontWeight: forte ? FontWeight.w700 : FontWeight.w400,
          color: forte ? TatuColors.textPrimary : TatuColors.textSecondary,
        ),
      ),
    ],
  );
}
