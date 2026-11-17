import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/tatu_colors.dart';
import '../../core/theme/tatu_theme.dart';
import '../../data/ajuda.dart';
import '../../data/documentos.dart';
import '../../shared/widgets/tela_permissao.dart';
import '../cliente/ajuda/abrir_ajuda.dart';
import '../cliente/privacidade/documento_page.dart';

/// C162/P59 · Conta suspensa (RN-122): não diz o motivo. Vale para os
/// dois modos.
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
void mostrarContaSuspensa(BuildContext context, {bool profissional = false}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => ContaSuspensaPage(profissional: profissional),
    ),
    (_) => false,
  );
}
