import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../data/prazos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../../entrada/seguranca.dart' show SeloAlertaAtivo;
import '../../profissional/cadastro/resultado_page.dart' show NomeVerificado;

/// C110–C113 · RN-165: depois do valor confirmado, a tela do pedido vira
/// o acompanhamento: "vai sair já" (prazo para sair, RN-76), a caminho
/// (mapa ao vivo, distância e previsão), chegando (menos de 2 min, com o
/// código) e chegou ("Passe o código", RN-39). O atraso (RN-78) aparece
/// no próprio mapa.
class AcompanharPedido extends StatelessWidget {
  const AcompanharPedido({
    super.key,
    required this.pedido,
    required this.etapa,
    required this.onMensagem,
    required this.onLigar,
    required this.onCancelar,
    this.atraso,
    this.onChamarOutro,
    this.onEsperar,
    this.direita,
  });

  final PedidoAndamento pedido;
  final EtapaAcompanhar etapa;
  final VoidCallback onMensagem;
  final VoidCallback onLigar;
  final VoidCallback onCancelar;

  /// RN-78: minutos de atraso (nulo = sem aviso).
  final int? atraso;
  final VoidCallback? onChamarOutro;
  final VoidCallback? onEsperar;

  /// Canto direito do topo (botão de segurança).
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _Mapa(pedido: p, etapa: etapa),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const _BotaoMapa(),
                      const Spacer(),
                      ?direita,
                    ],
                  ),
                  ListenableBuilder(
                    listenable: seguranca,
                    builder: (_, _) => seguranca.alertaCliente
                        ? const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Center(child: SeloAlertaAtivo()),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (atraso case final min?) ...[
                    const SizedBox(height: TatuMedidas.entreItens),
                    _CartaoAtraso(
                      pedido: p,
                      minutos: min,
                      onChamarOutro: onChamarOutro,
                      onEsperar: onEsperar,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: TatuMedidas.larguraMax,
              ),
              decoration: const BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(TatuMedidas.raioFolha),
                ),
              ),
              child: SafeArea(
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
                    children: _folha(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _folha(BuildContext context) {
    final p = pedido;
    final ela = p.profissao.endsWith('a');
    final codigo = etapa == EtapaAcompanhar.chegando ||
        etapa == EtapaAcompanhar.chegou;
    final (titulo, detalhe) = switch (etapa) {
      // RN-76: o prazo para sair.
      EtapaAcompanhar.antesDeSair when p.aindaNaoSaiu => (
        'Ainda não saiu',
        'Passou dos ${Prazos.estouACaminho.inMinutes} min para sair',
      ),
      EtapaAcompanhar.antesDeSair => (
        '${p.artigoNome} vai sair já',
        '${ela ? 'Ela' : 'Ele'} tem até ${Prazos.estouACaminho.inMinutes} '
            'min para sair · faltam ${p.minutosParaSair()} min',
      ),
      EtapaAcompanhar.aCaminho => (
        'Chega em ${p.minutosFaltando()} min',
        'A caminho · ${_km(p.kmFaltando())} km · '
            'previsão ${_hora(p.saiuEm!.add(Duration(minutes: p.minutosChegada)))}',
      ),
      EtapaAcompanhar.chegando => (
        '${p.artigoNome} está chegando',
        'Menos de ${RegrasAcompanhar.chegando.inMinutes} min',
      ),
      EtapaAcompanhar.chegou => (
        '${p.artigoNome} chegou',
        'Passe o código para ${ela ? 'ela' : 'ele'} começar o serviço',
      ),
    };
    return [
      const AlcaFolha(),
      const SizedBox(height: 16),
      Text(titulo, style: TatuTexto.tituloFolha),
      const SizedBox(height: 4),
      Text(detalhe, style: TatuTexto.nota),
      const SizedBox(height: TatuMedidas.entreItens + 4),
      if (codigo) ...[
        // RN-39: só o cliente vê o código.
        _CartaoCodigo(
          rotulo: etapa == EtapaAcompanhar.chegou
              ? 'Diga este código ${ela ? 'à' : 'ao'} ${p.primeiroNome}'
              : 'Código para passar ${ela ? 'à' : 'ao'} ${p.primeiroNome} '
                    'na porta',
          codigo: p.codigo,
        ),
        const SizedBox(height: TatuMedidas.entreItens + 4),
      ],
      _CartaoProfissional(
        pedido: p,
        onMensagem: onMensagem,
        onLigar: onLigar,
      ),
      if (!codigo) ...[
        const SizedBox(height: TatuMedidas.entreItens + 6),
        _CartaoEnderecoValor(pedido: p),
        const SizedBox(height: TatuMedidas.entreItens),
        Center(
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: TatuColors.danger),
            onPressed: onCancelar,
            child: const Text('Cancelar pedido'),
          ),
        ),
      ] else ...[
        const SizedBox(height: TatuMedidas.entreSecoes),
        Text(
          etapa == EtapaAcompanhar.chegou
              ? 'Quando ${ela ? 'ela' : 'ele'} digitar, o serviço '
                    'começa sozinho.'
              // RN-167: o código nunca vai por mensagem.
              : 'Só diga o código pessoalmente, nunca por mensagem.',
          textAlign: TextAlign.center,
          style: TatuTexto.legenda,
        ),
        const SizedBox(height: TatuMedidas.entreItens),
      ],
    ];
  }

  static String _km(double km) =>
      km.toStringAsFixed(1).replaceAll('.', ',');

  static String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

/// Botão branco redondo de voltar sobre o mapa.
class _BotaoMapa extends StatelessWidget {
  const _BotaoMapa();

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Voltar',
    child: Material(
      color: TatuColors.bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(TablerIcons.chevron_left, size: 20),
        ),
      ),
    ),
  );
}

/// RN-39: "Código para passar à Luiza na porta · 4 8 2 1".
class _CartaoCodigo extends StatelessWidget {
  const _CartaoCodigo({required this.rotulo, required this.codigo});

  final String rotulo;
  final String codigo;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo, style: TatuTexto.nota),
              const SizedBox(height: 2),
              Semantics(
                label: 'Código $codigo',
                excludeSemantics: true,
                child: Text(codigo.split('').join(' '), style: TatuTexto.codigo),
              ),
            ],
          ),
        ),
        const Icon(TablerIcons.shield_check, size: 24),
      ],
    ),
  );
}

/// Foto, nome verificado, nota e os botões Mensagem e Ligar (RN-140).
class _CartaoProfissional extends StatelessWidget {
  const _CartaoProfissional({
    required this.pedido,
    required this.onMensagem,
    required this.onLigar,
  });

  final PedidoAndamento pedido;
  final VoidCallback onMensagem;
  final VoidCallback onLigar;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AvatarIniciais(
        nome: pedido.profissional,
        tamanho: TatuMedidas.avatarAcompanhar,
      ),
      const SizedBox(width: TatuMedidas.entreItens),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NomeVerificado(pedido.profissional, tamanho: 16),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  TablerIcons.star_filled,
                  size: 12,
                  color: TatuColors.warning,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${pedido.nota} · ${pedido.profissao}',
                    overflow: TextOverflow.ellipsis,
                    style: TatuTexto.nota,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      _Circulo(
        icone: TablerIcons.message_circle,
        rotulo: 'Mensagem',
        onTap: onMensagem,
      ),
      const SizedBox(width: 6),
      _Circulo(icone: TablerIcons.phone, rotulo: 'Ligar', onTap: onLigar),
    ],
  );
}

class _Circulo extends StatelessWidget {
  const _Circulo({
    required this.icone,
    required this.rotulo,
    required this.onTap,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: rotulo,
    excludeSemantics: true,
    child: Material(
      color: TatuColors.fill,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: TatuMedidas.botaoCirculo,
          height: TatuMedidas.botaoCirculo,
          child: Icon(icone, size: 20),
        ),
      ),
    ),
  );
}

class _CartaoEnderecoValor extends StatelessWidget {
  const _CartaoEnderecoValor({required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            pedido.endereco,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pedido.valor,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

/// RN-78: atrasou o dobro do previsto: chamar outro sem pagar nada.
class _CartaoAtraso extends StatelessWidget {
  const _CartaoAtraso({
    required this.pedido,
    required this.minutos,
    this.onChamarOutro,
    this.onEsperar,
  });

  final PedidoAndamento pedido;
  final int minutos;
  final VoidCallback? onChamarOutro;
  final VoidCallback? onEsperar;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    final ela = p.profissao.endsWith('a');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        boxShadow: const [
          BoxShadow(color: TatuColors.sombra, blurRadius: 24, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconeCirculo(
                TablerIcons.clock,
                cor: TatuColors.warningTexto,
                fundo: TatuColors.warningSoft,
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Text(
                  '${p.artigoNome} está ${ela ? 'atrasada' : 'atrasado'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Era para chegar há $minutos minutos.\n'
            'Você pode chamar outro sem pagar nada.',
            style: TatuTexto.nota,
          ),
          const SizedBox(height: TatuMedidas.entreItens),
          FilledButton(
            onPressed: onChamarOutro,
            child: Text('Chamar outro ${p.servico.toLowerCase()}'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: onEsperar,
            child: const Text('Continuar esperando'),
          ),
        ],
      ),
    );
  }
}

/// Mapa com o destino (ponto preto) e o profissional (iniciais), conforme
/// a etapa. RN-166: a posição só aparece a caminho e na chegada.
class _Mapa extends StatelessWidget {
  const _Mapa({required this.pedido, required this.etapa});

  final PedidoAndamento pedido;
  final EtapaAcompanhar etapa;

  /// Rota do desenho (393 × 852), do profissional até o cliente.
  static Path rota(double sx, double sy) => Path()
    ..moveTo(120 * sx, 138 * sy)
    ..cubicTo(150 * sx, 190 * sy, 150 * sx, 240 * sy, 165 * sx, 300 * sy)
    ..cubicTo(185 * sx, 360 * sy, 255 * sx, 385 * sy, 262 * sx, 430 * sy);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final sx = c.maxWidth / 393;
      final sy = c.maxHeight / 852;
      Offset o(double x, double y) => Offset(x * sx, y * sy);
      final p = pedido;
      final (Offset destino, Offset? profissional) = switch (etapa) {
        EtapaAcompanhar.antesDeSair => (o(262, 430), null),
        EtapaAcompanhar.aCaminho => (o(262, 430), _naRota(sx, sy)),
        EtapaAcompanhar.chegando => (o(262, 358), o(236, 290)),
        EtapaAcompanhar.chegou => (o(262, 340), o(240, 328)),
      };
      final m = TatuMedidas.marcadorMapa;
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const MapaFalso(),
              foregroundPainter: _Desenho(
                etapa: etapa,
                destino: destino,
                profissional: profissional,
                rota: etapa == EtapaAcompanhar.aCaminho ? rota(sx, sy) : null,
              ),
            ),
          ),
          if (profissional != null) ...[
            if (etapa == EtapaAcompanhar.aCaminho)
              Positioned(
                left: profissional.dx - 44,
                top: profissional.dy - m / 2 - 40,
                width: 88,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: const ShapeDecoration(
                      color: TatuColors.action,
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      '${p.minutosFaltando()} min',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TatuColors.onAction,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: profissional.dx - m / 2,
              top: profissional.dy - m / 2,
              child: Container(
                width: m,
                height: m,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TatuColors.action,
                  shape: BoxShape.circle,
                  border: Border.all(color: TatuColors.bg, width: 2.5),
                ),
                child: Text(
                  iniciaisDe(p.profissional),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.onAction,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    },
  );

  /// Protótipo: a posição anda pela rota conforme o tempo previsto.
  Offset _naRota(double sx, double sy) {
    final previsto = pedido.minutosChegada * 60;
    final falta = pedido.faltaChegar().inSeconds;
    final andou = previsto <= 0 ? 1.0 : 1 - falta / previsto;
    final metrica = rota(sx, sy).computeMetrics().first;
    final t = 0.22 + 0.73 * andou.clamp(0.0, 1.0);
    return metrica.getTangentForOffset(metrica.length * t)!.position;
  }
}

class _Desenho extends CustomPainter {
  const _Desenho({
    required this.etapa,
    required this.destino,
    this.profissional,
    this.rota,
  });

  final EtapaAcompanhar etapa;
  final Offset destino;
  final Offset? profissional;
  final Path? rota;

  @override
  void paint(Canvas canvas, Size size) {
    final linha = Paint()
      ..color = TatuColors.action
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    // RN-76: antes de sair, só a área em volta do endereço.
    if (etapa == EtapaAcompanhar.antesDeSair) {
      for (final (r, a) in [(170.0, .10), (115.0, .14), (60.0, .22)]) {
        canvas.drawCircle(
          destino,
          r,
          Paint()..color = TatuColors.online.withValues(alpha: a),
        );
      }
    }
    if (rota case final r?) canvas.drawPath(r, linha);
    if (etapa == EtapaAcompanhar.chegando && profissional != null) {
      canvas.drawLine(profissional!, destino, linha);
    }
    canvas.drawCircle(destino, 13, Paint()..color = TatuColors.bg);
    canvas.drawCircle(destino, 10, Paint()..color = TatuColors.action);
  }

  @override
  bool shouldRepaint(_Desenho old) =>
      old.etapa != etapa ||
      old.destino != destino ||
      old.profissional != profissional;
}

/// C114 · RN-165: faixa da Home enquanto o profissional está a caminho:
/// "[nome] chega em X min"; o toque abre o mapa.
class FaixaACaminho extends StatefulWidget {
  const FaixaACaminho({super.key, required this.pedido, required this.onTap});

  final PedidoAndamento pedido;
  final VoidCallback onTap;

  @override
  State<FaixaACaminho> createState() => _FaixaACaminhoState();
}

class _FaixaACaminhoState extends State<FaixaACaminho> {
  late final Timer _relogio;

  @override
  void initState() {
    super.initState();
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      pedidos.avisarChegando();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _relogio.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    return Semantics(
      button: true,
      child: Material(
        color: TatuColors.action,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        child: InkWell(
          borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
            child: Row(
              children: [
                AvatarIniciais(nome: p.profissional, tamanho: 40),
                const SizedBox(width: TatuMedidas.entreItens),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.primeiroNome} chega em ${p.minutosFaltando()} min',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: TatuColors.onAction,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.profissao} · a caminho · ver no mapa',
                        overflow: TextOverflow.ellipsis,
                        style: TatuTexto.nota.copyWith(
                          color: TatuColors.avisoEscuroTexto,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  TablerIcons.chevron_right,
                  size: 18,
                  color: TatuColors.onAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
