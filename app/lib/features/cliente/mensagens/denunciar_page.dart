import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../data/conta.dart';
import '../../../data/conversas.dart';
import '../../../data/denuncias.dart';
import '../../../data/profissional.dart';
import '../../../data/suspender_conta.dart';
import '../../../shared/widgets/aviso_topo.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/opcao_selecionavel.dart';
import '../../../shared/widgets/tatu_field.dart';
import '../../../shared/widgets/tela_permissao.dart';

/// C138/P82 · Denunciar a pessoa pelo menu do chat (RN-133): motivo,
/// "Contar mais" opcional e envio. A denúncia nunca é mostrada para o
/// denunciado.
class DenunciarPage extends StatefulWidget {
  /// Cliente denunciando o profissional da conversa.
  const DenunciarPage({super.key, required this.conversa, this.motivo})
    : nome = null,
      feminino = null,
      denunciado = null,
      aoBloquear = null;

  /// Profissional denunciando o cliente.
  const DenunciarPage.pessoa({
    super.key,
    required String this.nome,
    required bool this.feminino,
    required String this.denunciado,
    this.aoBloquear,
    this.motivo,
  }) : conversa = null;

  final Conversa? conversa;
  final String? nome;
  final bool? feminino;

  /// Nome completo de quem é denunciado.
  final String? denunciado;

  /// RN-56: o que fazer quando a denúncia bloqueia os dois na hora.
  final VoidCallback? aoBloquear;

  /// Motivo já escolhido (para abrir a tela preenchida).
  final int? motivo;

  @override
  State<DenunciarPage> createState() => _DenunciarPageState();
}

class _DenunciarPageState extends State<DenunciarPage> {
  late int? _escolhido = widget.motivo;
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _enviar() {
    final c = widget.conversa;
    final denunciante = c != null ? conta.nomeCompleto : profissional.nome;
    final denunciado = widget.denunciado ?? c!.nome;
    // RN-241: a mesma pessoa sobre o mesmo atendimento vira uma só.
    if (denuncias.jaDenunciou(
          denunciante: denunciante,
          denunciado: denunciado,
        ) !=
        null) {
      mostrarAvisoTopo(
        context,
        titulo: 'Denúncia já enviada',
        texto: DenunciasRepo.textoRepetida,
      );
      Navigator.of(context).pop();
      return;
    }
    final d = denuncias.denunciarPessoa(
      denunciante: denunciante,
      denunciado: denunciado,
      motivo: motivosDenunciaPessoa[_escolhido!],
      texto: _texto.text,
    );
    // RN-56/RN-135: assédio ou discriminação bloqueia os dois na hora e
    // o acusado fica suspenso enquanto o suporte analisa (RN-129).
    if (d.bloqueiaNaHora) {
      if (c != null) {
        profissionalSuspenso(c);
      } else {
        widget.aoBloquear?.call();
      }
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DenunciaEnviadaPage(
          texto: c == null
              ? 'Nossa equipe vai analisar e pode\nfalar com você pelo app.'
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.nome ?? widget.conversa!.primeiroNome;
    final feminino = widget.feminino ?? widget.conversa!.feminino;
    return CadastroScaffold(
      titulo: 'Denunciar $nome',
      subtitulo:
          'O que aconteceu?\n'
          'Não mostramos a denúncia para ${feminino ? 'ela' : 'ele'}.',
      botao: 'Enviar denúncia',
      onBotao: _escolhido == null ? null : _enviar,
      children: [
        for (final (i, m) in motivosDenunciaPessoa.indexed) ...[
          OpcaoSelecionavel(
            selecionado: i == _escolhido,
            rotulo: m,
            onTap: () => setState(() => _escolhido = i),
            child: SizedBox(
              height: TatuMedidas.alturaOpcaoLista,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    BolinhaEscolha(selecionado: i == _escolhido),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        m,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: TatuMedidas.entreItens + 2),
        ],
        const SizedBox(height: TatuMedidas.entreItens - 2),
        // RN-133: contar mais é opcional.
        TatuField(
          label: 'Contar mais (opcional)',
          hintText: 'O que aconteceu…',
          controller: _texto,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}

/// C139/P83 · Denúncia enviada: a equipe analisa; volta para a conversa.
class DenunciaEnviadaPage extends StatelessWidget {
  const DenunciaEnviadaPage({super.key, this.texto});

  final String? texto;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const IconePermissao(TablerIcons.check, cor: TatuColors.online),
      titulo: 'Denúncia enviada',
      texto:
          texto ??
          'Nossa equipe vai analisar.\nVocê não precisa fazer mais nada.',
      principal: 'Voltar para a conversa',
      onPrincipal: () => Navigator.of(context).pop(),
    );
  }
}
