import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/conversas_profissional.dart';
import '../../../shared/widgets/abas_cliente.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/chat.dart';
import '../../../shared/widgets/estado_vazio.dart';
import '../../../shared/widgets/linha_do_tempo.dart';
import '../abas.dart';
import '../chamado/chat_profissional_page.dart';

/// Aba Mensagens do profissional: conversas em andamento e anteriores.
class MensagensProfissionalPage extends StatefulWidget {
  const MensagensProfissionalPage({super.key});

  @override
  State<MensagensProfissionalPage> createState() =>
      _MensagensProfissionalPageState();
}

class _MensagensProfissionalPageState extends State<MensagensProfissionalPage> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _abrir(ConversaProfissional c) {
    conversasProfissional.marcarLida(c);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatProfissionalPage(
          chamado: c.chamado,
          concluidoPor: c.concluidaPor,
          concluidoEm: c.concluidaEm,
          depois: c.depois,
          diaDepois: c.diaDepois,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AbasDoProfissional(
        ativa: AbaCliente.mensagens,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: ListenableBuilder(
              listenable: conversasProfissional,
              builder: (context, _) => _conteudo(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    const titulo = Padding(
      padding: EdgeInsets.fromLTRB(
        TatuMedidas.margem,
        TatuMedidas.entreSecoes + 8,
        TatuMedidas.margem,
        0,
      ),
      child: Text('Mensagens', style: TatuTexto.tituloGrande),
    );
    if (conversasProfissional.conversas.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          Expanded(
            child: EstadoVazio(
              icone: TablerIcons.message_circle,
              titulo: 'Nenhuma conversa ainda',
              texto:
                  'Quando você aceitar um chamado,\n'
                  'a conversa com o cliente aparece aqui.',
            ),
          ),
        ],
      );
    }

    final termo = _busca.text.trim().toLowerCase();
    bool combina(ConversaProfissional c) =>
        termo.isEmpty || c.nome.toLowerCase().contains(termo);
    final andamento = conversasProfissional.emAndamento.where(combina);
    final anteriores = conversasProfissional.anteriores.where(combina);

    Widget linha(ConversaProfissional c) => LinhaConversa(
      nome: c.nome,
      iniciais: c.nome,
      ultima: c.ultima,
      quando: c.quando,
      naoLidas: c.naoLidas,
      selo: switch (c.selo) {
        SeloConversa.nenhum => null,
        SeloConversa.combinado => SeloVerde(c.textoSelo, pequeno: true),
        SeloConversa.proposta => SeloVerde(
          c.textoSelo,
          aviso: true,
          pequeno: true,
        ),
      },
      onTap: () => _abrir(c),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
      children: [
        titulo,
        const SizedBox(height: TatuMedidas.entreItens),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TatuMedidas.margem),
          child: CampoBusca(
            hint: 'Buscar conversa',
            controller: _busca,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (andamento.isNotEmpty) ...[
          const _Grupo('Em andamento'),
          for (final c in andamento) linha(c),
        ],
        if (anteriores.isNotEmpty) ...[
          const _Grupo('Anteriores'),
          for (final c in anteriores) linha(c),
        ],
        if (andamento.isEmpty && anteriores.isEmpty)
          const Padding(
            padding: EdgeInsets.all(TatuMedidas.entreSecoes),
            child: Text(
              'Nenhuma conversa com esse nome.',
              textAlign: TextAlign.center,
              style: TatuTexto.detalhe,
            ),
          ),
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
