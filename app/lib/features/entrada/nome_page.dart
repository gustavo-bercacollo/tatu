import 'package:flutter/material.dart';

import '../../data/conta.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/tatu_field.dart';
import '../cliente/home_page.dart';

/// Cadastro · seu nome: como o profissional vai chamar o cliente.
class NomePage extends StatefulWidget {
  const NomePage({super.key});

  @override
  State<NomePage> createState() => _NomePageState();
}

class _NomePageState extends State<NomePage> {
  final _nome = TextEditingController();
  final _sobrenome = TextEditingController();

  bool get _valido => _nome.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nome.dispose();
    _sobrenome.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_valido) return;
    conta.definirNome(_nome.text, _sobrenome.text);
    // Cadastro concluído: a Home vira a única tela da pilha.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeClientePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Como podemos\nte chamar?',
      subtitulo: 'Seu nome aparece para o profissional.',
      botao: 'Continuar',
      onBotao: _valido ? _continuar : null,
      children: [
        const SizedBox(height: 12),
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
          onSubmitted: (_) => _continuar(),
        ),
        const SizedBox(height: 18),
        const CadastroNota(
          'Ao continuar, você aceita os Termos de Uso\ne a Política de Privacidade.',
        ),
      ],
    );
  }
}
