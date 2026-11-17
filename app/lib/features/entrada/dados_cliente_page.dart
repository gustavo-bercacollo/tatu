import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/canal_tatu.dart';
import '../../data/consulta_cpf.dart';
import '../../data/conta.dart';
import '../../data/profissional.dart' show cpfValido;
import '../../shared/formatadores.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/tatu_field.dart';
import '../cliente/home_page.dart';
import 'menor_de_idade_page.dart';

/// C09 · Cadastro · seus dados: nome completo e CPF (RN-111). Não pede
/// data de nascimento: a idade vem da consulta do CPF. Menor de 18 não
/// entra e a conta não é criada (RN-110).
class DadosClientePage extends StatefulWidget {
  const DadosClientePage({super.key});

  @override
  State<DadosClientePage> createState() => _DadosClientePageState();
}

class _DadosClientePageState extends State<DadosClientePage> {
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  bool _cpfTocado = false;
  bool _consultando = false;

  bool get _nomeOk => _nome.text.trim().contains(' ');
  bool get _cpfOk => cpfValido(_cpf.text);

  @override
  void dispose() {
    _nome.dispose();
    _cpf.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (!_nomeOk || !_cpfOk || _consultando) return;
    setState(() => _consultando = true);
    // RN-111: a idade vem do CPF.
    final maior = await cpfDeMaior(_cpf.text);
    if (!mounted) return;
    setState(() => _consultando = false);
    if (!maior) {
      // RN-110: menor de 18 não entra; a conta não é criada.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MenorDeIdadePage()),
      );
      return;
    }
    final partes = _nome.text.trim().split(RegExp(r'\s+'));
    conta
      ..definirNome(partes.first, partes.skip(1).join(' '))
      ..definirCpf(_cpf.text);
    // RN-115/RN-116: a conta nasce com o canal do Tatu e as boas-vindas.
    canalTatu.cliente.comecar(boasVindasCliente(partes.first));
    // Cadastro concluído: a Home vira a única tela da pilha.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeClientePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cpfCompleto = soDigitos(_cpf.text).length == 11;
    return CadastroScaffold(
      titulo: 'Seus dados',
      subtitulo: 'Usamos o CPF para confirmar sua idade.',
      botao: 'Continuar',
      botaoConteudo: _consultando
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: TatuColors.onAction,
              ),
            )
          : null,
      botaoEstilo: _consultando ? tatuBotaoSecundario() : null,
      onBotao: _nomeOk && _cpfOk ? _continuar : null,
      children: [
        const SizedBox(height: 12),
        TatuField(
          label: 'Nome completo',
          controller: _nome,
          autofocus: true,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TatuField(
          label: 'CPF',
          hintText: '000.000.000-00',
          controller: _cpf,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          errorText: (_cpfTocado || cpfCompleto) && !_cpfOk && cpfCompleto
              ? 'Confira o CPF.'
              : null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            MascaraFormatter('###.###.###-##'),
          ],
          onChanged: (_) => setState(() => _cpfTocado = true),
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
