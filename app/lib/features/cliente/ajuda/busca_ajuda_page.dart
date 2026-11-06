import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/ajuda.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_permissao.dart';
import 'abrir_ajuda.dart';

/// Busca na ajuda: resultados por título; sem nada, "Nada encontrado".
class BuscaAjudaPage extends StatefulWidget {
  const BuscaAjudaPage({super.key, this.termo = ''});

  /// Termo já digitado (para abrir a busca preenchida).
  final String termo;

  @override
  State<BuscaAjudaPage> createState() => _BuscaAjudaPageState();
}

class _BuscaAjudaPageState extends State<BuscaAjudaPage> {
  late final _controller = TextEditingController.fromValue(
    TextEditingValue(
      text: widget.termo,
      selection: TextSelection.collapsed(offset: widget.termo.length),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _controller.text.trim();
    final achados = buscarAjuda(termo);
    final vazio = termo.isNotEmpty && achados.isEmpty;
    return Scaffold(
      backgroundColor: vazio ? TatuColors.bg : TatuColors.surfaceGrouped,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const BackCircleButton(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CampoBusca(
                          hint: 'Buscar na ajuda',
                          controller: _controller,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: vazio
                        ? _NadaEncontrado(termo: termo)
                        : ListView(
                            padding: const EdgeInsets.only(
                              top: TatuMedidas.entreSecoes + 4,
                            ),
                            children: [
                              if (achados.isNotEmpty)
                                GrupoCartao(
                                  titulo: achados.length == 1
                                      ? '1 resultado'
                                      : '${achados.length} resultados',
                                  linhas: [
                                    for (final a in achados)
                                      LinhaSimples(
                                        texto: a.titulo,
                                        onTap: () => abrirArtigo(context, a),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                  ),
                  if (vazio)
                    FilledButton(
                      onPressed: () => abrirSuporte(context),
                      child: const Text('Falar com o suporte'),
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

class _NadaEncontrado extends StatelessWidget {
  const _NadaEncontrado({required this.termo});

  final String termo;

  @override
  Widget build(BuildContext context) {
    return const TelaPermissaoCorpo(
      icone: IconePermissao(TablerIcons.search),
      titulo: 'Nada encontrado',
      texto: 'Tente outras palavras ou fale\ncom a nossa equipe.',
    );
  }
}
