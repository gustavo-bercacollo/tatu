import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../shared/widgets/back_circle_button.dart';
import 'canal_tatu_page.dart';

/// RN-132: nome que aparece no lugar de uma conta suspensa.
const contaIndisponivel = 'Conta indisponível';

/// C163/P60 · Topo do chat encerrado pelo Tatu (RN-132): ícone de
/// pessoa e "Conta indisponível" em cinza, sem ligar nem opções.
class TopoContaIndisponivel extends StatelessWidget {
  const TopoContaIndisponivel({super.key, required this.detalhe});

  /// "Encanador" (cliente) ou "Cliente" (profissional).
  final String detalhe;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const BackCircleButton(),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AvatarIndisponivel(),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    contaIndisponivel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.textSecondary,
                    ),
                  ),
                  Text(detalhe, style: TatuTexto.nota),
                ],
              ),
            ),
          ],
        ),
      ),
      // Equilibra o botão de voltar para o nome ficar no centro.
      const SizedBox(width: 44),
    ],
  );
}

/// RN-132: avatar de conta suspensa (ícone de pessoa cinza).
class AvatarIndisponivel extends StatelessWidget {
  const AvatarIndisponivel({super.key, this.tamanho = 32});

  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    decoration: const BoxDecoration(
      color: TatuColors.circle,
      shape: BoxShape.circle,
    ),
    child: Icon(
      TablerIcons.user,
      size: tamanho * 0.56,
      color: TatuColors.textSecondary,
    ),
  );
}

/// RN-130/RN-131: mensagem do Tatu dentro do chat, com botão opcional.
class CartaoTatuChat extends StatelessWidget {
  const CartaoTatuChat({
    super.key,
    required this.texto,
    this.botao,
    this.onBotao,
  });

  final String texto;
  final String? botao;
  final VoidCallback? onBotao;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.surfaceGrouped,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            AvatarTatu(tamanho: 24),
            SizedBox(width: 8),
            Text(
              'Tatu',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 4),
            Icon(
              TablerIcons.rosette_discount_check_filled,
              size: 14,
              color: TatuColors.verified,
              semanticLabel: 'Verificado',
            ),
          ],
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        Text(
          texto,
          style: TatuTexto.corpo.copyWith(color: TatuColors.textPrimary),
        ),
        if (botao != null) ...[
          const SizedBox(height: 18),
          SizedBox(
            height: TatuMedidas.alturaBotaoCartao,
            child: FilledButton(
              onPressed: onBotao,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  TatuMedidas.alturaBotaoCartao,
                ),
              ),
              child: Text(botao!),
            ),
          ),
        ],
      ],
    ),
  );
}

/// RN-132: no lugar da barra de mensagem, só leitura.
class RodapeConversaEncerrada extends StatelessWidget {
  const RodapeConversaEncerrada({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: TatuColors.surfaceGrouped,
    padding: const EdgeInsets.fromLTRB(
      TatuMedidas.margem,
      30,
      TatuMedidas.margem,
      40,
    ),
    child: const Text(
      'Esta conversa foi encerrada.',
      textAlign: TextAlign.center,
      style: TatuTexto.nota,
    ),
  );
}
