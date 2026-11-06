import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_texto.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/campo_celular.dart';
import 'codigo_page.dart';
import 'email_page.dart';

/// Celular para receber o código por SMS: no cadastro ou para entrar.
class CelularPage extends StatefulWidget {
  /// Cadastro: "Qual é o seu celular?".
  const CelularPage({super.key}) : entrar = false;

  /// Entrar numa conta que já existe.
  const CelularPage.entrar({super.key}) : entrar = true;

  final bool entrar;

  @override
  State<CelularPage> createState() => _CelularPageState();
}

class _CelularPageState extends State<CelularPage> {
  final _controller = TextEditingController();
  final _criarConta = TapGestureRecognizer();

  // Celular com DDD: 11 dígitos.
  bool get _valido => CampoCelular.completo(_controller.text);

  @override
  void initState() {
    super.initState();
    _criarConta.onTap = () => Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const CelularPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _criarConta.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_valido) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CodigoPage(destino: _controller.text, entrar: widget.entrar),
      ),
    );
  }

  // Volta do e-mail com "Usar celular" é um pop; daqui para o e-mail é push.
  void _usarEmail() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => EmailPage(entrar: widget.entrar)));

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: widget.entrar ? 'Entrar' : 'Qual é o seu celular?',
      subtitulo: widget.entrar
          ? 'Digite o celular do seu cadastro.\nEnviamos um código por SMS.'
          : 'Vamos enviar um código por SMS.\nSem senha para decorar.',
      botao: 'Continuar',
      onBotao: _valido ? _continuar : null,
      botaoSecundario: 'Usar e-mail',
      onSecundario: _usarEmail,
      children: [
        CampoCelular(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _continuar(),
        ),
        if (widget.entrar) ...[
          const SizedBox(height: 26),
          Text.rich(
            TextSpan(
              text: 'Não tem conta? ',
              children: [
                TextSpan(
                  text: 'Criar conta',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TatuColors.verified,
                  ),
                  recognizer: _criarConta,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TatuTexto.detalhe,
          ),
        ] else ...[
          const SizedBox(height: 14),
          const CadastroNota(
            'Usamos o número só para entrar e avisar sobre seus pedidos.',
          ),
        ],
      ],
    );
  }
}
