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
import '../../core/theme/tatu_medidas.dart';
import '../../data/aceites.dart';
import '../../data/documentos_legais.dart';
import '../../data/resumo_tatu.dart';
import 'documentos_legais_page.dart';

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

  /// RN-150: aceite ativo; começa desmarcado.
  bool _aceitou = false;

  bool get _nomeOk => _nome.text.trim().contains(' ');
  bool get _cpfOk => cpfValido(_cpf.text);

  @override
  void dispose() {
    _nome.dispose();
    _cpf.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (!_nomeOk || !_cpfOk || !_aceitou || _consultando) return;
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
    // RN-150: registra o aceite (conta, tipo, versões, data e hora).
    await documentosLegais.carregarTodos();
    aceites.registrar(
      conta: contaDoAceite(),
      tipo: TipoAceite.cliente,
      termos: documentosLegais.termos!,
      politica: documentosLegais.politica!,
    );
    if (!mounted) return;
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
      // RN-150: "Continuar" só com a caixa marcada.
      onBotao: _nomeOk && _cpfOk && _aceitou ? _continuar : null,
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
        const SizedBox(height: TatuMedidas.entreSecoes),
        // RN-150: o essencial antes do aceite (bate com "O essencial em 1
        // minuto" dos Termos).
        CartaoEssencial(
          titulo: 'O essencial do Tatu',
          itens: [for (final p in resumoCliente) p.texto],
          pequeno: true,
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        CaixaAceite(
          marcado: _aceitou,
          onMudar: (v) => setState(() => _aceitou = v),
        ),
      ],
    );
  }
}
