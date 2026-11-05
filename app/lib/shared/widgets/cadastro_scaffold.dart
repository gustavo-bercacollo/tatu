import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
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
    required this.botao,
    required this.onBotao,
    this.botaoSecundario,
    this.onSecundario,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> children;
  final String botao;

  /// `null` deixa o botão desabilitado.
  final VoidCallback? onBotao;

  /// Botão cinza abaixo do principal (ex.: "Usar e-mail").
  final String? botaoSecundario;
  final VoidCallback? onSecundario;

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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 50),
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
                            style: const TextStyle(
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
                  const SizedBox(height: 16),
                  FilledButton(onPressed: onBotao, child: Text(botao)),
                  if (botaoSecundario != null) ...[
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: onSecundario,
                      style: tatuBotaoSecundario(),
                      child: Text(botaoSecundario!),
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
