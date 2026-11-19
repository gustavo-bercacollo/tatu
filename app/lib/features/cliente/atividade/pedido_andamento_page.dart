import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../entrada/seguranca.dart';
import '../chamar/procurando_page.dart';
import '../mensagens/chat_page.dart';
import 'acompanhar.dart';
import 'na_porta_page.dart' show mostrarAusencia;
import 'pedido_cancelado_page.dart';
import '../../entrada/ligacao_page.dart';
import '../../../data/ligacao.dart';

/// Pedido em andamento: profissional, etapas, dados e "Cancelar pedido".
/// RN-165: do valor confirmado até o código, vira o acompanhamento no
/// mapa ([AcompanharPedido]). Mostra também quando o profissional não
/// aparece: "Ainda não saiu" (RN-76), a volta à busca (RN-77) e o aviso
/// de atraso no mapa (RN-78).
class PedidoAndamentoPage extends StatefulWidget {
  const PedidoAndamentoPage({super.key});

  @override
  State<PedidoAndamentoPage> createState() => _PedidoAndamentoPageState();
}

class _PedidoAndamentoPageState extends State<PedidoAndamentoPage> {
  Timer? _relogio;

  @override
  void initState() {
    super.initState();
    pedidos.addListener(_mudou);
    // RN-165/RN-78: o mapa, a previsão e o atraso andam com o relógio.
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      pedidos.avisarChegando();
      setState(() {});
    });
  }

  @override
  void dispose() {
    pedidos.removeListener(_mudou);
    _relogio?.cancel();
    super.dispose();
  }

  /// RN-77: o pedido voltou à busca; abre a busca com o aviso.
  void _mudou() {
    // RN-81: o cliente não apareceu (se a porta não estiver aberta por cima).
    if (mounted &&
        pedidos.ausente != null &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      return mostrarAusencia(context);
    }
    final d = pedidos.devolvido;
    if (!mounted || d == null || pedidos.andamento != null) return;
    pedidos.consumirDevolvido();
    final busca = pedidos.busca;
    pedidos.cancelarBusca(); // a tela de busca assume daqui
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProcurandoPage(
          servico: busca?.servico ?? d.servico,
          endereco: busca?.endereco ?? d.endereco,
          anterior: d,
          troca: TrocaProfissional.naoConfirmou,
        ),
      ),
    );
  }

  /// RN-78: passou do dobro do tempo previsto; pode chamar outro sem
  /// pagar nada, nem a visita.
  void _chamarOutro(PedidoAndamento p) {
    // RN-78: troca sem custo (nem a visita).
    pedidos.cancelarAndamento();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProcurandoPage(
          servico: p.servico,
          endereco: p.endereco,
          anterior: p,
          troca: TrocaProfissional.atrasou,
        ),
      ),
    );
  }

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
    return ListenableBuilder(
      listenable: pedidos,
      builder: (context, _) {
        final p = pedidos.andamento;
        final etapa = p?.acompanhar();
        final tela = p != null && etapa != null
            ? _acompanhar(context, p, etapa)
            : _tela(context, p);
        if (p == null || !p.aindaNaoSaiu) return tela;
        // RN-76: aviso fixo no topo enquanto o profissional não sai.
        return Stack(
          children: [
            tela,
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  TatuMedidas.margem,
                  8,
                  TatuMedidas.margem,
                  0,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    type: MaterialType.transparency,
                    child: AvisoEscuro(
                      icone: const CircleAvatar(
                        radius: 16,
                        backgroundColor: TatuColors.warning,
                        child: Icon(
                          TablerIcons.clock,
                          size: 18,
                          color: TatuColors.onAction,
                        ),
                      ),
                      titulo: '${p.artigoNome} ainda não saiu',
                      texto:
                          'Perguntamos se ${p.profissao.endsWith('a') ? 'ela' : 'ele'} '
                          'ainda vem.',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mensagem() {
    final c = conversas.emAndamento.firstOrNull;
    if (c == null) return;
    conversas.marcarLida(c);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatPage(conversa: c)),
    );
  }

  /// RN-165: acompanhamento no mapa até o código ser digitado.
  Widget _acompanhar(
    BuildContext context,
    PedidoAndamento p,
    EtapaAcompanhar etapa,
  ) {
    final atraso = pedidos.minutosDeAtraso();
    return AcompanharPedido(
      pedido: p,
      etapa: etapa,
      direita: BotaoEscudo(servico: Atendimento.doPedido(p)),
      onMensagem: _mensagem,
      // RN-140: ligar pelo app do valor confirmado até concluir.
      onLigar: () => ligarPeloTatu(context, p.profissional),
      onCancelar: () => _cancelar(context, p),
      // RN-78: o aviso de atraso fica no próprio mapa.
      atraso: p.esperandoAtraso ? null : atraso,
      onChamarOutro: () => _chamarOutro(p),
      onEsperar: pedidos.esperarAtrasado,
    );
  }

  Widget _tela(BuildContext context, PedidoAndamento? p) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));
    return TelaInterna(
      titulo: 'Pedido',
      fundoCinza: true,
      // RN-98: à distância não tem botão de segurança.
      direita: p == null || p.distancia
          ? null
          : BotaoEscudo(servico: Atendimento.doPedido(p)),
      corpo: p == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(
                vertical: TatuMedidas.entreSecoes,
              ),
              children: [
                ListenableBuilder(
                  listenable: seguranca,
                  builder: (_, _) => seguranca.alertaCliente
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Center(child: SeloAlertaAtivo()),
                        )
                      : const SizedBox.shrink(),
                ),
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
                          // RN-76: selo laranja enquanto não sai.
                          p.aindaNaoSaiu
                              ? const SeloVerde('Ainda não saiu', aviso: true)
                              : SeloVerde(p.situacao),
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
                          // RN-140: ligar só do valor confirmado até
                          // o serviço ser concluído.
                          if (!p.distancia &&
                              RegrasLigacao.disponivel(
                                valorConfirmado: p.etapasFeitas >= 2,
                                concluido: p.etapasFeitas >= 5,
                              )) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BotaoContato(
                                icone: TablerIcons.phone,
                                texto: 'Ligar',
                                onTap: () =>
                                    ligarPeloTatu(context, p.profissional),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                _CartaoBranco(
                  child: LinhaDoTempo(
                    etapas: p.etapas,
                    feitas: p.etapasFeitas,
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                GrupoCartao(
                  linhas: [
                    // RN-93: à distância, o endereço não conta.
                    if (p.distancia)
                      const LinhaRotuloValor(
                        rotulo: 'Atendimento',
                        valor: 'À distância',
                      )
                    else
                      LinhaRotuloValor(rotulo: 'Endereço', valor: p.endereco),
                    LinhaRotuloValor(rotulo: 'Valor combinado', valor: p.valor),
                    // RN-103: à distância com sinal, mostra o sinal pago.
                    if (p.distancia && p.sinal > 0)
                      LinhaRotuloValor(
                        rotulo: 'Sinal pago',
                        valor: reais(p.sinal),
                      )
                    else
                      LinhaRotuloValor(
                        rotulo: 'Pagamento',
                        valor: p.pagamento,
                      ),
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
