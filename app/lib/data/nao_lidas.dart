import 'package:flutter/foundation.dart';

import 'canal_tatu.dart';
import 'conversas.dart';
import 'conversas_profissional.dart';
import 'notificacoes.dart';
import 'notificacoes_profissional.dart';

/// RN-155: mensagens não lidas da aba Mensagens. Este é o único lugar
/// que calcula o total (aba e ícone do app usam daqui).
enum LadoMensagens { cliente, profissional }

abstract final class NaoLidas {
  /// Acima disso aparece "9+".
  static const maximo = 9;

  /// RN-155: soma de todas as conversas do lado, inclusive a do Tatu.
  static int total(LadoMensagens lado) => switch (lado) {
    LadoMensagens.cliente =>
      conversas.conversas.fold(0, (t, c) => t + c.naoLidas) +
          canalTatu.cliente.naoLidas,
    LadoMensagens.profissional =>
      conversasProfissional.conversas.fold(0, (t, c) => t + c.naoLidas) +
          canalTatu.profissional.naoLidas,
  };

  /// O que avisa quando o total muda.
  static Listenable fonte(LadoMensagens lado) => switch (lado) {
    LadoMensagens.cliente => Listenable.merge([conversas, canalTatu.cliente]),
    LadoMensagens.profissional => Listenable.merge([
      conversasProfissional,
      canalTatu.profissional,
    ]),
  };

  /// Texto do contador: nulo sem não lidas; "9+" acima de 9.
  static String? rotulo(int n) =>
      n <= 0 ? null : (n > maximo ? '$maximo+' : '$n');

  /// Leitor de tela: "Mensagens, 3 não lidas".
  static String leitura(int n) => n <= 0
      ? 'Mensagens'
      : 'Mensagens, $n ${n == 1 ? 'não lida' : 'não lidas'}';

  /// RN-155: o ícone do app só mostra o número com as notificações
  /// permitidas no celular.
  static bool podeNoIcone(LadoMensagens lado) => switch (lado) {
    LadoMensagens.cliente => notificacoes.permitidoNoCelular,
    LadoMensagens.profissional => notificacoesProfissional.permitidoNoCelular,
  };
}
