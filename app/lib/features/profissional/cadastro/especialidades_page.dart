import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../data/profissional.dart';
import '../../../data/servicos.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';
import '../../../shared/widgets/tatu_chip.dart';
import 'como_atende_page.dart';
import 'profissoes_page.dart';
import '../../../data/profissoes_reguladas.dart';
import 'registro_page.dart';

/// P05 · Passo 2: especialidades de uma profissão (até 3).
/// Com [edicao], o botão é "Salvar" e volta para quem abriu.
class EspecialidadesPage extends StatefulWidget {
  const EspecialidadesPage({
    super.key,
    required this.indice,
    this.edicao = false,
  });

  final int indice;
  final bool edicao;

  @override
  State<EspecialidadesPage> createState() => _EspecialidadesPageState();
}

class _EspecialidadesPageState extends State<EspecialidadesPage> {
  late final ProfissaoEscolhida _prof = profissional.profissoes[widget.indice];
  late final List<String> _escolhidas = List.of(_prof.especialidades);

  bool get _cheio => _escolhidas.length >= maxEspecialidades;

  void _alternar(String e) => setState(() {
    if (_escolhidas.contains(e)) {
      _escolhidas.remove(e);
    } else if (!_cheio) {
      _escolhidas.add(e);
    }
  });

  /// RN-156: profissão regulada ainda sem registro informado.
  bool get _pedeRegistro =>
      profissional.exigeRegistro(_prof.nome) &&
      !profissional.registros.containsKey(_prof.nome);

  /// RN-156: a CNH vem do documento da verificação; os outros registros
  /// abrem a tela "Registro profissional".
  void _registro(NavigatorState nav, VoidCallback depois) {
    if (!_pedeRegistro) return depois();
    if (profissoesReguladas.porNome(_prof.nome)?.usaCnh ?? false) {
      profissional.registrarCnh(_prof.nome);
      return depois();
    }
    nav.push(
      MaterialPageRoute(
        builder: (_) => RegistroProfissionalPage(
          profissao: _prof.nome,
          onEnviar: depois,
        ),
      ),
    );
  }

  void _seguir() {
    profissional.definirEspecialidades(_prof.nome, _escolhidas);
    final total = profissional.profissoes.length;
    final nav = Navigator.of(context);
    if (widget.edicao) {
      // Profissão nova vinda de "Adicionar outra": pede o registro.
      if (_pedeRegistro &&
          !(profissoesReguladas.porNome(_prof.nome)?.usaCnh ?? false)) {
        nav.pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => RegistroProfissionalPage(
              profissao: _prof.nome,
              passo: null,
              onEnviar: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
        return;
      }
      if (_pedeRegistro) profissional.registrarCnh(_prof.nome);
      nav.pop();
      return;
    }
    void continuar() => _registro(
      nav,
      () => nav.push(
        MaterialPageRoute(
          builder: (_) => widget.indice < total - 1
              ? EspecialidadesPage(indice: widget.indice + 1)
              : const ProfissoesPage(),
        ),
      ),
    );
    // RN-97: com um modo só no catálogo, ele já fica salvo e a pergunta
    // não aparece.
    if (modoUnico(_prof.nome) case final m?) {
      profissional.definirModo(_prof.nome, m);
      continuar();
      return;
    }
    // RN-97: depois das especialidades, como atende nesta profissão.
    nav.push(
      MaterialPageRoute(
        builder: (_) => ComoAtendePage(
          indice: widget.indice,
          onContinuar: continuar,
        ),
      ),
    );
  }

  String get _botao {
    if (widget.edicao) return 'Salvar';
    final lista = profissional.profissoes;
    if (widget.indice >= lista.length - 1) return 'Continuar';
    return 'Próximo: ${lista[widget.indice + 1].nome}';
  }

  @override
  Widget build(BuildContext context) {
    final total = profissional.profissoes.length;
    final n = _escolhidas.length;
    return CadastroScaffold(
      passo: 2,
      etiquetaPasso: total > 1 && !widget.edicao
          ? EtiquetaCinza(
              icone: iconeServico(_prof.nome),
              texto: '${_prof.nome} · ${widget.indice + 1} de $total',
            )
          : null,
      titulo: 'O que você faz como ${_prof.nome.toLowerCase()}?',
      subtitulo: 'Escolha até 3. São as que o cliente vê no seu perfil.',
      notaAcimaBotao:
          '$n de $maxEspecialidades ${n == 1 ? 'escolhida' : 'escolhidas'}',
      botao: _botao,
      onBotao: n == 0 ? null : _seguir,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in especialidadesDe(_prof.nome))
              TatuChip(
                label: e,
                icone: TablerIcons.check,
                selecionado: _escolhidas.contains(e),
                desabilitado: _cheio && !_escolhidas.contains(e),
                onTap: () => _alternar(e),
              ),
          ],
        ),
        if (_cheio) ...[
          const SizedBox(height: 18),
          const Text(
            'Para trocar, desmarque uma das escolhidas.',
            style: TatuTexto.nota,
          ),
        ],
      ],
    );
  }
}

/// Etiqueta cinza em pílula com ícone (ex.: "Encanador · 1 de 2").
class EtiquetaCinza extends StatelessWidget {
  const EtiquetaCinza({
    super.key,
    required this.icone,
    required this.texto,
    this.verde = false,
  });

  final IconData icone;
  final String texto;

  /// Verde claro com texto verde (ex.: "Pediu você de novo", RN-178).
  final bool verde;

  @override
  Widget build(BuildContext context) {
    final cor = verde ? TatuColors.onlineTexto : TatuColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: verde ? TatuColors.onlineSoft : TatuColors.fill,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
