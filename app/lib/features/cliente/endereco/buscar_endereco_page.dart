import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../data/enderecos.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/topo_tela.dart';
import 'confirmar_endereco_page.dart';
import 'linha_endereco.dart';

/// Buscar endereço: resultados pela rua digitada e endereços recentes.
class BuscarEnderecoPage extends StatefulWidget {
  const BuscarEnderecoPage({super.key});

  @override
  State<BuscarEnderecoPage> createState() => _BuscarEnderecoPageState();
}

class _BuscarEnderecoPageState extends State<BuscarEnderecoPage> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: TatuColors.textSecondary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final texto = _busca.text.trim();
    final resultados = enderecos.buscar(texto);
    final recentes = enderecos.salvos;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                const TopoTela(titulo: 'Buscar endereço'),
                const SizedBox(height: 28),
                CampoBusca(
                  hint: 'Rua e número',
                  controller: _busca,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                if (texto.length >= 3) ...[
                  _titulo('Resultados'),
                  if (resultados.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Nenhum endereço encontrado. Confira a rua e o número.',
                        style: TextStyle(
                          fontSize: 15,
                          color: TatuColors.textSecondary,
                        ),
                      ),
                    ),
                  for (final r in resultados) ...[
                    LinhaEndereco(
                      recuo: 2,
                      icone: TablerIcons.map_pin,
                      titulo: r.rua,
                      detalhe: '${r.bairro} · ${r.cidade}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfirmarEnderecoPage(resultado: r),
                        ),
                      ),
                    ),
                    const DivisorEndereco(inicio: 48),
                  ],
                ],
                if (recentes.isNotEmpty) ...[
                  _titulo('Recentes'),
                  for (final e in recentes)
                    LinhaEndereco(
                      recuo: 2,
                      icone: TablerIcons.clock,
                      titulo: e.nome,
                      detalhe: e.rua,
                      onTap: () {
                        enderecos.usar(e);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
