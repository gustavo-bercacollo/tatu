import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_theme.dart';
import '../../../data/notificacoes.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/grupo_cartao.dart';
import '../../../shared/widgets/tela_interna.dart';

/// Notificações: avisos sobre os pedidos e extras. Se o celular bloqueou
/// as notificações, mostra o aviso para abrir os Ajustes.
class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  Future<void> _mudar(BuildContext context, TipoAviso a, bool valor) async {
    if (!valor && a.dePedido) {
      final desligar = await confirmar(
        context,
        icone: TablerIcons.alert_triangle,
        titulo: 'Desligar este aviso?',
        texto: _consequencia(a),
        confirmar: 'Desligar mesmo assim',
        cancelar: 'Manter ligado',
        destacarCancelar: true,
      );
      if (!desligar) return;
    }
    notificacoes.definir(a.id, valor);
  }

  static String _consequencia(TipoAviso a) => switch (a.id) {
    'aceitou' =>
      'Você pode não ver quando um profissional\naceitar seu pedido.',
    'caminho' => 'Você pode não ver quando o profissional\nsair e chegar.',
    'mensagens' => 'Você pode não ver as mensagens\ndo profissional.',
    _ => 'Você pode não ver propostas de valor\ne cobranças.',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificacoes,
      builder: (context, _) {
        final permitido = notificacoes.permitidoNoCelular;
        List<Widget> linhas(List<TipoAviso> avisos) => [
          for (final a in avisos)
            LinhaInterruptor(
              texto: a.titulo,
              detalhe: a.detalhe,
              valor: notificacoes.ligado(a.id),
              habilitado: permitido,
              onMudar: (v) => _mudar(context, a, v),
            ),
        ];
        return TelaInterna(
          titulo: 'Notificações',
          fundoCinza: true,
          corpo: ListView(
            padding: const EdgeInsets.only(top: TatuMedidas.topo),
            children: [
              if (permitido)
                FilledButton(
                  style: tatuBotaoSecundario(),
                  onPressed: notificacoes.ativarTodas,
                  child: const Text('Ativar todas'),
                )
              else
                const _AvisoBloqueado(),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(
                titulo: 'Sobre seus pedidos',
                nota: permitido
                    ? 'Recomendamos manter esses avisos ligados\n'
                          'para você não perder seu pedido.'
                    : null,
                linhas: linhas(avisosDePedido),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes + 8),
              GrupoCartao(titulo: 'Extras', linhas: linhas(avisosExtras)),
            ],
          ),
        );
      },
    );
  }
}

/// Aviso vermelho quando as notificações estão bloqueadas no celular.
class _AvisoBloqueado extends StatelessWidget {
  const _AvisoBloqueado();

  @override
  Widget build(BuildContext context) {
    final aparelho = defaultTargetPlatform == TargetPlatform.iOS
        ? 'no iPhone'
        : 'no celular';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.dangerSoft,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(TablerIcons.bell, size: 22, color: TatuColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desativadas $aparelho',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TatuColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ative nos Ajustes para saber quando um '
                  'profissional aceitar seu pedido.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: TatuColors.danger,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: TatuColors.danger,
                    foregroundColor: TatuColors.onAction,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Abrir Ajustes: em breve')),
                    ),
                  child: const Text('Abrir Ajustes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
