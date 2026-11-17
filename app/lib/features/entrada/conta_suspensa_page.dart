import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/ajuda.dart';
import '../../data/documentos.dart';
import '../../data/suspender_conta.dart';
import '../../shared/widgets/tela_permissao.dart';
import '../cliente/ajuda/abrir_ajuda.dart';
import '../cliente/privacidade/documento_page.dart';

/// C162/P59 · Conta suspensa (RN-122, RN-129): não diz o motivo. Vale
/// para os dois modos. É a única tela que a conta suspensa vê.
class ContaSuspensaPage extends StatelessWidget {
  const ContaSuspensaPage({super.key, this.profissional = false});

  /// Ajuda do profissional (senão, a do cliente).
  final bool profissional;

  @override
  Widget build(BuildContext context) {
    return TelaPermissao(
      voltar: false,
      perigo: true,
      icone: const Icon(
        TablerIcons.shield_check,
        size: 40,
        color: TatuColors.danger,
      ),
      titulo: 'Conta suspensa',
      texto: 'Sua conta foi suspensa por\nnão seguir as regras do Tatu.',
      principal: 'Ler as regras do Tatu',
      estiloPrincipal: tatuBotaoSecundario(),
      onPrincipal: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DocumentoPage(documento: termosDeUso),
        ),
      ),
      alternativa: 'Falar com o suporte',
      onAlternativa: () => abrirSuporte(
        context,
        profissional ? conteudoProfissional : conteudoCliente,
      ),
    );
  }
}

/// Abre "Conta suspensa" como única tela (RN-122).
/// RN-129: suspende a conta desta pessoa. Tudo que estava em andamento
/// acaba na hora e ela só vê "Conta suspensa".
void mostrarContaSuspensa(BuildContext context, {bool profissional = false}) {
  if (profissional) {
    suspenderContaProfissional();
  } else {
    suspenderContaCliente();
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => ContaSuspensaPage(profissional: profissional),
    ),
    (_) => false,
  );
}
