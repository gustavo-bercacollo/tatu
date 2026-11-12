import 'package:flutter/material.dart';

import '../../../data/ajuda.dart';
import '../../profissional/atividade/ganhos_page.dart';
import 'artigo_page.dart';
import 'assunto_page.dart';
import 'suporte_assunto_page.dart';

void _emBreve(BuildContext context, String o) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text('$o: em breve')));

/// Abre um artigo; os que ainda não têm texto mostram "em breve".
void abrirArtigo(
  BuildContext context,
  Artigo a, [
  ConteudoAjuda conteudo = conteudoCliente,
]) {
  if (a.atalho == AtalhoAjuda.ganhos) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const GanhosPage()));
    return;
  }
  if (!a.temTexto) return _emBreve(context, a.titulo);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ArtigoPage(artigo: a, conteudo: conteudo),
    ),
  );
}

/// Abre a lista de artigos de um assunto (sem artigos: "em breve").
void abrirAssunto(
  BuildContext context,
  AssuntoAjuda a, [
  ConteudoAjuda conteudo = conteudoCliente,
]) {
  if (a.artigos.isEmpty) return _emBreve(context, a.titulo);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AssuntoPage(assunto: a, conteudo: conteudo),
    ),
  );
}

/// "Falar com o suporte": começa pela escolha do assunto.
void abrirSuporte(
  BuildContext context, [
  ConteudoAjuda conteudo = conteudoCliente,
]) => Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => SuporteAssuntoPage(conteudo: conteudo)),
);
