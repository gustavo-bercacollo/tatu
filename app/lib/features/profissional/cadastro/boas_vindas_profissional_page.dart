import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/tatu_colors.dart';
import '../../../core/theme/tatu_medidas.dart';
import '../../../core/theme/tatu_texto.dart';
import '../../../shared/widgets/cadastro_scaffold.dart';

/// Passos do cadastro do profissional (barra de progresso).
const passosCadastro = ['Dados', 'Serviços', 'Receber', 'Verificação'];

/// P01 · Boas-vindas do profissional: vem de "Quero trabalhar" ou
/// "Trocar para modo profissional" (sem cadastro).
class BoasVindasProfissionalPage extends StatelessWidget {
  const BoasVindasProfissionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Trabalhe com o que você sabe fazer',
      subtitulo: 'Receba chamados de clientes perto de você, quando quiser.',
      botao: 'Começar cadastro',
      onBotao: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Cadastro: em breve'))),
      notaBotao: 'Tenha em mãos um documento com foto.',
      children: const [
        _Vantagem(
          icone: TablerIcons.map_pin,
          titulo: 'Clientes perto de você',
          texto: 'Só chamados da sua região, sem sair procurando.',
        ),
        _Vantagem(
          icone: TablerIcons.wallet,
          titulo: 'Receba pelo app',
          texto: 'Sem maquininha e sem troco.',
        ),
        _Vantagem(
          icone: TablerIcons.clock,
          titulo: 'Você escolhe quando',
          texto: 'Fique online só nos horários que quiser.',
        ),
        SizedBox(height: TatuMedidas.entreSecoes),
        Text('O cadastro leva uns 5 minutos', style: TatuTexto.detalhe),
        SizedBox(height: TatuMedidas.entreItens),
        ProgressoCadastro(feitos: 0),
      ],
    );
  }
}

class _Vantagem extends StatelessWidget {
  const _Vantagem({
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TatuMedidas.entreSecoes),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icone, size: 24),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(texto, style: TatuTexto.detalhe),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra do cadastro em 4 partes (Dados, Serviços, Receber, Verificação).
class ProgressoCadastro extends StatelessWidget {
  const ProgressoCadastro({super.key, required this.feitos});

  final int feitos;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cadastro: $feitos de ${passosCadastro.length} passos',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < passosCadastro.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: i == 0
                      ? CrossAxisAlignment.start
                      : i == passosCadastro.length - 1
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < feitos
                            ? TatuColors.action
                            : TatuColors.fillStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(passosCadastro[i], style: TatuTexto.nota),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
