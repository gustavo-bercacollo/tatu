import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Caixa cinza de texto de várias linhas, com contador ("58/500") e
/// borda preta em foco.
class CampoTextoLongo extends StatefulWidget {
  const CampoTextoLongo({
    super.key,
    required this.controller,
    required this.hint,
    this.maximo = 500,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maximo;
  final ValueChanged<String>? onChanged;

  @override
  State<CampoTextoLongo> createState() => _CampoTextoLongoState();
}

class _CampoTextoLongoState extends State<CampoTextoLongo> {
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TatuMedidas.alturaDescricao,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        border: Border.all(
          color: _foco.hasFocus ? TatuColors.action : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _foco,
              maxLines: null,
              expands: true,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [
                LengthLimitingTextInputFormatter(widget.maximo),
              ],
              onChanged: (v) {
                setState(() {});
                widget.onChanged?.call(v);
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: const EdgeInsets.only(top: 12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${widget.controller.text.characters.length}/${widget.maximo}',
              style: TatuTexto.legenda,
            ),
          ),
        ],
      ),
    );
  }
}
