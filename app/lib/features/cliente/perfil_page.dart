import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../entrada/boas_vindas_page.dart';

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

    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      bottomNavigationBar: AbasCliente(
        onInicio: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
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
                    Text(
                      '$nota · $pedidos pedidos',
                      style: const TextStyle(
                        fontSize: 15,
                        color: TatuColors.textSecondary,
                      ),
                    ),
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
                      valor: 'Casa',
                      onTap: () => emBreve('Endereços'),
                    ),
                    ItemLista(
                      icone: TablerIcons.credit_card,
                      texto: 'Pagamento',
                      valor: 'Visa 4242',
                      onTap: () => emBreve('Pagamento'),
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
                      onTap: () => emBreve('Minhas avaliações'),
                    ),
                    ItemLista(
                      icone: TablerIcons.bell,
                      texto: 'Notificações',
                      valor: 'Ativadas',
                      onTap: () => emBreve('Notificações'),
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
