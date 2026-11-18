import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/aceites.dart';
import '../../data/canal_tatu.dart';
import '../../data/conta.dart';
import '../../data/documentos_legais.dart';
import '../../shared/widgets/folha.dart';
import '../../shared/widgets/nota_icone.dart';
import '../../shared/widgets/tela_interna.dart';
import '../../shared/widgets/texto_markdown.dart';

/// RN-150: a conta (uma por CPF, com os dois perfis).
String contaDoAceite() => conta.cpf ?? conta.nomeCompleto;

/// Abre a leitura de um documento.
void abrirDocumento(BuildContext context, TipoDocumento tipo) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DocumentoLegalPage(tipo: tipo)),
    );

/// Espera o documento carregar (do `.md` empacotado).
class _ComDocumento extends StatelessWidget {
  const _ComDocumento({required this.tipo, required this.builder});

  final TipoDocumento tipo;
  final Widget Function(DocumentoLegal d) builder;

  @override
  Widget build(BuildContext context) {
    final pronto = documentosLegais.doc(tipo);
    if (pronto != null) return builder(pronto);
    return FutureBuilder<DocumentoLegal>(
      future: documentosLegais.carregar(tipo),
      builder: (context, s) => s.hasData
          ? builder(s.data!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

/// RN-150: "O essencial…": título e itens com marcador.
class CartaoEssencial extends StatelessWidget {
  const CartaoEssencial({
    super.key,
    required this.titulo,
    required this.itens,
    this.pequeno = false,
  });

  final String titulo;

  /// Itens em markdown simples (**negrito**).
  final List<String> itens;

  /// Versão do cadastro (texto menor e cinza).
  final bool pequeno;

  @override
  Widget build(BuildContext context) {
    final estilo = pequeno
        ? TatuTexto.nota
        : const TextStyle(fontSize: 14, height: 1.4, color: TatuColors.textPrimary);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: TatuColors.surfaceGrouped,
        borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final i in itens)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 7, 10, 0),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: TatuColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: TextoMarkdown.trechos(
                          i,
                          negrito: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      style: estilo,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// C71/C73 · RN-150: documento lido do `.md`: título, versão e data,
/// "O essencial em 1 minuto" e índice pelos títulos "##".
class DocumentoLegalPage extends StatefulWidget {
  const DocumentoLegalPage({
    super.key,
    required this.tipo,
    this.rodape,
    this.voltar = true,
    this.onSeusDados,
  });

  final TipoDocumento tipo;

  /// Barra fixa embaixo (ex.: "Concordo e continuar").
  final Widget? rodape;

  /// RN-151: na versão nova, só sai pelo aceite.
  final bool voltar;

  /// Política: "Ver seus dados e direitos".
  final VoidCallback? onSeusDados;

  @override
  State<DocumentoLegalPage> createState() => _DocumentoLegalPageState();
}

class _DocumentoLegalPageState extends State<DocumentoLegalPage> {
  bool _todas = false;

  void _abrirSecao(DocumentoLegal d, int i) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SecaoDocumentoPage(documento: d, indice: i)),
  );

  @override
  Widget build(BuildContext context) => _ComDocumento(
    tipo: widget.tipo,
    builder: (d) {
      final principais = [
        for (final (i, s) in d.secoes.indexed)
          if (_todas || widget.tipo.principais.contains(s.numero)) (i, s),
      ];
      final tela = TelaInterna(
        titulo: '',
        corpo: ListView(
          padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
          children: [
            Text(d.titulo, style: TatuTexto.tituloGrande),
            const SizedBox(height: 6),
            Text(
              d.rotuloVersao,
              style: TatuTexto.nota.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TatuMedidas.entreSecoes),
            CartaoEssencial(titulo: 'O essencial em 1 minuto', itens: d.essencial),
            const SizedBox(height: TatuMedidas.entreSecoes),
            const Text('ÍNDICE', style: TatuTexto.secao),
            const SizedBox(height: 4),
            for (final (i, s) in principais) ...[
              InkWell(
                onTap: () => _abrirSecao(d, i),
                child: SizedBox(
                  height: TatuMedidas.alturaLinha - 8,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      const Icon(
                        TablerIcons.chevron_right,
                        size: 16,
                        color: TatuColors.chevron,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 0.5),
            ],
            const SizedBox(height: TatuMedidas.entreSecoes),
            if (!_todas)
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _todas = true),
                  child: Text(
                    'Ver todas as ${d.numeradas} seções',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.verified,
                    ),
                  ),
                ),
              ),
            if (widget.onSeusDados != null)
              Center(
                child: TextButton(
                  onPressed: widget.onSeusDados,
                  child: const Text(
                    'Ver seus dados e direitos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.verified,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: TatuMedidas.base),
          ],
        ),
        rodape: widget.rodape,
      );
      return widget.voltar ? tela : PopScope(canPop: false, child: tela);
    },
  );
}

/// C72 · RN-150: uma seção, com anterior e próxima.
class SecaoDocumentoPage extends StatelessWidget {
  const SecaoDocumentoPage({
    super.key,
    required this.documento,
    required this.indice,
  });

  final DocumentoLegal documento;
  final int indice;

  void _ir(BuildContext context, int i) => Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, _, _) => SecaoDocumentoPage(documento: documento, indice: i),
      transitionDuration: Duration.zero,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final d = documento;
    final s = d.secoes[indice];
    final anterior = indice > 0 ? d.secoes[indice - 1] : null;
    final proxima = indice + 1 < d.secoes.length ? d.secoes[indice + 1] : null;
    Widget link(String texto, VoidCallback onTap, {bool direita = false}) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: direita ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TatuColors.verified,
              ),
            ),
          ),
        );
    return TelaInterna(
      titulo: d.titulo,
      corpo: ListView(
        padding: const EdgeInsets.only(top: TatuMedidas.entreSecoes),
        children: [
          Text(
            s.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: TatuMedidas.entreSecoes),
          TextoMarkdown(s.corpo),
          const SizedBox(height: TatuMedidas.entreSecoes),
        ],
      ),
      rodape: Row(
        children: [
          if (anterior != null)
            link('‹ ${anterior.titulo}', () => _ir(context, indice - 1))
          else
            const Spacer(),
          const SizedBox(width: TatuMedidas.entreItens),
          if (proxima != null)
            link('${proxima.titulo} ›', () => _ir(context, indice + 1), direita: true)
          else
            const Spacer(),
        ],
      ),
    );
  }
}

/// RN-150: caixa "Li e concordo com os Termos de Uso e a Política de
/// Privacidade", com os dois links. Começa desmarcada.
class CaixaAceite extends StatelessWidget {
  const CaixaAceite({super.key, required this.marcado, required this.onMudar});

  final bool marcado;
  final ValueChanged<bool> onMudar;

  @override
  Widget build(BuildContext context) {
    const texto = TextStyle(fontSize: 15);
    const link = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: TatuColors.verified,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: marcado,
          label: 'Li e concordo com os Termos de Uso e a Política de Privacidade',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () => onMudar(!marcado),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: marcado ? TatuColors.action : TatuColors.bg,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: marcado ? TatuColors.action : TatuColors.chevron,
                  width: 1.5,
                ),
              ),
              child: marcado
                  ? const Icon(TablerIcons.check, size: 18, color: TatuColors.onAction)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onMudar(!marcado),
                  child: const Text('Li e concordo com os ', style: texto),
                ),
                GestureDetector(
                  onTap: () => abrirDocumento(context, TipoDocumento.termos),
                  child: const Text('Termos de Uso', style: link),
                ),
                const Text(' e a ', style: texto),
                GestureDetector(
                  onTap: () => abrirDocumento(context, TipoDocumento.politica),
                  child: const Text('Política de Privacidade.', style: link),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// RN-151: documentos com versão nova que esta conta ainda não aceitou.
List<DocumentoLegal> documentosParaAceitar(TipoAceite tipo, {DateTime? agora}) {
  final t = documentosLegais.termos, p = documentosLegais.politica;
  if (t == null || p == null) return const [];
  final a = aceites.ultimo(contaDoAceite(), tipo);
  if (!aceites.precisaAceitar(
    conta: contaDoAceite(),
    tipo: tipo,
    termos: t,
    politica: p,
    agora: agora,
  )) {
    return const [];
  }
  return [
    if (a == null || a.versaoTermos != versaoVigente(t, agora)) t,
    if (a == null || a.versaoPolitica != versaoVigente(p, agora)) p,
  ];
}

/// RN-151: ao abrir o app (Home), confere se há versão nova vigente; se
/// houver, bloqueia até "Concordo e continuar". Versões futuras são
/// avisadas pelo canal do Tatu.
Future<void> verificarDocumentos(
  BuildContext context, {
  required TipoAceite tipo,
}) async {
  await documentosLegais.carregarTodos();
  final canal = tipo == TipoAceite.cliente ? canalTatu.cliente : canalTatu.profissional;
  for (final d in [documentosLegais.termos!, documentosLegais.politica!]) {
    aceites.avisarVersaoFutura(d, canal: canal);
  }
  final novos = documentosParaAceitar(tipo);
  if (novos.isEmpty || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TermosAtualizadosPage(documento: novos.first, tipo: tipo),
    ),
  );
}

/// C74 · RN-151: "Atualizamos os Termos de uso": o que mudou e o aceite.
/// O app fica bloqueado até "Concordo e continuar".
class TermosAtualizadosPage extends StatefulWidget {
  const TermosAtualizadosPage({
    super.key,
    required this.documento,
    required this.tipo,
  });

  final DocumentoLegal documento;
  final TipoAceite tipo;

  @override
  State<TermosAtualizadosPage> createState() => _TermosAtualizadosPageState();
}

class _TermosAtualizadosPageState extends State<TermosAtualizadosPage> {
  /// Fechou a folha para ler tudo: o aceite fica fixo embaixo.
  bool _lendo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _folha());
  }

  /// Registra o novo aceite (as duas versões vigentes) e libera o app.
  void _concordar() {
    aceites.registrar(
      conta: contaDoAceite(),
      tipo: widget.tipo,
      termos: documentosLegais.termos!,
      politica: documentosLegais.politica!,
    );
    Navigator.of(context).pop();
  }

  Future<void> _folha() async {
    final d = widget.documento;
    final concordou = await mostrarFolha<bool>(
      context,
      fechavel: false,
      builder: (ctx) => SafeArea(
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
              const SizedBox(height: TatuMedidas.entreSecoes),
              const Center(
                child: IconeResultado(
                  TablerIcons.file_text,
                  fundo: TatuColors.surfaceGrouped,
                ),
              ),
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Text(
                'Atualizamos os ${d.titulo}',
                textAlign: TextAlign.center,
                style: TatuTexto.tituloFolha,
              ),
              if (d.desta != null) ...[
                const SizedBox(height: TatuMedidas.entreSecoes),
                Text('O que mudou', style: TatuTexto.grupo),
                const SizedBox(height: 6),
                for (final item in d.desta!.itens)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(2, 8, 10, 0),
                          child: CircleAvatar(
                            radius: 2.5,
                            backgroundColor: TatuColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(item, style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: TatuMedidas.entreItens + 4),
              Text(
                'Vale a partir de ${dataPorExtenso(d.vigencia)}.',
                style: TatuTexto.nota,
              ),
              const SizedBox(height: TatuMedidas.entreSecoes),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Concordo e continuar'),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    d.tipo == TipoDocumento.termos
                        ? 'Ler os termos completos'
                        : 'Ler a política completa',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TatuColors.verified,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (concordou == true) return _concordar();
    setState(() => _lendo = true);
  }

  @override
  Widget build(BuildContext context) => DocumentoLegalPage(
    tipo: widget.documento.tipo,
    voltar: false,
    // Leu tudo: o aceite fica fixo embaixo.
    rodape: _lendo
        ? FilledButton(
            onPressed: _concordar,
            child: const Text('Concordo e continuar'),
          )
        : null,
  );
}
