import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../data/pagamentos.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

/// Cada lado pode propor até 3 valores.
const maxRodadasValor = 3;

/// "Visita R$ 40 · Serviço R$ 150" (e "material incluso", se for).
String detalheValor(ValorProposta v) => [
  if (v.visita > 0) 'Visita ${reaisInteiros(v.visita)}',
  'Serviço ${reaisInteiros(v.servico)}',
  if (v.material) 'material incluso',
].join(' · ');

/// C17 · Cartão do valor que o profissional enviou: total, forma de
/// pagamento (com "Trocar"), "Reservamos agora. Só cobramos no fim.",
/// Confirmar valor e Pedir outro valor.
class CartaoValorRecebido extends StatelessWidget {
  const CartaoValorRecebido({
    super.key,
    required this.valor,
    required this.onConfirmar,
    required this.onTrocar,
    required this.onPedirOutro,
  });

  final ValorProposta valor;
  final VoidCallback onConfirmar;
  final VoidCallback onTrocar;

  /// null = já usou as 3 rodadas.
  final VoidCallback? onPedirOutro;

  @override
  Widget build(BuildContext context) {
    final cartao = pagamentos.padrao;
    return _Cartao(
      contorno: true,
      children: [
        Text(detalheValor(valor), style: TatuTexto.detalhe),
        const SizedBox(height: 4),
        _Total(valor.total),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        Semantics(
          button: true,
          label: 'Trocar forma de pagamento',
          child: GestureDetector(
            onTap: onTrocar,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
              ),
              child: Row(
                children: [
                  const Icon(TablerIcons.credit_card, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cartao?.titulo ?? 'Escolha como pagar',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  Text(
                    cartao == null ? 'Escolher' : 'Trocar',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.verified,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        const Text(
          'Reservamos agora. Só cobramos no fim.',
          style: TatuTexto.nota,
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        FilledButton(
          onPressed: cartao == null ? onTrocar : onConfirmar,
          child: const Text('Confirmar valor'),
        ),
        if (onPedirOutro != null) ...[
          const SizedBox(height: 4),
          Center(child: LinkAzul('Pedir outro valor', onTap: onPedirOutro!)),
        ],
      ],
    );
  }
}

/// Valor confirmado: reservado na forma de pagamento.
class CartaoValorConfirmado extends StatelessWidget {
  const CartaoValorConfirmado({super.key, required this.valor});

  final ValorProposta valor;

  @override
  Widget build(BuildContext context) {
    final cartao = pagamentos.padrao;
    return _Cartao(
      children: [
        const Row(
          children: [
            Icon(TablerIcons.circle_check_filled,
                size: 20, color: TatuColors.online),
            SizedBox(width: 8),
            Text(
              'Valor confirmado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TatuColors.onlineTexto,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Total(valor.total),
        Text(detalheValor(valor), style: TatuTexto.detalhe),
        const SizedBox(height: TatuMedidas.entreItens),
        Text(
          'Reservado ${cartao == null ? '' : 'no ${cartao.curto}'}. '
          'Só cobramos no fim.',
          style: TatuTexto.nota,
        ),
      ],
    );
  }
}

/// Valor que o cliente pediu, esperando o profissional responder.
class CartaoValorPedido extends StatelessWidget {
  const CartaoValorPedido({
    super.key,
    required this.valor,
    required this.nome,
  });

  final ValorProposta valor;
  final String nome;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seu valor · ${valor.rodada} de $maxRodadasValor',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: 2),
              _Total(valor.pedido ?? 0),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    TablerIcons.clock,
                    size: 15,
                    color: TatuColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Aguardando $nome',
                      style: TatuTexto.nota.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.children, this.contorno = false});

  final List<Widget> children;

  /// Borda preta (valor esperando resposta).
  final bool contorno;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: contorno ? TatuColors.bg : TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: contorno
                ? Border.all(color: TatuColors.textPrimary, width: 1.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.valor);

  final double valor;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
      reais(valor),
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
    ),
  );
}

/// C18 · Folha "Quanto você quer pagar?". Devolve o total pedido ou null.
Future<double?> pedirOutroValor(
  BuildContext context, {
  required String nome,
  required String artigo,
  required int rodada,
}) => mostrarFolha<double>(
  context,
  builder: (_) => _FolhaPedir(nome: nome, artigo: artigo, rodada: rodada),
);

class _FolhaPedir extends StatefulWidget {
  const _FolhaPedir({
    required this.nome,
    required this.artigo,
    required this.rodada,
  });

  final String nome;
  final String artigo;
  final int rodada;

  @override
  State<_FolhaPedir> createState() => _FolhaPedirState();
}

class _FolhaPedirState extends State<_FolhaPedir> {
  final _campo = TextEditingController();

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  double get _valor => (int.tryParse(soDigitos(_campo.text)) ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
    );
    final artigo = widget.artigo.toUpperCase();
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
              const Text('Quanto você quer pagar?', style: TatuTexto.tituloFolha),
              const SizedBox(height: 6),
              Text(
                '$artigo ${widget.nome} pode aceitar ou enviar outro valor.',
                style: TatuTexto.corpo,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: TatuColors.fill,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
                  border: Border.all(color: TatuColors.textPrimary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total (visita + serviço)', style: TatuTexto.nota),
                    TextField(
                      controller: _campo,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ReaisFormatter()],
                      onChanged: (_) => setState(() {}),
                      cursorColor: TatuColors.textPrimary,
                      style: estilo,
                      decoration: InputDecoration.collapsed(
                        hintText: 'R\$ 0',
                        hintStyle: estilo.copyWith(
                          color: TatuColors.textDisabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Text(
                'Valor ${widget.rodada} de $maxRodadasValor',
                style: TatuTexto.detalhe,
              ),
              const SizedBox(height: TatuMedidas.entreItens),
              FilledButton(
                onPressed: _valor > 0
                    ? () => Navigator.of(context).pop(_valor)
                    : null,
                child: Text('Enviar para ${widget.artigo} ${widget.nome}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
