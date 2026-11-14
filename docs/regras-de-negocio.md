# Tatu · Regras de negócio

Atualizado em 13/11/2026 (v2)

Este documento é a fonte única das regras do Tatu: o que o app faz, o que permite e o que proíbe. Se uma tela ou o código discordar daqui, vale o que está aqui.

## Como usar

- Cada regra tem um número fixo (RN-01, RN-02…). O número nunca muda nem é reaproveitado, para telas, código e conversas poderem citá-lo.
- Regra que mudou: a linha é reescrita e a mudança entra no Histórico, no fim.
- Regra ainda não decidida fica em Decisões em aberto, não nas seções.
- Valores marcados como exemplo (taxa de 10%, prazos) são provisórios até a decisão final.
- Princípio que vale para tudo: o Tatu é prático e rápido. Menos telas, menos toques; caso raro se resolve dentro da tela que já existe.

## 1. Contas e cadastro

Uma pessoa tem uma conta só, que pode ter os dois perfis: cliente e profissional.

| RN | Regra |
| --- | --- |
| RN-01 | Uma conta por pessoa (CPF). A mesma conta pode ter perfil de cliente e de profissional. |
| RN-02 | Não existe senha. Entrar e cadastrar é por código enviado por SMS ou e-mail. Cinco códigos errados bloqueiam novas tentativas por 15 minutos. |
| RN-03 | O cliente pode se cadastrar com celular ou e-mail. Quem entrou só com e-mail confirma o celular antes do primeiro pedido. |
| RN-04 | Trocar de perfil é direto, sem tela de escolha. Só aparece aviso quando há serviço em andamento ou o profissional está online. |
| RN-05 | Foto do perfil: foto própria ou um dos avatares prontos do Tatu. |
| RN-06 | O profissional passa por verificação com documento e selfie antes de receber chamados. A recusa pode ser corrigível (envia de novo) ou definitiva. |
| RN-07 | O profissional pode ter até 3 profissões, com até 3 especialidades cada. |
| RN-08 | O profissional recebe só por Pix, numa chave do mesmo CPF dele. |
| RN-09 | Nome, CPF e nascimento do profissional vêm do documento e ficam travados. Mudar o nome exige enviar novo documento. |
| RN-10 | O app do profissional sempre abre offline. Ficar online é uma escolha dele a cada uso. |
| RN-11 | Com mais de uma profissão, ele escolhe em quais fica online. O app lembra a última escolha. |
| RN-12 | "Sobre você": até 300 caracteres. Não aceita telefone, e-mail nem rede social. |
| RN-13 | Fotos de trabalhos: até 12, revisadas antes de aparecer. Recusadas se mostram rosto de pessoa ou endereço. |
| RN-14 | Encerrar o perfil profissional mantém a conta de cliente. Para voltar, ele refaz a verificação. |
| RN-15 | Excluir a conta apaga os dois perfis. Fica bloqueado enquanto houver pedido em andamento ou dinheiro a receber. |

## 2. Pedido e busca

O cliente descreve o problema e toca em Chamar. O app avisa todos os profissionais perto ao mesmo tempo, e o primeiro que aceitar fala com ele.

| RN | Regra |
| --- | --- |
| RN-16 | O cliente descreve o problema e a IA sugere o serviço, que ele pode trocar. Com "Não sei qual serviço", a IA descobre pela descrição. |
| RN-17 | O pedido usa o endereço do topo da Home. O app não pergunta o endereço a cada pedido. |
| RN-18 | O pedido vai ao mesmo tempo para todos os profissionais ativos perto. O primeiro que aceitar fala com o cliente. |
| RN-19 | O raio amplia sozinho em 3 etapas (1, 2 e 3 km). O cliente não escolhe o raio. |
| RN-20 | A busca continua em segundo plano. O cliente recebe notificação quando alguém aceitar, mesmo com o app fechado. |
| RN-21 | O cliente tem 3 minutos para aceitar o profissional encontrado. Passou o prazo, o profissional é liberado e o pedido continua salvo. |
| RN-22 | "Ver outro profissional" libera o atual e chama outro. |
| RN-23 | Se o cliente já tem um pedido ativo do mesmo serviço, o app pergunta antes de chamar outro. |
| RN-24 | Fora da área atendida, o app avisa e oferece "Me avise quando chegar". |
| RN-25 | Sem localização ativa, o cliente usa um endereço salvo. |

## 3. Valor, visita e pagamento

Todo dinheiro sai do cliente e passa pelo app. O Tatu nunca paga nada do próprio bolso.

| RN | Regra |
| --- | --- |
| RN-26 | O valor é combinado no chat. O profissional define dois valores: Visita (pode ser zero) e Serviço. O cliente confirma o total uma vez. |
| RN-27 | São até 3 rodadas de proposta. Sem acordo, o chamado é encerrado e nada é cobrado. |
| RN-28 | O endereço exato só vai para o profissional depois que o valor é confirmado. Antes disso, ele vê só o bairro e a distância. |
| RN-29 | Pagamento só pelo app: cartão ou Pix. Não existe pagamento "por fora" nem em dinheiro. |
| RN-30 | Ao confirmar o valor, o total fica reservado no cartão padrão. Não é cobrado ainda. |
| RN-31 | Quando o profissional toca em "Concluir serviço", o cliente é cobrado automaticamente. Não existe tela de cobrança nem botão "Pagar" no fim. |
| RN-32 | Se o serviço for maior que o descrito, o profissional manda um novo valor pelo chat. Se o cliente aceita, a reserva sobe. Se recusa, o profissional faz só o combinado ou encerra cobrando só a visita. |
| RN-33 | A visita é sempre cobrada, mesmo que o serviço não aconteça. |
| RN-34 | O Tatu cobra comissão sobre todo serviço, visita incluída. Valor de exemplo: 10%. |
| RN-35 | O dinheiro fica retido por 24 horas depois da conclusão e então cai no Pix do profissional, já sem a comissão. |
| RN-36 | Reembolso volta pelo mesmo meio do pagamento: estorno no cartão ou devolução do Pix. |

## 4. Atendimento

Do valor confirmado até a avaliação, o atendimento segue sempre a mesma ordem: a caminho, chegou, em serviço, concluído.

| RN | Regra |
| --- | --- |
| RN-37 | O Tatu não tem GPS próprio. "Abrir rota" abre o app de navegação que o profissional escolher (Google Maps, Waze ou Apple Mapas), e ele pode deixar um como padrão. |
| RN-38 | O botão "Cheguei" só libera quando o profissional está perto do endereço. Para isso, a localização dele precisa estar ativa. |
| RN-39 | Na chegada, o cliente vê a foto e o nome do profissional e um código de 4 dígitos. Ele pede o código antes de abrir a porta. |
| RN-40 | O profissional pode tirar fotos ao chegar e ao concluir. Elas servem de prova numa contestação. |
| RN-41 | Ao concluir, os dois se avaliam. O cliente pode editar a avaliação até 7 dias depois. |
| RN-42 | Depois de concluído, o chat fica só para leitura. |

## 5. Cancelamentos e contestação

Quem cancela ou falha não transfere o custo para o outro lado nem para o Tatu.

| RN | Regra |
| --- | --- |
| RN-43 | O cliente pode cancelar o pedido sem taxa. Se o profissional já está a caminho, ele é avisado. |
| RN-44 | Se o profissional cancela ou some antes de começar, o app chama outro automaticamente e nada é cobrado do cliente. |
| RN-45 | O cliente pode contestar o serviço em até 24 horas depois da conclusão ("Algo errado?"), com motivo e fotos. |
| RN-46 | Durante a contestação, o valor do serviço fica retido. A visita não entra na contestação. |
| RN-47 | O suporte decide pelo chat e pelas fotos: o profissional refaz sem custo, reembolso parcial ou reembolso total. O valor devolvido sai do repasse do profissional, nunca do Tatu. |
| RN-48 | O profissional pode contestar uma avaliação injusta. O suporte revisa em até 3 dias úteis e, se for injusta, ela sai da nota. |
| RN-49 | Quem contesta demais e sem razão, cliente ou profissional, perde o direito à garantia ou a conta. |
| RN-76 | Depois de combinar o valor, o profissional tem 10 minutos para tocar "Estou a caminho". Sem isso, o app pergunta "Ainda vai?" e o cliente vê "Ainda não saiu". |
| RN-77 | Sem resposta ao "Ainda vai?" em 5 minutos, ou com "Não consigo ir", o pedido volta à busca automaticamente e nada é cobrado do cliente. Isso conta como abandono para o profissional. |
| RN-78 | Se o profissional passar do dobro do tempo previsto de chegada, o cliente pode chamar outro sem pagar nada, nem a visita. |

## 6. Segurança e atendimento entre mulheres

A segurança vem de saber quem é cada pessoa, não de confiar no que ela declara.

| RN | Regra |
| --- | --- |
| RN-50 | Cliente e profissional têm um botão de segurança (escudo) em todas as telas de atendimento. Ele abre: Ligar 190, Ligar 180, Alerta silencioso, Compartilhar atendimento e Sair agora (profissional) ou Encerrar atendimento (cliente). |
| RN-51 | Segurar o escudo por 3 segundos dispara o alerta silencioso, sem som e sem mudar a tela. |
| RN-52 | O alerta silencioso avisa os contatos de confiança e a central do Tatu, com a localização ao vivo. |
| RN-53 | Cada pessoa pode ter até 5 contatos de confiança. Eles são avisados por SMS quando são adicionados. |
| RN-54 | O link de acompanhamento abre no navegador, sem precisar do app. Mostra localização ao vivo, quem é o profissional e o status. Não mostra telefone, CPF, valor nem o chat. Para de funcionar quando o atendimento termina. |
| RN-55 | "Sair agora" ou "Encerrar atendimento" não tem penalidade para quem usa. A outra parte é bloqueada para ela e o suporte entra em contato. |
| RN-56 | Denúncia de assédio ou discriminação bloqueia os dois um para o outro na hora. O acusado fica suspenso enquanto o caso é analisado. |
| RN-57 | A cliente pode preferir só profissionais mulheres. A profissional pode atender só clientes mulheres. As duas opções ficam em Perfil → Segurança → Preferências de atendimento. |
| RN-58 | O gênero é informado pela própria pessoa (Mulher, Homem, Pessoa não binária, Prefiro não dizer) e só é usado para essas preferências. |
| RN-59 | Para usar qualquer preferência por mulheres, a pessoa verifica a identidade com documento e selfie ao vivo. Sem verificação, a preferência não liga. |
| RN-60 | Quem usar identidade falsa para chegar a uma mulher é banido e denunciado à polícia. Uma denúncia de "não era mulher" suspende a conta até a análise. |
| RN-61 | Se não houver mulheres disponíveis, o app pergunta se a cliente quer chamar qualquer profissional. Ele nunca muda a escolha sozinho. |
| RN-62 | Recusar um chamado por segurança nunca penaliza o profissional. |

## 7. Bloqueios e penalidades

As penalidades existem para impedir abuso, nunca para punir quem se protegeu.

| RN | Regra |
| --- | --- |
| RN-63 | Muitas visitas sem serviço pausam a conta do profissional até ele falar com o suporte. Valor de exemplo: 5 das últimas 8 visitas. |
| RN-64 | Cancelar atendimentos com frequência baixa a posição do profissional na fila de chamados. |
| RN-65 | Conta pausada não fica online. O suporte vê o histórico e decide se libera. |
| RN-66 | Banimento é para fraude, identidade falsa e assédio comprovado. |
| RN-79 | Três abandonos em 30 dias pausam a conta do profissional até ele falar com o suporte. |

## 8. Avaliações, perfil e anúncios

| RN | Regra |
| --- | --- |
| RN-67 | Antes de aceitar, o cliente vê do profissional: nota, número de serviços, distância, tempo de chegada, fotos de trabalhos, "Sobre" e avaliações. |
| RN-68 | O profissional vê as próprias avaliações em Perfil → Minhas avaliações: média, distribuição por estrelas, elogios mais citados e comentários com filtros. |
| RN-69 | Profissional não responde publicamente às avaliações. Discordância vai pela contestação (RN-48). |
| RN-70 | Anúncios aparecem em dois lugares só: na Home, acima do botão Chamar, e na tela de busca, abaixo da barra de carregamento. |
| RN-71 | O espaço de anúncio mede 353 × 76 e leva o selo "Patrocinado". Sem anúncio, o espaço some. Na Home, some também enquanto o cliente digita. |

## 9. Privacidade e dados (LGPD)

Cada dado é usado só para o motivo pelo qual foi pedido.

| RN | Regra |
| --- | --- |
| RN-72 | Qualquer pessoa pode baixar uma cópia dos próprios dados, recebida por e-mail em até 15 dias. Também pode corrigir os dados e excluir a conta. |
| RN-73 | A selfie da verificação é dado biométrico (sensível pela LGPD). Serve só para confirmar a identidade e para apurar denúncias. |
| RN-74 | O gênero informado não aparece para ninguém. |
| RN-75 | Telefone, e-mail e CPF de uma parte nunca aparecem para a outra. O contato acontece pelo chat do Tatu. |

## 10. Decisões em aberto

O que ainda não foi decidido. Quando decidir, a regra sobe para a seção certa e sai daqui.

- [ ] **Foto da cliente no modo só mulheres.** Recomendação: a profissional vê só o selo "Cliente verificada", nunca a selfie. Opcional: a cliente escolhe mostrar uma foto de perfil conferida com a selfie. As telas atuais ainda mostram a foto.
- [ ] **Código na porta para todos.** Hoje o cliente sempre vê o código, mas a tela de conferência do profissional existe só no modo só mulheres. Decidir se vale para todo atendimento.
- [ ] **Valor da comissão.** 10% é exemplo.
- [ ] **Prazos finais.** Tempo do profissional para aceitar um chamado, tempo do cliente para aceitar (hoje 3 minutos), retenção antes do repasse (hoje 24 horas).
- [ ] **Recuperação de conta.** O que fazer quando a pessoa perde o celular: recuperar pelo e-mail, selfie para profissional, "Sair de todos os aparelhos".
- [ ] **Conta bancária.** Hoje o profissional recebe só por Pix. Avaliar conta bancária depois.
- [ ] **Ligação pelo app.** O botão Ligar existe. Decidir se a ligação esconde o número real das partes.

## 11. Histórico de mudanças

| Data | Regras | Mudança |
| --- | --- | --- |
| 13/11/2026 | RN-76 a RN-79 | Profissional que aceita e não aparece: prazo para sair, devolução à busca, atraso sem custo e pausa por abandonos. |
| 13/11/2026 | — | Documento criado com todas as regras decididas até aqui. |
| 13/11/2026 | RN-26, RN-32, RN-33, RN-45 a RN-47, RN-63 | Valor dividido em Visita e Serviço. Encerrar cobrando só a visita. Contestação em 24 horas. Conta pausada por muitas visitas sem serviço. |
| 13/11/2026 | RN-30, RN-31 | O valor fica reservado no cartão ao confirmar e é cobrado automaticamente ao concluir. Saem a tela de cobrança e o botão Pagar. |
| 13/11/2026 | RN-29, RN-34 | Pagamento só pelo app. Sai o pagamento "por fora". Comissão em todo serviço. |
| 12/11/2026 | RN-57 a RN-61, RN-73, RN-74 | Atendimento entre mulheres, com verificação de identidade. |
| 12/11/2026 | RN-50 a RN-56, RN-62 | Botão de segurança, contatos de confiança e link de acompanhamento. |
| 12/11/2026 | RN-70, RN-71 | Espaços de anúncio na Home e na busca. |
