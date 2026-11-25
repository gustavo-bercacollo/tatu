import '../../../data/retorno.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../data/consulta_cpf.dart';
import '../../../data/profissional.dart';
import '../../entrada/menor_de_idade_page.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../entrada/codigo_page.dart';
import '../../../shared/widgets/nota_icone.dart';
import 'servicos_page.dart';

/// P02 · Passo 1: nome, CPF e celular (código por SMS).
class DadosProfissionalPage extends StatefulWidget {
  const DadosProfissionalPage({super.key});

  @override
  State<DadosProfissionalPage> createState() => _DadosProfissionalPageState();
}

class _DadosProfissionalPageState extends State<DadosProfissionalPage> {
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _celular = TextEditingController();
  bool _cpfTocado = false;

  @override
  void dispose() {
    _nome.dispose();
    _cpf.dispose();
    _celular.dispose();
    super.dispose();
  }

  bool get _nomeOk => _nome.text.trim().contains(' ');
  /// RN-192: CPF com dívida de retorno não abre outra conta.
  bool get _cpfComDivida => retornos.cpfComDivida(_cpf.text);
  bool get _cpfOk => cpfValido(_cpf.text) && !_cpfComDivida;
  bool get _celularOk => soDigitos(_celular.text).length == 11;

  bool _consultando = false;

  Future<void> _continuar() async {
    if (_consultando) return;
    // RN-112: mesma consulta do CPF do cliente; menor de 18 não segue.
    setState(() => _consultando = true);
    final maior = await cpfDeMaior(_cpf.text);
    if (!mounted) return;
    setState(() => _consultando = false);
    if (!maior) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MenorDeIdadePage()),
      );
      return;
    }
    profissional.salvarDados(
      nome: _nome.text,
      cpf: _cpf.text,
      celular: _celular.text,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CodigoPage(
          destino: formatarCelular(_celular.text),
          onConfirmado: (ctx) => Navigator.of(ctx).pushReplacement(
            MaterialPageRoute(builder: (_) => const ServicosProfissionalPage()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cpfCompleto = soDigitos(_cpf.text).length == 11;
    return CadastroScaffold(
      passo: 1,
      titulo: 'Seus dados',
      subtitulo: 'Como aparecem no seu documento.',
      botao: 'Continuar',
      onBotao: _nomeOk && _cpfOk && _celularOk ? _continuar : null,
      children: [
        TatuField(
          label: 'Nome completo',
          hintText: 'Nome e sobrenome',
          controller: _nome,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        TatuField(
          label: 'CPF',
          hintText: '000.000.000-00',
          controller: _cpf,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            MascaraFormatter('###.###.###-##'),
          ],
          errorText: cpfCompleto && _cpfComDivida
              ? 'Este CPF tem uma dívida com o Tatu. Quite antes de abrir '
                    'outra conta.'
              : (cpfCompleto || _cpfTocado) && !_cpfOk && cpfCompleto
              ? 'CPF inválido. Confira os números.'
              : null,
          onChanged: (_) => setState(() => _cpfTocado = true),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        TatuField(
          label: 'Celular com DDD',
          hintText: '(00) 00000-0000',
          controller: _celular,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            MascaraFormatter(moldeCelular),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const NotaIcone(
          icone: TablerIcons.lock,
          texto:
              'Usamos o CPF só para confirmar sua identidade.\n'
              'Vamos enviar um código por SMS para o celular.',
        ),
      ],
    );
  }
}
