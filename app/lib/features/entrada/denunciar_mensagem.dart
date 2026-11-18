import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/denuncias.dart';
import '../../shared/widgets/folha.dart';
import 'denunciar_arquivo.dart';

/// Opção do menu ao segurar uma mensagem.
enum AcaoMensagem { copiar, denunciar }

/// C135/P84 · RN-134: segurar uma mensagem de texto do outro. A tela
/// escurece, a mensagem fica em destaque e abre "Copiar" / "Denunciar
/// mensagem" logo abaixo dela. [alvo] é a chave do balão na conversa.
Future<AcaoMensagem?> menuMensagem(
  BuildContext context, {
  required GlobalKey alvo,
  required Widget balao,
}) {
  final caixa = alvo.currentContext?.findRenderObject() as RenderBox?;
  final rect = caixa == null
      ? Rect.zero
      : caixa.localToGlobal(Offset.zero) & caixa.size;
  return showGeneralDialog<AcaoMensagem>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: TatuColors.scrim,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, _, _) {
      final altura = MediaQuery.sizeOf(ctx).height;
      // Sem espaço embaixo, o menu abre acima da mensagem.
      final embaixo = rect.bottom + 10 + _MenuMensagem.altura < altura - 24;
      return Stack(
        children: [
          Positioned.fromRect(
            rect: rect,
            // Mesmo estilo de texto da conversa (a rota não tem Material).
            child: IgnorePointer(
              child: Material(type: MaterialType.transparency, child: balao),
            ),
          ),
          Positioned(
            left: rect.left,
            top: embaixo ? rect.bottom + 10 : null,
            bottom: embaixo ? null : altura - rect.top + 10,
            child: _MenuMensagem(
              onAcao: (a) => Navigator.of(ctx).pop(a),
            ),
          ),
        ],
      );
    },
  );
}

class _MenuMensagem extends StatelessWidget {
  const _MenuMensagem({required this.onAcao});

  final ValueChanged<AcaoMensagem> onAcao;

  static const largura = 250.0;
  static const altura = TatuMedidas.alturaLinha * 2;

  @override
  Widget build(BuildContext context) {
    Widget item(AcaoMensagem a, IconData icone, String texto, Color cor) =>
        InkWell(
          onTap: () => onAcao(a),
          child: SizedBox(
            height: TatuMedidas.alturaLinha,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(icone, size: 18, color: cor),
                  const SizedBox(width: 12),
                  Text(texto, style: TextStyle(fontSize: 16, color: cor)),
                ],
              ),
            ),
          ),
        );
    return Material(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: largura,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item(
              AcaoMensagem.copiar,
              TablerIcons.file_text,
              'Copiar',
              TatuColors.textPrimary,
            ),
            const Divider(
              height: 0.5,
              thickness: 0.5,
              color: TatuColors.tabBarLine,
            ),
            item(
              AcaoMensagem.denunciar,
              TablerIcons.alert_triangle,
              'Denunciar mensagem',
              TatuColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}

/// C136/P85 · RN-134: folha com os motivos. Devolve o motivo.
Future<String?> denunciarMensagem(
  BuildContext context, {
  required String nome,
  required bool feminino,
  String? motivo,
}) => mostrarFolha<String>(
  context,
  builder: (_) => FolhaMotivos(
    titulo: 'Denunciar mensagem',
    texto: 'A mensagem some da sua conversa e vai para o suporte.',
    motivos: motivosDenunciaMensagem,
    // RN-133: a denúncia nunca é mostrada para o denunciado.
    nota: 'Não mostramos a denúncia para ${feminino ? 'a' : 'o'} $nome.',
    botao: 'Denunciar mensagem',
    motivo: motivo,
  ),
);

/// RN-134: segurar a mensagem → menu → folha. "Copiar" copia e devolve
/// nulo; "Denunciar mensagem" devolve o motivo escolhido.
Future<String?> segurarMensagem(
  BuildContext context, {
  required GlobalKey alvo,
  required Widget balao,
  required String texto,
  required String nome,
  required bool feminino,
}) async {
  final acao = await menuMensagem(context, alvo: alvo, balao: balao);
  if (acao == null || !context.mounted) return null;
  if (acao == AcaoMensagem.copiar) {
    await Clipboard.setData(ClipboardData(text: texto));
    return null;
  }
  return denunciarMensagem(context, nome: nome, feminino: feminino);
}

/// C137/P86 · RN-134: no lugar da mensagem denunciada, só para quem
/// denunciou.
class MensagemDenunciada extends StatelessWidget {
  const MensagemDenunciada({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TatuMedidas.raioCampo + 4),
            border: Border.all(color: TatuColors.chevron, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                TablerIcons.alert_triangle,
                size: 16,
                color: TatuColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Mensagem denunciada · em análise',
                style: TatuTexto.nota,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: TatuMedidas.entreItens + 4),
      const Text(
        'O suporte vai analisar. Se precisar, use Denunciar no menu.',
        textAlign: TextAlign.center,
        style: TatuTexto.nota,
      ),
    ],
  );
}
