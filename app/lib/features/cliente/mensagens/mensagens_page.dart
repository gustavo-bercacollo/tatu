import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../plano_fixo/plano_fixo.dart' show tornarFixo, textoTornarFixo;
import '../../../shared/widgets/menu_contexto.dart';
import '../../../shared/widgets/selo_plano_fixo.dart';
import '../../../data/plano_fixo.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/canal_tatu.dart';
import '../../../data/conversas.dart';
import '../../entrada/canal_tatu_page.dart';
import '../home_page.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/chat.dart';
import '../abas.dart';
import 'chat_page.dart';
import '../../entrada/chat_encerrado.dart';

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

  /// RN-115 a RN-118: abre o canal do Tatu.
  void _abrirTatu() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CanalTatuPage(
        canal: canalTatu.cliente,
        onDestino: abrirDestinoTatuCliente,
      ),
    ),
  );

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
              listenable: Listenable.merge([conversas, planosFixos]),
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
    // RN-115: o canal do Tatu fica fixado no topo; Mensagens nunca fica
    // vazia (as telas de vazio ficam para quando não houver canal).
    final tatu = LinhaCanalTatu(canal: canalTatu.cliente, onTap: _abrirTatu);
    if (conversas.conversas.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          const SizedBox(height: TatuMedidas.entreItens),
          tatu,
          const Expanded(
            child: Center(
              child: Text(
                'Quando você aceitar um profissional,\n'
                'a conversa aparece aqui.',
                textAlign: TextAlign.center,
                style: TatuTexto.detalhe,
              ),
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
          tatu,
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
          if (termo.isEmpty || 'tatu'.contains(termo)) ...[
            const SizedBox(height: 8),
            tatu,
          ],
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

/// RN-208: o que dá para fazer segurando a conversa.
enum _AcaoConversa { perfil, plano, pedirDeNovo }

class _LinhaConversa extends StatefulWidget {
  const _LinhaConversa({required this.conversa, required this.onTap});

  final Conversa conversa;
  final VoidCallback onTap;

  @override
  State<_LinhaConversa> createState() => _LinhaConversaState();
}

class _LinhaConversaState extends State<_LinhaConversa> {
  final _chave = GlobalKey();

  Conversa get conversa => widget.conversa;

  /// C214 · RN-208: segurar a conversa: "Ver perfil", "Tornar [nome]
  /// fixa" (ou "Ver plano fixo") e "Pedir de novo". Qualquer profissão.
  Future<void> _segurar() async {
    final c = conversa;
    final da = c.feminino ? 'da' : 'do';
    final temPlano = planosFixos.planoCom(c.nome) != null;
    final acao = await mostrarMenuContexto<_AcaoConversa>(
      context,
      alvo: _chave,
      destaque: _linha(segurar: false),
      itens: [
        ItemMenuContexto(
          _AcaoConversa.perfil,
          TablerIcons.user,
          'Ver perfil $da ${c.primeiroNome}',
        ),
        ItemMenuContexto(
          _AcaoConversa.plano,
          TablerIcons.calendar_repeat,
          temPlano
              ? 'Ver plano fixo'
              : textoTornarFixo(c.nome, c.feminino),
        ),
        const ItemMenuContexto(
          _AcaoConversa.pedirDeNovo,
          TablerIcons.refresh,
          'Pedir de novo',
        ),
      ],
    );
    if (acao == null || !mounted) return;
    switch (acao) {
      case _AcaoConversa.perfil:
        verPerfilDaConversa(context, c, voltar: 'Voltar');
      case _AcaoConversa.plano:
        await tornarFixo(
          context,
          profissional: c.nome,
          profissao: c.profissao,
          feminino: c.feminino,
          endereco: c.rua,
        );
      case _AcaoConversa.pedirDeNovo:
        pedirDeNovoDaConversa(context, c);
    }
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _chave, child: _linha(segurar: true));

  Widget _linha({required bool segurar}) => LinhaConversa(
    // RN-132: conta suspensa vira "Conta indisponível".
    nome: conversa.nomeVisivel,
    iniciais: conversa.primeiroNome,
    avatar: conversa.encerrada
        ? const AvatarIndisponivel(tamanho: 48)
        : null,
    ultima: conversa.ultima,
    quando: conversa.quando,
    naoLidas: conversa.naoLidas,
    online: conversa.online && !conversa.encerrada,
    // RN-200/RN-201: selo "Plano fixo" embaixo da última mensagem.
    selo: conversa.encerrada
        ? null
        : SeloPlanoFixo.de(
            planosFixos.ultimoCom(profissional: conversa.nome),
          ),
    onTap: widget.onTap,
    onLongPress: segurar && !conversa.encerrada ? _segurar : null,
  );
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

/// Destinos dos botões do Tatu no modo cliente (RN-117, RN-118).
void abrirDestinoTatuCliente(BuildContext context, String destino) {
  final nav = Navigator.of(context);
  switch (destino) {
    case DestinoTatu.dicas:
      nav.push(MaterialPageRoute(builder: (_) => const DicasTatuPage()));
    case DestinoTatu.distancia:
      nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeClientePage(distancia: true),
        ),
        (_) => false,
      );
  }
}
