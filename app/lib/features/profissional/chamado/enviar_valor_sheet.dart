import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';

/// P24 · Folha "Quanto vai custar?". [rodada] é qual dos 3 valores
/// possíveis este é. Devolve null se fechar sem enviar.
Future<double?> pedirValor(
  BuildContext context, {
  required String cliente,
  required int rodada,
}) => mostrarFolha<double>(
  context,
  builder: (_) => _FolhaValor(cliente: cliente, rodada: rodada),
);

/// Digitação de dinheiro em centavos: "15000" vira "R$ 150,00".
class ReaisFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = soDigitos(newValue.text);
    if (d.length > 7) d = d.substring(0, 7);
    final centavos = int.tryParse(d) ?? 0;
    final texto = centavos == 0 ? '' : reais(centavos / 100);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _FolhaValor extends StatefulWidget {
  const _FolhaValor({required this.cliente, required this.rodada});

  final String cliente;
  final int rodada;

  @override
  State<_FolhaValor> createState() => _FolhaValorState();
}

class _FolhaValorState extends State<_FolhaValor> {
  final _campo = TextEditingController();
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  double get _valor => (int.tryParse(soDigitos(_campo.text)) ?? 0) / 100;

  @override
  Widget build(BuildContext context) {
    final v = _valor;
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
                  'A ${widget.cliente} pode aceitar ou propor outro valor.',
                  style: TatuTexto.corpo,
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                GestureDetector(
                  onTap: _foco.requestFocus,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: TatuColors.fill,
                      borderRadius: BorderRadius.circular(
                        TatuMedidas.raioCampo,
                      ),
                      border: Border.all(
                        color: _foco.hasFocus
                            ? TatuColors.textPrimary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valor do serviço', style: TatuTexto.nota),
                        TextField(
                          controller: _campo,
                          focusNode: _foco,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ReaisFormatter()],
                          onChanged: (_) => setState(() {}),
                          cursorColor: TatuColors.textPrimary,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'R\$ 0,00',
                            hintStyle: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: TatuColors.textDisabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
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
                      _Recebe(
                        'Pelo app (taxa de $pct%)',
                        reais(v * (1 - taxaTatu)),
                      ),
                      const SizedBox(height: 6),
                      _Recebe('Pago por fora', reais(v)),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                Text('Valor ${widget.rodada} de 3', style: TatuTexto.detalhe),
                const SizedBox(height: TatuMedidas.entreItens),
                FilledButton(
                  onPressed: v > 0 ? () => Navigator.of(context).pop(v) : null,
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

class _Recebe extends StatelessWidget {
  const _Recebe(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(rotulo, style: TatuTexto.detalhe)),
      Text(
        valor,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
