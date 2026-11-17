import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/consulta_cpf.dart';
import '../../../data/pagamentos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Novo cartão: número, validade, CVV, nome e CPF. Se o banco recusar,
/// mostra o aviso no topo e marca número e CVV.
class NovoCartaoPage extends StatefulWidget {
  const NovoCartaoPage({super.key, this.agora});

  /// Data usada para checar a validade (nos testes).
  final DateTime? agora;

  @override
  State<NovoCartaoPage> createState() => _NovoCartaoPageState();
}

class _NovoCartaoPageState extends State<NovoCartaoPage> {
  final _numero = TextEditingController();
  final _validade = TextEditingController();
  final _cvv = TextEditingController();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  bool _padrao = true;
  ErroCartao? _erro;

  @override
  void dispose() {
    for (final c in [_numero, _validade, _cvv, _nome, _cpf]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _validadeOk {
    final d = soDigitos(_validade.text);
    if (d.length != 4) return false;
    final mes = int.parse(d.substring(0, 2));
    final ano = 2000 + int.parse(d.substring(2));
    if (mes < 1 || mes > 12) return false;
    final hoje = widget.agora ?? DateTime.now();
    return DateTime(ano, mes + 1).isAfter(DateTime(hoje.year, hoje.month));
  }

  bool get _valido =>
      soDigitos(_numero.text).length == 16 &&
      _validadeOk &&
      soDigitos(_cvv.text).length >= 3 &&
      _nome.text.trim().isNotEmpty &&
      soDigitos(_cpf.text).length == 11;

  /// RN-111: o titular do cartão também precisa ter 18 anos.
  String? _erroCpf;

  Future<void> _salvar() async {
    final maior = await cpfDeMaior(_cpf.text);
    if (!mounted) return;
    if (!maior) {
      setState(
        () => _erroCpf = 'O titular do cartão precisa ter 18 anos ou mais.',
      );
      return;
    }
    final erro = pagamentos.adicionar(
      numero: soDigitos(_numero.text),
      validade: _validade.text,
      nome: _nome.text.trim(),
      padrao: _padrao,
    );
    if (erro == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _erro = erro);
    }
  }

  // Ao corrigir número ou CVV, o aviso de recusa some.
  void _mudouCartao(String _) => setState(() => _erro = null);

  @override
  Widget build(BuildContext context) {
    final recusado = _erro == ErroCartao.recusado;
    return TelaInterna(
      titulo: 'Novo cartão',
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.topo),
        children: [
          if (recusado)
            const _AvisoRecusa()
          else
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Ler cartão: em breve')),
                ),
              child: const Text('Ler cartão com a câmera'),
            ),
          const SizedBox(height: TatuMedidas.entreItens * 2),
          TatuField(
            label: 'Número do cartão',
            hintText: '0000 0000 0000 0000',
            controller: _numero,
            errorText: recusado ? '' : null,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MascaraFormatter('#### #### #### ####'),
            ],
            onChanged: _mudouCartao,
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          Row(
            children: [
              Expanded(
                child: TatuField(
                  label: 'Validade',
                  hintText: 'MM/AA',
                  controller: _validade,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    MascaraFormatter('##/##'),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: TatuField(
                  label: 'CVV',
                  controller: _cvv,
                  obscureText: true,
                  errorText: recusado ? '' : null,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: _mudouCartao,
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          TatuField(
            label: 'Nome no cartão',
            controller: _nome,
            textCapitalization: TextCapitalization.characters,
            autofillHints: const [AutofillHints.creditCardName],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          TatuField(
            label: 'CPF do titular',
            hintText: '000.000.000-00',
            controller: _cpf,
            errorText: _erroCpf,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MascaraFormatter('###.###.###-##'),
            ],
            onChanged: (_) => setState(() => _erroCpf = null),
          ),
          if (!recusado) ...[
            const SizedBox(height: TatuMedidas.entreSecoes),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Definir como padrão',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                CupertinoSwitch(
                  value: _padrao,
                  activeTrackColor: TatuColors.online,
                  onChanged: (v) => setState(() => _padrao = v),
                ),
              ],
            ),
          ],
        ],
      ),
      rodape: FilledButton(
        onPressed: _valido ? _salvar : null,
        child: Text(recusado ? 'Tentar de novo' : 'Salvar cartão'),
      ),
    );
  }
}

class _AvisoRecusa extends StatelessWidget {
  const _AvisoRecusa();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.dangerSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: const Row(
        children: [
          Icon(TablerIcons.alert_triangle, size: 22, color: TatuColors.danger),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cartão recusado',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.danger,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'O banco recusou. Confira os dados.',
                  style: TextStyle(fontSize: 14, color: TatuColors.danger),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
