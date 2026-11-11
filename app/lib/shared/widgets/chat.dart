import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';

/// Esqueleto das telas de chat: topo, lista de mensagens e rodapé
/// (barra de mensagem, aviso de conversa encerrada…).
class TelaChat extends StatelessWidget {
  const TelaChat({
    super.key,
    required this.topo,
    required this.mensagens,
    required this.rodape,
    this.rodapeColado = false,
  });

  final Widget topo;
  final List<Widget> mensagens;
  final Widget rodape;

  /// Rodapé de largura total, sem margens (ex.: "Esta conversa foi encerrada").
  final bool rodapeColado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
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
                        topo,
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        Expanded(child: ListView(children: mensagens)),
                      ],
                    ),
                  ),
                ),
                if (rodapeColado)
                  rodape
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                      TatuMedidas.margem,
                      TatuMedidas.entreItens,
                    ),
                    child: rodape,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Espaço antes de um balão: maior quando muda quem fala.
double espacoAntesDoBalao({
  required bool? anteriorMinha,
  required bool minha,
}) => anteriorMinha == null ? 0 : (anteriorMinha == minha ? 10 : 18);

/// Nota cinza centralizada no meio da conversa.
class NotaChat extends StatelessWidget {
  const NotaChat(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto, textAlign: TextAlign.center, style: TatuTexto.nota);
}

/// Cartão cinza com o pedido no topo da conversa.
class CartaoPedidoChat extends StatelessWidget {
  const CartaoPedidoChat({
    super.key,
    required this.servico,
    required this.descricao,
    required this.lado,
  });

  final String servico;
  final String descricao;

  /// Texto pequeno à direita (data ou rua).
  final String lado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido · $servico',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  overflow: TextOverflow.ellipsis,
                  style: TatuTexto.detalhe,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(lado, style: TatuTexto.nota),
        ],
      ),
    );
  }
}

/// Balão de mensagem: da pessoa (preto, à direita) ou do outro lado
/// (cinza, à esquerda). Pode ser uma foto e mostrar "Não enviada".
class BalaoChat extends StatelessWidget {
  const BalaoChat({
    super.key,
    this.texto,
    this.minha = false,
    this.foto = false,
    this.imagem,
    this.legenda,
    this.falhou = false,
    this.onTentarDeNovo,
  });

  final String? texto;
  final bool minha;
  final bool foto;
  final Uint8List? imagem;

  /// Linha pequena embaixo (ex.: "Enviada · 14:32").
  final String? legenda;
  final bool falhou;
  final VoidCallback? onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final raio = BorderRadius.circular(TatuMedidas.raioOpcao);
    final Widget balao = foto
        ? ClipRRect(
            borderRadius: raio,
            child: Container(
              width: largura * 0.46,
              height: largura * 0.33,
              color: TatuColors.fillStrong,
              child: imagem == null
                  ? const Icon(
                      TablerIcons.photo,
                      size: 36,
                      color: TatuColors.textSecondary,
                    )
                  : Image.memory(imagem!, fit: BoxFit.cover),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: largura * 0.86),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: minha ? TatuColors.action : TatuColors.fill,
                borderRadius: raio,
              ),
              child: Text(
                texto ?? '',
                style: TextStyle(
                  fontSize: 17,
                  height: 1.3,
                  color: minha ? TatuColors.onAction : TatuColors.textPrimary,
                ),
              ),
            ),
          );
    return Column(
      crossAxisAlignment: minha
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: minha
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (falhou) ...[
              const Icon(
                TablerIcons.alert_circle_filled,
                size: 22,
                color: TatuColors.danger,
                semanticLabel: 'Não enviada',
              ),
              const SizedBox(width: 8),
            ],
            Flexible(child: balao),
          ],
        ),
        if (falhou)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              onTap: onTentarDeNovo,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Não enviada · Tentar de novo',
                style: TatuTexto.nota.copyWith(color: TatuColors.danger),
              ),
            ),
          )
        else if (legenda != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(legenda!, style: TatuTexto.nota),
          ),
      ],
    );
  }
}

/// Barra embaixo do chat: câmera e campo "Mensagem".
class BarraMensagem extends StatelessWidget {
  const BarraMensagem({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.onCamera,
  });

  final TextEditingController controller;
  final VoidCallback onEnviar;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Enviar foto',
          child: Material(
            color: TatuColors.fill,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onCamera,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(TablerIcons.camera, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: TatuMedidas.alturaChip,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const ShapeDecoration(
              color: TatuColors.fill,
              shape: StadiumBorder(),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onEnviar(),
              textInputAction: TextInputAction.send,
              cursorColor: TatuColors.textPrimary,
              style: const TextStyle(fontSize: 17),
              decoration: const InputDecoration.collapsed(
                hintText: 'Mensagem',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: TatuColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Enviar (como no WhatsApp): preto quando há texto.
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final temTexto = controller.text.trim().isNotEmpty;
            return Semantics(
              button: true,
              label: 'Enviar mensagem',
              child: Material(
                color: temTexto ? TatuColors.action : TatuColors.fill,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: temTexto ? onEnviar : null,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      TablerIcons.send,
                      size: 18,
                      color: temTexto
                          ? TatuColors.onAction
                          : TatuColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
