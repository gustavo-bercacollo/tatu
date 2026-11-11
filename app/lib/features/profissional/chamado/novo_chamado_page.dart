import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servico_profissional.dart';
import '../../../data/servicos.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import 'chat_profissional_page.dart';

/// P22 · Novo chamado: painel sobre o mapa, com a contagem para aceitar.
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
    final nota = c.notaCliente.toStringAsFixed(1).replaceAll('.', ',');
    final km = c.distanciaKm.toStringAsFixed(1).replaceAll('.', ',');
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: MapaFalso())),
          const Positioned.fill(child: ColoredBox(color: TatuColors.scrim)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: TatuMedidas.larguraMax,
              ),
              decoration: const BoxDecoration(
                color: TatuColors.bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(TatuMedidas.raioFolha),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TatuMedidas.margem,
                    10,
                    TatuMedidas.margem,
                    TatuMedidas.entreItens,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AlcaFolha(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text('NOVO CHAMADO', style: TatuTexto.secao),
                          ),
                          _Contagem(restante: _restante),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: TatuColors.fill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(iconeServico(c.profissao), size: 22),
                          ),
                          const SizedBox(width: TatuMedidas.entreItens),
                          Expanded(
                            child: Text(
                              c.profissao,
                              style: TatuTexto.tituloFolha,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                c.descricao,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                          if (c.temFoto) ...[
                            const SizedBox(width: TatuMedidas.entreItens),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: TatuColors.fillStrong,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                TablerIcons.photo,
                                color: TatuColors.textSecondary,
                                semanticLabel: 'Foto do problema',
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      const Divider(height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _Dado('${c.minutos} min', '$km km'),
                            const VerticalDivider(
                              width: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            _Dado(c.bairro, 'região'),
                            const VerticalDivider(
                              width: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            _Dado(nota, 'cliente ${c.primeiroNome}'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: TatuMedidas.entreItens),
                      Text(
                        'Estimativa na região: R\$ ${c.estimativaMin} a '
                        'R\$ ${c.estimativaMax}',
                        textAlign: TextAlign.center,
                        style: TatuTexto.nota,
                      ),
                      const SizedBox(height: TatuMedidas.entreItens),
                      FilledButton(
                        onPressed: _aceitar,
                        child: const Text('Aceitar chamado'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          foregroundColor: TatuColors.textSecondary,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Recusar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Anel com os segundos que faltam para aceitar.
class _Contagem extends StatelessWidget {
  const _Contagem({required this.restante});

  final int restante;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Faltam $restante segundos para aceitar',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CircularProgressIndicator(
                value: restante / segundosParaAceitar,
                strokeWidth: 3.5,
                strokeCap: StrokeCap.round,
                color: TatuColors.action,
                backgroundColor: TatuColors.trilho,
              ),
            ),
            ExcludeSemantics(
              child: Text(
                '${restante}s',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              maxLines: 1,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(rotulo, maxLines: 1, style: TatuTexto.nota),
          ),
        ],
      ),
    ),
  );
}
