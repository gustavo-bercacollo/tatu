/// Prazos do atendimento que ainda podem mudar (decisão em aberto: ver
/// "Prazos finais" em docs/regras-de-negocio.md). Mudou um prazo, muda
/// só aqui.
abstract final class Prazos {
  /// RN-76: depois de combinar o valor, tempo para tocar
  /// "Estou a caminho" antes do app perguntar "Ainda vai?".
  static const estouACaminho = Duration(minutes: 10);

  /// RN-77: tempo para responder "Ainda vai?" antes do pedido voltar
  /// sozinho para a busca.
  static const aindaVai = Duration(minutes: 5);

  /// RN-78: atraso que libera "Chamar outro" sem custo, em vezes o tempo
  /// previsto de chegada.
  static const fatorAtraso = 2;

  /// RN-79: abandonos que pausam a conta dentro da janela.
  static const abandonosParaPausar = 3;
  static const janelaAbandonos = Duration(days: 30);

  /// RN-80/RN-81: espera do profissional na porta depois do "Cheguei";
  /// depois dela, libera "Cliente não apareceu".
  static const esperaCliente = Duration(minutes: 10);

  /// RN-82: ausências do cliente que pausam a conta dentro da janela.
  static const ausenciasParaPausar = 3;
  static const janelaAusencias = Duration(days: 30);

  /// RN-35: retenção antes do repasse ao profissional (Pix em 24 horas).
  static const repasse = Duration(hours: 24);

  /// Protótipo: os relógios andam [aceleracao] vezes mais rápido, para a
  /// demo não esperar 10 minutos de verdade (1 s real = 20 s no app).
  /// Nos testes fica 1 (tempo real, controlado pelo teste).
  static int aceleracao = 20;

  /// Quanto [d] dura de verdade no protótipo.
  static Duration naDemo(Duration d) => d ~/ aceleracao;
}
