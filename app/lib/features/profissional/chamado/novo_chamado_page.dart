import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/atendimento_profissional.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../data/base_tecnica.dart';
import '../../../data/profissional.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servico_profissional.dart';
import '../../../shared/widgets/icone_profissao.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/mapa_falso.dart';
import '../cadastro/especialidades_page.dart' show EtiquetaCinza;
import 'chat_profissional_page.dart';
import 'toque_chamado.dart';
import '../../../shared/widgets/miniatura_anexo.dart';

/// P22 · Novo chamado: painel sobre o mapa, com a contagem para aceitar.
/// Sem resposta até o fim da contagem, o chamado passa para outro.
class NovoChamadoPage extends StatefulWidget {
  const NovoChamadoPage({
    super.key,
    this.chamado = chamadoExemplo,
    this.restante,
  });

  final ChamadoNovo chamado;

  /// Segundos que faltam ao abrir (para o fluxograma e testes); nulo =
  /// o prazo inteiro do chamado ([ChamadoNovo.segundos]).
  final int? restante;

  @override
  State<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

class _NovoChamadoPageState extends State<NovoChamadoPage> {
  late int _restante = widget.restante ?? widget.chamado.segundos;
  Timer? _timer;
  final _toque = ToqueChamado();

  @override
  void initState() {
    super.initState();
    _toque.tocar();
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
    _toque.parar();
    _timer?.cancel();
    super.dispose();
  }

  void _aceitar() {
    // RN-18: só o 1º aceite vale; os outros veem "Outro profissional
    // aceitou".
    final c = widget.chamado;
    final id = '${c.cliente}:${c.titulo}:${c.rua}';
    if (!aceitesChamado.aceitar(id, profissional.nome)) {
      _timer?.cancel();
      _toque.parar();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AceitesChamado.textoOutroAceitou)),
        );
      Navigator.of(context).maybePop();
      return;
    }
    registroAtendimentos.registrar(id, 'aceito', quem: 'profissional');
    atendimentoProfissional.aceitar(widget.chamado);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChatProfissionalPage(chamado: widget.chamado),
      ),
    );
  }

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
                          _Contagem(restante: _restante, total: c.segundos),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // RN-227: 40 px em cards.
                          IconeProfissaoCirculo(c.profissao),
                          const SizedBox(width: TatuMedidas.entreItens),
                          Expanded(
                            child: Text(
                              c.profissao,
                              style: TatuTexto.tituloFolha,
                            ),
                          ),
                        ],
                      ),
                      // RN-178: o cliente pediu este profissional de novo.
                      if (c.pediuDeNovoEm case final dia?) ...[
                        const SizedBox(height: TatuMedidas.entreItens),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: EtiquetaCinza(
                            icone: TablerIcons.refresh,
                            texto:
                                'Pediu você de novo · atendeu '
                                '${c.feminino ? 'a' : 'o'} ${c.primeiroNome} '
                                'em $dia',
                            verde: true,
                          ),
                        ),
                      ],
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
                        ],
                      ),
                      // RN-139: o profissional vê os anexos da descrição.
                      if (c.anexos.isNotEmpty) ...[
                        const SizedBox(height: TatuMedidas.entreItens),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final a in c.anexos)
                                MiniaturaAnexo(anexo: a),
                            ],
                          ),
                        ),
                      ],
                      if (c.distancia) ...[
                        // RN-93/RN-95: chamado à distância, sem visita.
                        const SizedBox(height: TatuMedidas.entreItens),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: EtiquetaCinza(
                            icone: TablerIcons.world,
                            texto: 'À distância',
                          ),
                        ),
                      ],
                      const SizedBox(height: TatuMedidas.entreItens + 4),
                      const Divider(height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            if (c.distancia)
                              const _Dado('Sem visita', 'tudo pelo chat')
                            else ...[
                              _Dado('${c.minutos} min', '$km km'),
                              const VerticalDivider(
                                width: 1,
                                indent: 12,
                                endIndent: 12,
                              ),
                              _Dado(c.bairro, 'região'),
                            ],
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
                        '${c.distancia ? 'Estimativa' : 'Estimativa na região'}: '
                        'R\$ ${c.estimativaMin} a '
                        'R\$ ${c.estimativaMax}',
                        textAlign: TextAlign.center,
                        style: TatuTexto.nota,
                      ),
                      // RN-177/RN-178: só dele por 2 min; depois, para
                      // os outros por perto, como um pedido normal.
                      if (c.pediuDeNovo) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Só para você por 2 min. Depois vai para outros.',
                          textAlign: TextAlign.center,
                          style: TatuTexto.nota,
                        ),
                      ],
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
  const _Contagem({required this.restante, required this.total});

  final int restante;
  final int total;

  /// "25s" ou, com 1 minuto ou mais, "1:21".
  String get _texto => restante < 60
      ? '${restante}s'
      : '${restante ~/ 60}:${(restante % 60).toString().padLeft(2, '0')}';

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
                value: restante / total,
                strokeWidth: 3.5,
                strokeCap: StrokeCap.round,
                color: TatuColors.action,
                backgroundColor: TatuColors.trilho,
              ),
            ),
            ExcludeSemantics(
              child: Text(
                _texto,
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
