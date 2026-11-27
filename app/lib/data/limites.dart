/// RN-247: números ajustáveis. Todo prazo, limite e percentual marcado
/// como exemplo nas regras vem da configuração do servidor e muda sem
/// versão nova do app. Enquanto não há backend, os valores abaixo são os
/// exemplos das regras; [aplicar] recebe a configuração remota (JSON) e
/// [restaurar] volta aos exemplos (testes).
///
/// Números que já tinham lugar próprio continuam lá e seguem a mesma
/// ideia: [Prazos] (data/prazos.dart), `RegrasValor`, `RegrasPlanoFixo`,
/// `RegrasPagamento`, `RegrasSelos`.
abstract final class Limites {
  /// RN-237: "Pedir de novo" no valor expirado, por card.
  static int pedirDeNovoPorCard = 1;

  /// RN-238: depois de "Sem acordo" no valor, chamar a mesma pessoa.
  static Duration esperaSemAcordo = const Duration(hours: 24);

  /// RN-238: depois de "Sem acordo" no plano fixo, nova proposta à mesma
  /// pessoa.
  static Duration esperaPropostaPlano = const Duration(days: 7);

  /// RN-239: "Ver outro profissional" por pedido.
  static int trocasPorPedido = 3;

  /// RN-240: novos valores recusados no mesmo atendimento que desativam
  /// "Novo valor".
  static int novosValoresRecusados = 2;

  /// RN-242: semanas seguidas com "Não vou nesta semana": aviso ao
  /// cliente e, depois, pausa sozinha.
  static int semanasSemVisitaAviso = 2;
  static int semanasSemVisitaPausa = 3;

  /// RN-242: pausa máxima do plano e aviso antes do fim.
  static Duration pausaPlanoMaxima = const Duration(days: 60);
  static Duration avisoFimPausaPlano = const Duration(days: 7);

  /// RN-243: "Sugerir outro horário" (profissional) e "Escolher outro"
  /// (cliente) no retorno.
  static int sugestoesHorario = 2;
  static int escolherOutroHorario = 1;

  /// RN-244: pausas da conta na janela; 1ª e 2ª voltam sozinhas.
  static Duration janelaPausas = const Duration(days: 180);
  static Duration voltaPrimeiraPausa = const Duration(days: 7);
  static Duration voltaSegundaPausa = const Duration(days: 30);

  /// RN-188: "Não consigo ir até lá" só conta falta a partir desta vez
  /// na janela.
  static int naoConsigoIrFaltaAPartirDe = 2;
  static Duration janelaNaoConsigoIr = const Duration(days: 90);

  /// RN-248: código de acesso (por número e por aparelho).
  static int codigosPorJanela = 3;
  static Duration janelaCodigos = const Duration(minutes: 15);
  static int codigosPorDia = 10;

  /// RN-248: cartões recusados na conta em 24 h que deixam só Pix.
  static int cartoesRecusados = 3;
  static Duration janelaCartoes = const Duration(hours: 24);

  /// RN-248: pedidos novos por hora por conta.
  static int pedidosPorHora = 5;

  /// RN-247: aplica a configuração que veio do servidor. Chave
  /// desconhecida é ignorada; durações vêm em minutos.
  static void aplicar(Map<String, Object?> c) {
    int i(String k, int atual) => (c[k] as num?)?.toInt() ?? atual;
    Duration d(String k, Duration atual) {
      final v = c[k] as num?;
      return v == null ? atual : Duration(minutes: v.toInt());
    }

    pedirDeNovoPorCard = i('pedirDeNovoPorCard', pedirDeNovoPorCard);
    esperaSemAcordo = d('esperaSemAcordo', esperaSemAcordo);
    esperaPropostaPlano = d('esperaPropostaPlano', esperaPropostaPlano);
    trocasPorPedido = i('trocasPorPedido', trocasPorPedido);
    novosValoresRecusados = i('novosValoresRecusados', novosValoresRecusados);
    semanasSemVisitaAviso = i('semanasSemVisitaAviso', semanasSemVisitaAviso);
    semanasSemVisitaPausa = i('semanasSemVisitaPausa', semanasSemVisitaPausa);
    pausaPlanoMaxima = d('pausaPlanoMaxima', pausaPlanoMaxima);
    avisoFimPausaPlano = d('avisoFimPausaPlano', avisoFimPausaPlano);
    sugestoesHorario = i('sugestoesHorario', sugestoesHorario);
    escolherOutroHorario = i('escolherOutroHorario', escolherOutroHorario);
    janelaPausas = d('janelaPausas', janelaPausas);
    voltaPrimeiraPausa = d('voltaPrimeiraPausa', voltaPrimeiraPausa);
    voltaSegundaPausa = d('voltaSegundaPausa', voltaSegundaPausa);
    naoConsigoIrFaltaAPartirDe = i(
      'naoConsigoIrFaltaAPartirDe',
      naoConsigoIrFaltaAPartirDe,
    );
    janelaNaoConsigoIr = d('janelaNaoConsigoIr', janelaNaoConsigoIr);
    codigosPorJanela = i('codigosPorJanela', codigosPorJanela);
    janelaCodigos = d('janelaCodigos', janelaCodigos);
    codigosPorDia = i('codigosPorDia', codigosPorDia);
    cartoesRecusados = i('cartoesRecusados', cartoesRecusados);
    janelaCartoes = d('janelaCartoes', janelaCartoes);
    pedidosPorHora = i('pedidosPorHora', pedidosPorHora);
  }

  /// Volta aos exemplos das regras (testes).
  static void restaurar() {
    pedirDeNovoPorCard = 1;
    esperaSemAcordo = const Duration(hours: 24);
    esperaPropostaPlano = const Duration(days: 7);
    trocasPorPedido = 3;
    novosValoresRecusados = 2;
    semanasSemVisitaAviso = 2;
    semanasSemVisitaPausa = 3;
    pausaPlanoMaxima = const Duration(days: 60);
    avisoFimPausaPlano = const Duration(days: 7);
    sugestoesHorario = 2;
    escolherOutroHorario = 1;
    janelaPausas = const Duration(days: 180);
    voltaPrimeiraPausa = const Duration(days: 7);
    voltaSegundaPausa = const Duration(days: 30);
    naoConsigoIrFaltaAPartirDe = 2;
    janelaNaoConsigoIr = const Duration(days: 90);
    codigosPorJanela = 3;
    janelaCodigos = const Duration(minutes: 15);
    codigosPorDia = 10;
    cartoesRecusados = 3;
    janelaCartoes = const Duration(hours: 24);
    pedidosPorHora = 5;
  }

  /// Quantos eventos de [eventos] caem na [janela] até [agora].
  static int naJanela(
    Iterable<DateTime> eventos,
    Duration janela,
    DateTime agora,
  ) => eventos.where((e) => agora.difference(e) < janela).length;
}
