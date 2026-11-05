import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/enderecos.dart';
import '../../data/notificacoes.dart';
import '../../data/pagamentos.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../entrada/boas_vindas_page.dart';
import 'avaliacoes/minhas_avaliacoes_page.dart';
import 'endereco/enderecos_page.dart';
import 'notificacoes/notificacoes_page.dart';
import 'pagamento/pagamento_page.dart';

/// Perfil do cliente: dados, troca de modo e atalhos da conta.
class PerfilClientePage extends StatelessWidget {
  const PerfilClientePage({
    super.key,
    required this.nome,
    this.nota = '4,8',
    this.pedidos = 23,
  });

  final String nome;
  final String nota;
  final int pedidos;

  String get _iniciais => nome
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));

    return ListenableBuilder(
      listenable: Listenable.merge([enderecos, pagamentos, notificacoes]),
      builder: (context, _) => _tela(context, emBreve),
    );
  }

  Widget _tela(BuildContext context, void Function(String) emBreve) {
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      bottomNavigationBar: AbasCliente(
        onInicio: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                26,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: TatuColors.circle,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _iniciais,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      TablerIcons.circle_check_filled,
                      size: 20,
                      color: TatuColors.verified,
                      semanticLabel: 'Verificado',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      TablerIcons.star_filled,
                      size: 14,
                      color: TatuColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text('$nota · $pedidos pedidos', style: TatuTexto.detalhe),
                  ],
                ),
                const SizedBox(height: 26),
                GrupoLista(
                  titulo: 'Modo',
                  itens: [
                    ItemLista(
                      icone: TablerIcons.refresh,
                      texto: 'Trocar para modo profissional',
                      onTap: () => emBreve('Modo profissional'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GrupoLista(
                  titulo: 'Pedido rápido',
                  itens: [
                    ItemLista(
                      icone: TablerIcons.map_pin,
                      texto: 'Endereços',
                      valor: enderecos.salvos.isEmpty
                          ? null
                          : enderecos.atual.nome,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EnderecosPage(),
                        ),
                      ),
                    ),
                    ItemLista(
                      icone: TablerIcons.credit_card,
                      texto: 'Pagamento',
                      valor: pagamentos.padrao?.curto ?? 'Adicionar',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PagamentoPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                GrupoLista(
                  titulo: 'Conta',
                  itens: [
                    ItemLista(
                      icone: TablerIcons.star,
                      texto: 'Minhas avaliações',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MinhasAvaliacoesPage(),
                        ),
                      ),
                    ),
                    ItemLista(
                      icone: TablerIcons.bell,
                      texto: 'Notificações',
                      valor: notificacoes.ativas ? 'Ativadas' : 'Desativadas',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificacoesPage(),
                        ),
                      ),
                    ),
                    ItemLista(
                      icone: TablerIcons.user,
                      texto: 'Dados da conta',
                      onTap: () => emBreve('Dados da conta'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GrupoLista(
                  itens: [
                    ItemLista(
                      icone: TablerIcons.help_circle,
                      texto: 'Ajuda',
                      onTap: () => emBreve('Ajuda'),
                    ),
                    ItemLista(
                      icone: TablerIcons.lock,
                      texto: 'Privacidade e termos',
                      onTap: () => emBreve('Privacidade e termos'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GrupoLista(
                  itens: [
                    ItemLista(
                      icone: TablerIcons.logout,
                      texto: 'Sair da conta',
                      cor: TatuColors.danger,
                      seta: false,
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const BoasVindasPage(),
                        ),
                        (_) => false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
