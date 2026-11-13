# Tatu · Guia de design para desenvolvimento (Flutter / Dart)

Última atualização: 04/11/2026. Este documento reúne tudo o que foi decidido nas conversas de design: estilo, medidas, telas, estados e regras de negócio. Os desenhos de referência ficaram no chat; o Figma (https://www.figma.com/design/zprQlhIOqkpKJ5esa3zean/Tatu) tem as telas originais organizadas, mas ainda NÃO recebeu as telas novas (limite do plano Starter).

---

## 1. Princípios

1. **Velocidade acima de tudo.** O cliente pede ajuda "agora". Menos campos, menos toques, nunca silêncio ou tela travada.
2. **Uma escolha por vez.** Um caminho principal por tela, um botão principal por tela.
3. **Mostrar o que vem a seguir.** Cadastro com passos e tempo estimado, linhas do tempo, textos que dizem o próximo passo.
4. **Honestidade.** Estimativas são chamadas de estimativa, taxas aparecem antes, erros explicam o motivo.
5. **Estilo iPhone / Mac, minimalista.** Branco, cinzas translúcidos, texto preto, botões pretos em pílula. Sem cor de marca por enquanto.

---

## 2. Tema

### 2.1 Cores

| Token | Valor | Uso |
|---|---|---|
| bg | `#FFFFFF` | Fundo das telas |
| surfaceGrouped | `#F2F2F7` | Fundo de listas agrupadas (Atividade, Perfil) |
| surfaceTab | `#F9F9F9` (94%) | Barra de abas |
| fill | `#787880` a 12% | Campos, chips, cartões suaves |
| fillStrong | `#787880` a 16% | Botão secundário, botões redondos |
| textPrimary | `#000000` | Texto principal |
| textSecondary | `#8E8E93` | Texto de apoio, legendas |
| action | `#1C1C1E` | Botão principal, chip selecionado |
| onAction | `#FFFFFF` | Texto sobre `action` |
| online | `#34C759` | Ponto "online", "Pago", ✓ de passou |
| hairline | `#3C3C43` a 29% | Divisores de 0,5 px |
| scrim | `#000000` a 38% | Fundo escurecido atrás de folhas |
| verified | `#007AFF` | Selo de verificado, links, "Editar" |
| warning | `#FF9F0A` (texto `#A85F00`) | Aguardando, atenção, "refazer" |
| danger | `#FF3B30` | Erros, "Sair da conta", "Desativadas" |

### 2.2 Tipografia

Fonte: SF Pro no iOS. No Android, embutir **Inter** para manter a mesma aparência.

| Estilo | Tamanho / linha | Peso |
|---|---|---|
| Título grande (cadastro, Home) | 30–32 / 36–38, tracking −2% | Bold |
| Título de folha | 20–22 / 26 | Bold |
| Título de item | 17 / 22 | Semibold |
| Corpo | 17 / 24 | Regular |
| Corpo pequeno | 15 / 21 | Regular |
| Rótulo | 15 / 20 | Medium |
| Legenda | 13 / 18 | Regular |
| Botão | 17 / 24 | Semibold |
| Tab | 11 / 13 | Medium |

### 2.3 Medidas

- Margem lateral: **20 px** (telas de cadastro: **24 px**).
- Altura: botão principal **56** (em folhas **54**), campo **62**, chip **38** (cadastro **44**), linha de lista **52**, barra de abas **49** + área segura.
- Raios: botão e chips **pílula**, cartões **18–20**, campo **16**, folha **30** (só no topo), selo de avatar **círculo**.
- Ícones: traço fino (Lucide/Tabler), 22–24 px, pretos.
- Divisor: 0,5 px.

### 2.4 Esqueleto em Dart

```dart
import 'package:flutter/material.dart';

class TatuColors {
  static const bg = Color(0xFFFFFFFF);
  static const surfaceGrouped = Color(0xFFF2F2F7);
  static const fill = Color(0x1F787880);        // 12%
  static const fillStrong = Color(0x29787880);  // 16%
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF8E8E93);
  static const action = Color(0xFF1C1C1E);
  static const onAction = Color(0xFFFFFFFF);
  static const online = Color(0xFF34C759);
  static const verified = Color(0xFF007AFF);
  static const warning = Color(0xFFFF9F0A);
  static const danger = Color(0xFFFF3B30);
  static const hairline = Color(0x4A3C3C43);
  static const scrim = Color(0x61000000);
}

ThemeData tatuTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: TatuColors.bg,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.light(
    primary: TatuColors.action,
    onPrimary: TatuColors.onAction,
    surface: TatuColors.bg,
    error: TatuColors.danger,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: TatuColors.hairline),
);
```

---

## 3. Componentes reutilizáveis

- **Botão principal / secundário / desabilitado** (pílula, 56 px). Texto muda conforme o contexto ("Chamar encanador", "Aceitar Luiza"). Desabilitado: fundo `fill`, texto cinza.
- **Chip de serviço** (pílula, 38 px): padrão cinza; selecionado preto com ✓ ou ✦ (sugerido pela IA); opção "+ Outra" com contorno tracejado.
- **Folha (bottom sheet)**: raio 30 no topo, alça de 36×5, fundo escurecido atrás.
- **Campo de texto**: fundo `fill`, rótulo pequeno cinza dentro, valor embaixo; foco com contorno preto 1,5 px; erro com contorno vermelho + frase.
- **Lista agrupada** (estilo Ajustes do iPhone): cartões brancos sobre `surfaceGrouped`, ícone de traço à esquerda, valor atual à direita, seta cinza clara.
- **Cartão de valor / cobrança** (no chat): borda fina, valor grande, botão dentro.
- **Barra de progresso do cadastro**: 4 barrinhas + "Passo N de 4".
- **Selo de verificado**: círculo azul com ✓.
- **Avatar**: círculo cinza com iniciais (sem foto, por decisão).
- **Barra de abas**: Início, Atividade, Mensagens (ícones de traço + rótulo).

---

## 4. Mapa de telas

### 4.1 Cliente

| # | Tela | Estados / observações |
|---|---|---|
| C1 | Abertura | Só o nome "tatu" centralizado (sem ícone, sem frase) |
| C2 | Boas-vindas | "Como você quer usar o Tatu?": Preciso de um serviço / Quero trabalhar / Entrar (app único) |
| C3 | **Home** | Descrição é o centro. Chips de serviço únicos. Botão "Escolha um serviço" (desabilitado) → "Chamar [serviço]". Estados: IA marcou (✦ + "Sugerido pela descrição"); conflito (folha "Isso parece serviço de X", só se o cliente escolheu primeiro); Outros (folha com busca e "Não sei qual serviço"); serviço de Outros escolhido (chip com seta) |
| C4 | Endereço | Busca + mapa de confirmação (telas já existentes no Figma) |
| C5 | **Procurando** | Mapa com profissionais próximos; 1) primeiros 60 s; 2) "Expandindo a busca…" (raio aumenta); 3) "Ninguém ativo nesse momento": busca continua em segundo plano, botão "Voltar ao início" (linha "Buscando em segundo plano"). Notificação quando alguém ACEITA |
| C6 | Profissional encontrado | Mapa com rota e tempo; nota, serviços, distância; estimativa "R$ 80 a R$ 250"; Aceitar / Ver outro; contagem de prazo; seta para o perfil |
| C7 | Perfil do profissional | Topo (nota, serviços, resposta média, especialidades, sobre, verificação); rolagem (fotos, medalhas, avaliações em carrossel de 3 + "Ver todas"); barra fixa "Ver outro / Aceitar" |
| C8 | Chat | Resumo do pedido fixo; respostas rápidas; câmera; "Luiza enviou um valor" + cartão do valor ("Visita R$ 40 · Serviço R$ 150", total, forma de pagamento com "Trocar", "Reservamos agora. Só cobramos no fim.", **Confirmar valor** / Pedir outro valor); folha "Quanto você quer pagar?"; contraproposta ("1 de 3") |
| C9 | Cobrança | No fim do serviço o app cobra o valor reservado; estados: cobrança pendente, pago, falha no pagamento (trocar forma de pagamento). Não existe pagamento por fora |
| C10 | Pagamento | Folha (cartão, Pix, parcelas até 6x) → "Pagamento feito" com recibo → Avaliação (estrelas, tags, comentário opcional, "A [nome] também avalia você") |
| C11 | Atividade | Em andamento (linha do tempo: Pedido, Combinado, A caminho, Serviço, Pagamento; busca em segundo plano com "Cancelar pedido"); Concluídos (por mês, Pedir de novo, Recibo, Avaliar) |
| C12 | Mensagens | Lista simples; cobrança pendente isolada em cartão no topo com botão Pagar; estado vazio |
| C13 | Perfil do cliente | Iniciais + nome + selo + nota; grupos "Pedido rápido" (Endereços, Pagamento), "Conta" (Minhas avaliações, Notificações, Dados da conta), Ajuda, Privacidade e termos, Sair. Estado: sem cartão ("Adicionar") e notificações desativadas (vermelho + explicação) |

### 4.2 Profissional

| # | Tela | Estados / observações |
|---|---|---|
| P1 | Boas-vindas | Benefícios (perto de você, receba pelo app, você escolhe quando) + "O cadastro leva uns 5 minutos" + 4 passos |
| P2 | Passo 1: Seus dados | Opção A: nome, CPF, celular (login por SMS). Opção B: + e-mail e senha. Botão desabilitado até válido |
| P3 | Passo 2: Profissão | Escolha única → especialidades (até 3; "+ Outra" abre folha; em análise com relógio) → "Suas profissões" (até 3, "Adicionar outra profissão"). "Outros": lista com busca e "Escrever outro" (análise) |
| P4 | Passo 3: Onde receber | Chave Pix (CPF pré-preenchido, mascarado); "Ver taxas do Tatu" (folha); "Fazer isso depois" (folha de aviso). Estados: confirmando, "Chave salva", erro "chave em nome de outra pessoa", falha de conexão |
| P5 | Passo 4: Verificação | Intro (documento, selfie, selo); câmera do documento (frente/verso, só câmera, captura automática); conferência; selfie; **Em análise** (pedir permissão de avisos); **Aprovada**; **Reprovada corrigível** (lista de ✓ verdes, só o item a refazer em destaque); **Reprovada definitiva** (falar com a equipe) |
| P6 | Primeira Home | Dica apontando "Ficar online" (só na primeira vez) |
| P7 | Home | Offline: botão "Ficar online", resumo do dia, lembrete "Cadastre onde receber" se faltar; Online: "Buscando chamados…" |
| P8 | Novo chamado | Anel de contagem; serviço, descrição, foto, tempo/distância, região aproximada, nota do cliente, estimativa; Aceitar / Recusar |
| P9 | Chat | Igual ao do cliente + respostas rápidas + botão **Enviar valor** → folha "Quanto vai custar?" (Visita + Serviço; "A visita é sua mesmo se o serviço não acontecer."; Material incluso; "Você recebe": total, taxa do Tatu, no seu Pix; "Valor 1 de 3") |
| P10 | Andamento | A caminho (endereço exato, Abrir rota, "Cheguei" só perto do local); Chegou (Iniciar serviço); Em andamento (Concluir e cobrar, "Precisa mudar o valor?") |
| P11 | Cobrança | "Cobrar [cliente]" (valor, taxa, você recebe, fotos opcionais) → Aguardando → Pagamento recebido → Avaliar o cliente |
| P12 | Atividade e Ganhos | Cartão de ganhos da semana; Aguardando pagamento; Concluídos (Pago); Ganhos (hoje, semana, mês, gráfico, recebido / a receber) |
| P13 | Perfil | Cabeçalho, "Ver como o cliente vê" (prévia com faixa), Profissões, Fotos de trabalhos, Sobre você, Região de atendimento (2 a 20 km), Onde receber, Verificação, Notificações, Dados da conta, Ajuda, Privacidade, Sair |

---

## 5. Regras de negócio

### 5.1 Pedido e busca
- O chamado é enviado **ao mesmo tempo** para todos os profissionais ativos no raio.
- Sem aceite em **60 a 90 s**, o raio **expande sozinho** e a tela diz "Expandindo a busca para sua região…". Nunca silêncio.
- O raio **não é configurado pelo cliente**; é uma regra interna (por cidade e serviço).
- Sem ninguém ativo, a busca **continua em segundo plano**. A notificação ao cliente é "Encontramos um [serviço]" quando alguém **aceita** (não quando alguém só fica online). O pedido tem prazo de validade (a definir; sugestão 1 hora).
- O cliente tem prazo para confirmar o profissional (sugestão 2 a 3 min); depois o chamado passa ao próximo.
- Um profissional por vez, com "Ver outro profissional".

### 5.2 IA e serviço
- A IA lê a descrição e **marca** o serviço (✦). Sem confiança, **não marca nada**.
- A escolha manual do cliente **nunca é trocada em silêncio**; o ✦ some quando ele toca em outro.
- Se o cliente escolheu o serviço primeiro e a descrição discorda com confiança alta, aparece a folha de confirmação ("Chamar encanador" / "Manter pintor").
- O profissional pode usar "Isso é de outra categoria" para redirecionar o chamado.

### 5.3 Valor e chat
- O profissional envia o **valor** em duas partes: **visita** (dele mesmo se o serviço não acontecer) e **serviço**, e diz se o material está incluso. O cliente **confirma** ou pede outro. Até **3 rodadas**; depois sugere "Ver outro profissional".
- Valor confirmado só muda com uma nova proposta aceita pelo cliente.
- Endereço exato só aparece ao profissional **depois do valor confirmado**; antes, só a região aproximada.
- Estimativa de preço é da plataforma, por região e serviço, e sempre rotulada como estimativa.

### 5.4 Pagamento
- **Todo pagamento passa pelo app** (decidido em 13/11/2026): não existe pagamento por fora. Cartão (parcelas até 6x) ou Pix.
- Ao **confirmar o valor**, o app reserva o valor na forma de pagamento do cliente ("Reservamos agora. Só cobramos no fim."); a cobrança acontece no fim do serviço. A avaliação abre depois do pagamento.
- Comprovante para os dois lados.
- **Taxa**: comissão sobre todo serviço (valor de exemplo: 10%). A profissional vê o total, a taxa e o que cai no Pix antes de enviar o valor.

### 5.5 Cadastro do profissional
- Até **3 profissões**, até **3 especialidades** por profissão (as que aparecem no cartão do cliente).
- "Outros" e "+ Outra": revisão leve antes de aparecer; ocupa uma vaga enquanto está em análise; se recusada, a vaga volta.
- **Chave Pix** precisa estar no nome do CPF informado. "Fazer depois" permitido, com lembrete na Home; ao tocar em "Cobrar" sem chave, o app abre o Pix na hora.
- **Verificação** (documento só por câmera, sem galeria + selfie): reprovação **corrigível** (foto escura, cortada, documento vencido) mostra só o item a refazer; **definitiva** (identidade não confere) vai para a equipe. Limite de tentativas (sugestão 3).
- Sugestão (em aberto): verificação **obrigatória para ficar online**.
- Permissão de notificações pedida nos momentos certos (cliente: ao entrar em busca em segundo plano; profissional: tela "Em análise").

### 5.6 Chamados
- O app sempre abre **offline**. Só quem está online recebe chamados.
- Chamado com contagem (sugestão 30 s). Recusar não pune de cara; muitos perdidos seguidos põem a profissional offline automaticamente.
- "Cheguei" só libera perto do local (GPS). Iniciar e concluir ficam no histórico.

### 5.7 Avaliação
- Mútua. Estrelas + tags de um toque + comentário opcional. Nota baixa troca as tags para as negativas.
- Perfil mostra 3 avaliações em carrossel + "Ver todas".

### 5.8 Privacidade (LGPD)
- Fotos de documento e selfie usadas só para verificação; texto de aviso nas telas.
- Endereço exato só quando necessário. Denunciar fica no menu "⋯" do perfil.

---

## 6. Textos-chave (português)

- Home: "Oi, Ana" / "Do que você precisa?" / "O que está acontecendo?" / "Serviço" / "Escolha um serviço" → "Chamar encanador" / "Profissionais ativos perto de você".
- Busca: "Procurando um profissional" / "Expandindo a busca para sua região…" / "Ninguém ativo nesse momento" / "Cancelar pedido".
- Profissional encontrado: "Aceitar Luiza" / "Ver outro profissional" / "Estimativa na sua região: R$ 80 a R$ 250".
- Chat: "Você aceitou a Luiza. Combinem os detalhes e o valor por aqui." / "Valor combinado" / "Confirmar valor" / "Pedir outro valor".
- Valor: "Luiza enviou um valor" / "Visita R$ 40 · Serviço R$ 150" / "Reservamos agora. Só cobramos no fim." / "Quanto vai custar?" / "Material incluso" / "Você recebe" / "Taxa do Tatu (10%)" / "No seu Pix".
- Cadastro profissional: "Trabalhe com o que você sabe fazer" / "O cadastro leva uns 5 minutos" / "Seus dados" / "Qual é a sua profissão?" / "Escolha até 3 em que você manda muito bem." / "Onde você quer receber?" / "Vamos confirmar que é você" / "Cadastro aprovado!" / "Precisamos de uma nova foto".

---

## 7. Decisões em aberto

1. **App único** (recomendado) ou dois apps.
2. **Login**: celular + SMS (recomendado) ou e-mail + senha.
3. **Verificação obrigatória** para ficar online (recomendado) ou opcional.
4. **Comissão** (o 10% é só exemplo) e **modelo freemium** para profissionais.
5. **Prazo de repasse** do dinheiro (hoje o texto diz "enviado").
6. Prazos: validade do pedido em segundo plano, confirmação do cliente, contagem do chamado, limite de tentativas da verificação.
7. Avatar: iniciais (atual) ou foto real; medalhas reais (Pontual, Bem avaliada, Experiente são exemplos).
8. Barra do sistema Android: o Figma original mostra uma barra de navegação Android dentro da moldura de iPhone; decidir para qual plataforma o desenho vale.

---

## 8. Estado do Figma

- Página "user" organizada: 15 pastas numeradas (01 Splash ... 15 Perfil do cliente) e grupo "Setas de fluxo". Home original intacta.
- Já existe uma seção "Redesign · 02 Home v2" com uma biblioteca em tema laranja que foi **abandonada** (a paleta atual é a da seção 2). Pode ser apagada.
- Nenhuma tela nova foi montada no Figma. O plano Starter tem limite de chamadas de MCP por mês; ver a pesquisa no chat.
