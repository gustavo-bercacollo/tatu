import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../abas.dart';
import 'chat_page.dart';

/// Aba Mensagens: conversas com os profissionais.
class MensagensPage extends StatefulWidget {
  const MensagensPage({super.key});

  @override
  State<MensagensPage> createState() => _MensagensPageState();
}

class _MensagensPageState extends State<MensagensPage> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _abrir(Conversa c) {
    conversas.marcarLida(c);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChatPage(conversa: c)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AbasDoCliente(ativa: AbaCliente.mensagens),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: ListenableBuilder(
              listenable: conversas,
              builder: (context, _) => _conteudo(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    const margem = EdgeInsets.symmetric(horizontal: TatuMedidas.margem);
    const titulo = Padding(
      padding: EdgeInsets.fromLTRB(
        TatuMedidas.margem,
        TatuMedidas.entreSecoes + 8,
        TatuMedidas.margem,
        0,
      ),
      child: Text('Mensagens', style: TatuTexto.tituloGrande),
    );
    if (conversas.conversas.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          Expanded(
            child: EstadoVazio(
              icone: TablerIcons.message_circle,
              titulo: 'Nenhuma conversa ainda',
              texto: 'Quando você aceitar um profissional,\na conversa aparece aqui.',
            ),
          ),
        ],
      );
    }

    final termo = _busca.text.trim().toLowerCase();
    bool combina(Conversa c) =>
        termo.isEmpty || c.nome.toLowerCase().contains(termo);
    final andamento = conversas.emAndamento.where(combina).toList();
    final anteriores = conversas.anteriores.where(combina).toList();
    final cobranca = conversas.cobrancaPendente
        ? conversas.emAndamento.firstOrNull
        : null;

    return ListView(
      padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
      children: [
        titulo,
        const SizedBox(height: TatuMedidas.entreItens),
        if (cobranca != null) ...[
          Padding(
            padding: margem,
            child: _CobrancaPendente(conversa: cobranca),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          for (final c in conversas.conversas)
            _LinhaConversa(conversa: c, onTap: () => _abrir(c)),
        ] else ...[
          Padding(
            padding: margem,
            child: CampoBusca(
              hint: 'Buscar conversa',
              controller: _busca,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (andamento.isNotEmpty) ...[
            const _Grupo('Em andamento'),
            for (final c in andamento)
              _LinhaConversa(conversa: c, onTap: () => _abrir(c)),
          ],
          if (anteriores.isNotEmpty) ...[
            const _Grupo('Anteriores'),
            for (final c in anteriores)
              _LinhaConversa(conversa: c, onTap: () => _abrir(c)),
          ],
        ],
      ],
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TatuMedidas.margem,
      TatuMedidas.entreSecoes,
      TatuMedidas.margem,
      TatuMedidas.tituloSecao,
    ),
    child: Text(texto, style: TatuTexto.grupo),
  );
}

class _LinhaConversa extends StatelessWidget {
  const _LinhaConversa({required this.conversa, required this.onTap});

  final Conversa conversa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = conversa;
    final naoLida = c.naoLidas > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: TatuMedidas.margem),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarIniciais(nome: c.primeiroNome, tamanho: 48),
                if (c.online)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: TatuColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: TatuColors.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  14,
                  TatuMedidas.margem,
                  14,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TatuColors.trilho, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.nome,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.ultima,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TatuTexto.detalhe.copyWith(
                              color: naoLida
                                  ? TatuColors.textPrimary
                                  : TatuColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(c.quando, style: TatuTexto.nota),
                        const SizedBox(height: 6),
                        if (naoLida)
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: TatuColors.action,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${c.naoLidas}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: TatuColors.onAction,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CobrancaPendente extends StatelessWidget {
  const _CobrancaPendente({required this.conversa});

  final Conversa conversa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TatuColors.bg,
        borderRadius: BorderRadius.circular(TatuMedidas.raioOpcao),
        border: Border.all(color: TatuColors.textPrimary, width: 2),
      ),
      child: Row(
        children: [
          AvatarIniciais(nome: conversa.nome),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cobrança pendente', style: TatuTexto.nota),
                const SizedBox(height: 2),
                Text(
                  'R\$ 150,00 · ${conversa.primeiroNome}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, TatuMedidas.alturaBusca),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
            onPressed: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Pagamento: em breve')),
              ),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }
}
