import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/servicos.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/campo_busca.dart';
import '../../../shared/widgets/folha.dart';
import '../../../shared/widgets/lista_agrupada.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_chip.dart';

/// Folha "Outros serviços": lista por grupos, busca e "Não sei qual
/// serviço". Devolve o nome escolhido ou [naoSeiServico].
/// Com [profissional], é a lista "Outras profissões" do cadastro do
/// profissional (sem "Não sei qual serviço").
Future<String?> escolherOutroServico(
  BuildContext context, {
  bool profissional = false,
}) => mostrarFolha<String>(
  context,
  alturaRelativa: 0.93,
  builder: (_) => _FolhaOutros(profissional: profissional),
);

class _FolhaOutros extends StatefulWidget {
  const _FolhaOutros({this.profissional = false});

  final bool profissional;

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
    final achados = buscarServicos(termo);
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
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  TatuMedidas.tituloSecao,
                ),
                child: Text(
                  'MAIS PEDIDOS PERTO DE VOCÊ',
                  style: TatuTexto.secao,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in maisPedidos)
                    TatuChip(label: s, onTap: () => _escolher(s)),
                ],
              ),
              for (final (titulo, lista) in gruposServicos) ...[
                const SizedBox(height: TatuMedidas.entreSecoes),
                GrupoLista(
                  titulo: titulo,
                  fundo: TatuColors.surfaceGrouped,
                  itens: [
                    for (final s in lista)
                      ItemLista(
                        icone: s.icone,
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
        if (!widget.profissional) ...[
          const Divider(height: 1),
          const SizedBox(height: TatuMedidas.entreItens + 4),
          _NaoSei(onTap: () => _escolher(naoSeiServico)),
          const SizedBox(height: TatuMedidas.base),
        ],
      ],
    );
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
                icone: s.icone,
                texto: s.nome,
                detalhe: s.detalhe,
                seta: false,
                onTap: () => _escolher(s.nome),
              ),
          ],
        ),
        if (!widget.profissional) ...[
          const SizedBox(height: TatuMedidas.entreSecoes),
          _NaoSei(onTap: () => _escolher(naoSeiServico)),
        ],
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
            onTap: () => mostrarAvisoTopo(
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
