import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/prazos.dart';
import '../../../data/profissional.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/formatadores.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/tela_interna.dart';

/// P52–P53 · RN-31/RN-171: depois de "Concluir serviço", nada é cobrado
/// na hora. O profissional vê "Aguardando a Ana confirmar" com o tempo
/// das 2 horas e já pode ficar online. Confirmado (pelo cliente ou
/// sozinho), vê o valor que vai para o Pix.
class ConclusaoServicoPage extends StatefulWidget {
  const ConclusaoServicoPage({
    super.key,
    this.servico = servicoExemplo,
    this.confirmado = false,
  });

  final ServicoAceito servico;

  /// Abre já confirmado (fluxograma e testes).
  final bool confirmado;

  /// Protótipo: o cliente confirma depois deste tempo de verdade (nulo
  /// nos testes: só pelas 2 horas).
  static Duration? clienteConfirmaEm = const Duration(seconds: 6);

  @override
  State<ConclusaoServicoPage> createState() => _ConclusaoServicoPageState();
}

class _ConclusaoServicoPageState extends State<ConclusaoServicoPage> {
  late bool _confirmado = widget.confirmado;
  final _concluidoEm = clock.now();
  Timer? _relogio;
  Timer? _cliente;

  @override
  void initState() {
    super.initState();
    if (_confirmado) return;
    _relogio = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      // RN-31: 2 horas sem resposta, confirma sozinho.
      if (_falta == Duration.zero) return _confirmar();
      setState(() {});
    });
    final em = ConclusaoServicoPage.clienteConfirmaEm;
    if (em != null) _cliente = Timer(em, _confirmar);
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _cliente?.cancel();
    super.dispose();
  }

  /// Quanto falta das 2 horas (protótipo: relógio acelerado).
  Duration get _falta {
    final r =
        Prazos.confirmarConclusao -
        clock.now().difference(_concluidoEm) * Prazos.aceleracao;
    return r.isNegative ? Duration.zero : r;
  }

  void _confirmar() {
    _relogio?.cancel();
    _cliente?.cancel();
    if (mounted) setState(() => _confirmado = true);
  }

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final nome = s.primeiroNome;
    final a = s.feminino ? 'a' : 'o';
    // RN-35: taxa do Tatu; o resto vai para o Pix em 24 horas.
    final liquido = s.valor * (1 - taxaTatu);
    final f = _falta;
    final tempo =
        '${f.inHours}:${(f.inMinutes % 60).toString().padLeft(2, '0')}';
    return TelaInterna(
      titulo: 'Serviço concluído',
      fundoCinza: true,
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TatuColors.bg,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AvatarIniciais(
                            nome: s.cliente,
                            tamanho: TatuMedidas.avatarAcompanhar,
                          ),
                          const SizedBox(width: TatuMedidas.entreItens),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.cliente,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.descricao} · ${reais(s.valor)}',
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
                      if (_confirmado)
                        Row(
                          children: [
                            const Icon(
                              TablerIcons.check,
                              size: 20,
                              color: TatuColors.onlineTexto,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$nome confirmou',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: TatuColors.onlineTexto,
                                ),
                              ),
                            ),
                            Text(
                              reais(liquido),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: TatuColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Aguardando $a $nome confirmar',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              tempo,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens + 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _confirmado
                        ? '${reais(liquido)} no seu Pix em '
                              '${Prazos.repasse.inHours} horas (taxa de '
                              '${(taxaTatu * 100).round()}%).'
                        // RN-171: pode ficar online enquanto espera.
                        : 'Se $a $nome não responder em '
                              '${Prazos.confirmarConclusao.inHours} horas,\n'
                              'confirmamos sozinho.\n'
                              'Você já pode ficar online para outros chamados.',
                    style: TatuTexto.nota.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: TatuMedidas.base),
            child: FilledButton(
              onPressed: _confirmado
                  ? () => _emBreve('Avaliar cliente')
                  : () {
                      profissional.ficarOnline(true);
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
              child: Text(_confirmado ? 'Avaliar $a $nome' : 'Ficar online'),
            ),
          ),
        ],
      ),
    );
  }
}
