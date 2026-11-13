import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/botao_tracejado.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';

/// Motivos para contestar um serviço.
const motivosContestacao = [
  'Ficou mal feito',
  'Não terminou o serviço',
  'Cobrou diferente do combinado',
  'Outro motivo',
];

/// "O que deu errado?": o cliente contesta o serviço em até 24 h.
/// O valor do serviço fica retido até resolver; a visita não entra.
class ContestarServicoPage extends StatefulWidget {
  const ContestarServicoPage({super.key});

  @override
  State<ContestarServicoPage> createState() => _ContestarServicoPageState();
}

class _ContestarServicoPageState extends State<ContestarServicoPage> {
  int _motivo = 0;

  void _emBreve(String o) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$o: em breve')));

  void _enviar() {
    // O aviso fica no Overlay raiz e continua na tela anterior.
    mostrarAvisoTopo(
      context,
      titulo: 'Recebemos sua contestação',
      texto: 'O valor do serviço fica retido até resolvermos.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'O que deu errado?',
      subtitulo:
          'O valor do serviço fica retido até resolvermos. '
          'A visita não entra na contestação.',
      botao: 'Enviar',
      onBotao: _enviar,
      children: [
        for (final (i, motivo) in motivosContestacao.indexed) ...[
          OpcaoSelecionavel(
            selecionado: i == _motivo,
            rotulo: motivo,
            onTap: () => setState(() => _motivo = i),
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
                    BolinhaEscolha(selecionado: i == _motivo),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(motivo, style: const TextStyle(fontSize: 17)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: TatuMedidas.entreItens),
        const Text('Fotos ajudam a resolver mais rápido', style: TatuTexto.nota),
        const SizedBox(height: TatuMedidas.entreItens),
        Row(
          spacing: TatuMedidas.entreItens,
          children: [
            QuadradoFoto(
              icone: TablerIcons.plus,
              rotulo: 'Adicionar foto',
              onTap: () => _emBreve('Adicionar foto'),
            ),
            const QuadradoFoto(),
            const QuadradoFoto(),
          ],
        ),
      ],
    );
  }
}
