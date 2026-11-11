import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/servico_profissional.dart';
import 'chat_profissional_page.dart';

/// P22 · Novo chamado: tela escura com a contagem para aceitar.
/// Sem resposta até o fim da contagem, o chamado passa para outro.
class NovoChamadoPage extends StatefulWidget {
  const NovoChamadoPage({
    super.key,
    this.chamado = chamadoExemplo,
    this.restante = segundosParaAceitar,
  });

  final ChamadoNovo chamado;

  /// Segundos que faltam ao abrir (para o fluxograma e testes).
  final int restante;

  @override
  State<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

class _NovoChamadoPageState extends State<NovoChamadoPage> {
  late int _restante = widget.restante;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_restante <= 1) {
        _timer?.cancel();
        Navigator.of(context).maybePop(); // passou para outro profissional
      } else {
        setState(() => _restante--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _aceitar() => Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => ChatProfissionalPage(chamado: widget.chamado),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.chamado;
    const branco = TatuColors.onAction;
    final cinza = branco.withValues(alpha: 0.68);
    final nota = c.notaCliente.toStringAsFixed(1).replaceAll('.', ',');
    final km = c.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return Scaffold(
      backgroundColor: TatuColors.textPrimary,
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
                  const Text(
                    'Novo chamado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: branco,
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  Center(
                    child: Semantics(
                      label: 'Faltam $_restante segundos para aceitar',
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: _restante / segundosParaAceitar,
                                strokeWidth: 5,
                                strokeCap: StrokeCap.round,
                                color: TatuColors.online,
                                backgroundColor: TatuColors.editorTrilho,
                              ),
                            ),
                            ExcludeSemantics(
                              child: Text(
                                '0:${_restante.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: branco,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TatuColors.action,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.profissao.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: TatuColors.online,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              c.titulo,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: branco,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.descricao,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: cinza,
                              ),
                            ),
                            if (c.temFoto) ...[
                              const SizedBox(height: 18),
                              Container(
                                width: 100,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: TatuColors.editorTrilho,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  TablerIcons.photo,
                                  color: TatuColors.textSecondary,
                                  semanticLabel: 'Foto do problema',
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Pilula('$km km · ${c.minutos} min'),
                                if (c.urgente) const _Pilula('Urgente'),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  TablerIcons.map_pin,
                                  size: 16,
                                  color: cinza,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${c.bairro} · endereço depois do valor',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: cinza,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Cliente ${c.cliente} · nota $nota · '
                              'Estimativa R\$ ${c.estimativaMin} a '
                              'R\$ ${c.estimativaMax}',
                              style: TextStyle(fontSize: 13, color: cinza),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TatuMedidas.entreItens + 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: branco,
                      foregroundColor: TatuColors.textPrimary,
                    ),
                    onPressed: _aceitar,
                    child: const Text('Aceitar chamado'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: TatuColors.editorFundo,
                      foregroundColor: branco,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Recusar'),
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

class _Pilula extends StatelessWidget {
  const _Pilula(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    height: TatuMedidas.alturaChip,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const ShapeDecoration(
      color: TatuColors.editorFundo,
      shape: StadiumBorder(),
    ),
    child: Center(
      widthFactor: 1,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: TatuColors.onAction,
        ),
      ),
    ),
  );
}
