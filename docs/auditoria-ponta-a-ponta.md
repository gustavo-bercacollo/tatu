# Tatu · Auditoria de ponta a ponta

26/11/2026 · Base: regras v51 · Itens simples já viraram regra na v52 (RN-234 a RN-249), Termos 1.2, Política 1.1, catálogo 1.2

> Isto não substitui advogado nem contador. Serve para você chegar neles com as perguntas certas e com as soluções já desenhadas.

## Resumo em 1 minuto

- **O app é viável.** O coração dele está certo: valor confirmado no app, código na porta, foto ao concluir e retorno com limite. Isso já fecha a maioria dos loops e gera prova para quase toda briga.
- **O que pode quebrar não está nas telas.** Está no dinheiro (como o pagamento é guardado, repassado em 24 h e contestado no cartão) e no tamanho do app (434 telas e vários pontos que dependem de uma pessoa do suporte, que hoje é você).
- **O loop do retorno que você citou já não existe:** é 1 retorno + 1 mediação, e a mediação termina em dinheiro de volta ou "não procede". Falta só uma trava no "refazer com outro profissional". Achei **11 outros loops sem trava** (seção 1).
- **13 falhas de lógica** (seção 2). Três podem travar um atendimento: limite de 2 visitas × retorno, reserva do cartão que vence antes do serviço e falta de internet no local.
- **15 brechas para oportunistas** (seção 3). A mais grave: cartão roubado + profissional laranja.
- **As 5 coisas que eu resolveria antes de lançar:**
  1. Pagamento por um intermediador autorizado pelo Banco Central, com divisão automática (split).
  2. Antifraude mínima contra cartão roubado e conta laranja.
  3. Regra de quem paga o chargeback, com uma reserva maior.
  4. Lançar menor: uma cidade, poucas profissões, sem "à distância".
  5. Antecedentes criminais para babá, cuidador e enfermagem, ou tirar essas profissões do lançamento.

**Legenda da coluna "Quebra?"**
- **App**: trava um atendimento ou uma cobrança.
- **Negócio**: pode dar prejuízo grande ou problema legal sério.
- **Suporte**: gera trabalho manual demais.
- **Brecha**: alguém tira vantagem.
- **Ajuste**: corrige, mas não quebra nada.

## 1. Loops: o que a lei deixa limitar

**A regra:** você pode limitar quantas vezes o **app** repete um processo. Não pode limitar o **direito** da pessoa. Por isso todo loop precisa terminar numa saída que a lei aceita.

- **Serviço com defeito.** A lei (CDC, art. 20) dá ao cliente três saídas: refazer, dinheiro de volta ou desconto. Ela não obriga a refazer infinitas vezes. Depois que o conserto falhou, basta oferecer o dinheiro (todo ou parte). Por isso o limite de 1 retorno é legal.
- **O que seria ilegal:** uma trava que termina em "acabou, sem nada" e tira a opção de reembolso (CDC, art. 51, II e IV). No Tatu, a mediação tem "devolver 50%" e "devolver 100%", então está ok.
- **Depois que o app encerra o caso** ("não procede"), a pessoa ainda pode ir ao Procon ou à Justiça. Isso não tem como travar e não precisa: o app só não repete o processo dele.
- **Todo o resto** (negociação, horários, trocas, pausas) não é direito do consumidor: é processo do app. Pode limitar, desde que a regra esteja nos Termos e apareça na tela antes de a pessoa agir.

### O seu exemplo: retorno infinito

Hoje já termina assim:

serviço → Algo errado → **1 retorno** (RN-184) → "Resolveu? Não" → **1 mediação** (RN-190) → refazer com outro profissional · devolver 50% · devolver 100% · não procede → **fim**

**Falta uma trava.** "Refazer com outro profissional" é um serviço novo. Se ele também falhar, pode virar outro retorno, outra mediação, outro refazer…

**Trava proposta:**
- O refazer tem retorno próprio, porque o trabalho é do novo profissional.
- Se esse retorno também for para a mediação, ela **não pode escolher "refazer" de novo**: só devolver o dinheiro ou "não procede".
- Resultado: no máximo 2 tentativas de conserto por problema; depois, dinheiro.

### Ajuste jurídico importante no "Algo errado"

Hoje o cliente só pode pedir retorno, e o dinheiro só aparece se a mediação decidir. Pelo art. 20, quem escolhe é o cliente.

**Proposta:** o 1º passo do "Algo errado" passa a ter duas opções.
1. **"Quero que a [nome] volte e arrume (sem custo)"**: o padrão, mais rápido.
2. **"Prefiro o dinheiro de volta"**: vai para o profissional, que escolhe "Devolver" ou "Prefiro voltar e arrumar". Se o cliente mantiver o pedido de dinheiro, vai para a mediação.

Isso é a pergunta J-04 do advogado. Se ele disser que "retorno primeiro" é aceitável, fica como está. Eu colocaria a opção: protege o Tatu, e o conserto grátis continua sendo o caminho mais fácil.

### Loops sem trava hoje

| # | Loop | Regra | Trava proposta | Quebra? |
| --- | --- | --- | --- | --- |
| 1 | No horário do retorno, o profissional sugere outro horário, o cliente volta à grade, ele sugere de novo, e assim por diante. Os 7 dias acabam e o profissional leva falta, mesmo quando quem recusou foi o cliente. | RN-213 | O profissional sugere no máximo 2 vezes e o cliente volta à grade 1 vez. Sem acordo de horário, ninguém leva falta e o cliente pode pedir a mediação (decidido: RN-243). | Brecha: o cliente força devolução |
| 2 | Sem acordo no valor → "Pedir de novo" para a mesma pessoa → mais 3 rodadas → … | RN-27, RN-176 | Depois de "Sem acordo", "Chamar a [nome]" fica desativado por 24 h. Qualquer outro profissional pode ser chamado. | Ajuste |
| 3 | A mesma coisa no plano: sem acordo → "Tornar fixa" de novo | RN-210 | Espera de 7 dias para propor de novo à mesma pessoa. | Ajuste |
| 4 | Novo valor durante o serviço sem limite: vira pressão sobre o cliente. | RN-32, RN-87 | 1 novo valor pendente por vez. Com 2 recusados no mesmo atendimento, não dá para mandar outro: o profissional conclui o combinado ou encerra cobrando a visita. | Brecha |
| 5 | Valor expirado → "Pedir de novo" → expira → … | RN-229 | O botão funciona 1 vez por card. | Ajuste |
| 6 | "Ver outro profissional" sem limite no mesmo pedido | RN-22 | 3 trocas por pedido; depois, "Tente de novo em alguns minutos". | Ajuste: queima profissionais |
| 7 | O cliente confirma, o profissional sai, o cliente cancela de graça, e repete. | RN-43 | Grátis até 2 min depois de "Estou a caminho"; depois, cobra a visita, com aviso antes de confirmar. Validar com o advogado (J-08). | Brecha: afasta profissionais |
| 8 | Pausa → fala com o suporte → libera → pausa de novo | RN-63, RN-79, RN-82, RN-106 | 1ª pausa: volta sozinho em 7 dias, depois de ler o motivo. 2ª pausa em 6 meses: 30 dias. 3ª: análise de banimento. | Suporte |
| 9 | "Não vou nesta semana" toda semana: um plano que nunca acontece. | RN-147 | 2 seguidas: o cliente recebe "Pausar ou encerrar o plano?". 3 seguidas: o plano pausa sozinho. | Ajuste |
| 10 | Plano pausado para sempre | RN-148 (em aberto) | Pausa de até 60 dias. Depois, o plano encerra, com aviso 7 dias antes. | Ajuste |
| 11 | Contestar avaliação, pedir revisão e denunciar sem limite | RN-48, RN-198, RN-135 | 1 contestação por avaliação. 1 revisão por decisão. Denúncias repetidas sobre o mesmo fato viram uma só. | Suporte |

## 2. Falhas de lógica

| # | Falha | Exemplo | Solução | Quebra? |
| --- | --- | --- | --- | --- |
| L-01 | O limite de 2 visitas por semana conta visitas, e não dias, e não diz o que é "semana". O retorno da diarista do plano vira a 3ª visita, é bloqueado, e ela leva falta por não marcar. | Plano na segunda e na quinta; o cliente pede retorno da faxina de quinta. | Contar **dias**: a lei (LC 150) fala em "mais de 2 dias por semana". Semana de segunda a domingo. Na grade do retorno e no "Pedir de novo", os dias que passariam do limite ficam apagados com "Limite de 2 dias por semana". Retorno no mesmo dia de uma visita do plano conta como um dia só. | **App** |
| L-02 | O card do plano diz "cobrado no fim do mês" (RN-211), mas a regra cobra cada visita ao concluir (RN-146). | — | Trocar o texto para "cobrado a cada visita". | Ajuste: informação errada de preço gera reclamação |
| L-03 | "O Tatu nunca paga do próprio bolso" (seção 3) contradiz a RN-188 (o Tatu paga outro profissional) e o chargeback perdido. | — | Reescrever: "O Tatu só paga em 2 casos, cobertos pela reserva: o refazer do retorno e o chargeback perdido." | Ajuste |
| L-04 | A reserva no cartão vence, em geral em até 7 dias (varia por bandeira). Num serviço marcado para daqui a 10 dias, a reserva feita na confirmação já não vale no dia. | Pintura marcada para o dia 10. | Serviço marcado para mais de 5 dias depois: na confirmação, só valida o cartão; a reserva é feita na véspera, igual ao plano (RN-225). | **App**: a cobrança falha em silêncio |
| L-05 | Sem internet no local (P-11), o código na porta e o "Concluir" não funcionam. | Subsolo, sítio. | Modo sem internet: o código é conferido no próprio celular (os dois aparelhos recebem a chave quando o valor é confirmado). Foto e conclusão ficam guardadas com a hora certa e são enviadas quando a internet volta. | **App** |
| L-06 | "Cliente não apareceu" não tem defesa: o profissional pode marcar mesmo com o cliente em casa. | Ele não tocou a campainha. | Depois do "Cheguei", o cliente tem o botão "Estou indo abrir". Se ele tocar, o "Cliente não apareceu" só libera depois de uma ligação pelo app e mais 10 min. Vale também para "cliente ausente" no retorno. | Brecha: visita cobrada sem trabalho |
| L-07 | "Não consigo ir", na recusa do retorno, vai para a mediação humana, mas o caso é óbvio. | — | "Não consigo ir" = devolução automática pelos repasses presos (RN-188), sem falta na 1ª vez. | Suporte |
| L-08 | O prazo do retorno continua correndo com o pedido aberto. Pela lei (CDC, art. 26, §2º, I), a reclamação suspende o prazo. | Pedido no dia 88 de 90. | "O prazo fica parado enquanto o pedido estiver aberto." | Negócio (risco jurídico) |
| L-09 | Os horários não têm fuso: "Vale até 17:55" num serviço à distância entre Manaus e São Paulo. | — | Todo horário aparece no fuso de quem está vendo. | App (bug) |
| L-10 | Não há regra para profissional suspenso ou banido com retorno aberto. | — | O caso vai direto para a RN-188 (outro profissional ou devolução). | App: o pedido fica preso |
| L-11 | Excluir a conta fica bloqueado enquanto há dívida (RN-15, RN-185), mas a LGPD dá direito de pedir a exclusão. | — | Aceitar o pedido, apagar o que der e guardar só o necessário (dívida e provas), como a LGPD permite (art. 16). | Ajuste jurídico |
| L-12 | "Só menor em casa" (em aberto) | — | O código já resolve: só o titular da conta, adulto, passa o código. Sem adulto em casa, o profissional não entra e vale a RN-81, com a proteção da L-06. Falta só escrever a regra. | Ajuste |
| L-13 | Avaliação com vários pagamentos (em aberto) | — | Decidir antes de programar, porque mexe no banco de dados. Sugestão: uma avaliação por atendimento (por card). | Retrabalho no código |

## 3. Brechas para oportunistas

| # | Golpe | Como funciona | Trava | Quebra? |
| --- | --- | --- | --- | --- |
| O-01 | **Cartão roubado + profissional laranja** | O golpista cria uma conta de cliente com cartão roubado e uma de profissional com documento de laranja. Faz um "serviço" de R$ 2.000 e recebe no Pix em 24 h. Meses depois, o dono do cartão contesta e o Tatu devolve tudo. Hoje a proteção ("Uso fora da finalidade") está adiada. | **No lançamento, não depois:**<br>(1) 3DS no cartão: o banco do cliente confirma a compra no app dele, e na maioria das fraudes a perda passa a ser do banco.<br>(2) Trava de autopagamento: mesmo CPF, aparelho, cartão, chave Pix ou endereço nos dois lados = bloqueado.<br>(3) Profissional novo recebe em 7 dias nos 5 primeiros serviços; depois, em 24 h.<br>(4) Cliente novo: teto por serviço (ex.: R$ 500) e sem parcelamento nos primeiros pedidos.<br>(5) Antifraude do intermediador ligado. | **Negócio** |
| O-02 | **Chargeback "amigo"** | O cliente recebe o serviço e contesta no cartão. A contestação pode chegar meses depois, e o repasse já foi feito. Hoje há as provas (RN-194), mas nenhuma regra diz quem paga quando o Tatu perde. | **Perdido com provas fortes** (código na porta, foto e confirmação): o Tatu paga pela reserva e a conta do cliente fica com pendência (RN-226) até ele pagar.<br>**Perdido sem código na porta:** desconta do profissional (RN-192).<br>**Reserva:** 1% da comissão dá cerca de 0,1% do volume, pouco para fraude e chargeback. Começar com 10% da comissão e ajustar pelos números reais. | **Negócio** se a reserva for pequena |
| O-03 | Cliente recusa todos os horários do retorno | Força a devolução automática. | Loop 1. | Brecha |
| O-04 | Cancelar de graça com o profissional na porta | — | Loop 7. | Brecha |
| O-05 | Profissional sobe o preço no meio do serviço | Usa a visita como pressão. | Loop 4 + valor de referência (O-10). | Brecha |
| O-06 | "Cliente não apareceu" falso | — | L-06. | Brecha |
| O-07 | **Denúncia como arma** | A denúncia de assédio suspende o acusado na hora (RN-56), e "não era mulher" suspende até a análise (RN-60). Um concorrente ou um cliente com raiva derruba a renda de um profissional. | O bloqueio entre os dois na hora continua.<br>**Suspensão na hora só** com mensagem denunciada no chat, relato de violência física ou 2 denúncias de pessoas diferentes. O resto: análise em até 24 h.<br>**"Não era mulher" nunca suspende sozinho:** o suporte compara com a verificação (documento + selfie). Suspender uma mulher trans por denúncia pode ser discriminação (o STF equiparou a transfobia ao racismo).<br>Não há solução perfeita: é segurança × injustiça, e isto é o meio-termo. | Negócio (risco jurídico) |
| O-08 | Avaliação falsa (P-09) | Contas de amigos dão 5 estrelas. | Só avalia quem pagou um serviço com código na porta (ou entrega aprovada). Contas ligadas não contam (mesma regra dos selos, RN-218). | Brecha |
| O-09 | **Fechar por fora** (P-03) | Antes do valor confirmado: "me chama no zap que faço mais barato". O filtro de contato está na fase 2. | Trazer para o lançamento só o filtro de número, e-mail e @ **até o valor ser confirmado**, que é simples de fazer. Depois do serviço, aceitar: nenhum marketplace resolveu isso por completo. O Tatu ganha sendo a opção mais vantajosa (garantia, pagamento garantido, Pedir de novo). | Negócio: come a receita, não quebra o app |
| O-10 | Preço abusivo na emergência (P-06) | O CDC proíbe "vantagem manifestamente excessiva" (art. 39, V), e o Tatu pode ser cobrado junto. | No card de valor, a linha "Valor comum aqui: R$ 80–150", calculada pelos serviços do app (sem dados, a linha não aparece). Valor 3× acima do comum: o cliente vê "Acima do comum para esse serviço" antes de confirmar. | Negócio (risco jurídico) |
| O-11 | Material inflado (P-07) | "Gastei R$ 300 em peças." | No novo valor, linha separada "Material · R$ X" com foto da nota ou do cupom (obrigatória acima de R$ 100, exemplo). Decidir se a taxa do Tatu vale sobre o material. | Brecha |
| O-12 | Banido volta com CPF de parente ou documento de outro (P-10) | — | Verificação com prova de vida e comparação com a base do governo (ex.: Serpro Datavalid), não só foto do documento. Aparelho, cartão e chave Pix de conta banida ficam marcados. Não há solução completa. | Brecha |
| O-13 | Conta roubada (troca de chip) | Não existe senha: quem pega o número entra e usa o cartão salvo. | Entrar num aparelho novo pede também um código no e-mail. A primeira compra num aparelho novo passa pelo 3DS. A chave Pix presa ao CPF (já existe) protege o profissional. Fechar "Recuperação de conta" antes do lançamento. | Negócio |
| O-14 | Teste de cartão e SMS pago por robô | Cartões roubados são testados com gorjetas de R$ 2; robôs pedem código por SMS sem parar, e o SMS custa. | Limite de tentativas por cartão, aparelho e número. Captcha invisível no pedido de código. 3DS. | Negócio (custo) |
| O-15 | Burlar o limite de 2 dias com outra conta da mesma casa | — | Já conta por endereço. Somar também as contas ligadas (mesmo cartão, Pix ou aparelho). O resto é risco do cliente (Termos 13.4). | Ajuste |

## 4. Riscos jurídicos

### A. Dinheiro e Banco Central · **Negócio**

As regras dizem que o Tatu "guarda" o Pix e segura repasses. Se o dinheiro cai numa conta do Tatu e ele repassa depois, o Tatu está guardando dinheiro de terceiros. Isso pode exigir autorização do Banco Central (como instituição de pagamento ou subcredenciador). O BC mexeu nas regras de arranjos de pagamento em novembro de 2025 (Resolução BCB 522), então o advogado precisa olhar a versão atual.

**Solução:** usar um intermediador de pagamentos autorizado pelo BC, com split e uma subconta para cada profissional.
- O dinheiro fica no intermediador. O Tatu só dá as ordens: reservar, cobrar, segurar, liberar e devolver.
- Todas as regras atuais (repasse em 24 h, repasse preso, devolução) funcionam assim.
- Escolher o intermediador antes de programar o pagamento.

### B. Tributos e nota fiscal · **Negócio**

- **Sem split**, a Receita pode tratar os 100% como receita do Tatu e cobrar imposto sobre o total.
- **Com split**, a receita do Tatu é só a comissão, com nota da comissão para o profissional.
- **Reforma tributária:** a LC 214/2025 torna as plataformas digitais que intermedeiam e participam do pagamento responsáveis pelo IBS/CBS em alguns casos, principalmente quando o prestador não está regular. Entra em transição a partir de 2026–2027.
- **Contador agora.** Isso também decide a questão em aberto "Contas com CNPJ".

### C. Vínculo de emprego · **Negócio**

O Tatu já está numa posição melhor que os apps de transporte: o profissional define o preço, escolhe o cliente, recusa sem penalidade (RN-62) e não tem exclusividade.

**Cuidados:**
- Penalidade só por prejuízo ao cliente (faltar, sumir). Nunca por recusar chamado ou ficar offline.
- A RN-64 (cancelar baixa a posição na fila) é aceitável porque cancelar depois de aceitar prejudica o cliente. Deixar esse motivo escrito.
- Nada de metas, horário obrigatório ou ranking.
- Plano fixo: corrigir a L-01 (contar dias).

**STF:** o tribunal ainda discute o vínculo de trabalhadores de aplicativo (Tema 1291). Até onde consegui ver, não há decisão final: o julgamento foi retirado de pauta depois que a OIT aprovou uma convenção sobre trabalho em plataformas. O resultado pode mudar as regras para todos e não depende de você. Confirmar a situação com o advogado.

### D. Consumidor

- **Art. 20:** a escolha entre conserto e dinheiro (J-04). Ver seção 1.
- **Art. 26, §2º:** o prazo para enquanto o pedido está aberto. Ver L-08.
- **Art. 49** (arrependimento em 7 dias em compra fora da loja) × cobrar a visita quando o cliente cancela: J-08, nova.
- **Decreto 7.962/2013 (comércio eletrônico):** CNPJ, endereço e contato visíveis no app, resumo do contrato antes de confirmar e atendimento eletrônico com resposta em até 5 dias. A "Ajuda" precisa prometer e cumprir isso.
- **Dano na casa (P-04, adiado):** na Justiça, a plataforma às vezes responde junto com o profissional (J-03). Não há solução completa. O Tatu reduz o risco com provas (fotos e chat), regra clara e, quando tiver volume, seguro de responsabilidade civil.

### E. Profissões reguladas e comissão · **Negócio**

- **Advogado:** o Estatuto da OAB proíbe o advogado de usar agenciador com participação nos honorários (art. 34, III). Uma comissão de 10% sobre honorários é muito parecida com isso.
- **Saúde** (psicologia, nutrição, fisioterapia, veterinária, enfermagem): os conselhos têm regras próprias de publicidade e cobrança.

**Solução:**
- Tirar Advogado do lançamento.
- Manter as profissões de saúde só depois do parecer (J-11, nova).
- Se essas profissões entrarem no futuro, o modelo costuma ser assinatura fixa, não comissão.

### F. Crianças, idosos e saúde em casa · **Negócio**

Babá, cuidador de idosos, técnico de enfermagem e professor particular de criança (presencial) ficam sozinhos com pessoas vulneráveis. Os antecedentes criminais estão adiados, e um caso grave aqui pode acabar com o Tatu.

**Solução:** para essas profissões, uma das duas:
- exigir certidão de antecedentes criminais (federal e estadual, gratuitas pela internet) antes de ativar, renovada todo ano;
- ou tirá-las do lançamento.

A Justiça do Trabalho já aceitou exigir antecedentes quando o trabalho é cuidar de criança, idoso ou pessoa com deficiência (J-12, nova).

### G. Denúncia e gênero

Ver O-07 (J-13, nova).

### H. LGPD: o que falta

- **Selfie:** é biometria. Conferir se a Política dá a base legal específica (consentimento destacado ou prevenção à fraude, art. 11).
- **Conversas:** hoje ficam guardadas para sempre (RN-42). Definir um prazo, por exemplo 5 anos depois do último serviço, igual às fotos.
- **Relatório de impacto (RIPD):** para biometria, localização ao vivo e moderação de arquivos. O advogado faz com você, e a ANPD pode pedir.

## 5. Suporte: o que hoje depende de uma pessoa

| Ponto manual | Regra | Como automatizar |
| --- | --- | --- |
| Verificação do profissional | RN-06 | O fornecedor de verificação aprova sozinho os casos claros. Você só vê os duvidosos. |
| Registro no conselho | RN-157 | Consulta automática onde o conselho permitir. O resto vai para uma fila sem pressa. |
| Fotos de trabalhos | RN-13 | A IA aprova sozinha quando não aparece rosto nem endereço. |
| Reembolso à distância | RN-104 | **O maior vazamento:** todo pedido vai para uma pessoa. Usar o modelo do retorno: o profissional aceita devolver ou contesta, e só a contestação vai para uma pessoa. |
| Pausas "até falar com o suporte" | RN-63, RN-65, RN-79, RN-82, RN-106 | Loop 8: na 1ª vez, a pessoa volta sozinha. |
| "Não consigo ir" no retorno | RN-186 | L-07. |
| Contestação de avaliação | RN-48 | A IA separa as óbvias (palavrão, avaliação de outro serviço). |
| Código errado 3 vezes | RN-167 | Antes do suporte, "Ligar para o cliente" pelo app. |
| Sinal de volta sem entrega | RN-105 | Automático: sem entrega no prazo, o sinal volta sozinho. |
| Mediação, revisão (LGPD) e denúncias | RN-190, RN-198, RN-135 | Continuam humanas, porque a lei e a segurança pedem. Já têm limite. |

**Conta rápida (exemplo):**
- 1.000 serviços por mês com 3% passando por uma pessoa = 30 casos por mês. Cabe numa pessoa.
- Com 10%, são 100 casos por mês: aí não cabe junto com programar.
- **Meta:** menos de 3%.

## 6. É viável?

**Sim, com três condições.**

### 1. A margem real · **Negócio**

10% de R$ 150 = R$ 15. Desse valor ainda saem:
- a taxa do cartão;
- **o adiantamento do dinheiro do cartão.** No crédito, o dinheiro chega em cerca de 30 dias; no parcelado, uma parcela por mês. Pagar o profissional em 24 h obriga a antecipar, e antecipar custa;
- a taxa do Pix;
- antifraude e 3DS;
- SMS;
- consulta de CPF;
- verificação do profissional;
- a reserva de chargeback.

A sobra pode ficar bem abaixo de 10%.

**Antes de fixar os 10% e as 24 h:** pedir a tabela do intermediador e fazer a conta. Se não fechar:
- Pix em 24 h e cartão em mais dias;
- ou o profissional escolhe "receber em 24 h, com taxa" ou "em X dias, sem taxa";
- parcelamento só com juros pagos pelo cliente, ou fora do lançamento.

### 2. Começar pequeno

Um marketplace precisa de clientes e profissionais no mesmo bairro, ao mesmo tempo. Lançar numa cidade (ou em poucos bairros) e com 10 a 15 profissões de casa.

### 3. Um escopo que caiba numa pessoa

434 telas é app de empresa com equipe. Proposta para o lançamento:

| Entra no lançamento | Fica para a fase 2 |
| --- | --- |
| Pedido no local, busca, chat, valor, código na porta, foto, conclusão, cobrança (cartão e Pix), retorno, avaliação, segurança, denúncia e Termos | Todo o "à distância": sinal, prévias protegidas, entregas e arquivos executáveis. É a parte mais complexa, com mais fraude e mais suporte. |
| 10 a 15 profissões de casa: encanador, eletricista, diarista, pintor, montador, chaveiro, jardineiro… | Profissões reguladas, babá, cuidador e enfermagem, até sair o parecer e os antecedentes. |
| | Selos: precisam de 20 serviços em 90 dias, então ninguém terá no 1º mês. Gorjeta, anúncios e parcelamento também. |
| | Plano fixo pode esperar: no começo ainda não há clientes recorrentes. |

Nada se perde: as telas e as regras ficam prontas para a fase 2.

## 7. Pontas sem solução completa: aceitar e reduzir

| Ponta | Por que não tem solução | Como reduzir | Quebra? |
| --- | --- | --- | --- |
| Fechar por fora depois do 1º serviço | Não dá para provar nem impedir. | Garantia, pagamento garantido, Pedir de novo, plano fixo e o filtro antes do valor (O-09). | Não. Come receita. |
| Documento ou CPF de parente | Uma verificação boa reduz o risco, mas não zera. | Prova de vida, base do governo e marcação do aparelho (O-12). | Não. |
| Dano na casa | A plataforma pode responder junto. | Provas, regra clara e seguro depois. | Pode, num caso grande. |
| Denúncia falsa × segurança | Proteger rápido às vezes pune um inocente. | O-07. | Não. |
| Chargeback amigo | Quem decide é o banco, não o Tatu. | Provas, 3DS e reserva (O-02). | Não, com reserva. |
| Profissional some com dívida | Não dá para cobrar fora do app. | Repasse preso e reserva. | Não. |
| Print no iPhone | O iPhone não deixa bloquear. | Marca d'água (já existe). | Não. |
| Decisão do STF ou lei nova sobre plataformas | Não depende de você. | Manter a autonomia real do profissional e acompanhar com o advogado. | Pode mudar o modelo. |

## 8. Perguntas novas para o advogado e o contador

| Nº | Pergunta |
| --- | --- |
| J-04 (reforçar) | **A mais importante:** "retorno primeiro" é aceitável, ou o cliente precisa poder escolher o dinheiro de volta desde o início (CDC, art. 20)? |
| J-08 | Podemos cobrar a visita quando o cliente cancela depois que o profissional saiu? O direito de arrependimento (CDC, art. 49) atrapalha? |
| J-09 | Com intermediador de pagamento (split e subcontas), o Tatu precisa de alguma autorização do Banco Central? O que muda com a Resolução BCB 522/2025? |
| J-10 (contador) | Com split, a receita do Tatu é só a comissão? Como ficam a nota da comissão e a responsabilidade pelo IBS/CBS (LC 214/2025) quando o profissional não emite nota? |
| J-11 | Advogados e profissionais de saúde podem pagar comissão ao Tatu? (Estatuto da OAB, art. 34, III; conselhos de saúde.) |
| J-12 | Podemos exigir antecedentes criminais de babá, cuidador e técnico de enfermagem? Como guardar esse dado? |
| J-13 | Como fazer a suspensão na hora (RN-56) e a denúncia "não era mulher" (RN-60) sem discriminar e sem punir inocente? |

## 9. Checklist técnico (para a conversa do código)

- **Aceite atômico:** se dois profissionais tocam "Aceitar" ao mesmo tempo, só um ganha.
- **Pagamento idempotente:** tentar de novo nunca cobra duas vezes.
- **Configuração remota:** todo número marcado como "exemplo" (prazos, limites, taxa) muda sem lançar versão nova do app.
- **Fuso horário** (L-09) e **modo sem internet** (L-05).
- **Limite de SMS** por número, aparelho e IP (O-14).
- **Registros de acesso** guardados por 6 meses (Marco Civil, já está na Política) e backup.
- **Trilha de auditoria:** toda mudança de estado de um pedido fica guardada, com data e quem fez. É a prova no chargeback e na mediação.

## 10. Ordem sugerida

1. **Dinheiro:** escolher o intermediador e fazer a conta da margem (seção 4-A, 4-B e 6.1).
2. **Advogado e contador:** J-04 e J-08 a J-13.
3. **Cortar o escopo do lançamento** (6.3).
4. **Antifraude mínima:** O-01, O-02, O-13 e O-14.
5. **Falhas que travam:** L-01, L-04 e L-05; depois as outras.
6. **Travas dos loops** (seção 1).

Cada item vira regra (RN-234 em diante) quando você aprovar, um de cada vez.
