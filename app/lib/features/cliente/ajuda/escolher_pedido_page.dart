import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/ajuda.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'chat_suporte_page.dart';
import '../../../shared/widgets/icone_profissao.dart';

/// Falar com o suporte · "Qual pedido?": escolhe um pedido recente.
class EscolherPedidoPage extends StatefulWidget {
  const EscolherPedidoPage({super.key, this.conteudo = conteudoCliente});

  final ConteudoAjuda conteudo;

  @override
  State<EscolherPedidoPage> createState() => _EscolherPedidoPageState();
}

class _EscolherPedidoPageState extends State<EscolherPedidoPage> {
  int _escolhido = 0;

  void _abrirChat([PedidoRecente? pedido]) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          ChatSuportePage(pedido: pedido, conteudo: widget.conteudo),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: widget.conteudo.tituloRecentes,
      subtitulo: 'Os mais recentes aparecem primeiro.',
      botao: 'Continuar',
      onBotao: () => _abrirChat(widget.conteudo.recentes[_escolhido]),
      children: [
        for (final (i, p) in widget.conteudo.recentes.indexed) ...[
          OpcaoSelecionavel(
            selecionado: i == _escolhido,
            rotulo: p.tituloLista,
            onTap: () => setState(() => _escolhido = i),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (p.iniciais != null)
                    AvatarIniciais(nome: p.iniciais!, tamanho: 40)
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: TatuColors.bg,
                        shape: BoxShape.circle,
                      ),
                      // RN-227: o ícone da profissão.
                      child: p.icone == null
                          ? IconeProfissao(p.servico, tamanho: 20)
                          : Icon(p.icone, size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.tituloLista,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(p.quando, style: TatuTexto.nota),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(p.resumo, style: TatuTexto.detalhe),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens),
        ],
        const SizedBox(height: 4),
        Center(
          child: LinkAzul(
            widget.conteudo.semRecente,
            onTap: () => _abrirChat(),
          ),
        ),
      ],
    );
  }
}
