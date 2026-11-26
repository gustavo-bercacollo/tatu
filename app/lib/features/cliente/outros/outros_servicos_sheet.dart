import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servicos.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/icone_profissao.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_chip.dart';
import '../../../data/profissional.dart';
import '../../../data/sugestoes_profissao.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/tatu_field.dart';

/// Folha "Outros serviços": lista por grupos, busca e "Não sei qual
/// serviço". Devolve o nome escolhido ou [naoSeiServico].
/// Com [profissional], é a lista "Outras profissões" do cadastro do
/// profissional (sem "Não sei qual serviço").
Future<String?> escolherOutroServico(
  BuildContext context, {
  bool profissional = false,
  bool distancia = false,
}) => mostrarFolha<String>(
  context,
  alturaRelativa: 0.93,
  builder: (_) =>
      _FolhaOutros(profissional: profissional, distancia: distancia),
);

class _FolhaOutros extends StatefulWidget {
  const _FolhaOutros({this.profissional = false, this.distancia = false});

  final bool profissional;

  /// RN-92: cliente no modo à distância vê só serviços à distância.
  final bool distancia;

  @override
  State<_FolhaOutros> createState() => _FolhaOutrosState();
}

class _FolhaOutrosState extends State<_FolhaOutros> {
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _escolher(String nome) => Navigator.of(context).pop(nome);

  @override
  Widget build(BuildContext context) {
    final termo = _busca.text.trim();
    // RN-92: o cliente só acha o que atende no modo escolhido.
    final achados = buscarServicos(
      termo,
      profissional: widget.profissional,
      distancia: widget.profissional ? null : widget.distancia,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          TatuMedidas.margem,
          10,
          TatuMedidas.margem,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AlcaFolha(),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.profissional
                        ? 'Outras profissões'
                        : 'Outros serviços',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Fechar',
                  child: Material(
                    color: TatuColors.fill,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(TablerIcons.x, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TatuMedidas.entreItens + 4),
            CampoBusca(
              hint: widget.profissional ? 'Buscar profissão' : 'Buscar serviço',
              controller: _busca,
              onChanged: (_) => setState(() {}),
            ),
            Expanded(
              child: termo.isEmpty
                  ? _lista()
                  : achados.isEmpty
                  ? _nadaEncontrado()
                  : _resultados(achados),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              top: TatuMedidas.entreSecoes,
              bottom: TatuMedidas.entreSecoes,
            ),
            children: [
              ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    TatuMedidas.tituloSecao,
                  ),
                  child: Text(
                    widget.profissional
                        ? 'MAIS PROCURADAS'
                        : widget.distancia
                        ? 'MAIS PEDIDOS À DISTÂNCIA'
                        : 'MAIS PEDIDOS PERTO DE VOCÊ',
                    style: TatuTexto.secao,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s
                        in widget.profissional
                            ? maisProcuradas
                            : widget.distancia
                            ? maisPedidosDistancia
                            : maisPedidos)
                      TatuChip(
                        label: s,
                        profissao: s,
                        onTap: () => _escolher(s),
                      ),
                  ],
                ),
              ],
              // RN-161: segmentos de docs/catalogo-de-servicos.md.
              for (final (titulo, lista) in [
                if (widget.profissional) ...[
                  ...gruposProfissoes,
                  // RN-156: reguladas que não estão no catálogo.
                  (
                    'Com registro profissional',
                    [
                      for (final s in servicosRegulados)
                        if (!gruposProfissoes.any(
                          (g) => g.$2.any((x) => x.nome == s.nome),
                        ))
                          s,
                    ],
                  ),
                ] else
                  // RN-92/RN-161: todas as profissões do modo, por
                  // segmento.
                  ...gruposDoModo(distancia: widget.distancia),
              ])
                if (lista.isNotEmpty) ...[
                  const SizedBox(height: TatuMedidas.entreSecoes),
                  GrupoLista(
                    titulo: titulo,
                    fundo: TatuColors.surfaceGrouped,
                    itens: [
                      for (final s in lista)
                        ItemLista(
                          // RN-227: 52 px na seleção.
                          iconeWidget: IconeProfissaoQuadrado(
                            s.nome,
                            fundo: TatuColors.bg,
                          ),
                          texto: s.nome,
                          seta: false,
                          onTap: () => _escolher(s.nome),
                        ),
                    ],
                  ),
                ],
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: TatuMedidas.entreItens + 4),
        if (widget.profissional)
          _NaoAchei(onTap: _sugerir)
        else
          _NaoSei(onTap: () => _escolher(naoSeiServico)),
        const SizedBox(height: TatuMedidas.base),
      ],
    );
  }

  /// RN-162: "Não achei a minha": sugere a profissão ao Tatu.
  Future<void> _sugerir() async {
    final nome = await sugerirProfissao(context, inicial: _busca.text.trim());
    if (nome == null || !mounted) return;
    Navigator.of(context).pop();
  }

  Widget _resultados(List<ServicoCatalogo> achados) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: TatuMedidas.entreSecoes),
      children: [
        GrupoLista(
          titulo: 'Resultados',
          fundo: TatuColors.surfaceGrouped,
          itens: [
            for (final s in achados)
              ItemLista(
                // RN-227: 52 px na seleção.
                iconeWidget: IconeProfissaoQuadrado(
                  s.nome,
                  fundo: TatuColors.bg,
                ),
                texto: s.nome,
                detalhe: s.detalhe,
                seta: false,
                onTap: () => _escolher(s.nome),
              ),
          ],
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        if (widget.profissional)
          _NaoAchei(onTap: _sugerir)
        else
          _NaoSei(onTap: () => _escolher(naoSeiServico)),
      ],
    );
  }

  Widget _nadaEncontrado() {
    return ListView(
      padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes * 2),
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: TatuColors.fill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              TablerIcons.search,
              size: 32,
              color: TatuColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: TatuMedidas.entreSecoes),
        Text(
          widget.profissional
              ? 'Não achamos essa profissão'
              : 'Não achamos esse serviço',
          textAlign: TextAlign.center,
          style: TatuTexto.tituloFolha,
        ),
        const SizedBox(height: 8),
        Text(
          widget.profissional
              ? 'Sugira essa profissão e avisamos\nquando ela entrar no Tatu.'
              : 'Toque abaixo e a gente procura quem\nresolve pela sua descrição.',
          textAlign: TextAlign.center,
          style: TatuTexto.corpo,
        ),
        const SizedBox(height: TatuMedidas.entreSecoes + 8),
        if (!widget.profissional)
          _NaoSei(onTap: () => _escolher(naoSeiServico)),
        const SizedBox(height: TatuMedidas.entreItens),
        Center(
          child: LinkAzul(
            widget.profissional
                ? 'Sugerir essa profissão ao Tatu'
                : 'Sugerir esse serviço ao Tatu',
            onTap: widget.profissional
                ? _sugerir
                : () => mostrarAvisoTopo(
                    context,
                    titulo: 'Sugestão enviada',
                    texto: 'Obrigado! Vamos avaliar esse serviço.',
                  ),
          ),
        ),
      ],
    );
  }
}

/// Cartão "Não sei qual serviço": a gente descobre pela descrição.
class _NaoSei extends StatelessWidget {
  const _NaoSei({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(TablerIcons.sparkles, size: 22),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Não sei qual serviço',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'A gente descobre pela sua descrição',
                      style: TatuTexto.nota,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RN-162: rodapé "Não achei a minha · Sugerir uma profissão ao Tatu".
class _NaoAchei extends StatelessWidget {
  const _NaoAchei({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BotaoTracejado(
    texto: 'Não achei a minha',
    detalhe: 'Sugerir uma profissão ao Tatu',
    onTap: onTap,
  );
}

/// C13 · RN-162: "Sugerir profissão": o nome vai para a fila do suporte e
/// fica em análise no perfil do profissional. Devolve o nome enviado.
Future<String?> sugerirProfissao(BuildContext context, {String inicial = ''}) =>
    mostrarFolha<String>(
      context,
      builder: (_) => _FolhaSugerir(inicial: inicial),
    );

class _FolhaSugerir extends StatefulWidget {
  const _FolhaSugerir({this.inicial = ''});

  final String inicial;

  @override
  State<_FolhaSugerir> createState() => _FolhaSugerirState();
}

class _FolhaSugerirState extends State<_FolhaSugerir> {
  late final _nome = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _enviar() {
    final s = sugestoesProfissao.sugerir(
      _nome.text,
      profissional: profissional.nome,
    );
    if (s == null) return;
    Navigator.of(context).pop(s.nome);
    mostrarAvisoTopo(
      context,
      titulo: 'Sugestão enviada',
      texto: '${s.nome} fica em análise.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ok = _nome.text.trim().length >= RegrasSugestao.minimoLetras;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TatuMedidas.margemCadastro,
            10,
            TatuMedidas.margemCadastro,
            TatuMedidas.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AlcaFolha(),
              const SizedBox(height: 22),
              const Text('Sugerir profissão', style: TatuTexto.tituloFolha),
              const SizedBox(height: 4),
              const Text(
                'Analisamos e colocamos no Tatu.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              TatuField(
                label: 'Nome da profissão',
                controller: _nome,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _enviar(),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              const Text(
                // RN-162.
                'Fica em análise por até ${RegrasSugestao.diasUteis} dias úteis.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              FilledButton(
                onPressed: ok ? _enviar : null,
                child: const Text('Enviar sugestão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
