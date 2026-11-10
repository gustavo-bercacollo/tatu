import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../mensagens/chat_page.dart';
import 'pedido_cancelado_page.dart';

/// Pedido em andamento: profissional, etapas, dados e "Cancelar pedido".
class PedidoAndamentoPage extends StatelessWidget {
  const PedidoAndamentoPage({super.key});

  Future<void> _cancelar(BuildContext context, PedidoAndamento p) async {
    final sim = await confirmar(
      context,
      titulo: 'Cancelar pedido?',
      texto: p.etapasFeitas >= 3
          ? 'A ${p.primeiroNome} já está a caminho e será avisada.'
          : 'A ${p.primeiroNome} será avisada.',
      confirmar: 'Cancelar pedido',
      cancelar: 'Manter pedido',
      perigo: true,
    );
    if (!sim || !context.mounted) return;
    pedidos.cancelarAndamento();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PedidoCanceladoPage(profissional: p.primeiroNome),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = pedidos.andamento;
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));
    return TelaInterna(
      titulo: 'Pedido',
      fundoCinza: true,
      corpo: p == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(
                vertical: TatuMedidas.entreSecoes,
              ),
              children: [
                _CartaoBranco(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AvatarIniciais(nome: p.profissional, tamanho: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.profissional,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${p.profissao} · ${p.nota}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TatuTexto.nota,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      TablerIcons.star_filled,
                                      size: 13,
                                      color: TatuColors.warning,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SeloVerde(p.situacao),
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      Row(
                        children: [
                          Expanded(
                            child: _BotaoContato(
                              icone: TablerIcons.message_circle,
                              texto: 'Mensagem',
                              onTap: () {
                                final c = conversas.emAndamento.firstOrNull;
                                if (c == null) return emBreve('Mensagem');
                                conversas.marcarLida(c);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(conversa: c),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _BotaoContato(
                              icone: TablerIcons.phone,
                              texto: 'Ligar',
                              onTap: () => emBreve('Ligar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                _CartaoBranco(
                  child: LinhaDoTempo(
                    etapas: etapasPedido,
                    feitas: p.etapasFeitas,
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                GrupoCartao(
                  linhas: [
                    LinhaRotuloValor(rotulo: 'Endereço', valor: p.endereco),
                    LinhaRotuloValor(rotulo: 'Valor combinado', valor: p.valor),
                    LinhaRotuloValor(rotulo: 'Pagamento', valor: p.pagamento),
                  ],
                ),
                const SizedBox(height: TatuMedidas.entreSecoes),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: TatuColors.danger,
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () => _cancelar(context, p),
                    child: const Text('Cancelar pedido'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartaoBranco extends StatelessWidget {
  const _CartaoBranco({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      ),
      child: child,
    );
  }
}

class _BotaoContato extends StatelessWidget {
  const _BotaoContato({
    required this.icone,
    required this.texto,
    required this.onTap,
  });

  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.fill,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
