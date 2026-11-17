import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../data/pedidos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../entrada/seguranca.dart';
import '../chamar/procurando_page.dart';
import '../mensagens/chat_page.dart';
import 'na_porta_page.dart';
import 'pedido_cancelado_page.dart';

/// Pedido em andamento: profissional, etapas, dados e "Cancelar pedido".
/// Mostra também quando o profissional não aparece: "Ainda não saiu"
/// (RN-76), a volta à busca (RN-77) e o aviso de atraso (RN-78).
class PedidoAndamentoPage extends StatefulWidget {
  const PedidoAndamentoPage({super.key});

  @override
  State<PedidoAndamentoPage> createState() => _PedidoAndamentoPageState();
}

class _PedidoAndamentoPageState extends State<PedidoAndamentoPage> {
  Timer? _relogio;
  bool _perguntouAtraso = false;
  bool _mostrouPorta = false;

  @override
  void initState() {
    super.initState();
    pedidos.addListener(_mudou);
    // RN-78: confere o atraso enquanto a tela está aberta.
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) => _atraso());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atraso();
      _porta();
    });
  }

  /// RN-80: o profissional chegou: abre a tela da porta (uma vez).
  void _porta() {
    final p = pedidos.andamento;
    if (!mounted || p == null || !p.naPorta || _mostrouPorta) return;
    _mostrouPorta = true;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const NaPortaPage()));
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
    _porta();
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
  Future<void> _atraso() async {
    final p = pedidos.andamento;
    final min = pedidos.minutosDeAtraso();
    if (!mounted || p == null || min == null) return;
    if (p.esperandoAtraso || _perguntouAtraso) return;
    _perguntouAtraso = true;
    final ela = p.profissao.endsWith('a');
    final outro = await confirmar(
      context,
      titulo: '${p.artigoNome} está ${ela ? 'atrasada' : 'atrasado'}',
      texto:
          'Era para chegar há $min minutos.\n'
          'Você pode chamar outro sem pagar nada.',
      confirmar: 'Chamar outro ${p.servico.toLowerCase()}',
      cancelar: 'Continuar esperando',
      iconeAviso: false,
    );
    if (!mounted) return;
    if (!outro) {
      pedidos.esperarAtrasado();
      return;
    }
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
        final tela = _tela(context, p);
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
                          if (!p.distancia) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BotaoContato(
                                icone: TablerIcons.phone,
                                texto: 'Ligar',
                                onTap: () => emBreve('Ligar'),
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
