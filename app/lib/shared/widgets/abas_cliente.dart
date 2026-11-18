import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/icone_app/icone_app.dart';
import '../../core/theme/tatu_colors.dart';
import '../../data/nao_lidas.dart';

/// Abas do cliente.
enum AbaCliente { inicio, atividade, mensagens, perfil }

/// Barra de abas do cliente: Início · Atividade · Mensagens.
class AbasCliente extends StatelessWidget {
  const AbasCliente({
    super.key,
    this.ativa = AbaCliente.inicio,
    this.onTrocar,
    this.comPerfil = false,
    this.lado,
  });

  /// RN-155: de quem são as mensagens do contador (nulo = sem contador).
  final LadoMensagens? lado;

  /// Profissional: Perfil como 4ª aba.
  final bool comPerfil;

  final AbaCliente ativa;

  /// Toque numa aba (a navegação fica em `features/cliente/abas.dart`).
  final ValueChanged<AbaCliente>? onTrocar;

  @override
  Widget build(BuildContext context) {
    final l = lado;
    if (l == null) return _barra(0);
    // RN-155: o total vem de um lugar só (NaoLidas) e muda na hora.
    return ListenableBuilder(
      listenable: NaoLidas.fonte(l),
      builder: (context, _) {
        final n = NaoLidas.total(l);
        // O mesmo número no ícone do app, se as notificações deixam.
        IconeDoApp.definir(NaoLidas.podeNoIcone(l) ? n : 0);
        return _barra(n);
      },
    );
  }

  Widget _barra(int naoLidas) {
    VoidCallback? ir(AbaCliente a) =>
        onTrocar == null ? null : () => onTrocar!(a);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TatuColors.tabBar,
        border: Border(
          top: BorderSide(color: TatuColors.tabBarLine, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 49,
          child: Row(
            children: [
              _Aba(
                icone: TablerIcons.home,
                texto: 'Início',
                ativa: ativa == AbaCliente.inicio,
                onTap: ir(AbaCliente.inicio),
              ),
              _Aba(
                icone: TablerIcons.clock,
                texto: 'Atividade',
                ativa: ativa == AbaCliente.atividade,
                onTap: ir(AbaCliente.atividade),
              ),
              _Aba(
                icone: TablerIcons.message_circle,
                texto: 'Mensagens',
                ativa: ativa == AbaCliente.mensagens,
                onTap: ir(AbaCliente.mensagens),
                contador: NaoLidas.rotulo(naoLidas),
                leitura: NaoLidas.leitura(naoLidas),
              ),
              if (comPerfil)
                _Aba(
                  icone: TablerIcons.user,
                  texto: 'Perfil',
                  ativa: ativa == AbaCliente.perfil,
                  onTap: ir(AbaCliente.perfil),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({
    required this.icone,
    required this.texto,
    this.ativa = false,
    this.onTap,
    this.contador,
    this.leitura,
  });

  final IconData icone;
  final String texto;
  final bool ativa;
  final VoidCallback? onTap;

  /// RN-155: "3" ou "9+" no canto do ícone (nulo = nada).
  final String? contador;

  /// Nome para o leitor de tela ("Mensagens, 3 não lidas").
  final String? leitura;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? TatuColors.textPrimary : TatuColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: ativa,
        label: leitura,
        excludeSemantics: leitura != null,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icone, size: 24, color: cor),
                  if (contador != null)
                    Positioned(
                      left: 15,
                      top: -6,
                      child: ContadorVermelho(contador!),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: ativa ? FontWeight.w600 : FontWeight.w500,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RN-155: bolinha vermelha com o número de não lidas ("9+" no máximo).
class ContadorVermelho extends StatelessWidget {
  const ContadorVermelho(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 18),
    height: 18,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: TatuColors.danger,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: TatuColors.tabBar, width: 2),
    ),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 10,
        height: 1,
        fontWeight: FontWeight.w700,
        color: TatuColors.onAction,
      ),
    ),
  );
}
