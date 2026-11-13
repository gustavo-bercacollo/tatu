import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_medidas.dart';
import '../../core/theme/tatu_texto.dart';
import '../../data/seguranca.dart';
import '../../shared/widgets/cadastro_scaffold.dart';
import '../../shared/widgets/nota_icone.dart';
import '../../shared/widgets/tela_permissao.dart';
import '../profissional/cadastro/verificacao_page.dart';

/// Cliente: verificar a identidade para usar a preferência por
/// profissionais mulheres (documento + selfie ao vivo).
class VerificarIdentidadePage extends StatelessWidget {
  const VerificarIdentidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CadastroScaffold(
      titulo: 'Verifique sua identidade',
      subtitulo:
          'Para usar a preferência por mulheres, precisamos saber quem você '
          'é. Leva uns 2 minutos.',
      botao: 'Começar',
      onBotao: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CameraVerificacaoPage(
            etapa: EtapaFoto.frente,
            cliente: true,
          ),
        ),
      ),
      children: const [
        _Item(
          icone: TablerIcons.id,
          titulo: 'Foto do documento',
          detalhe: 'RG ou CNH',
        ),
        SizedBox(height: TatuMedidas.entreItens),
        _Item(
          icone: TablerIcons.camera,
          titulo: 'Selfie ao vivo',
          detalhe: 'Para conferir que é você',
        ),
        SizedBox(height: TatuMedidas.entreSecoes + 4),
        CaixaAviso(
          'Usar identidade falsa leva a banimento e denúncia à polícia. '
          'Seus dados não aparecem para ninguém.',
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.titulo,
    required this.detalhe,
  });

  final IconData icone;
  final String titulo;
  final String detalhe;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: TatuColors.fill,
      borderRadius: BorderRadius.circular(TatuMedidas.raioCartao),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: TatuColors.bg,
          child: Icon(icone, size: 18, color: TatuColors.textPrimary),
        ),
        const SizedBox(width: 14),
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
              const SizedBox(height: 2),
              Text(detalhe, style: TatuTexto.nota),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Fim da verificação do cliente: a preferência já fica ligada.
class IdentidadeVerificadaPage extends StatelessWidget {
  const IdentidadeVerificadaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      sucesso: true,
      icone: const Icon(
        TablerIcons.check,
        size: 44,
        color: TatuColors.online,
      ),
      titulo: 'Identidade verificada',
      texto:
          'A preferência por profissionais mulheres está ativa. Você pode '
          'desligar quando quiser, no Perfil ou na Home.',
      principal: 'Concluir',
      onPrincipal: () => Navigator.of(context).maybePop(),
    );
  }
}

/// Liga a preferência: pede a verificação antes, se ainda não fez.
Future<void> ligarPreferenciaMulheres(BuildContext context) async {
  if (seguranca.identidadeVerificada) {
    seguranca.definirPreferirMulheres(true);
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const VerificarIdentidadePage()),
  );
}
