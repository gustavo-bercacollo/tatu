/// Números dos valores combinados que ainda são exemplo (ver "Decisões em
/// aberto" em docs/regras-de-negocio.md). Mudou um, muda só aqui.
abstract final class RegrasValor {
  /// RN-89: nenhum valor fica aberto mais que isso. Passou, o app pede
  /// para concluir ou dividir o trabalho em partes.
  static const validade = Duration(days: 7);

  /// RN-91: parcelamento no cartão a partir deste total…
  static const parcelarAPartirDe = 300.0;

  /// …em até tantas vezes.
  static const maxParcelas = 6;

  /// Opções da folha "Parcelar": à vista, 3x e o máximo.
  static List<int> get opcoesParcelas => {1, 3, maxParcelas}.toList();

  /// RN-91: o total pode ser parcelado?
  static bool podeParcelar(double total) => total >= parcelarAPartirDe;

  /// RN-89: o valor combinado em [combinadoEm] já passou da validade?
  static bool vencido(DateTime combinadoEm, DateTime agora) =>
      agora.difference(combinadoEm) > validade;
}
