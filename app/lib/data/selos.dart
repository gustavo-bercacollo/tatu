import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// RN-217 a RN-220: selos de confiança do profissional.
///
/// Não são medalhas de jogo: nada de pontos, níveis, ranking, sequência de
/// dias nem selos para clientes. **Só informam** (RN-219): nada aqui pode
/// mudar quem recebe chamados, nem dar desconto ou prioridade.

/// RN-217/RN-218: os números dos selos. Exemplos a confirmar com o
/// advogado (J-07): mude só aqui.
abstract final class RegrasSelos {
  /// Pontual: chegou no horário em pelo menos 95% dos agendados…
  static const pontualMinimo = 0.95;

  /// …entre os últimos 20 serviços agendados.
  static const pontualUltimos = 20;

  /// Resolve de primeira: pelo menos 20 serviços na janela.
  static const resolveMinServicos = 20;

  /// Clientes voltam: pelo menos 30% dos clientes…
  static const voltamMinimo = 0.30;

  /// …com no mínimo 10 clientes diferentes.
  static const voltamMinClientes = 10;

  /// RN-218: janela móvel: o selo vem e vai sozinho.
  static const janela = Duration(days: 90);
}

/// RN-217/RN-220: os selos, com o texto de cada visão.
enum Selo {
  verificado(
    'Verificado',
    'verificado',
    'Documento e selfie conferidos',
    'Documento e selfie conferidos.',
  ),
  registroConferido(
    'Registro conferido',
    'registro-conferido',
    'Registro no conselho conferido',
    'Registro no conselho da profissão conferido pelo Tatu.',
  ),
  pontual(
    'Pontual',
    'pontual',
    'Chega no horário combinado',
    'Chegou no horário em pelo menos 95% dos serviços agendados '
        '(últimos 20).',
  ),
  resolveDePrimeira(
    'Resolve de primeira',
    'resolve-de-primeira',
    'Serviços sem retorno contra ele',
    'Pelo menos 20 serviços em 90 dias, sem retorno decidido contra você.',
  ),
  clientesVoltam(
    'Clientes voltam',
    'clientes-voltam',
    'Muitos clientes chamam de novo',
    '30% dos clientes chamaram de novo ou viraram plano fixo (mínimo 10 '
        'clientes).',
  );

  const Selo(this.nome, this.arquivo, this.frase, this.comoFunciona);

  /// "Pontual".
  final String nome;

  /// Parte do nome do arquivo em assets/selos/.
  final String arquivo;

  /// Uma frase para o cliente (perfil, RN-219).
  final String frase;

  /// Como funciona, para o profissional ("Seus selos").
  final String comoFunciona;

  /// Os 3 que o app calcula (os outros vêm da verificação e do registro).
  static const calculados = [pontual, resolveDePrimeira, clientesVoltam];

  /// RN-220: o selo (preto; o verificado é azul) ou o cinza "Ainda não".
  String imagem({bool conquistado = true}) => conquistado
      ? 'assets/selos/selo-$arquivo.svg'
      : 'assets/selos/selo-$arquivo-ainda-nao.svg';

  /// O verificado não tem versão cinza.
  bool get temAindaNao => this != verificado;
}

/// RN-218: um serviço feito, como o servidor vê para os selos.
@immutable
class ServicoParaSelo {
  const ServicoParaSelo({
    required this.cliente,
    required this.em,
    this.agendado = false,
    this.noHorario = false,
    this.retornoContra = false,
    this.clienteVoltou = false,
    this.clienteLigado = false,
  });

  /// Quem pediu (um id do cliente).
  final String cliente;
  final DateTime em;

  /// Com hora marcada (retorno, plano fixo, serviço agendado). Chamado
  /// imediato não conta para "Pontual".
  final bool agendado;

  /// Chegou no horário combinado (código na porta até a hora).
  final bool noHorario;

  /// Retorno com decisão contra ele (mediação ou resolução automática).
  /// O pedido de retorno sozinho não conta.
  final bool retornoContra;

  /// O cliente pediu de novo ou virou plano fixo.
  final bool clienteVoltou;

  /// Cliente ligado ao profissional (mesmo CPF, cartão, aparelho ou
  /// endereço): não conta.
  final bool clienteLigado;
}

/// RN-217/RN-218: quais selos o profissional tem agora. Conta pausada ou
/// suspensa ([ativa] falso) perde todos.
Set<Selo> calcularSelos({
  required List<ServicoParaSelo> servicos,
  required bool verificado,
  bool registroConferido = false,
  bool ativa = true,
  DateTime? agora,
}) {
  if (!ativa) return const {};
  final hoje = agora ?? clock.now();
  final desde = hoje.subtract(RegrasSelos.janela);
  final validos = [
    for (final s in servicos)
      if (!s.clienteLigado && !s.em.isBefore(desde) && !s.em.isAfter(hoje)) s,
  ]..sort((a, b) => b.em.compareTo(a.em));

  final selos = <Selo>{
    if (verificado) Selo.verificado,
    if (registroConferido) Selo.registroConferido,
  };

  // Pontual: entre os últimos 20 agendados, pelo menos 95% no horário.
  final agendados = validos
      .where((s) => s.agendado)
      .take(RegrasSelos.pontualUltimos)
      .toList();
  if (agendados.length >= RegrasSelos.pontualUltimos) {
    final noHorario = agendados.where((s) => s.noHorario).length;
    if (noHorario / agendados.length >= RegrasSelos.pontualMinimo) {
      selos.add(Selo.pontual);
    }
  }

  // Resolve de primeira: 20 serviços na janela e nenhum retorno contra.
  if (validos.length >= RegrasSelos.resolveMinServicos &&
      !validos.any((s) => s.retornoContra)) {
    selos.add(Selo.resolveDePrimeira);
  }

  // Clientes voltam: 30% dos clientes (mínimo 10 diferentes).
  final clientes = <String, bool>{};
  for (final s in validos) {
    clientes[s.cliente] = (clientes[s.cliente] ?? false) || s.clienteVoltou;
  }
  if (clientes.length >= RegrasSelos.voltamMinClientes) {
    final voltaram = clientes.values.where((v) => v).length;
    if (voltaram / clientes.length >= RegrasSelos.voltamMinimo) {
      selos.add(Selo.clientesVoltam);
    }
  }
  return selos;
}

/// Ordem de exibição (RN-219): verificado, registro e os calculados.
List<Selo> emOrdem(Iterable<Selo> selos) => [
  for (final s in Selo.values)
    if (selos.contains(s)) s,
];

/// Demonstração (o servidor calcula; aqui, simulado): 20 agendados com 19
/// no horário (Pontual), um retorno decidido contra (sem "Resolve de
/// primeira") e 12 clientes, 5 voltaram (Clientes voltam). Um cliente
/// ligado ao profissional, que não conta.
List<ServicoParaSelo> historicoSelosDemo(DateTime agora) => [
  for (var i = 0; i < 24; i++)
    ServicoParaSelo(
      cliente: 'cliente-${i % 12}',
      em: agora.subtract(Duration(days: 2 + i * 3)),
      agendado: i < 20,
      noHorario: i != 7,
      retornoContra: i == 15,
      clienteVoltou: i % 12 < 5,
    ),
  ServicoParaSelo(
    cliente: 'parente',
    em: agora.subtract(const Duration(days: 5)),
    clienteVoltou: true,
    clienteLigado: true,
  ),
];
