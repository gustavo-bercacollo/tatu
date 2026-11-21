import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/avaliacoes_de_clientes.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/estrelas.dart';
import '../../../shared/widgets/tatu_chip.dart';

/// P28 · RN-41: "Pagamento recebido" e "Como foi com a Ana?": nota,
/// elogios e comentário opcional. Depois da confirmação do cliente
/// (RN-171), o profissional também avalia.
class AvaliarClientePage extends StatefulWidget {
  const AvaliarClientePage({
    super.key,
    required this.servico,
    required this.liquido,
  });

  final ServicoAceito servico;

  /// O que caiu (ou vai cair) no Pix.
  final double liquido;

  @override
  State<AvaliarClientePage> createState() => _AvaliarClientePageState();
}

class _AvaliarClientePageState extends State<AvaliarClientePage> {
  int _nota = 0;
  final _elogios = <String>{};
  final _comentario = TextEditingController();

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _enviar() {
    final s = widget.servico;
    avaliacoesDeClientes.avaliar(
      AvaliacaoDoCliente(
        cliente: s.cliente,
        nota: _nota,
        elogios: _elogios.toList(),
        comentario: _comentario.text.trim(),
      ),
    );
    mostrarAvisoTopo(
      context,
      titulo: 'Avaliação enviada',
      texto: 'Obrigado por avaliar ${s.feminino ? 'a' : 'o'} ${s.primeiroNome}.',
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
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
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              color: TatuColors.online,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              TablerIcons.check,
                              size: 34,
                              color: TatuColors.onAction,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Pagamento recebido',
                          textAlign: TextAlign.center,
                          style: TatuTexto.tituloFolha,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reais(widget.liquido)} na sua chave Pix',
                          textAlign: TextAlign.center,
                          style: TatuTexto.detalhe,
                        ),
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        const Divider(height: 1, color: TatuColors.hairline),
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        Text(
                          'Como foi com ${s.feminino ? 'a' : 'o'} '
                          '${s.primeiroNome}?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: TatuMedidas.entreItens + 4),
                        Center(
                          child: EstrelasEscolha(
                            nota: _nota,
                            onMudar: (n) => setState(() => _nota = n),
                          ),
                        ),
                        const SizedBox(height: TatuMedidas.entreSecoes),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final e in elogiosDoCliente(
                              feminino: s.feminino,
                            ))
                              TatuChip(
                                label: e,
                                selecionado: _elogios.contains(e),
                                onTap: () => setState(
                                  () => _elogios.contains(e)
                                      ? _elogios.remove(e)
                                      : _elogios.add(e),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: TatuMedidas.entreItens),
                        Container(
                          height: 90,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: TatuColors.fill,
                            borderRadius: BorderRadius.circular(
                              TatuMedidas.raioCampo,
                            ),
                          ),
                          child: TextField(
                            controller: _comentario,
                            maxLines: null,
                            expands: true,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Comentário (opcional)',
                              hintStyle: TextStyle(
                                color: TatuColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.only(top: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // RN-41: a nota é obrigatória; o resto é opcional.
                  FilledButton(
                    onPressed: _nota == 0 ? null : _enviar,
                    child: const Text('Enviar avaliação'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
