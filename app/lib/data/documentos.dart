/// Documento legal (Termos de uso, Política de privacidade).
class Documento {
  const Documento(this.titulo, this.atualizado, this.secoes);

  final String titulo;
  final String atualizado;
  final List<(String titulo, String texto)> secoes;
}

// TODO(jurídico): revisar os Termos de uso com advogado antes do
// lançamento, principalmente as seções 4 e 5 (RN-108).
const termosDeUso = Documento(
  'Termos de uso',
  'Atualizado em 17 de novembro de 2026',
  [
    (
      '1. O que é o Tatu',
      'O Tatu conecta quem precisa de um serviço a profissionais que atendem perto.',
    ),
    (
      '2. Seu cadastro',
      'Use dados verdadeiros. Cada pessoa tem uma conta, com até os dois perfis.',
    ),
    (
      '3. Pedidos e pagamentos',
      'O valor é combinado entre cliente e profissional. O pagamento pode ser pelo app ou direto, e a comissão vale só no app.',
    ),
    // RN-108: o Tatu intermedia.
    (
      '4. O papel do Tatu',
      'O Tatu intermedia: conecta cliente e profissional e processa o '
          'pagamento. Quem presta o serviço é o profissional.',
    ),
    // RN-45, RN-107 e RN-108: garantia do Tatu de 24 horas; a garantia
    // legal do serviço é do profissional.
    (
      '5. Garantia',
      'A garantia do Tatu é de 24 horas depois que o serviço é concluído. '
          'Nesse prazo, você pode contestar pelo app e o suporte decide. '
          'Depois disso, a garantia legal do serviço é do profissional '
          '(pelo Código de Defesa do Consumidor, 90 dias para serviços '
          'duráveis). Fale com ele pelo mesmo chat do pedido.',
    ),
  ],
);

const politicaDePrivacidade = Documento(
  'Política de privacidade',
  'Atualizado em 1 de outubro de 2026',
  [
    (
      'Quais dados usamos',
      'Nome, celular, e-mail e endereços. Sua localização só quando você usa o app.',
    ),
    (
      'Para que usamos',
      'Para achar profissionais perto, combinar o serviço, cobrar pelo app e dar suporte.',
    ),
    (
      'Seus direitos',
      'Você pode ver, corrigir e apagar seus dados quando quiser.',
    ),
  ],
);
