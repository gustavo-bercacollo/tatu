import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tatu_field.dart';

/// Folha "Enviar valor": o profissional informa o valor do serviço.
/// Devolve o valor em reais (null se fechar sem enviar).
Future<double?> pedirValor(BuildContext context, {required String cliente}) =>
    mostrarFolha<double>(
      context,
      builder: (_) => _FolhaValor(cliente: cliente),
    );

class _FolhaValor extends StatefulWidget {
  const _FolhaValor({required this.cliente});

  final String cliente;

  @override
  State<_FolhaValor> createState() => _FolhaValorState();
}

class _FolhaValorState extends State<_FolhaValor> {
  final _valor = TextEditingController();

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  int get _reais => int.tryParse(_valor.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margem,
            10,
            TatuMedidas.margem,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AlcaFolha(),
              const SizedBox(height: 22),
              const Text('Enviar valor', style: TatuTexto.tituloFolha),
              const SizedBox(height: 6),
              Text(
                '${widget.cliente} confirma ou pede outro valor. '
                'O endereço aparece depois da confirmação.',
                style: TatuTexto.corpo,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              TatuField(
                label: 'Valor do serviço (R\$)',
                hintText: '150',
                controller: _valor,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              FilledButton(
                onPressed: _reais > 0
                    ? () => Navigator.of(context).pop(_reais.toDouble())
                    : null,
                child: const Text('Enviar valor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
