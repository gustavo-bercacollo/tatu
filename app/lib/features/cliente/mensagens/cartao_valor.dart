import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../data/pagamentos.dart';
import '../../../data/regras_valor.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

/// Cada lado pode propor até 3 valores.
const maxRodadasValor = 3;

/// "Visita R$ 40 · Serviço R$ 150"; à distância, "Serviço · sem visita"
/// (RN-95); valor novo só de serviço, "Serviço · troca da tubulação".
String detalheValor(ValorProposta v) {
  if (v.distancia) return 'Serviço · sem visita';
  // RN-181: novo valor no chat de um serviço concluído.
  if (v.novo && v.descricao != null) return 'Novo serviço · ${v.descricao}';
  if (v.visita == 0 && v.descricao != null) return 'Serviço · ${v.descricao}';
  return [
    if (v.visita > 0) 'Visita ${reaisInteiros(v.visita)}',
    'Serviço ${reaisInteiros(v.servico)}',
  ].join(' · ');
}

/// RN-91: "Em 6x de R$ 200,00" ou "À vista".
String textoParcelas(double total, int parcelas) => parcelas <= 1
    ? 'À vista'
    : 'Em ${parcelas}x de ${reais(total / parcelas)}';

/// C127 · Folha "Parcelar R$ 1.200,00": à vista, 3x ou 6x (RN-91).
/// Devolve o número de parcelas escolhido (null se fechar).
Future<int?> escolherParcelas(
  BuildContext context, {
  required double total,
  required int atual,
}) => mostrarFolha<int>(
  context,
  builder: (_) => _FolhaParcelas(total: total, atual: atual),
);

class _FolhaParcelas extends StatefulWidget {
  const _FolhaParcelas({required this.total, required this.atual});

  final double total;
  final int atual;

  @override
  State<_FolhaParcelas> createState() => _FolhaParcelasState();
}

class _FolhaParcelasState extends State<_FolhaParcelas> {
  late int _n = widget.atual;

  @override
  Widget build(BuildContext context) {
    final t = widget.total;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            Text('Parcelar ${reais(t)}', style: TatuTexto.tituloFolha),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            for (final n in RegrasValor.opcoesParcelas) ...[
              OpcaoSelecionavel(
                selecionado: _n == n,
                onTap: () => setState(() => _n = n),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      BolinhaEscolha(selecionado: _n == n),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n == 1 ? 'À vista' : '${n}x',
                              style: const TextStyle(fontSize: 17),
                            ),
                            Text(
                              n == 1
                                  ? reais(t)
                                  : '$n parcelas de ${reais(t / n)}',
                              style: TatuTexto.nota,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              'Parcelamento a partir de '
              '${reais(RegrasValor.parcelarAPartirDe)}.',
              style: TatuTexto.nota,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_n),
              child: Text(_n == 1 ? 'Pagar à vista' : 'Usar ${_n}x'),
            ),
          ],
        ),
      ),
    );
  }
}

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
    this.onRecusar,
    this.onParcelas,
    this.nome = '',
  });

  /// RN-208: no 3º valor (sem [onPedirOutro]), "Recusar valor".
  final VoidCallback? onRecusar;

  /// "a Marina" (para "O sinal paga o tempo da Marina.").
  final String nome;

  final ValorProposta valor;
  final VoidCallback onConfirmar;
  final VoidCallback onTrocar;

  /// RN-91: "Mudar" o número de parcelas (só a partir do mínimo).
  final VoidCallback? onParcelas;

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
        // RN-102/RN-103: sinal cobrado agora, restante quando aprovar.
        if (valor.sinal > 0) ...[
          _Sinal(valor: valor),
          const SizedBox(height: 8),
        ],
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
        if (onParcelas != null && RegrasValor.podeParcelar(valor.total)) ...[
          const SizedBox(height: 8),
          _LinhaAcao(
            texto: textoParcelas(valor.total, valor.parcelas),
            acao: 'Mudar',
            rotulo: 'Mudar parcelas',
            onTap: onParcelas!,
          ),
        ],
        const SizedBox(height: TatuMedidas.entreItens),
        Text(
          valor.sinal > 0
              ? 'O sinal paga o tempo ${_daDo(nome)}.'
              : 'Reservamos agora. Só cobramos no fim.',
          style: TatuTexto.nota,
        ),
        // RN-208: avisa antes que este é o último valor.
        if (onPedirOutro == null && onRecusar != null) ...[
          const SizedBox(height: 6),
          Text(
            'Último valor. Se recusar, a conversa com $nome termina sem '
            'custo.',
            style: TatuTexto.nota,
          ),
        ],
        const SizedBox(height: TatuMedidas.entreItens + 4),
        FilledButton(
          onPressed: cartao == null ? onTrocar : onConfirmar,
          child: const Text('Confirmar valor'),
        ),
        if (onPedirOutro != null) ...[
          const SizedBox(height: 4),
          Center(child: LinkAzul('Pedir outro valor', onTap: onPedirOutro!)),
        ] else if (onRecusar != null) ...[
          const SizedBox(height: 4),
          Center(
            child: LinkAzul('Recusar valor', onTap: onRecusar!, perigo: true),
          ),
        ],
      ],
    );
  }
}

/// Valor confirmado: reservado na forma de pagamento.
class CartaoValorConfirmado extends StatelessWidget {
  const CartaoValorConfirmado({
    super.key,
    required this.valor,
    this.avulso = false,
  });

  final ValorProposta valor;

  /// RN-203: com plano fixo, "Valor combinado · avulso".
  final bool avulso;

  @override
  Widget build(BuildContext context) {
    final cartao = pagamentos.padrao;
    return _Cartao(
      children: [
        Row(
          children: [
            const Icon(TablerIcons.circle_check_filled,
                size: 20, color: TatuColors.online),
            const SizedBox(width: 8),
            Text(
              avulso ? 'Valor combinado · avulso' : 'Valor confirmado',
              style: const TextStyle(
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
        if (valor.parcelas > 1)
          Text(
            textoParcelas(valor.total, valor.parcelas),
            style: TatuTexto.detalhe,
          ),
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

/// Linha cinza com texto e ação azul à direita ("Em 6x de R$ 200,00 ·
/// Mudar").
class _LinhaAcao extends StatelessWidget {
  const _LinhaAcao({
    required this.texto,
    required this.acao,
    required this.rotulo,
    required this.onTap,
  });

  final String texto;
  final String acao;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: rotulo,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Text(
              acao,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TatuColors.verified,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// "a Marina" → "da Marina"; "o Tiago" → "do Tiago".
String _daDo(String artigoNome) {
  if (artigoNome.startsWith('a ')) return 'da ${artigoNome.substring(2)}';
  if (artigoNome.startsWith('o ')) return 'do ${artigoNome.substring(2)}';
  return 'do profissional';
}

/// Caixa cinza "Sinal · cobrado agora" e "Restante · quando aprovar".
class _Sinal extends StatelessWidget {
  const _Sinal({required this.valor});

  final ValorProposta valor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Sinal · cobrado agora',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Text(
              reais(valor.sinal),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Expanded(
              child: Text('Restante · quando aprovar', style: TatuTexto.nota),
            ),
            Text(reais(valor.restante), style: TatuTexto.nota),
          ],
        ),
      ],
    ),
  );
}
