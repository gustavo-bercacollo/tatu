import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tatu/core/theme/tatu_theme.dart';
import 'package:tatu/data/conversas.dart';
import 'package:tatu/features/cliente/mensagens/chat_page.dart';
import 'package:tatu/shared/contato_oculto.dart';

/// RN-85: contato não passa pelo chat.
void main() {
  group('acharContatos', () {
    test('acha telefone, e-mail, endereço, @ e link', () {
      expect(contatoNoTexto('me chama no 11 98888-7777'), TipoContato.telefone);
      expect(contatoNoTexto('(11) 3456-7890'), TipoContato.telefone);
      expect(contatoNoTexto('+55 11988887777'), TipoContato.telefone);
      expect(contatoNoTexto('manda pra ana@email.com'), TipoContato.email);
      expect(contatoNoTexto('moro na Rua das Flores, 120'), TipoContato.endereco);
      expect(contatoNoTexto('Av. Paulista 1000'), TipoContato.endereco);
      expect(contatoNoTexto('me segue @luiza.encanadora'), TipoContato.rede);
      expect(contatoNoTexto('olha www.meusite.com.br'), TipoContato.link);
      expect(contatoNoTexto('wa.me/5511988887777'), TipoContato.link);
    });

    test('não marca valores, horas e conversa normal', () {
      for (final t in [
        'Chego em 12 min.',
        r'Fica R$ 1.500,00 com material',
        'Chego às 14:32',
        'Oi! Vi o vazamento, posso hoje.',
        'São 3 torneiras e 2 registros',
        'A rua está em obra',
      ]) {
        expect(contatoNoTexto(t), isNull, reason: t);
      }
    });
  });

  testWidgets('Cliente: contato não é enviado e o recebido fica oculto', (
    t,
  ) async {
    conversas.restaurar();
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final c = conversas.emAndamento.first;
    c.mensagens.add(
      MensagemChat(texto: 'Se precisar de novo, me chama no 11 97777-1234'),
    );
    await t.pumpWidget(
      MaterialApp(theme: tatuTheme(), home: ChatPage(conversa: c)),
    );
    await t.pumpAndSettle();
    // Recebido: o número some e vira "contato oculto".
    expect(find.textContaining('97777'), findsNothing);
    expect(find.text('contato oculto'), findsOneWidget);
    expect(find.text('Telefones e redes ficam ocultos.'), findsOneWidget);

    final antes = c.mensagens.length;
    await t.enterText(find.byType(TextField), 'me chama no 11 98888-7777');
    await t.pump();
    expect(find.text('Telefone não é enviado pelo chat'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Enviar mensagem'));
    await t.testTextInput.receiveAction(TextInputAction.send);
    await t.pump();
    expect(c.mensagens.length, antes);

    await t.enterText(find.byType(TextField), 'Rua das Flores, 120');
    await t.pump();
    expect(find.text('Endereço não é enviado pelo chat'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'Pode vir agora');
    await t.pump();
    expect(find.textContaining('não é enviado pelo chat'), findsNothing);
    await t.tap(find.bySemanticsLabel('Enviar mensagem'));
    await t.pump();
    expect(c.mensagens.length, antes + 1);
    conversas.restaurar();
  });
}
