import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/plano_fixo.dart';
import '../formatadores.dart';
import 'avatar_iniciais.dart';

/// RN-211/RN-212: a negociação do plano fixo no chat, igual para cliente
/// e profissional ([souCliente] diz quem está vendo).
///
/// As propostas antigas ficam encolhidas numa linha cinza (à esquerda as
/// da outra pessoa, à direita as suas); só a da vez fica grande. Com o
/// plano confirmado, o card fica no chat com "Confirmado" e "Ver plano";
/// sem acordo, todas encolhidas com o aviso embaixo.
class NegociacaoPlanoChat extends StatelessWidget {
  const NegociacaoPlanoChat({
    super.key,
    required this.plano,
    required this.souCliente,
    this.novoValor = false,
    this.ultimoAvulso,
    this.cartao,
    this.onConfirmar,
    this.onOutroValor,
    this.onRecusar,
    this.onTrocarCartao,
    this.onAceitar,
    this.onEnviarOutro,
    this.onVerPlano,
  });

  final PlanoFixo plano;
  final bool souCliente;

  /// RN-148: negociação de um novo valor num plano ativo.
  final bool novoValor;

  /// RN-211: valor do último serviço avulso com a pessoa (para a
  /// economia; só o cliente vê).
  final double? ultimoAvulso;

  /// Cartão de cobrança (só o cliente vê).
  final String? cartao;

  // Cliente.
  final VoidCallback? onConfirmar;
  final VoidCallback? onOutroValor;
  final VoidCallback? onRecusar;
  final VoidCallback? onTrocarCartao;

  // Profissional.
  final VoidCallback? onAceitar;
  final VoidCallback? onEnviarOutro;

  /// Plano confirmado: abre a tela do plano.
  final VoidCallback? onVerPlano;

  NegociacaoPlano get _n =>
      (novoValor ? plano.novoValor : null) ?? plano.negociacao;

  bool _minha(PropostaPlano p) => p.doCliente == souCliente;

  String _nomeCurto(PropostaPlano p) => _minha(p)
      ? 'Você'
      : p.doCliente
      ? plano.primeiroCliente
      : plano.primeiroNome;

  String _nomeDe(PropostaPlano p) =>
      p.doCliente ? plano.cliente : plano.profissional;

  /// "a Luiza" / "o Carlos" / "a Ana": a outra pessoa.
  String get _outro => souCliente
      ? '${plano.feminino ? 'a' : 'o'} ${plano.primeiroNome}'
      : '${plano.clienteFeminina ? 'a' : 'o'} ${plano.primeiroCliente}';

  @override
  Widget build(BuildContext context) {
    final n = _n;
    final todas = n.propostas;
    final reais = [
      for (final p in todas)
        if (!p.aceite) p,
    ];
    if (reais.isEmpty) return const SizedBox.shrink();
    final ultima = todas.last;
    final semAcordo = n.recusada;
    final confirmado =
        !novoValor && plano.status != StatusPlano.pendente && !semAcordo;

    // Quais ficam encolhidas e com que rótulo.
    final encolhidas = <(PropostaPlano, int, String)>[];
    PropostaPlano? grande;
    for (var i = 0; i < reais.length; i++) {
      final p = reais[i];
      final ehUltimaReal = i == reais.length - 1;
      if (semAcordo) {
        encolhidas.add((p, i + 1, ehUltimaReal ? 'recusada' : 'substituída'));
      } else if (ehUltimaReal && !ultima.aceite) {
        grande = p;
      } else {
        encolhidas.add((
          p,
          i + 1,
          ehUltimaReal && ultima.aceite ? 'aceita' : 'substituída',
        ));
      }
    }
    // O profissional aceitou o valor do cliente: o card da vez é o aceite.
    if (!semAcordo && ultima.aceite) grande = ultima;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (p, numero, rotulo) in encolhidas) ...[
          _PropostaEncolhida(
            nome: _nomeDe(p),
            titulo:
                '${_nomeCurto(p)} · ${reaisInteiros(p.porVisita)} por visita',
            detalhe: 'Proposta $numero · $rotulo',
            minha: _minha(p),
          ),
          const SizedBox(height: 8),
        ],
        if (semAcordo)
          _SemAcordo(outro: _outro)
        else if (grande != null) ...[
          const SizedBox(height: 4),
          _card(grande, n, confirmado),
        ],
      ],
    );
  }

  Widget _card(PropostaPlano p, NegociacaoPlano n, bool confirmado) {
    final minha = _minha(p);
    final ultimaRodada = n.ultimaProposta && !p.aceite;
    final porVisita = p.porVisita;
    final total = porVisita * plano.visitasNoPeriodo;
    final subtitulo = confirmado
        ? 'Plano ${plano.mensal ? 'mensal' : 'semanal'}'
        : p.aceite
        ? (minha ? 'aceitou o valor pedido' : 'aceitou o seu valor')
        : p.doCliente
        ? 'pediu outro valor'
        : n.numero >= RegrasPlanoFixo.maxPropostas
        ? 'enviou a última proposta'
        : novoValor
        ? 'propôs um novo valor'
        : 'propôs um plano ${plano.mensal ? 'mensal' : 'semanal'}';
    // Economia vs. avulso: só o cliente, na proposta da outra pessoa.
    final avulso = ultimoAvulso;
    final economia = avulso == null
        ? 0.0
        : avulso * plano.visitasNoPeriodo - total;
    final daVez = !confirmado && !minha;

    final corpo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AvatarIniciais(
              nome: _nomeDe(p),
              tamanho: TatuMedidas.avatarProposta,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    minha ? 'Você' : _nomeDe(p),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitulo, style: TatuTexto.legenda),
                ],
              ),
            ),
            if (confirmado)
              const _SeloConfirmado()
            else
              _Rodada(numero: n.numero, ultima: ultimaRodada),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, thickness: 0.5, color: TatuColors.tabBarLine),
        const SizedBox(height: 18),
        // RN-210/RN-211: total do período em destaque, sempre calculado.
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: reaisInteiros(total),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              TextSpan(
                text: ' por ${plano.periodo}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: TatuColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${plano.visitasNoPeriodo} visita'
          '${plano.visitasNoPeriodo == 1 ? '' : 's'} × '
          // RN-146: cada visita é cobrada ao concluir.
          '${reaisInteiros(porVisita)} · cobrado a cada visita',
          style: TatuTexto.legenda,
        ),
        const SizedBox(height: 16),
        _DiasDaSemana(dias: plano.dias),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(TablerIcons.calendar, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${plano.diasCurtos}, às ${horaCurta(plano.horario)} · '
                '1ª visita: ${diaMes(plano.primeiraVisita())}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (souCliente && daVez && economia > 0) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _SeloEconomia(
              'Economia de ${reaisInteiros(economia)} por ${plano.periodo} '
              'vs. avulso',
            ),
          ),
        ],
        if (confirmado) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onVerPlano,
            style: tatuBotaoSecundario().copyWith(
              minimumSize: const WidgetStatePropertyAll(
                Size.fromHeight(TatuMedidas.alturaBotaoCartao),
              ),
            ),
            child: const Text('Ver plano'),
          ),
        ] else if (minha) ...[
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: TatuColors.tabBarLine,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                TablerIcons.clock,
                size: 18,
                color: TatuColors.warningTexto,
              ),
              const SizedBox(width: 8),
              Text(
                'Aguardando $_outro responder',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.warningTexto,
                ),
              ),
            ],
          ),
        ] else if (souCliente)
          ..._botoesCliente(n)
        else
          ..._botoesProfissional(porVisita),
      ],
    );

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.91,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
            border: Border.all(
              color: confirmado ? TatuColors.chevron : TatuColors.action,
              width: 1.5,
            ),
          ),
          child: corpo,
        ),
      ),
    );
  }

  List<Widget> _botoesCliente(NegociacaoPlano n) => [
    const SizedBox(height: 14),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      ),
      child: Row(
        children: [
          const Icon(TablerIcons.credit_card, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cartao ?? 'Visa final 4242',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: onTrocarCartao,
            child: const Text(
              'Trocar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TatuColors.verified,
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: TatuMedidas.entreItens),
    FilledButton(
      onPressed: onConfirmar,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(TatuMedidas.alturaBotaoCartao),
      ),
      child: Text(novoValor ? 'Confirmar novo valor' : 'Confirmar plano'),
    ),
    // RN-210: "Pedir outro valor" dentro do card, mesma largura.
    if (n.clientePodePedirOutro) ...[
      const SizedBox(height: 8),
      FilledButton(
        onPressed: onOutroValor,
        style: tatuBotaoSecundario().copyWith(
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(TatuMedidas.alturaBotaoCartao),
          ),
        ),
        child: const Text('Pedir outro valor'),
      ),
    ],
    if (n.clientePodeRecusar) ...[
      const SizedBox(height: 4),
      TextButton(
        onPressed: onRecusar,
        style: TextButton.styleFrom(foregroundColor: TatuColors.danger),
        child: const Text(
          'Recusar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  ];

  List<Widget> _botoesProfissional(double porVisita) => [
    const SizedBox(height: 16),
    FilledButton(
      onPressed: onAceitar,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(TatuMedidas.alturaBotaoCartao),
      ),
      child: Text('Aceitar ${reaisInteiros(porVisita)} por visita'),
    ),
    const SizedBox(height: 8),
    FilledButton(
      onPressed: onEnviarOutro,
      style: tatuBotaoSecundario().copyWith(
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(TatuMedidas.alturaBotaoCartao),
        ),
      ),
      child: const Text('Enviar outro valor'),
    ),
  ];
}

/// RN-212: proposta substituída (ou recusada), encolhida numa linha cinza.
class _PropostaEncolhida extends StatelessWidget {
  const _PropostaEncolhida({
    required this.nome,
    required this.titulo,
    required this.detalhe,
    required this.minha,
  });

  final String nome;
  final String titulo;
  final String detalhe;
  final bool minha;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.79,
        child: Container(
          height: TatuMedidas.alturaLinha,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
            border: Border.all(color: TatuColors.contornoClaro, width: 1.2),
          ),
          child: Row(
            children: [
              AvatarIniciais(
                nome: nome,
                tamanho: TatuMedidas.avatarPropostaPequeno,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TatuColors.textSecondary,
                      ),
                    ),
                    Text(
                      detalhe,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TatuColors.textoTerciario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RN-211: "1 de 3 ● ○ ○"; na última, "Última" e as bolinhas em laranja.
class _Rodada extends StatelessWidget {
  const _Rodada({required this.numero, required this.ultima});

  final int numero;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    const max = RegrasPlanoFixo.maxPropostas;
    final cor = ultima ? TatuColors.warningTexto : TatuColors.action;
    return Semantics(
      label: ultima ? 'Última proposta' : 'Proposta $numero de $max',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ultima ? 'Última' : '$numero de $max',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ultima
                    ? TatuColors.warningTexto
                    : TatuColors.textSecondary,
              ),
            ),
            for (var i = 1; i <= max; i++) ...[
              const SizedBox(width: 6),
              Container(
                width: TatuMedidas.bolinhaRodada,
                height: TatuMedidas.bolinhaRodada,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= numero ? cor : TatuColors.contornoClaro,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// RN-211: D S T Q Q S S, com os dias do plano em preto.
class _DiasDaSemana extends StatelessWidget {
  const _DiasDaSemana({required this.dias});

  final List<int> dias;

  static const _letras = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  /// Domingo primeiro (weekday 7), depois segunda (1) a sábado (6).
  static const _ordem = [7, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          Container(
            width: TatuMedidas.diaSemana,
            height: TatuMedidas.diaSemana,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dias.contains(_ordem[i])
                  ? TatuColors.action
                  : TatuColors.surfaceGrouped,
            ),
            child: Text(
              _letras[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: dias.contains(_ordem[i])
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: dias.contains(_ordem[i])
                    ? TatuColors.onAction
                    : TatuColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// RN-211: selo verde com ✓ (economia vs. avulso).
class _SeloEconomia extends StatelessWidget {
  const _SeloEconomia(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const ShapeDecoration(
        color: TatuColors.onlineSoft,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            TablerIcons.check,
            size: 14,
            color: TatuColors.onlineTexto,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TatuColors.onlineTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// RN-212: "Confirmado" no lugar das bolinhas.
class _SeloConfirmado extends StatelessWidget {
  const _SeloConfirmado();

  @override
  Widget build(BuildContext context) => const _SeloEconomia('Confirmado');
}

/// RN-212: sem acordo, o plano não começou.
class _SemAcordo extends StatelessWidget {
  const _SemAcordo({required this.outro});

  final String outro;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const ShapeDecoration(
            color: TatuColors.surfaceGrouped,
            shape: StadiumBorder(),
          ),
          child: const Text(
            'Sem acordo · o plano não começou',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TatuColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Serviços avulsos com $outro continuam valendo.',
          textAlign: TextAlign.center,
          style: TatuTexto.legenda,
        ),
      ],
    );
  }
}
