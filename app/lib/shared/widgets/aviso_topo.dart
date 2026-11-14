import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';

/// Aviso escuro fixo sobre a tela (ex.: "Você chegou perto da Ana",
/// "A Luiza ainda não saiu"): ícone, título branco e texto cinza.
class AvisoEscuro extends StatelessWidget {
  const AvisoEscuro({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  final Widget icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: BoxDecoration(
      color: TatuColors.avisoEscuro,
      borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
      boxShadow: const [
        BoxShadow(color: TatuColors.sombra, blurRadius: 14, offset: Offset(0, 6)),
      ],
    ),
    child: Row(
      children: [
        icone,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TatuColors.onAction,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  color: TatuColors.avisoEscuroTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Aviso escuro de sucesso no topo da tela (ex.: "Foto atualizada").
/// Some sozinho depois de alguns segundos ou ao tocar.
void mostrarAvisoTopo(
  BuildContext context, {
  required String titulo,
  required String texto,
  Duration duracao = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entrada;
  var removida = false;
  void remover() {
    if (removida) return;
    removida = true;
    entrada.remove();
  }

  entrada = OverlayEntry(
    builder: (_) => _AvisoTopo(
      titulo: titulo,
      texto: texto,
      duracao: duracao,
      onFim: remover,
    ),
  );
  overlay.insert(entrada);
}

class _AvisoTopo extends StatefulWidget {
  const _AvisoTopo({
    required this.titulo,
    required this.texto,
    required this.duracao,
    required this.onFim,
  });

  final String titulo;
  final String texto;
  final Duration duracao;
  final VoidCallback onFim;

  @override
  State<_AvisoTopo> createState() => _AvisoTopoState();
}

class _AvisoTopoState extends State<_AvisoTopo>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duracao, _fechar);
  }

  Future<void> _fechar() async {
    _timer?.cancel();
    if (!mounted) return;
    await _anim.reverse();
    widget.onFim();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curva = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.entreItens,
                TatuMedidas.margem,
                0,
              ),
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, -1.2),
                  end: Offset.zero,
                ).animate(curva),
                child: FadeTransition(
                  opacity: curva,
                  child: GestureDetector(
                    onTap: _fechar,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        decoration: BoxDecoration(
                          color: TatuColors.action,
                          borderRadius: BorderRadius.circular(
                            TatuMedidas.raioOpcao,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: TatuColors.sombra,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: TatuColors.online,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  TablerIcons.check,
                                  size: 18,
                                  color: TatuColors.onAction,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.titulo,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: TatuColors.onAction,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.texto,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: TatuColors.textDisabled,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
