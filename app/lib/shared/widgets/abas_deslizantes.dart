import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'segmento.dart';

/// Abas em [Segmento] com o conteúdo lado a lado: troca tocando na aba ou
/// deslizando o dedo para os lados (Atividade do cliente e do
/// profissional).
///
/// - A marcação branca acompanha o dedo durante o arraste.
/// - Passou da metade ou foi rápido: troca; senão, volta com animação.
/// - Só reconhece o gesto claramente horizontal (não atrapalha a rolagem
///   da lista) e não começa na borda esquerda (gesto de "voltar" do iPhone).
/// - Cada aba guarda a própria posição de rolagem.
class AbasDeslizantes extends StatefulWidget {
  const AbasDeslizantes({
    super.key,
    required this.opcoes,
    required this.paginas,
    this.inicial = 0,
    this.espacoAntes = 0,
  }) : assert(opcoes.length == paginas.length);

  final List<String> opcoes;
  final List<Widget> paginas;
  final int inicial;

  /// Espaço entre as abas e o conteúdo.
  final double espacoAntes;

  /// Faixa da borda esquerda onde o arraste não começa.
  static const bordaVoltar = 24.0;

  /// O movimento horizontal precisa ser pelo menos isso × o vertical.
  static const razaoHorizontal = 2.0;

  @override
  State<AbasDeslizantes> createState() => _AbasDeslizantesState();
}

class _AbasDeslizantesState extends State<AbasDeslizantes> {
  late final _paginas = PageController(initialPage: widget.inicial);
  Drag? _arraste;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  double get _posicao => _paginas.hasClients && _paginas.positions.length == 1
      ? (_paginas.page ?? widget.inicial.toDouble())
      : widget.inicial.toDouble();

  void _atualizar(DragUpdateDetails d) => _arraste?.update(d);
  void _terminar(DragEndDetails d) => _arraste?.end(d);
  void _cancelar() => _arraste?.cancel();

  void _comecar(DragStartDetails d) {
    if (!_paginas.hasClients) return;
    _arraste = _paginas.position.drag(d, () => _arraste = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListenableBuilder(
          listenable: _paginas,
          builder: (_, _) {
            final p = _posicao;
            return Segmento(
              opcoes: widget.opcoes,
              selecionada: p.round(),
              posicao: p,
              // Tocar continua trocando na hora, como antes.
              onMudar: (i) => _paginas.jumpToPage(i),
            );
          },
        ),
        if (widget.espacoAntes > 0) SizedBox(height: widget.espacoAntes),
        Expanded(
          child: RawGestureDetector(
            gestures: {
              _ArrasteHorizontal:
                  GestureRecognizerFactoryWithHandlers<_ArrasteHorizontal>(
                    _ArrasteHorizontal.new,
                    (r) {
                      r
                        ..onStart = _comecar
                        ..onUpdate = _atualizar
                        ..onEnd = _terminar
                        ..onCancel = _cancelar;
                    },
                  ),
            },
            child: PageView(
              controller: _paginas,
              // O arraste é o nosso (acima); a física de página continua
              // decidindo se troca (metade ou rápido) ou volta.
              physics: const NeverScrollableScrollPhysics(),
              children: [for (final p in widget.paginas) _ManterViva(child: p)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Arraste horizontal só quando é claramente horizontal e não começa na
/// borda esquerda da tela.
class _ArrasteHorizontal extends HorizontalDragGestureRecognizer {
  _ArrasteHorizontal() : super(debugOwner: null);

  final _total = <int, Offset>{};

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (event.position.dx < AbasDeslizantes.bordaVoltar) return false;
    return super.isPointerAllowed(event);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _total[event.pointer] = Offset.zero;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _total[event.pointer] =
          (_total[event.pointer] ?? Offset.zero) + event.delta;
      _ultimo = event.pointer;
    }
    super.handleEvent(event);
  }

  int? _ultimo;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    final t = _total[_ultimo] ?? Offset.zero;
    return super.hasSufficientGlobalDistanceToAccept(
          pointerDeviceKind,
          deviceTouchSlop,
        ) &&
        t.dx.abs() >= AbasDeslizantes.razaoHorizontal * t.dy.abs();
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _total.remove(pointer);
    super.didStopTrackingLastPointer(pointer);
  }
}

/// Mantém a aba montada (e a rolagem dela) quando sai da tela.
class _ManterViva extends StatefulWidget {
  const _ManterViva({required this.child});

  final Widget child;

  @override
  State<_ManterViva> createState() => _ManterVivaState();
}

class _ManterVivaState extends State<_ManterViva>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
