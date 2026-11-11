import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../profissional/trocar_modo.dart';
import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/conta.dart';
import '../../data/enderecos.dart';
import '../../data/notificacoes.dart';
import '../../data/pagamentos.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../../shared/widgets/avatar_usuario.dart';
import '../../shared/widgets/grupo_cartao.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../entrada/boas_vindas_page.dart';
import 'abas.dart';
import 'ajuda/ajuda_page.dart';
import 'avaliacoes/minhas_avaliacoes_page.dart';
import 'conta/dados_conta_page.dart';
import 'endereco/enderecos_page.dart';
import 'foto/foto_perfil_sheet.dart';
import 'notificacoes/notificacoes_page.dart';
import 'pagamento/pagamento_page.dart';
import 'privacidade/privacidade_page.dart';

/// Perfil do cliente: dados, troca de modo e atalhos da conta.
class PerfilClientePage extends StatelessWidget {
  const PerfilClientePage({super.key, this.nota = '4,8', this.pedidos = 23});

  final String nota;
  final int pedidos;

  @override
  Widget build(BuildContext context) {
    void emBreve(String o) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$o: em breve')));

    return ListenableBuilder(
      listenable: Listenable.merge([
        conta,
        enderecos,
        pagamentos,
        notificacoes,
      ]),
      builder: (context, _) => _tela(context, emBreve),
    );
  }

  Widget _tela(BuildContext context, void Function(String) emBreve) {
    return Scaffold(
      backgroundColor: TatuColors.surfaceGrouped,
      bottomNavigationBar: const AbasDoCliente(ativa: AbaCliente.inicio),
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
                  child: Semantics(
                    button: true,
                    label: 'Foto do perfil',
                    child: GestureDetector(
                      onTap: () => trocarFotoDoPerfil(context),
                      child: AvatarUsuario(
                        tamanho: TatuMedidas.avatarPerfil,
                        camera: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        conta.nomeCompleto,
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
                      onTap: () => trocarParaModoProfissional(context),
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
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DadosContaPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GrupoLista(
                  itens: [
                    ItemLista(
                      icone: TablerIcons.help_circle,
                      texto: 'Ajuda',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AjudaPage()),
                      ),
                    ),
                    ItemLista(
                      icone: TablerIcons.lock,
                      texto: 'Privacidade e termos',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacidadePage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CartaoBotao(
                  texto: 'Sair da conta',
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const BoasVindasPage()),
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
