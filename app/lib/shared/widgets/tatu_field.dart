import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Campo de texto do guia: fundo cinza, rótulo pequeno dentro e valor
/// embaixo; contorno preto no foco e vermelho com [errorText] (texto vazio
/// marca só a borda).
/// Sem [label], mostra só o valor (ou o [hintText]) no meio do campo.
class TatuField extends StatefulWidget {
  const TatuField({
    super.key,
    this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  /// Só leitura: mostra o valor sem abrir o teclado nem ganhar contorno.
  final bool readOnly;

  /// Esconde o que foi digitado (ex.: CVV).
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TatuField> createState() => _TatuFieldState();
}

class _TatuFieldState extends State<TatuField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? TatuColors.danger
        : _focus.hasFocus && !widget.readOnly
        ? TatuColors.textPrimary
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _focus.requestFocus,
          child: Container(
            height: TatuMedidas.alturaCampo,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TatuColors.fill,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.label != null) ...[
                  Text(
                    widget.label!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  readOnly: widget.readOnly,
                  obscureText: widget.obscureText,
                  obscuringCharacter: '•',
                  showCursor: !widget.readOnly,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  autofillHints: widget.autofillHints,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: TatuColors.textPrimary,
                  style: const TextStyle(
                    fontSize: 17,
                    color: TatuColors.textPrimary,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontSize: 17,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(fontSize: 13, color: TatuColors.danger),
          ),
        ],
      ],
    );
  }
}
