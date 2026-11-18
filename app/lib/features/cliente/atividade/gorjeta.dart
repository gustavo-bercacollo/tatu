import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/gorjeta.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// C111 · RN-141: cartão opcional "Quer pagar um café para a Luiza?" na
/// avaliação (só depois do serviço concluído).
class CartaoGorjeta extends StatelessWidget {
  const CartaoGorjeta({
    super.key,
    required this.nome,
    required this.feminino,
    required this.valor,
    required this.onValor,
  });

  final String nome;
  final bool feminino;

  /// Valor escolhido (nulo = sem gorjeta).
  final double? valor;
  final ValueChanged<double?> onValor;

  Future<void> _outro(BuildContext context) async {
    final v = await pedirOutroValorGorjeta(context);
    if (v != null) onValor(v);
  }

  @override
  Widget build(BuildContext context) {
    final outro = valor != null && !RegrasGorjeta.opcoes.contains(valor);
    Widget chip(String rotulo, bool sel, VoidCallback onTap, {int flex = 72}) =>
        Expanded(
          flex: flex,
          child: Semantics(
            button: true,
            selected: sel,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? TatuColors.action : TatuColors.fill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: sel ? TatuColors.onAction : TatuColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        border: Border.all(color: TatuColors.circle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: TatuColors.warningSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  TablerIcons.coffee,
                  size: 16,
                  color: TatuColors.warningTexto,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Quer pagar um café para ${feminino ? 'a' : 'o'} $nome?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 8,
            children: [
              // Tocar de novo no escolhido tira a gorjeta.
              for (final o in RegrasGorjeta.opcoes)
                chip(
                  reaisInteiros(o),
                  valor == o,
                  () => onValor(valor == o ? null : o),
                ),
              chip(
                outro ? reaisInteiros(valor!) : 'Outro',
                outro,
                () => _outro(context),
                flex: 92,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Opcional · 100% para ${feminino ? 'ela' : 'ele'}, '
            'só sai a taxa do cartão.',
            style: TatuTexto.legenda,
          ),
        ],
      ),
    );
  }
}

/// C112 · "Outro valor" (até [RegrasGorjeta.maximo]).
Future<double?> pedirOutroValorGorjeta(BuildContext context) =>
    mostrarFolha<double>(context, builder: (_) => const _FolhaOutroValor());

class _FolhaOutroValor extends StatefulWidget {
  const _FolhaOutroValor();

  @override
  State<_FolhaOutroValor> createState() => _FolhaOutroValorState();
}

class _FolhaOutroValorState extends State<_FolhaOutroValor> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  double get _valor => double.tryParse(_campo.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final v = _valor;
    final acima = v > RegrasGorjeta.maximo;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margemCadastro,
            10,
            TatuMedidas.margemCadastro,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AlcaFolha(),
              const SizedBox(height: 22),
              const Text('Outro valor', style: TatuTexto.tituloFolha),
              const SizedBox(height: 4),
              Text(
                'Até ${reaisInteiros(RegrasGorjeta.maximo)}.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              TatuField(
                label: 'Gorjeta',
                controller: _campo,
                autofocus: true,
                hintText: 'R\$ 0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                // RN-141: acima do máximo não passa.
                errorText: acima
                    ? 'Até ${reaisInteiros(RegrasGorjeta.maximo)}.'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              FilledButton(
                onPressed: RegrasGorjeta.valida(v)
                    ? () => Navigator.of(context).pop(v)
                    : null,
                child: Text(
                  RegrasGorjeta.valida(v) ? 'Usar ${reaisInteiros(v)}' : 'Usar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C113 · Avaliação e café enviados.
class GorjetaEnviadaPage extends StatelessWidget {
  const GorjetaEnviadaPage({
    super.key,
    required this.nome,
    required this.feminino,
    required this.valor,
    required this.cartao,
    required this.onInicio,
  });

  final String nome;
  final bool feminino;
  final double valor;
  final String cartao;
  final VoidCallback onInicio;

  @override
  Widget build(BuildContext context) => TelaPermissao(
    voltar: false,
    sucesso: true,
    icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
    titulo: 'Obrigado!',
    texto:
        'Sua avaliação e o café de ${reaisInteiros(valor)}\n'
        'foram enviados para ${feminino ? 'a' : 'o'} $nome.',
    extra: Text(
      'Cobrado no $cartao.',
      textAlign: TextAlign.center,
      style: TatuTexto.nota,
    ),
    principal: 'Voltar ao início',
    onPrincipal: onInicio,
  );
}
