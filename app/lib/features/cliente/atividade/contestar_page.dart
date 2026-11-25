import 'package:flutter/material.dart';

import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/pedidos.dart';
import '../../../data/retorno.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/retorno.dart';
import '../../entrada/camera_prova_page.dart';
import '../retorno/retorno_cliente.dart';

/// Motivos para contestar um serviço.
const motivosContestacao = motivosAlgoErrado;

/// C124 · "O que deu errado?" nas primeiras 24 horas (RN-45, RN-46): o
/// valor fica retido até resolver e o profissional pode voltar primeiro,
/// sem custo. Fotos só pela câmera do app (RN-184).
class ContestarServicoPage extends StatefulWidget {
  const ContestarServicoPage({
    super.key,
    this.aoEnviar,
    this.pedido,
    this.nome,
  });

  /// RN-31/RN-172: só ao enviar a contestação o valor fica retido e a
  /// confirmação pendente sai da Home e da Atividade. Voltar não muda nada.
  final VoidCallback? aoEnviar;

  /// Serviço já concluído: ao enviar, vira o pedido de retorno (fluxo
  /// único, RN-45) e abre o chat.
  final PedidoConcluido? pedido;

  /// "Luiza" (para "Primeiro a Luiza pode voltar").
  final String? nome;

  @override
  State<ContestarServicoPage> createState() => _ContestarServicoPageState();
}

class _ContestarServicoPageState extends State<ContestarServicoPage> {
  int _motivo = 0;
  final _fotos = <FotoProva>[];

  String get _nome =>
      widget.nome ?? widget.pedido?.primeiroNome ?? 'o profissional';

  String get _aNome {
    final p = widget.pedido;
    if (p == null) return widget.nome == null ? _nome : 'a $_nome';
    return '${p.feminino ? 'a' : 'o'} $_nome';
  }

  Future<void> _camera() async {
    final f = await tirarFotoProva(context);
    if (f != null && mounted) setState(() => _fotos.add(f));
  }

  void _enviar() {
    widget.aoEnviar?.call();
    final p = widget.pedido;
    if (p != null) {
      // RN-45/RN-46: o pedido de retorno, com o valor retido.
      final r = pedirRetornoCliente(
        p,
        descricao: motivosContestacao[_motivo],
        fotos: _fotos,
        motivo: motivosContestacao[_motivo],
      );
      if (r != null) return abrirChatDoRetorno(context, p, substituir: true);
    }
    // O aviso fica no Overlay raiz e continua na tela anterior.
    mostrarAvisoTopo(
      context,
      titulo: 'Recebemos seu aviso',
      texto: 'O valor do serviço fica retido até resolver.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'O que deu errado?',
      subtitulo:
          'O valor fica retido até resolver. Primeiro $_aNome pode voltar, '
          'sem custo.',
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
        const Text(
          'Tire fotos do problema agora (só pela câmera)',
          style: TatuTexto.nota,
        ),
        const SizedBox(height: TatuMedidas.entreItens),
        FotosProva(fotos: _fotos, onCamera: _camera),
      ],
    );
  }
}
