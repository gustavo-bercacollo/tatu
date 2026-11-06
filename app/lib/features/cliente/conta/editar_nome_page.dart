import 'package:flutter/material.dart';

import '../../../data/conta.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_field.dart';

/// Seu nome: editar nome e sobrenome (o que o profissional vê).
class EditarNomePage extends StatefulWidget {
  const EditarNomePage({super.key});

  @override
  State<EditarNomePage> createState() => _EditarNomePageState();
}

class _EditarNomePageState extends State<EditarNomePage> {
  late final _nome = TextEditingController(text: conta.nome);
  late final _sobrenome = TextEditingController(text: conta.sobrenome);

  bool get _valido => _nome.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nome.dispose();
    _sobrenome.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_valido) return;
    conta.definirNome(_nome.text, _sobrenome.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Seu nome',
      subtitulo: 'Aparece para o profissional.',
      botao: 'Salvar',
      onBotao: _valido ? _salvar : null,
      children: [
        TatuField(
          label: 'Nome',
          controller: _nome,
          autofocus: true,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TatuField(
          label: 'Sobrenome (opcional)',
          controller: _sobrenome,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.familyName],
          onSubmitted: (_) => _salvar(),
        ),
      ],
    );
  }
}
