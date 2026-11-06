import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import 'chat_suporte_page.dart';
import 'escolher_pedido_page.dart';

/// Falar com o suporte · "Sobre o que é?": escolhe o assunto.
class SuporteAssuntoPage extends StatefulWidget {
  const SuporteAssuntoPage({super.key});

  @override
  State<SuporteAssuntoPage> createState() => _SuporteAssuntoPageState();
}

class _SuporteAssuntoPageState extends State<SuporteAssuntoPage> {
  static const _opcoes = [
    ('Um pedido recente', 'Escolha qual'),
    ('Pagamento ou cobrança', null),
    ('Minha conta', null),
    ('Segurança ou denúncia', null),
    ('Outro assunto', null),
  ];

  int _escolhida = 0;

  void _continuar() {
    final nav = Navigator.of(context);
    nav.push(
      MaterialPageRoute(
        builder: (_) => _escolhida == 0
            ? const EscolherPedidoPage()
            : const ChatSuportePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Sobre o que é?',
      subtitulo: 'Assim levamos você ao atendente certo.',
      botao: 'Continuar',
      onBotao: _continuar,
      children: [
        for (final (i, (titulo, detalhe)) in _opcoes.indexed) ...[
          OpcaoSelecionavel(
            selecionado: i == _escolhida,
            rotulo: titulo,
            onTap: () => setState(() => _escolhida = i),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TatuMedidas.alturaBotao,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    BolinhaEscolha(selecionado: i == _escolhida),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: const TextStyle(fontSize: 17)),
                          if (detalhe != null)
                            Text(detalhe, style: TatuTexto.nota),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: TatuMedidas.entreSecoes - 8),
        const CadastroNota('Em emergência, ligue 190 (polícia) ou 192 (SAMU).'),
      ],
    );
  }
}
