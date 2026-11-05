import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/topo_tela.dart';

/// Editar endereço: nome, complemento e tipo; salvar ou excluir.
class EditarEnderecoPage extends StatefulWidget {
  const EditarEnderecoPage({super.key, required this.endereco});

  final Endereco endereco;

  @override
  State<EditarEnderecoPage> createState() => _EditarEnderecoPageState();
}

class _EditarEnderecoPageState extends State<EditarEnderecoPage> {
  late final _nome = TextEditingController(text: widget.endereco.nome);
  late final _rua = TextEditingController(
    text: '${widget.endereco.rua} · ${widget.endereco.bairro}',
  );
  late final _complemento = TextEditingController(
    text: widget.endereco.complemento,
  );
  late TipoEndereco _tipo = widget.endereco.tipo;

  @override
  void dispose() {
    _nome.dispose();
    _rua.dispose();
    _complemento.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nome.text.trim();
    enderecos.atualizar(
      widget.endereco.copyWith(
        nome: nome.isEmpty ? _tipo.rotulo : nome,
        tipo: _tipo,
        complemento: _complemento.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  void _excluir() {
    enderecos.excluir(widget.endereco.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopoTela(
                    titulo: 'Editar endereço',
                    acao: 'Salvar',
                    onAcao: _salvar,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(4, 36, 4, 0),
                      children: [
                        TatuField(
                          label: 'Nome',
                          controller: _nome,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TatuField(
                          label: 'Endereço',
                          controller: _rua,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        TatuField(
                          label: 'Complemento',
                          controller: _complemento,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _salvar(),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Tipo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: TatuColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final t in TipoEndereco.values)
                              TatuChip(
                                label: t.rotulo,
                                selecionado: _tipo == t,
                                onTap: () => setState(() => _tipo = t),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _excluir,
                    style: TextButton.styleFrom(
                      foregroundColor: TatuColors.danger,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Excluir endereço',
                      style: TextStyle(fontSize: 17),
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
