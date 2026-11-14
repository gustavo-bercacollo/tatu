import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/ajuda.dart';
import '../../../data/pedidos.dart';
import '../../../data/prazos.dart';
import '../../../data/seguranca.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/tela_interna.dart';
import '../../../shared/widgets/tela_permissao.dart';
import '../../entrada/seguranca.dart';
import '../../profissional/cadastro/resultado_page.dart' show NomeVerificado;
import '../abas.dart';
import '../ajuda/abrir_ajuda.dart';

/// Abre "Você não estava no local" no lugar da tela atual (RN-81).
void mostrarAusencia(BuildContext context) {
  final p = pedidos.ausente;
  if (p == null) return;
  pedidos.consumirAusente();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => VoceNaoEstavaPage(pedido: p)),
  );
}

/// C132 · O profissional chegou: foto, nome verificado e o código que o
/// cliente pede antes de abrir a porta (RN-39). O profissional espera
/// até [Prazos.esperaCliente] (RN-80); depois disso pode encerrar
/// cobrando só a visita (RN-81).
class NaPortaPage extends StatefulWidget {
  const NaPortaPage({super.key});

  @override
  State<NaPortaPage> createState() => _NaPortaPageState();
}

class _NaPortaPageState extends State<NaPortaPage> {
  @override
  void initState() {
    super.initState();
    pedidos.addListener(_mudou);
  }

  @override
  void dispose() {
    pedidos.removeListener(_mudou);
    super.dispose();
  }

  void _mudou() {
    if (!mounted) return;
    if (pedidos.ausente != null) return mostrarAusencia(context);
    // Cancelado ou já abriu a porta: volta para o pedido.
    final p = pedidos.andamento;
    if (p == null || !p.naPorta) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final p = pedidos.andamento;
    if (p == null) return const Scaffold();
    final minutos = Prazos.esperaCliente.inMinutes;
    return TelaInterna(
      titulo: '${p.primeiroNome} chegou',
      corpo: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          TatuMedidas.entreSecoes,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: AvatarIniciais(
                      nome: p.profissional,
                      tamanho: TatuMedidas.avatarChegada,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(child: NomeVerificado(p.profissional, tamanho: 24)),
                  const SizedBox(height: 6),
                  Text(
                    '${p.profissao} · documento e selfie conferidos',
                    textAlign: TextAlign.center,
                    style: TatuTexto.nota,
                  ),
                  const SizedBox(height: TatuMedidas.entreSecoes + 6),
                  // RN-39: o cliente pede o código antes de abrir.
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    decoration: BoxDecoration(
                      color: TatuColors.surfaceGrouped,
                      borderRadius: BorderRadius.circular(
                        TatuMedidas.raioOpcao,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Antes de abrir, peça este código',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final (i, d) in p.codigo.split('').indexed)
                              Padding(
                                padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                                child: _Digito(d),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Só ${p.profissao.endsWith('a') ? 'a' : 'o'} '
                          '${p.primeiroNome} tem esse código no app '
                          '${p.profissao.endsWith('a') ? 'dela' : 'dele'}.',
                          textAlign: TextAlign.center,
                          style: TatuTexto.nota,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // RN-80: a espera tem limite.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        TablerIcons.clock,
                        size: 16,
                        color: TatuColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${p.artigoNome} espera por até $minutos minutos.',
                          style: TatuTexto.nota.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {
                pedidos.abriuPorta();
              },
              child: const Text('O código confere'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => abrirSeguranca(context, Atendimento.doPedido(p)),
              child: const Text('Não é essa pessoa'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Digito extends StatelessWidget {
  const _Digito(this.digito);

  final String digito;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TatuMedidas.codigoPortaLargura,
      height: TatuMedidas.codigoPortaAltura,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCodigo),
      ),
      child: Text(
        digito,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// C95 · O cliente não apareceu: o profissional esperou e encerrou o
/// chamado; só a visita foi cobrada (RN-81).
class VoceNaoEstavaPage extends StatelessWidget {
  const VoceNaoEstavaPage({super.key, required this.pedido});

  final PedidoAndamento pedido;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return TelaPermissao(
      voltar: false,
      aviso: true,
      icone: const Icon(
        TablerIcons.door,
        size: 40,
        color: TatuColors.warningTexto,
      ),
      titulo: 'Você não estava no local',
      texto: 'A visita foi cobrada: ${reais(p.visita)}',
      extra: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TatuColors.surfaceGrouped,
          borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${p.artigoNome} esperou ${Prazos.esperaCliente.inMinutes} '
              'minutos na porta.',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text('O serviço não foi cobrado.', style: TatuTexto.nota),
          ],
        ),
      ),
      principal: 'Pedir de novo',
      onPrincipal: () => irParaAba(context, AbaCliente.inicio),
      // RN-81: discordou? Avisa o suporte em até 24 h.
      link: 'Algo errado? Avise em até 24h',
      onLink: () => abrirSuporte(context, conteudoCliente),
    );
  }
}
