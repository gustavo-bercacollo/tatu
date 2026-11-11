import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../core/theme/tatu_theme.dart';
import 'back_circle_button.dart';

/// Esqueleto das telas de cadastro: voltar, título, subtítulo, conteúdo
/// e botão principal fixo embaixo (sobe junto com o teclado).
class CadastroScaffold extends StatelessWidget {
  const CadastroScaffold({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.children,
    this.botao,
    this.onBotao,
    this.botaoSecundario,
    this.onSecundario,
    this.perigo = false,
    this.botaoCinza = false,
    this.subtituloNota = false,
    this.notaBotao,
    this.passo,
    this.etiquetaPasso,
    this.voltar = true,
    this.topo,
    this.notaAcimaBotao,
    this.link,
    this.onLink,
    this.linkAzul = false,
    this.botaoConteudo,
    this.botaoEstilo,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;

  /// Sem [botao], a tela não tem botão embaixo (ex.: documentos).
  final String? botao;

  /// `null` deixa o botão desabilitado.
  final VoidCallback? onBotao;

  /// Botão cinza abaixo do principal (ex.: "Usar e-mail").
  final String? botaoSecundario;
  final VoidCallback? onSecundario;

  /// Botão principal vermelho claro (ex.: "Excluir minha conta").
  final bool perigo;

  /// Botão principal cinza (secundário), ex.: "Falar com o suporte".
  final bool botaoCinza;

  /// Subtítulo pequeno (13 cinza), ex.: "Atualizado em…".
  final bool subtituloNota;

  /// Nota cinza centralizada abaixo dos botões (ex.: "Tenha em mãos…").
  final String? notaBotao;

  /// Cadastro do profissional: passo atual (1 a 4). Mostra a barra ao lado
  /// do voltar e "Passo X de 4" acima do título.
  final int? passo;

  /// Ao lado de "Passo X de 4" (ex.: "Encanador · 1 de 2").
  final Widget? etiquetaPasso;

  /// Sem o botão de voltar (ex.: "Recebemos seus dados").
  final bool voltar;

  /// Acima do título (ex.: ícone grande num círculo).
  final Widget? topo;

  /// Nota cinza centralizada logo acima do botão (ex.: "2 selecionados").
  final String? notaAcimaBotao;

  /// Link de texto abaixo do botão (ex.: "Fazer isso depois").
  final String? link;
  final VoidCallback? onLink;

  /// O link fica azul (ex.: "Falar com a gente"); senão, cinza.
  final bool linkAzul;

  /// Conteúdo do botão no lugar do texto (ex.: "✓ Chave salva").
  final Widget? botaoConteudo;
  final ButtonStyle? botaoEstilo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TatuMedidas.larguraMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TatuMedidas.margemCadastro,
                TatuMedidas.topo,
                TatuMedidas.margemCadastro,
                TatuMedidas.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (voltar || passo != null)
                    Row(
                      children: [
                        if (voltar) const BackCircleButton(),
                        if (passo != null) ...[
                          const SizedBox(width: TatuMedidas.entreItens),
                          Expanded(child: BarraPassos(passo: passo!)),
                        ],
                      ],
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: passo != null ? 28 : 50),
                          if (topo != null) ...[
                            Align(alignment: Alignment.centerLeft, child: topo),
                            const SizedBox(height: TatuMedidas.entreSecoes),
                          ],
                          if (passo != null) ...[
                            Row(
                              children: [
                                Text(
                                  'Passo $passo de 4',
                                  style: TatuTexto.nota.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (etiquetaPasso != null) ...[
                                  const Text('  ·  ', style: TatuTexto.nota),
                                  Flexible(child: etiquetaPasso!),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 36 / 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitulo,
                            style: subtituloNota
                                ? TatuTexto.nota
                                : const TextStyle(
                                    fontSize: 16,
                                    height: 22 / 16,
                                    color: TatuColors.textSecondary,
                                  ),
                          ),
                          const SizedBox(height: 32),
                          ...children,
                        ],
                      ),
                    ),
                  ),
                  if (notaAcimaBotao != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      notaAcimaBotao!,
                      textAlign: TextAlign.center,
                      style: TatuTexto.nota,
                    ),
                  ],
                  if (botao != null) ...[
                    SizedBox(height: notaAcimaBotao != null ? 10 : 16),
                    FilledButton(
                      onPressed: onBotao,
                      style:
                          botaoEstilo ??
                          (perigo
                              ? tatuBotaoPerigo()
                              : botaoCinza
                              ? tatuBotaoSecundario()
                              : null),
                      child: botaoConteudo ?? Text(botao!),
                    ),
                  ],
                  if (botaoSecundario != null) ...[
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: onSecundario,
                      style: tatuBotaoSecundario(),
                      child: Text(botaoSecundario!),
                    ),
                  ],
                  if (link != null) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: onLink,
                      style: TextButton.styleFrom(
                        foregroundColor: linkAzul
                            ? TatuColors.verified
                            : TatuColors.textSecondary,
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(link!),
                    ),
                  ],
                  if (notaBotao != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      notaBotao!,
                      textAlign: TextAlign.center,
                      style: TatuTexto.nota,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto pequeno cinza abaixo dos campos (avisos, termos).
class CadastroNota extends StatelessWidget {
  const CadastroNota(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: TatuColors.textSecondary,
      ),
    );
  }
}

/// Barra do cadastro do profissional: 4 traços, preenchidos até [passo].
class BarraPassos extends StatelessWidget {
  const BarraPassos({super.key, required this.passo, this.total = 4});

  final int passo;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Passo $passo de $total',
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < passo ? TatuColors.action : TatuColors.fillStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
