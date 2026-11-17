import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../contato_oculto.dart';
import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import 'avatar_iniciais.dart';

/// Esqueleto das telas de chat: topo, lista de mensagens e rodapé
/// (barra de mensagem e botões).
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

  /// Rodapé de largura total, sem margens.
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
    this.rotulo = 'Pedido',
  });

  /// "Pedido" (cliente) ou "Chamado" (profissional).
  final String rotulo;
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
                  '$rotulo · $servico',
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
    this.ocultarContato = true,
    this.outro,
  });

  /// RN-85: contatos em mensagens recebidas aparecem como "contato oculto".
  final bool ocultarContato;

  /// "a Luiza", para a nota embaixo do contato oculto.
  final String? outro;

  final String? texto;
  final bool minha;
  final bool foto;
  final Uint8List? imagem;

  /// Linha pequena embaixo (ex.: "Enviada · 14:32").
  final String? legenda;
  final bool falhou;
  final VoidCallback? onTentarDeNovo;

  /// O texto com cada contato trocado pela pílula "contato oculto".
  TextSpan _textoComContato(List<TrechoContato> oculto) {
    final t = texto ?? '';
    if (oculto.isEmpty) return TextSpan(text: t);
    final partes = <InlineSpan>[];
    var i = 0;
    for (final c in oculto) {
      if (c.inicio > i) partes.add(TextSpan(text: t.substring(i, c.inicio)));
      partes.add(
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _PilulaOculta(),
        ),
      );
      i = c.fim;
    }
    if (i < t.length) partes.add(TextSpan(text: t.substring(i)));
    return TextSpan(children: partes);
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final raio = BorderRadius.circular(TatuMedidas.raioOpcao);
    // RN-85: só nas mensagens recebidas (as minhas nunca saem com contato).
    final oculto = !minha && !foto && ocultarContato && texto != null
        ? acharContatos(texto!)
        : const <TrechoContato>[];
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
              child: Text.rich(
                _textoComContato(oculto),
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
        if (oculto.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: TatuMedidas.entreItens + 4),
            child: _NotaContatoOculto(outro: outro),
          ),
      ],
    );
  }
}

/// Pílula cinza com cadeado no lugar de um contato (RN-85).
class _PilulaOculta extends StatelessWidget {
  const _PilulaOculta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: TatuColors.fill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            TablerIcons.lock,
            size: 15,
            color: TatuColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'contato oculto',
            style: TatuTexto.corpo.copyWith(
              fontWeight: FontWeight.w600,
              color: TatuColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão cinza embaixo de uma mensagem com contato oculto (RN-85).
class _NotaContatoOculto extends StatelessWidget {
  const _NotaContatoOculto({this.outro});

  final String? outro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        children: [
          const Icon(
            TablerIcons.shield_check,
            size: 22,
            color: TatuColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telefones e redes ficam ocultos.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  outro == null
                      ? 'Chame de novo pelo app, com garantia.'
                      : 'Chame $outro de novo pelo app, com garantia.',
                  style: TatuTexto.nota,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso amarelo acima do campo quando há contato no texto (RN-85).
class _AvisoContato extends StatelessWidget {
  const _AvisoContato({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.warningSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            TablerIcons.lock,
            size: 22,
            color: TatuColors.warningTexto,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TatuColors.warningTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: TatuTexto.nota.copyWith(
                    color: TatuColors.warningTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra embaixo do chat: câmera e campo "Mensagem". Com
/// [bloquearContato], telefone, e-mail, endereço, @ e links não são
/// enviados: a borda fica preta e aparece o aviso amarelo (RN-85).
class BarraMensagem extends StatelessWidget {
  const BarraMensagem({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.onCamera,
    this.bloquearContato = true,
    this.porQue = 'Pelo Tatu o serviço tem garantia.',
  });

  final TextEditingController controller;
  final VoidCallback onEnviar;
  final VoidCallback onCamera;
  final bool bloquearContato;

  /// Explicação no aviso (muda entre cliente e profissional).
  final String porQue;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final contato = bloquearContato
            ? contatoNoTexto(controller.text)
            : null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (contato != null) ...[
              _AvisoContato(
                titulo: contato.aviso,
                texto: contato == TipoContato.endereco
                    // RN-28: o endereço vai sozinho depois do valor.
                    ? 'O endereço vai pelo app depois que o valor é '
                          'confirmado.'
                    : porQue,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
            ],
            _linha(context, bloqueado: contato != null),
          ],
        );
      },
    );
  }

  Widget _linha(BuildContext context, {required bool bloqueado}) {
    void enviar() {
      if (!bloqueado) onEnviar();
    }

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
            decoration: ShapeDecoration(
              color: bloqueado ? TatuColors.bg : TatuColors.fill,
              shape: StadiumBorder(
                side: bloqueado
                    ? const BorderSide(color: TatuColors.action, width: 1.5)
                    : BorderSide.none,
              ),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => enviar(),
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
        // Enviar (como no WhatsApp): preto quando há texto que pode ir.
        Builder(
          builder: (context) {
            final temTexto = controller.text.trim().isNotEmpty && !bloqueado;
            return Semantics(
              button: true,
              label: 'Enviar mensagem',
              child: Material(
                color: temTexto ? TatuColors.action : TatuColors.fill,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: temTexto ? enviar : null,
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

/// RN-42: faixa verde "Serviço concluído · R$ 190,00 · 04 nov" no meio
/// da conversa, que continua aberta depois dela.
class MarcoConcluido extends StatelessWidget {
  const MarcoConcluido(this.texto, {super.key, this.nota = true});

  final String texto;

  /// Mostra embaixo "A conversa continua aberta…".
  final bool nota;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.onlineSoft,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: Row(
            children: [
              const Icon(
                TablerIcons.check,
                size: 20,
                color: TatuColors.onlineTexto,
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.onlineTexto,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (nota) ...[
          const SizedBox(height: TatuMedidas.entreItens),
          const NotaChat(
            'A conversa continua aberta. Precisou de novo, é só chamar por '
            'aqui.',
          ),
        ],
      ],
    );
  }
}

/// Separador de dia no meio da conversa ("12 nov").
class SeparadorDia extends StatelessWidget {
  const SeparadorDia(this.dia, {super.key});

  final String dia;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      dia,
      textAlign: TextAlign.center,
      style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

/// RN-96: arquivo enviado no chat (entrega à distância).
class BalaoArquivo extends StatelessWidget {
  const BalaoArquivo({
    super.key,
    required this.nome,
    required this.detalhe,
    this.minha = false,
  });

  final String nome;

  /// "PDF · 2,4 MB".
  final String detalhe;
  final bool minha;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.74,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TatuColors.bg,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCaixa),
                ),
                child: const Icon(TablerIcons.file_text, size: 22),
              ),
              const SizedBox(width: TatuMedidas.entreItens),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(detalhe, style: TatuTexto.nota),
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

/// Linha da lista de Mensagens: avatar, nome, última mensagem, hora,
/// contador de não lidas e um selo opcional (ex.: "Proposta 2 de 3").
class LinhaConversa extends StatelessWidget {
  const LinhaConversa({
    super.key,
    required this.nome,
    required this.iniciais,
    required this.ultima,
    required this.quando,
    required this.onTap,
    this.naoLidas = 0,
    this.online = false,
    this.selo,
  });

  final String nome;

  /// Nome usado para as iniciais do avatar.
  final String iniciais;
  final String ultima;
  final String quando;
  final int naoLidas;
  final bool online;
  final Widget? selo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final naoLida = naoLidas > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: TatuMedidas.margem),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarIniciais(nome: iniciais, tamanho: 48),
                if (online)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: TatuColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: TatuColors.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  14,
                  TatuMedidas.margem,
                  14,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TatuColors.trilho, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ultima,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TatuTexto.detalhe.copyWith(
                              color: naoLida
                                  ? TatuColors.textPrimary
                                  : TatuColors.textSecondary,
                            ),
                          ),
                          if (selo != null) ...[
                            const SizedBox(height: 6),
                            selo!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(quando, style: TatuTexto.nota),
                        const SizedBox(height: 6),
                        if (naoLida)
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: TatuColors.action,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$naoLidas',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TatuColors.onAction,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
