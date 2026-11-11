import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../shared/widgets/avatar_iniciais.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/nota_icone.dart';
import '../../entrada/boas_vindas_page.dart';
import '../home/home_profissional_page.dart';
import 'verificacao_page.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// Abre a Home do profissional limpando o cadastro da pilha.
void abrirHomeProfissional(BuildContext context) => Navigator.of(context)
    .pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeProfissionalPage()),
      (_) => false,
    );

enum EstadoItem { feito, pendente, analise, refazer }

/// Linha da lista "o que passou e o que falta".
class ItemChecklist extends StatelessWidget {
  const ItemChecklist(this.texto, this.estado, {super.key});

  final String texto;
  final EstadoItem estado;

  @override
  Widget build(BuildContext context) {
    final (IconData icone, Color fundo, Color cor) = switch (estado) {
      EstadoItem.feito => (
        TablerIcons.check,
        TatuColors.online,
        TatuColors.onAction,
      ),
      EstadoItem.pendente => (
        TablerIcons.minus,
        TatuColors.fill,
        TatuColors.textSecondary,
      ),
      EstadoItem.analise => (
        TablerIcons.clock,
        TatuColors.fill,
        TatuColors.textPrimary,
      ),
      EstadoItem.refazer => (
        TablerIcons.exclamation_mark,
        TatuColors.warningSoft,
        TatuColors.warningTexto,
      ),
    };
    final forte = estado == EstadoItem.analise || estado == EstadoItem.refazer;
    return SizedBox(
      height: TatuMedidas.alturaLinha + 4,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
            child: Icon(icone, size: 17, color: cor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 17,
                fontWeight: forte ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista com divisórias entre os itens.
class Checklist extends StatelessWidget {
  const Checklist(this.itens, {super.key});

  final List<ItemChecklist> itens;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < itens.length; i++) ...[
        if (i > 0) const Divider(height: 1, indent: 46),
        itens[i],
      ],
    ],
  );
}

/// P15 · Cadastro enviado: verificação em análise.
class EmAnalisePage extends StatefulWidget {
  const EmAnalisePage({super.key});

  @override
  State<EmAnalisePage> createState() => _EmAnalisePageState();
}

class _EmAnalisePageState extends State<EmAnalisePage> {
  Timer? _aprovacao;

  @override
  void dispose() {
    _aprovacao?.cancel();
    super.dispose();
  }

  void _ativarAvisos() {
    mostrarAvisoTopo(
      context,
      titulo: 'Avisos ativados',
      texto: 'Avisamos assim que o cadastro for aprovado.',
    );
    // Protótipo: a aprovação chega alguns segundos depois.
    _aprovacao = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      profissional.definirVerificacao(Verificacao.aprovada);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AprovadoPage()),
        (r) => r.isFirst,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      voltar: false,
      topo: const IconeResultado(TablerIcons.hourglass),
      titulo: 'Recebemos seus dados',
      subtitulo:
          'Estamos verificando seu documento. '
          'Avisamos assim que estiver pronto.',
      botao: 'Ativar avisos',
      onBotao: _aprovacao == null ? _ativarAvisos : null,
      link: 'Explorar o app',
      onLink: () => abrirHomeProfissional(context),
      notaAcimaBotao: null,
      children: [
        Checklist([
          const ItemChecklist('Seus dados', EstadoItem.feito),
          ItemChecklist(
            profissional.profissoes.length > 1
                ? 'Suas profissões'
                : 'Sua profissão',
            EstadoItem.feito,
          ),
          profissional.temPix
              ? const ItemChecklist('Onde receber', EstadoItem.feito)
              : const ItemChecklist(
                  'Onde receber: fazer depois',
                  EstadoItem.pendente,
                ),
          const ItemChecklist('Verificação em análise', EstadoItem.analise),
        ]),
        const SizedBox(height: TatuMedidas.entreSecoes * 2),
        const NotaIcone(
          icone: TablerIcons.bell,
          texto:
              'Ative os avisos para saber na hora quando o seu cadastro '
              'for aprovado.',
        ),
      ],
    );
  }
}

/// P17 · Reprovada, mas dá para corrigir (nova foto).
class RefazerFotoPage extends StatelessWidget {
  const RefazerFotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      voltar: false,
      topo: const IconeResultado(
        TablerIcons.camera,
        fundo: TatuColors.warningSoft,
        cor: TatuColors.warningTexto,
      ),
      titulo: 'Precisamos de uma nova foto',
      subtitulo:
          'A frente do documento ficou escura e não deu para ler os dados.',
      botao: 'Tirar nova foto',
      onBotao: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CameraVerificacaoPage(
            etapa: EtapaFoto.frente,
            refazendo: true,
          ),
        ),
      ),
      link: 'Falar com a gente',
      linkAzul: true,
      onLink: () => _emBreve(context, 'Falar com a gente'),
      children: [
        Checklist([
          const ItemChecklist('Seus dados', EstadoItem.feito),
          const ItemChecklist('Sua profissão', EstadoItem.feito),
          ItemChecklist(
            profissional.temPix ? 'Onde receber' : 'Onde receber: fazer depois',
            profissional.temPix ? EstadoItem.feito : EstadoItem.pendente,
          ),
          const ItemChecklist('Verso do documento', EstadoItem.feito),
          const ItemChecklist('Selfie', EstadoItem.feito),
          const ItemChecklist(
            'Frente do documento: refazer',
            EstadoItem.refazer,
          ),
        ]),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        const NotaIcone(
          icone: TablerIcons.bulb,
          escura: true,
          texto: 'Fique perto de uma janela ou de uma luz forte.',
        ),
      ],
    );
  }
}

/// P18 · Reprovada de vez: só a equipe pode ajudar.
class ReprovadoPage extends StatelessWidget {
  const ReprovadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      voltar: false,
      topo: const IconeResultado(TablerIcons.user_x),
      titulo: 'Não foi possível aprovar seu cadastro',
      subtitulo:
          'Não conseguimos confirmar sua identidade com as informações '
          'enviadas.',
      botao: 'Falar com a gente',
      onBotao: () => _emBreve(context, 'Falar com a gente'),
      link: 'Sair da conta',
      onLink: () {
        profissional.restaurar();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BoasVindasPage()),
          (_) => false,
        );
      },
      children: [
        const Text(
          'Nossa equipe pode ajudar a entender o que aconteceu e ver o que '
          'fazer.',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: const Row(
            children: [
              Icon(TablerIcons.message_circle, size: 20),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Você receberá a resposta por notificação e por mensagem.',
                  style: TextStyle(fontSize: 15, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// P16 · Cadastro aprovado: selo de verificado.
class AprovadoPage extends StatelessWidget {
  const AprovadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = profissional;
    return CadastroScaffold(
      voltar: false,
      topo: const IconeResultado(
        TablerIcons.rosette_discount_check,
        fundo: TatuColors.verified,
        cor: TatuColors.onAction,
      ),
      titulo: 'Cadastro aprovado!',
      subtitulo:
          'Agora você tem o selo de verificado e já pode receber chamados.',
      botao: 'Começar',
      onBotao: () => abrirHomeProfissional(context),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TatuColors.fill,
            borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
          ),
          child: Row(
            children: [
              AvatarIniciais(nome: p.nome, tamanho: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NomeVerificado(p.nome),
                    const SizedBox(height: 2),
                    Text(
                      '${profissaoNoGenero(p.profissaoPrincipal, feminino: p.feminino)}'
                      ' · Perfil verificado',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        const ItemVantagem(
          icone: TablerIcons.wifi,
          titulo: 'Só quem está online recebe chamados',
          texto: 'Fique online quando quiser trabalhar.',
        ),
        const ItemVantagem(
          icone: TablerIcons.bolt,
          titulo: 'Responda rápido',
          texto:
              'Se você não responder, o chamado passa para outro '
              'profissional.',
        ),
      ],
    );
  }
}

/// Nome com o selo azul de verificado.
class NomeVerificado extends StatelessWidget {
  const NomeVerificado(this.nome, {super.key, this.tamanho = 18});

  final String nome;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            nome,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: tamanho, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          TablerIcons.rosette_discount_check_filled,
          size: tamanho + 2,
          color: TatuColors.verified,
          semanticLabel: 'Verificado',
        ),
      ],
    );
  }
}
