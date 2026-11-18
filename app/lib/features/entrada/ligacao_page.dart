import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../data/ligacao.dart';
import '../../shared/widgets/avatar_iniciais.dart';

/// RN-140: abre a ligação pelo Tatu com [nome] (nunca o número).
Future<void> ligarPeloTatu(
  BuildContext context,
  String nome, {
  bool profissional = false,
}) {
  ligacao.ligar(nome);
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => LigacaoPage(nome: nome, profissional: profissional),
    ),
  );
}

/// C105/P32 · Ligação pelo app (RN-140): mostra só o nome; o número de
/// ninguém aparece.
class LigacaoPage extends StatefulWidget {
  const LigacaoPage({super.key, required this.nome, this.profissional = false});

  final String nome;

  /// Texto do profissional ("até você concluir o serviço").
  final bool profissional;

  @override
  State<LigacaoPage> createState() => _LigacaoPageState();
}

class _LigacaoPageState extends State<LigacaoPage> {
  bool _mudo = false;
  bool _vivaVoz = false;

  Future<void> _desligar() async {
    await ligacao.desligar();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget botao(String rotulo, IconData icone, bool ligado, VoidCallback onTap) =>
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              toggled: ligado,
              label: rotulo,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ligado ? TatuColors.bg : TatuColors.ligacaoBotao,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icone,
                    size: 24,
                    color: ligado ? TatuColors.action : TatuColors.onAction,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              rotulo,
              style: const TextStyle(
                fontSize: 12,
                color: TatuColors.avisoEscuroTexto,
              ),
            ),
          ],
        );
    return Scaffold(
      backgroundColor: TatuColors.avisoEscuro,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 150),
            AvatarIniciais(nome: widget.nome, tamanho: 112),
            const SizedBox(height: 26),
            Text(
              widget.nome,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: TatuColors.onAction,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chamando pelo Tatu…',
              style: TextStyle(
                fontSize: 16,
                color: TatuColors.avisoEscuroTexto,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: TatuColors.editorFundo,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    TablerIcons.lock,
                    size: 14,
                    color: TatuColors.avisoEscuroTexto,
                  ),
                  SizedBox(width: 30),
                  Text(
                    'Seu número não aparece',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: TatuColors.avisoEscuroTexto,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.profissional
                  ? 'Disponível até você concluir o serviço.'
                  : 'Disponível até o serviço ser concluído.',
              style: const TextStyle(
                fontSize: 13,
                color: TatuColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botao('Mudo', TablerIcons.microphone, _mudo, () {
                  setState(() => _mudo = !_mudo);
                  ligacao.mudo(_mudo);
                }),
                const SizedBox(width: 76),
                botao('Viva-voz', TablerIcons.phone, _vivaVoz, () {
                  setState(() => _vivaVoz = !_vivaVoz);
                  ligacao.vivaVoz(_vivaVoz);
                }),
              ],
            ),
            const SizedBox(height: 32),
            Semantics(
              button: true,
              label: 'Desligar',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: _desligar,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: TatuColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    TablerIcons.phone_off,
                    size: 26,
                    color: TatuColors.onAction,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TatuMedidas.base + 20),
          ],
        ),
      ),
    );
  }
}

/// RN-140: botão de ligar no topo do chat (só quando liberado).
class BotaoLigar extends StatelessWidget {
  const BotaoLigar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Ligar pelo Tatu',
    excludeSemantics: true,
    child: IconButton(
      onPressed: onTap,
      icon: const Icon(TablerIcons.phone, size: 22),
    ),
  );
}

/// C104/P31 · RN-140: balão preto apontando para o telefone, quando o
/// valor é confirmado. Toque fecha.
class BalaoLigarLiberado extends StatelessWidget {
  const BalaoLigarLiberado({super.key, required this.onFechar});

  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onFechar,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: CustomPaint(
            size: const Size(14, 8),
            painter: _Ponta(),
          ),
        ),
        Container(
          width: 232,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: TatuColors.avisoEscuro,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agora dá para ligar pelo Tatu.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.onAction,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Seu número não aparece.',
                style: TextStyle(
                  fontSize: 12,
                  color: TatuColors.avisoEscuroTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Ponta extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = TatuColors.avisoEscuro,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
