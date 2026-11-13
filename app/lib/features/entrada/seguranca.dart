import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/ajuda.dart';
import '../../data/seguranca.dart';
import '../../data/pedidos.dart';
import '../../shared/widgets/avatar_iniciais.dart';
import '../../shared/widgets/aviso_topo.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/lista_agrupada.dart';
import '../../shared/widgets/nota_icone.dart';
import '../../shared/widgets/opcao_selecionavel.dart';
import '../../shared/widgets/tela_interna.dart';
import '../../shared/widgets/tela_permissao.dart';
import '../../shared/widgets/abas_cliente.dart';
import '../cliente/abas.dart';
import '../cliente/ajuda/chat_suporte_page.dart';
import '../profissional/cadastro/resultado_page.dart' show abrirHomeProfissional;
import '../profissional/servico/rota.dart' show abrirLink;

/// Liga para um número (190, 180).
Future<void> ligar(String numero) => abrirLink(Uri.parse('tel:$numero'));

/// Escudo no topo do atendimento: toque abre "Segurança"; segurar por
/// [segurarPor] dispara o alerta silencioso. Fica vermelho com o alerta.
class BotaoEscudo extends StatefulWidget {
  const BotaoEscudo({super.key, required this.servico});

  final Atendimento servico;

  static const segurarPor = Duration(seconds: 3);

  @override
  State<BotaoEscudo> createState() => _BotaoEscudoState();
}

class _BotaoEscudoState extends State<BotaoEscudo> {
  Timer? _segurando;
  bool _disparou = false;

  void _inicio() {
    _disparou = false;
    _segurando = Timer(BotaoEscudo.segurarPor, () {
      _disparou = true;
      HapticFeedback.heavyImpact();
      _acionarAlerta(context);
    });
  }

  void _fim() {
    _segurando?.cancel();
    _segurando = null;
  }

  @override
  void dispose() {
    _segurando?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: seguranca,
      builder: (_, _) {
        final ativo = seguranca.alertaAtivo;
        return Semantics(
          button: true,
          label: 'Segurança',
          child: GestureDetector(
            onTapDown: (_) => _inicio(),
            onTapCancel: _fim,
            onTapUp: (_) {
              _fim();
              if (!_disparou) abrirSeguranca(context, widget.servico);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ativo ? TatuColors.danger : TatuColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                TablerIcons.shield_check,
                size: 20,
                color: ativo ? TatuColors.onAction : TatuColors.danger,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pílula "Alerta ativo · 2 contatos" embaixo do título.
class SeloAlertaAtivo extends StatelessWidget {
  const SeloAlertaAtivo({super.key});

  @override
  Widget build(BuildContext context) {
    final n = seguranca.contatos.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const ShapeDecoration(
        color: TatuColors.dangerSoft,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TatuColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Alerta ativo · $n ${n == 1 ? 'contato' : 'contatos'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TatuColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _acionarAlerta(BuildContext context) {
  seguranca.acionarAlerta();
  final n = seguranca.contatos.length;
  mostrarAvisoTopo(
    context,
    titulo: 'Alerta enviado',
    texto: n == 0
        ? 'O Tatu já está acompanhando.'
        : 'Seus $n contatos e o Tatu foram avisados.',
  );
}

/// Folha "Segurança": 190, 180, alerta silencioso e sair agora.
Future<void> abrirSeguranca(BuildContext context, Atendimento s) async {
  final escolha = await mostrarFolha<String>(
    context,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TatuColors.dangerSoft,
                  child: Icon(
                    TablerIcons.shield_check,
                    size: 20,
                    color: TatuColors.danger,
                  ),
                ),
                SizedBox(width: 12),
                Text('Segurança', style: TatuTexto.tituloFolha),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: TatuColors.fill,
                borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
              ),
              child: Column(
                children: [
                  _LinhaSeguranca(
                    icone: TablerIcons.phone,
                    titulo: 'Ligar 190',
                    detalhe: 'Polícia, em caso de perigo',
                    perigo: true,
                    onTap: () => Navigator.of(ctx).pop('190'),
                  ),
                  const _Divisor(),
                  _LinhaSeguranca(
                    icone: TablerIcons.phone,
                    titulo: 'Ligar 180',
                    detalhe: 'Central de Atendimento à Mulher',
                    onTap: () => Navigator.of(ctx).pop('180'),
                  ),
                  const _Divisor(),
                  _LinhaSeguranca(
                    icone: TablerIcons.bell,
                    titulo: 'Alerta silencioso',
                    detalhe: 'Avisa seus contatos e o Tatu',
                    onTap: () => Navigator.of(ctx).pop('alerta'),
                  ),
                  const _Divisor(),
                  _LinhaSeguranca(
                    icone: TablerIcons.logout,
                    titulo: 'Sair agora',
                    detalhe: 'Encerra sem perder nada',
                    onTap: () => Navigator.of(ctx).pop('sair'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const NotaIcone(
              icone: TablerIcons.help_circle,
              texto: 'Segure o escudo por 3 s para o alerta silencioso.',
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    ),
  );
  if (escolha == null || !context.mounted) return;
  final nav = Navigator.of(context);
  switch (escolha) {
    case '190':
      nav.push(MaterialPageRoute(builder: (_) => Ligar190Page(servico: s)));
    case '180':
      await ligar('180');
    case 'alerta':
      _acionarAlerta(context);
    case 'sair':
      await sairDoAtendimento(context, s);
  }
}

/// "Sair do atendimento agora?" → "Você saiu do atendimento".
Future<void> sairDoAtendimento(BuildContext context, Atendimento s) async {
  final ela = s.outroFeminino;
  final sair = await mostrarFolha<bool>(
    context,
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          TatuMedidas.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text(
              'Sair do atendimento agora?',
              style: TatuTexto.tituloFolha,
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            LinhaConsequencia(
              TablerIcons.check,
              s.doCliente
                  ? 'Nada é cobrado por sair.'
                  : 'Você não perde pontos nem posição.',
            ),
            LinhaConsequencia(
              TablerIcons.x,
              '${s.papel[0].toUpperCase()}${s.papel.substring(1)} é '
              '${ela ? 'bloqueada' : 'bloqueado'} para você.',
            ),
            const LinhaConsequencia(
              TablerIcons.message_circle,
              'O suporte fala com você em seguida.',
            ),
            const SizedBox(height: 4),
            FilledButton(
              style: tatuBotaoVermelho(),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sair agora'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: tatuBotaoSecundario(),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Continuar atendimento'),
            ),
          ],
        ),
      ),
    ),
  );
  if (sair != true || !context.mounted) return;
  if (s.doCliente) pedidos.cancelarAndamento();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => VoceSaiuPage(servico: s)),
    (r) => r.isFirst,
  );
}

/// Depois de sair: "Você está em um lugar seguro?".
class VoceSaiuPage extends StatelessWidget {
  const VoceSaiuPage({super.key, this.servico = Atendimento.exemplo});

  final Atendimento servico;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margem,
                TatuMedidas.topo,
                TatuMedidas.margem,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 36),
                  Expanded(
                    child: TelaPermissaoCorpo(
                      icone: const Icon(
                        TablerIcons.shield_check,
                        size: 44,
                        color: TatuColors.danger,
                      ),
                      perigo: true,
                      titulo: 'Você saiu do atendimento',
                      texto: 'Você está em um lugar seguro?',
                      extra: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: () {
                              seguranca.encerrarAlerta();
                              servico.doCliente
                                  ? irParaAba(context, AbaCliente.inicio)
                                  : abrirHomeProfissional(context);
                            },
                            child: const Text('Estou bem'),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            style: tatuBotaoVermelho(),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Ligar190Page(servico: servico),
                              ),
                            ),
                            child: const Text('Preciso de ajuda · ligar 190'),
                          ),
                          const SizedBox(height: TatuMedidas.entreSecoes),
                          Center(
                            child: LinkAzul(
                              'Contar o que aconteceu',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatSuportePage(
                                    conteudo: servico.doCliente
                                        ? conteudoCliente
                                        : conteudoProfissional,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'O suporte responde em minutos.',
                            textAlign: TextAlign.center,
                            style: TatuTexto.nota,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Antes de ligar para o 190: o que ler para o atendente. Abrir esta
/// tela já dispara o alerta silencioso.
class Ligar190Page extends StatefulWidget {
  const Ligar190Page({
    super.key,
    this.servico = Atendimento.exemplo,
  });

  final Atendimento servico;

  @override
  State<Ligar190Page> createState() => _Ligar190PageState();
}

class _Ligar190PageState extends State<Ligar190Page> {
  @override
  void initState() {
    super.initState();
    if (!seguranca.alertaAtivo) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => seguranca.acionarAlerta(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servico;
    final complemento = s.complemento;
    return TelaInterna(
      titulo: 'Ligar 190',
      corpo: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TatuColors.dangerSoft,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
            ),
            child: const Row(
              children: [
                Icon(
                  TablerIcons.shield_check,
                  size: 22,
                  color: TatuColors.danger,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Se puder, vá para um lugar seguro.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TatuColors.danger,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Seus contatos já foram avisados.',
                        style: TextStyle(
                          fontSize: 13,
                          color: TatuColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('LEIA PARA O ATENDENTE', style: TatuTexto.secao),
          ),
          const SizedBox(height: TatuMedidas.tituloSecao),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TatuColors.surfaceGrouped,
              borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
            ),
            child: Column(
              children: [
                _Dado(
                  rotulo: 'Onde você está',
                  valor: complemento.isEmpty
                      ? s.rua
                      : '${s.rua} · $complemento',
                  detalhe: s.bairro,
                ),
                const Divider(height: 1, color: TatuColors.hairline),
                _Dado(
                  rotulo: s.doCliente ? 'Profissional' : 'Cliente',
                  valor: s.outro,
                  detalhe: 'Celular ${s.celularOutro}',
                ),
                const Divider(height: 1, color: TatuColors.hairline),
                s.chegouAs.isEmpty
                    ? _Dado(
                        rotulo: 'Pedido',
                        valor: 'nº ${s.pedido}',
                        detalhe: s.descricao,
                      )
                    : _Dado(
                        rotulo: 'Chegou às',
                        valor: s.chegouAs,
                        detalhe: 'Pedido nº ${s.pedido}',
                      ),
              ],
            ),
          ),
        ],
      ),
      rodape: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            style: tatuBotaoVermelho(),
            onPressed: () => ligar('190'),
            child: const Text('Ligar 190 agora'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: tatuBotaoSecundario(),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado({
    required this.rotulo,
    required this.valor,
    required this.detalhe,
  });

  final String rotulo;
  final String valor;
  final String detalhe;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: TatuTexto.nota),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(detalhe, style: TatuTexto.detalhe),
        ],
      ),
    ),
  );
}

/// Linha da folha Segurança: ícone em círculo, título, detalhe e seta.
class _LinhaSeguranca extends StatelessWidget {
  const _LinhaSeguranca({
    required this.icone,
    required this.titulo,
    required this.detalhe,
    required this.onTap,
    this.perigo = false,
  });

  final IconData icone;
  final String titulo;
  final String detalhe;
  final VoidCallback onTap;
  final bool perigo;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: perigo ? TatuColors.danger : TatuColors.bg,
            child: Icon(
              icone,
              size: 18,
              color: perigo ? TatuColors.onAction : TatuColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: perigo ? TatuColors.danger : TatuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detalhe, style: TatuTexto.nota),
              ],
            ),
          ),
          const Icon(
            TablerIcons.chevron_right,
            size: 18,
            color: TatuColors.chevron,
          ),
        ],
      ),
    ),
  );
}

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 0.5,
    indent: 66,
    color: TatuColors.hairline,
  );
}

/// Contatos de confiança: recebem o alerta silencioso e podem acompanhar
/// os atendimentos ao vivo.
class ContatosConfiancaPage extends StatelessWidget {
  const ContatosConfiancaPage({super.key});

  void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  Future<void> _opcoes(BuildContext context, ContatoConfianca c) async {
    final remover = await mostrarFolha<bool>(
      context,
      builder: (ctx) => FolhaOpcoes(
        itens: [
          ItemLista(
            icone: TablerIcons.trash,
            texto: 'Remover ${c.nome.split(' ').first}',
            cor: TatuColors.danger,
            seta: false,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (remover == true) seguranca.remover(c);
  }

  @override
  Widget build(BuildContext context) {
    return TelaInterna(
      titulo: 'Contatos de confiança',
      fundoCinza: true,
      corpo: ListenableBuilder(
        listenable: seguranca,
        builder: (_, _) {
          final contatos = seguranca.contatos;
          final cheio = contatos.length >= SegurancaRepo.maxContatos;
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Text(
                  'Recebem seu alerta silencioso e podem acompanhar seus '
                  'atendimentos ao vivo.',
                  style: TatuTexto.detalhe,
                ),
              ),
              if (contatos.isNotEmpty) ...[
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: TatuColors.bg,
                    borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < contatos.length; i++) ...[
                        if (i > 0) const _Divisor(),
                        _LinhaContato(
                          contato: contatos[i],
                          onOpcoes: () => _opcoes(context, contatos[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: TatuMedidas.entreItens),
              ],
              if (!cheio)
                Material(
                  color: TatuColors.bg,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _emBreve(context, 'Adicionar contato'),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Icon(
                            TablerIcons.plus,
                            size: 22,
                            color: TatuColors.verified,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Adicionar contato',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: TatuColors.verified,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  'Até 5 contatos. Eles recebem um SMS avisando que foram '
                  'adicionados.',
                  style: TatuTexto.nota,
                ),
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  color: TatuColors.bg,
                  borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Compartilhar todo atendimento',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    Semantics(
                      label: 'Compartilhar todo atendimento',
                      toggled: seguranca.compartilharTudo,
                      child: CupertinoSwitch(
                        value: seguranca.compartilharTudo,
                        activeTrackColor: TatuColors.online,
                        inactiveTrackColor: TatuColors.trilho,
                        onChanged: seguranca.definirCompartilhar,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LinhaContato extends StatelessWidget {
  const _LinhaContato({required this.contato, required this.onOpcoes});

  final ContatoConfianca contato;
  final VoidCallback onOpcoes;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
    child: Row(
      children: [
        AvatarIniciais(nome: contato.nome, tamanho: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${contato.nome} · ${contato.relacao}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(contato.celular, style: TatuTexto.detalhe),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Opções de ${contato.nome}',
          onPressed: onOpcoes,
          icon: const Icon(
            TablerIcons.dots,
            size: 20,
            color: TatuColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
