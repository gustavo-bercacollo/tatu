import '../../data/retorno.dart' show DecisaoAutomatica;
import '../../shared/widgets/retorno.dart' show CartaoDecisaoTatu, PedirRevisao;
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/canal_tatu.dart';
import '../../shared/widgets/back_circle_button.dart';
import '../../shared/widgets/chat.dart';
import '../../shared/widgets/tela_interna.dart';

const _meses = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

bool _mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "02 nov".
String _dia(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_meses[d.month - 1]}';

/// Hora na lista: "agora", "10:02" (hoje) ou "02 nov".
String quandoTatu(DateTime em, [DateTime? agora]) {
  final hoje = agora ?? clock.now();
  if (!_mesmoDia(em, hoje)) return _dia(em);
  if (hoje.difference(em).inMinutes < 1) return 'agora';
  return '${em.hour.toString().padLeft(2, '0')}:'
      '${em.minute.toString().padLeft(2, '0')}';
}

/// Avatar do Tatu: círculo preto com "T".
class AvatarTatu extends StatelessWidget {
  const AvatarTatu({super.key, this.tamanho = 48});

  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: TatuColors.action,
      shape: BoxShape.circle,
    ),
    child: Text(
      'T',
      style: TextStyle(
        fontSize: tamanho * 0.5,
        fontWeight: FontWeight.w800,
        color: TatuColors.onAction,
      ),
    ),
  );
}

/// "Tatu ✓" (selo de verificado, RN-115).
class _NomeTatu extends StatelessWidget {
  const _NomeTatu({this.fixada = false});

  final bool fixada;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Tatu',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      const SizedBox(width: 4),
      const Icon(
        TablerIcons.rosette_discount_check_filled,
        size: 18,
        color: TatuColors.verified,
        semanticLabel: 'Verificado',
      ),
      if (fixada) ...[
        const SizedBox(width: 4),
        const Text('· Fixada', style: TatuTexto.nota),
      ],
    ],
  );
}

/// RN-115: conversa do Tatu fixada no topo de Mensagens (não apaga).
class LinhaCanalTatu extends StatelessWidget {
  const LinhaCanalTatu({super.key, required this.canal, required this.onTap});

  final CanalTatu canal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: canal,
    builder: (_, _) {
      final u = canal.ultima;
      return LinhaConversa(
        nome: 'Tatu',
        iniciais: 'Tatu',
        avatar: const AvatarTatu(),
        titulo: const _NomeTatu(fixada: true),
        ultima: u?.resumo ?? '',
        quando: u == null ? '' : quandoTatu(u.em),
        naoLidas: canal.naoLidas,
        onTap: onTap,
      );
    },
  );
}

/// C124/C125/P75 · Canal oficial do Tatu (RN-115 a RN-117): só o Tatu
/// envia. Mensagens antigas aparecem resumidas ("+ 2 mensagens").
class CanalTatuPage extends StatefulWidget {
  const CanalTatuPage({
    super.key,
    required this.canal,
    required this.onDestino,
  });

  final CanalTatu canal;

  /// Abre o destino de um botão ou link ([DestinoTatu]).
  final void Function(BuildContext context, String destino) onDestino;

  @override
  State<CanalTatuPage> createState() => _CanalTatuPageState();
}

class _CanalTatuPageState extends State<CanalTatuPage> {
  final _abertas = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.canal.marcarLido(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.canal,
      builder: (context, _) {
        final msgs = widget.canal.mensagens;
        final hoje = clock.now();
        final itens = <Widget>[];
        for (var i = 0; i < msgs.length; i++) {
          final m = msgs[i];
          if (i == 0 || !_mesmoDia(msgs[i - 1].em, m.em)) {
            itens
              ..add(const SizedBox(height: TatuMedidas.entreItens))
              ..add(SeparadorDia(_mesmoDia(m.em, hoje) ? 'Hoje' : _dia(m.em)))
              ..add(const SizedBox(height: TatuMedidas.entreItens));
          }
          final resumida = i < msgs.length - 1 && !_abertas.contains(m.id);
          itens.add(_mensagem(context, m, resumida: resumida));
        }
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    TatuMedidas.topo,
                    TatuMedidas.margem,
                    0,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: BackCircleButton(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AvatarTatu(tamanho: 34),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _NomeTatu(),
                                Text(
                                  'Canal oficial',
                                  style: TatuTexto.nota.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                      TatuMedidas.margem,
                      TatuMedidas.entreSecoes,
                    ),
                    children: itens,
                  ),
                ),
                // RN-117: só o Tatu envia; suporte continua na Ajuda.
                Container(
                  color: TatuColors.surfaceGrouped,
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    22,
                    TatuMedidas.margem,
                    22,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Text(
                      'Só o Tatu envia mensagens neste canal.',
                      textAlign: TextAlign.center,
                      style: TatuTexto.nota,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mensagem(
    BuildContext context,
    MensagemTatu m, {
    required bool resumida,
  }) {
    if (m.titulo != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _Novidade(
          mensagem: m,
          onLink: m.link == null
              ? null
              : () => widget.onDestino(context, m.link!.destino),
        ),
      );
    }
    final partes = <Widget>[_Balao(m.texto)];
    if (resumida) {
      final mais = m.baloes - 1;
      if (mais > 0) {
        partes.add(
          GestureDetector(
            onTap: () => setState(() => _abertas.add(m.id)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Text(
                '+ $mais ${mais == 1 ? 'mensagem' : 'mensagens'}',
                style: TatuTexto.nota.copyWith(fontSize: 12),
              ),
            ),
          ),
        );
      }
    } else {
      final c = m.cartao;
      if (c != null) {
        if (c.introducao != null) partes.add(_Balao(c.introducao!));
        partes.add(
          _CartaoDicas(
            cartao: c,
            onTap: () => widget.onDestino(context, c.link),
          ),
        );
      }
      // RN-191: a decisão do Tatu sobre um retorno.
      if (m.decisao case final d?) {
        partes.add(
          CartaoDecisaoTatu(
            titulo: d.titulo,
            texto: d.texto,
            rodape: d.rodape,
            rodapeAviso: d.rodapeAviso,
            cabecalho: d.automatica
                ? 'Resolvido automaticamente'
                : 'Decisão do Tatu',
            // P157 · RN-198: só a decisão automática pode ser revista.
            revisao: d.automatica && d.revisaoEm != null
                ? PedirRevisao(
                    decisao: DecisaoAutomatica.falta,
                    quem: d.revisaoQuem ?? '',
                    decididoEm: d.revisaoEm!,
                    servico: d.revisaoServico,
                    texto: 'Pedir revisão',
                  )
                : null,
          ),
        );
      }
      if (m.textoDepois != null) partes.add(_Balao(m.textoDepois!));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in partes) ...[p, const SizedBox(height: 10)],
      ],
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: 0.78,
    alignment: Alignment.centerLeft,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: TatuColors.fill,
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 15, height: 1.35)),
      ),
    ),
  );
}

/// RN-118: cartão "Dicas Tatu · Ver dicas".
class _CartaoDicas extends StatelessWidget {
  const _CartaoDicas({required this.cartao, required this.onTap});

  final CartaoTatu cartao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: 0.78,
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        border: Border.all(color: TatuColors.fillStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TatuColors.fill,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
                ),
                child: const Icon(TablerIcons.sparkles, size: 22),
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartao.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cartao.detalhe != null)
                      Text(cartao.detalhe!, style: TatuTexto.nota),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TatuMedidas.entreItens + 2),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: onTap,
            child: Text(cartao.botao),
          ),
        ],
      ),
    ),
  );
}

/// C125 · Novidade: faixa escura com o título e o texto embaixo.
class _Novidade extends StatelessWidget {
  const _Novidade({required this.mensagem, required this.onLink});

  final MensagemTatu mensagem;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final m = mensagem;
    return FractionallySizedBox(
      widthFactor: 0.78,
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: TatuColors.action,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    TablerIcons.sparkles,
                    size: 24,
                    color: TatuColors.onAction,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    m.titulo!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.avisoEscuroTexto,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: TatuColors.fill,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (m.destaque != null)
                    Text(
                      m.destaque!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(m.texto, style: const TextStyle(fontSize: 15)),
                  if (m.link != null) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onLink,
                      child: Text(
                        m.link!.texto,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TatuColors.verified,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// C126 · Dicas Tatu: por enquanto "Em breve" (RN-118).
class DicasTatuPage extends StatelessWidget {
  const DicasTatuPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icone, String titulo, String detalhe) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          Icon(icone, size: 22, color: TatuColors.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.textSecondary,
                  ),
                ),
                Text(detalhe, style: TatuTexto.nota),
              ],
            ),
          ),
          Text('em breve', style: TatuTexto.nota.copyWith(fontSize: 12)),
        ],
      ),
    );
    return TelaInterna(
      titulo: 'Dicas Tatu',
      fundoCinza: true,
      corpo: ListView(
        padding: const EdgeInsets.only(
          top: TatuMedidas.entreSecoes + 16,
          bottom: TatuMedidas.base,
        ),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: TatuColors.bg,
                shape: BoxShape.circle,
              ),
              child: const Icon(TablerIcons.sparkles, size: 36),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          const Text(
            'Em breve',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dicas para uma boa convivência\ne boas negociações no Tatu.',
            textAlign: TextAlign.center,
            style: TatuTexto.detalhe,
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          item(
            TablerIcons.users,
            'Boa convivência',
            'Na casa do cliente e no chat',
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          item(
            TablerIcons.wallet,
            'Boa negociação',
            'Como combinar o valor certo',
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          item(
            TablerIcons.shield_check,
            'Segurança',
            'Cuidados antes, durante e depois',
          ),
          const SizedBox(height: TatuMedidas.entreSecoes + 8),
          const Text(
            'Avisamos pelo chat do Tatu quando abrir.',
            textAlign: TextAlign.center,
            style: TatuTexto.nota,
          ),
        ],
      ),
    );
  }
}
