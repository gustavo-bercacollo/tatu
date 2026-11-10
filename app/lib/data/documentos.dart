/// Documento legal (Termos de uso, Política de privacidade).
class Documento {
  const Documento(this.titulo, this.atualizado, this.secoes);

  final String titulo;
  final String atualizado;
  final List<(String titulo, String texto)> secoes;
}

const termosDeUso = Documento(
  'Termos de uso',
  'Atualizado em 1 de outubro de 2026',
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
