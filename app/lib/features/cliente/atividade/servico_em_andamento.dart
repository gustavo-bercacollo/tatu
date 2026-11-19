import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/pedidos.dart';
import '../../../data/prazos.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/tela_interna.dart';

/// C115 · RN-169: depois do código, "A Luiza está trabalhando": hora de
/// início e tempo correndo, Mensagem e Ligar, valor combinado (cobrado
/// quando o cliente confirmar), aviso de novo valor no chat e o escudo.
/// Sem cancelar.
class ServicoEmAndamento extends StatelessWidget {
  const ServicoEmAndamento({
    super.key,
    required this.pedido,
    required this.onMensagem,
    required this.onLigar,
    this.direita,
  });

  final PedidoAndamento pedido;
  final VoidCallback onMensagem;
  final VoidCallback onLigar;

  /// Escudo de segurança.
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    final ela = p.profissao.endsWith('a');
    final i = p.iniciadoEm;
    final hora = i == null
        ? '--:--'
        : '${i.hour.toString().padLeft(2, '0')}:'
              '${i.minute.toString().padLeft(2, '0')}';
    return TelaInterna(
      titulo: 'Em andamento',
      fundoCinza: true,
      direita: direita,
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
              children: [
                _Cartao(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          AvatarIniciais(
                            nome: p.profissional,
                            tamanho: TatuMedidas.avatarAcompanhar,
                          ),
                          const SizedBox(width: TatuMedidas.entreItens),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.artigoNome} está trabalhando',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.profissao} · ${p.descricao}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TatuTexto.nota,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: TatuColors.hairline),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Começou às $hora',
                              style: TatuTexto.nota.copyWith(fontSize: 14),
                            ),
                          ),
                          const _Ponto(),
                          const SizedBox(width: 8),
                          Text(
                            '${p.minutosTrabalhando()} min',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Pilula(
                              icone: TablerIcons.message_circle,
                              texto: 'Mensagem',
                              onTap: onMensagem,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // RN-140: ligar até o serviço ser concluído.
                          Expanded(
                            child: _Pilula(
                              icone: TablerIcons.phone,
                              texto: 'Ligar',
                              onTap: onLigar,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                _Cartao(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Valor combinado',
                              style: TatuTexto.nota.copyWith(fontSize: 14),
                            ),
                          ),
                          Text(
                            p.valor,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: TatuColors.hairline),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            TablerIcons.credit_card,
                            size: 18,
                            color: TatuColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              // RN-31: só cobra quando o cliente confirmar.
                              '${p.pagamento} · cobrado quando você confirmar',
                              style: TatuTexto.nota,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                _Cartao(
                  child: Row(
                    children: [
                      const Icon(TablerIcons.pencil, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Novo valor?',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Se ${ela ? 'a' : 'o'} ${p.primeiroNome} '
                              'mandar, você aprova no chat.',
                              style: TatuTexto.nota,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 8, 40, TatuMedidas.base),
            child: Text(
              'Quando ${ela ? 'ela' : 'ele'} concluir, você confirma se '
              'está tudo certo.',
              textAlign: TextAlign.center,
              style: TatuTexto.nota,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.bg,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
    ),
    child: child,
  );
}

class _Ponto extends StatelessWidget {
  const _Ponto();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 8,
    height: 8,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: TatuColors.online,
        shape: BoxShape.circle,
      ),
    ),
  );
}

class _Pilula extends StatelessWidget {
  const _Pilula({required this.icone, required this.texto, required this.onTap});

  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: TatuColors.fill,
    shape: const StadiumBorder(),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: SizedBox(
        height: TatuMedidas.botaoCirculo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 20),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Resposta do cliente na folha de conclusão.
enum RespostaConclusao { confirmar, algoErrado }

/// C118 · RN-31: "A Luiza concluiu o serviço. Está tudo certo?". "Sim,
/// confirmar" cobra; "Algo errado" segura o valor e abre a contestação.
/// Sem resposta em 2 horas, confirma sozinho (a folha fecha).
Future<RespostaConclusao?> perguntarConclusao(
  BuildContext context,
  PedidoAndamento p,
) => mostrarFolha<RespostaConclusao>(
  context,
  fechavel: false,
  builder: (_) => _FolhaConclusao(pedido: p),
);

class _FolhaConclusao extends StatefulWidget {
  const _FolhaConclusao({required this.pedido});

  final PedidoAndamento pedido;

  @override
  State<_FolhaConclusao> createState() => _FolhaConclusaoState();
}

class _FolhaConclusaoState extends State<_FolhaConclusao> {
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

  /// Confirmou sozinho (2 h) ou o pedido saiu: fecha a folha.
  void _mudou() {
    final a = pedidos.andamento;
    // Só fecha se a folha ainda estiver aberta (não fechou por um botão).
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    if (a == null || a.id != widget.pedido.id || !a.aguardandoConfirmacao) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    final horas = Prazos.confirmarConclusao.inHours;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margemCadastro,
          10,
          TatuMedidas.margemCadastro,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: TatuColors.onlineSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  TablerIcons.check,
                  size: 30,
                  color: TatuColors.online,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${p.artigoNome} concluiu o serviço',
              textAlign: TextAlign.center,
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: 4),
            const Text(
              'Está tudo certo?',
              textAlign: TextAlign.center,
              style: TatuTexto.detalhe,
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: TatuColors.surfaceGrouped,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCampo),
              ),
              child: Row(
                children: [
                  const Icon(TablerIcons.credit_card, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.pagamento,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(
                    p.valor,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(RespostaConclusao.confirmar),
              child: const Text('Sim, confirmar'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () =>
                  Navigator.of(context).pop(RespostaConclusao.algoErrado),
              child: const Text('Algo errado'),
            ),
            const SizedBox(height: TatuMedidas.entreItens),
            Text(
              'Sem resposta em $horas horas, confirmamos sozinho.',
              textAlign: TextAlign.center,
              style: TatuTexto.legenda,
            ),
          ],
        ),
      ),
    );
  }
}
