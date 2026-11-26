# Tatu · Regras de negócio

Atualizado em 26/11/2026 (v48)

Este documento é a fonte única das regras do Tatu: o que o app faz, o que permite e o que proíbe. Se uma tela ou o código discordar daqui, vale o que está aqui.

## Como usar

- Cada regra tem um número fixo (RN-01, RN-02…). O número nunca muda nem é reaproveitado, para telas, código e conversas poderem citá-lo.
- Regra que mudou: a linha é reescrita e a mudança entra no Histórico, no fim.
- Regra ainda não decidida fica em Decisões em aberto, não nas seções.
- Problemas que o Tatu pode ter ficam em Problemas mapeados. Quando um é resolvido, as regras entram nas seções e o problema é marcado como resolvido.
- Valores marcados como exemplo (taxa de 10%, prazos) são provisórios até a decisão final.
- Regras marcadas com **(fase 2)** já estão decididas, mas só entram no app depois da primeira versão.
- Termos de Uso (`docs/termos-de-uso.md`) e Política de Privacidade (`docs/politica-de-privacidade.md`) são escritos a partir destas regras. Toda mudança de regra que afete cliente ou profissional atualiza esses documentos na mesma mudança (RN-150).
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
| RN-97 | No cadastro de cada profissão, o profissional marca como atende: no local, à distância ou os dois. Pode mudar depois no Perfil. |
| RN-110 | O Tatu é só para maiores de 18 anos, cliente e profissional. Não existe conta de menor nem "permissão dos pais": o adulto pede pela conta dele, com o endereço e o cartão dele. |
| RN-111 | No cadastro, o cliente informa nome completo e CPF. Não pedimos data de nascimento: o app descobre a idade consultando o CPF. Menor de 18 vê "O Tatu é para maiores de 18 anos" e não entra. O cartão também precisa ser de um adulto (CPF do titular). |
| RN-112 | O profissional passa pela mesma consulta do CPF no passo 1 e vê a mesma tela de bloqueio se for menor de 18. A verificação com documento confirma a idade. |
| RN-156 | Profissões reguladas (lista em `docs/profissoes-reguladas.md`) exigem registro no conselho ou órgão competente. Ao escolher uma delas, o profissional informa conselho, estado e número. Não pedimos foto da carteirinha. |
| RN-157 | O Tatu confere o registro na consulta pública do conselho (até 2 dias úteis, exemplo). Até conferir, a profissão fica "Em análise" e não recebe chamados; as outras profissões dele seguem ativas. O nome do registro precisa ser o mesmo do documento da verificação. |
| RN-158 | Registro não encontrado: o profissional vê "Não encontramos seu registro" e pode corrigir o número ou falar com o suporte. |
| RN-159 | Registro conferido aparece no perfil para o cliente: "Registro conferido · [conselho] [número]/[UF]". |
| RN-160 | Registro cancelado, suspenso ou vencido (ex.: CNH) pausa só aquela profissão. O Tatu confere de novo periodicamente e antes do vencimento. Profissões da seção "Fora do Tatu por enquanto" não podem ser cadastradas. |
| RN-161 | No cadastro, a escolha da profissão segue o mesmo padrão do pedido do cliente: as principais aparecem como botões e "Outros" abre todas as profissões do Tatu separadas por segmento, com as mais procuradas no topo e busca (aceita sinônimos, ex.: "bombeiro hidráulico" → Encanador). A lista vem de `docs/catalogo-de-servicos.md`. **"Outros" não é profissão:** o botão é branco, com contorno cinza e uma seta para baixo, nunca fica preto (selecionado) e só abre a lista "Outras profissões". |
| RN-162 | Não achou a profissão: "Não achei a minha · Sugerir uma profissão ao Tatu". A sugestão fica em análise (até 2 dias úteis, exemplo) e, aprovada, entra no catálogo para todos. |
| RN-114 | O cadastro atende ao ECA Digital (Lei 15.211/2025, em vigor desde 17/03/2026): a idade é verificada de forma confiável, não só declarada. Revisar com advogado junto com os termos (RN-108). |

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
| RN-92 | Todo pedido é "No local" ou "À distância". O cliente escolhe na Home, num seletor acima dos serviços. O padrão é No local. |
| RN-93 | No pedido à distância o endereço e a localização não contam. O chamado vai para profissionais online de qualquer cidade que atendem à distância naquela profissão. |
| RN-94 | A busca à distância não usa raio. Vai em ondas: primeiro os mais bem avaliados que estão online, depois todos os online. |

## 3. Valor, visita e pagamento

Todo dinheiro sai do cliente e passa pelo app. O Tatu nunca paga nada do próprio bolso.

| RN | Regra |
| --- | --- |
| RN-26 | O valor é combinado no chat. O profissional define dois valores: Visita (pode ser zero) e Serviço. O cliente confirma o total uma vez. |
| RN-27 | São até 3 rodadas de proposta. Sem acordo, o chamado é encerrado e nada é cobrado. No 3º valor, o cliente confirma ou recusa (RN-228). |
| RN-228 | No 3º valor, "Pedir outro valor" vira "Recusar valor" (vermelho) e o cartão avisa antes: "Último valor. Se recusar, a conversa com a [nome] termina sem custo." Recusar abre a folha "Recusar o valor?" com três saídas: "Recusar e chamar outro" (o pedido volta à busca, RN-18 a RN-20), "Recusar e cancelar pedido" (volta para a Home com "Pedido cancelado. Nada foi cobrado.") e "Voltar". Nada é cobrado, nem a visita, e o endereço exato nunca chega ao profissional (RN-28). |
| RN-229 | Depois da recusa, o profissional vê "Sem acordo de valor" ("A [cliente] recusou o último valor. O chamado foi encerrado sem custo e não conta contra você.") e continua online. Ele não recebe de novo o mesmo pedido. Sem acordo não conta como cancelamento (RN-64) nem como abandono (RN-79) para nenhum dos dois. A conversa fica nas Mensagens dos dois só para leitura, com "Sem acordo de valor". |
| RN-28 | O endereço exato só vai para o profissional depois que o valor é confirmado. Antes disso, ele vê só o bairro e a distância. |
| RN-29 | Pagamento só pelo app: cartão ou Pix. Não existe pagamento "por fora" nem em dinheiro. |
| RN-30 | Ao confirmar o valor, o total fica reservado no cartão padrão. Não é cobrado ainda. |
| RN-31 | Quando o profissional toca em "Concluir serviço", o cliente confirma ("A [nome] concluiu o serviço. Está tudo certo?"). "Sim, confirmar" cobra na hora; "Algo errado" segura o valor e abre a contestação (RN-45). Sem resposta em 2 horas (exemplo), a conclusão é confirmada sozinha e o cliente é cobrado. Não existe tela de pagamento nem botão "Pagar". |
| RN-32 | Se o serviço for maior que o descrito, o profissional manda um novo valor pelo chat. Se o cliente aceita, a reserva sobe. Se recusa, o profissional faz só o combinado ou encerra cobrando só a visita. |
| RN-33 | A visita é sempre cobrada, mesmo que o serviço não aconteça. |
| RN-34 | O Tatu cobra comissão sobre todo serviço, visita incluída. Valor de exemplo: 10%. |
| RN-35 | O dinheiro fica retido por 24 horas depois da conclusão e então cai no Pix do profissional, já sem a comissão. |
| RN-36 | Reembolso volta pelo mesmo meio do pagamento: estorno no cartão ou devolução do Pix. |
| RN-87 | Cada valor combinado é um pagamento. O profissional pode enviar um novo valor na mesma conversa quantas vezes precisar: outro dia, outra etapa ou outro serviço. |
| RN-88 | O Tatu cobra a comissão em cada valor combinado. |
| RN-89 | Nenhum valor fica aberto por mais de 7 dias (exemplo). Passou disso, o app pede para concluir ou dividir o trabalho em partes. Não existe chamado aberto por meses. |
| RN-90 | Um valor em aberto não impede o profissional de ficar online e atender outros clientes. O cliente também pode ter vários profissionais ao mesmo tempo. |
| RN-91 | Valores altos podem ser parcelados no cartão. Exemplo: a partir de R$ 300, em até 6 vezes. |
| RN-141 | Gorjeta ("pagar um café") é opcional e só aparece na tela de avaliação, depois do serviço concluído: R$ 2, R$ 5, R$ 10 ou outro valor (até R$ 100, exemplo). Nunca no chat nem antes do serviço. |
| RN-142 | A gorjeta é cobrada no mesmo cartão, junto com o envio da avaliação. O Tatu não cobra comissão: 100% vai para o profissional, descontada só a taxa do cartão. Vai no Pix com o próximo repasse. |
| RN-143 | A gorjeta não muda a nota e não aparece para outros clientes. O profissional é avisado por notificação ("Ana deixou R$ 5 de gorjeta"). |
| RN-144 | Plano fixo: o cliente toca em "Tornar [nome] fixa" (no perfil aberto pelo chat, no menu do chat, segurando a conversa, no card de Concluídos ou na opção "Precisa toda semana? Tornar a [nome] fixa" da folha "Pedir de novo", que aparece em qualquer profissão quando ainda não há plano com a pessoa; RN-208 e RN-209) e escolhe Mensal ou Semanal, 1 ou 2 vezes por semana, dia e horário. O profissional responde com o valor por visita e o valor pode ser negociado (RN-210); com o valor confirmado pelo cliente, o plano fica ativo. Ninguém renegocia a cada visita. |
| RN-145 | Limite legal: a mesma profissional vai no máximo 2 vezes por semana ao mesmo endereço pelo Tatu, somando plano fixo e pedidos avulsos, para qualquer serviço na casa. A 3ª visita na semana é bloqueada com o aviso: "Pelo Tatu, a mesma profissional pode vir até 2 vezes por semana. Para mais que isso, a lei exige contratação com carteira assinada." (Lei Complementar 150.) |
| RN-146 | O valor do plano é de pacote de visitas (valor por visita × visitas do período), combinado entre cliente e profissional; o Tatu não define. O valor de cada visita é **reservado na véspera** e **cobrado quando a visita é concluída**, como no avulso; o cliente vê o resumo do período (ex.: "8 visitas · R$ 1.200"). Comissão normal do Tatu em cada visita. Reserva recusada suspende a visita (RN-225). |
| RN-147 | O profissional pode avisar "Não vou nesta semana" sem penalidade: a visita não é cobrada e o Tatu avisa o cliente pelo canal oficial. Faltar sem avisar segue as regras de abandono (RN-76 a RN-79). |
| RN-148 | Cliente e profissional podem pausar ou cancelar o plano quando quiserem, valendo a partir do próximo período. Mudar o valor exige nova proposta (mesma negociação da RN-210) e aceite dos dois. |
| RN-149 | Nos termos de uso, o cliente declara que contrata um serviço autônomo, que o Tatu só intermedia e que está ciente do limite de 2 visitas por semana. Revisar com advogado trabalhista. |

### Identificação do plano fixo

| RN | Regra |
| --- | --- |
| RN-200 | **Um selo só: "Plano fixo"**, cinza, com ícone de repetição, igual para cliente e profissional. Fica embaixo do nome ou da última mensagem, no mesmo lugar das pílulas de status ("Valor combinado", "Proposta 2 de 3"), nunca ao lado do nome (onde fica o selo de verificado). Não existe seção própria de fixos. |
| RN-201 | Onde o selo aparece. **Cliente:** Mensagens (lista) e Atividade → Concluídos (cobrança do plano). No card de Atividade → Em andamento, o selo tem outro formato (RN-206). **Profissional:** Mensagens (lista) e Atividade (card da visita e a lista "Próximas visitas do plano"). |
| RN-202 | **Chat com plano:** o topo mostra "[profissão] · Plano fixo" (para o cliente) ou "Cliente · Plano fixo" (para o profissional). Logo abaixo, uma barra fixa: **"Plano fixo · [dia], [hora] · Próxima: [data] ›"**, que abre a tela do plano. A tela do plano tem o botão **"Mensagem"**, que volta para o chat com a pessoa. |
| RN-203 | **Fixo × avulso com a mesma pessoa.** Visita do plano: card "Plano fixo · visita X de Y" sem valor; divisor no chat "Visita do plano · [data] · feita"; nos concluídos, a cobrança aparece como "Plano fixo · N visitas". Serviço avulso: segue como hoje, com "avulso" na linha da Atividade e "Valor combinado · avulso" no card de valor. |
| RN-204 | **Dia da visita:** a Home do cliente mostra a faixa "A [nome] vem hoje às [hora]" · "[profissão] · Plano fixo · ver plano". O profissional vê as visitas na Atividade → "Próximas visitas do plano". |
| RN-205 | **Estados do plano** (selo · barra no chat). Aguardando o valor: sem selo · "Plano fixo · aguardando o valor da [nome]". Valor enviado: sem selo · cliente vê "Plano fixo · confirme o valor ›" em laranja, profissional vê "aguardando a [cliente] confirmar". Ativo: "Plano fixo" · "toda [dia], [hora] · Próxima: [data]". Sem visita na semana: "Plano fixo" · "Sem visita nesta semana · Próxima: [data]". Pausado: "Plano pausado" (cinza apagado) · "Plano pausado · volta quando quiser ›". Cancelado: "Plano até [data]" · "Plano termina em [data]". Encerrado: sem selo e sem barra; fica só o divisor "Plano fixo encerrado · [data]" no chat. **Laranja só quando o cliente precisa agir.** |
| RN-206 | **Card da visita do plano em Atividade → Em andamento (cliente).** Mesma estrutura dos outros cards: foto com as iniciais do nome (ex.: "JC"), nome em cima, profissão embaixo e status à direita. O plano aparece como um **selo de repetição no canto da foto** e no texto "[profissão] · Plano fixo". **Visita agendada:** pílula clara "Hoje, [hora]" e, embaixo, a barra do mês (um segmento por visita: feitas em preto, a de hoje em cinza, as próximas em cinza claro) com "Visita X de Y de [mês]" e "toda [dia]". **A caminho em diante:** pílula escura com o tempo ("8 min"), subtítulo "[profissão] · visita X de Y" e a linha de etapas Agendada → A caminho → Serviço → Feita (a etapa "Feita" inclui a cobrança da visita). O card tem a mesma altura nos dois estados. |
| RN-208 | **Segurar a conversa** (Mensagens, cliente): segurar uma conversa abre um menu com "Ver perfil da [nome]", "Tornar [nome] fixa" (ou "fixo") e "Pedir de novo". Vale para qualquer profissão. Se já existe plano com a pessoa, o item vira "Ver plano fixo". |
| RN-209 | **Botão "Tornar fixa" em Atividade → Concluídos** (cliente): no card do serviço, ao lado de "Pedir de novo" e "Recibo", com contorno escuro. Só aparece em profissões marcadas como **Fixo: Sim** no catálogo (diarista, passadeira, jardineiro, babá, professor etc.). Se já existe plano com a pessoa, o botão não aparece. O acesso pelo perfil e pelo menu do chat continua para todas as profissões. |
| RN-210 | **Negociação do valor do plano**, igual ao avulso (RN-27): até **3 propostas**, sempre pelo **valor por visita** (o total do mês aparece calculado). (1) A profissional envia o valor. (2) O cliente toca em "Confirmar plano" ou "Pedir outro valor" (botão cinza dentro do card, abaixo de "Confirmar plano") e digita quanto quer pagar por visita. (3) A profissional toca em "Aceitar R$ X por visita" ou "Enviar outro valor" (a última proposta). Na última, o cliente vê "Proposta 3 de 3 · última" em laranja, com "Confirmar plano" ou "Recusar". Sem acordo, o plano não começa e serviços avulsos continuam valendo. O card mostra "Proposta X de 3". A barra do chat mostra "Plano fixo · confirme o valor" (cliente) ou "Plano fixo · responda" (profissional) em laranja, com o valor por visita. |
| RN-211 | **Card do plano no chat.** Topo: foto e nome de quem propôs ("propôs um plano mensal", "pediu outro valor", "enviou a última proposta") e as bolinhas da rodada (● ○ ○ "1 de 3"; na última, "Última" em laranja). Corpo: total do mês em destaque ("R$ 1.200 por mês"), "8 visitas × R$ 150 · cobrado no fim do mês", os 7 dias da semana em bolinhas (D S T Q Q S S) com os dias do plano marcados em preto, e "Sex e sáb, às 9h · 1ª visita: 28 nov". Para o cliente, quando já houve serviço avulso com a pessoa: selo verde "Economia de R$ X por mês vs. avulso" (avulso × visitas − total do plano). Embaixo, o cartão e os botões da rodada (RN-210). A proposta de quem está vendo aparece à direita, sem botões, com "Aguardando a [nome] responder". |
| RN-212 | **Histórico da negociação e card que não some.** Quando chega uma proposta nova, a anterior encolhe para uma linha cinza ("Luiza · R$ 150 por visita · Proposta 1 · substituída"); só o card da vez fica grande. Confirmado o plano, o card **fica no chat** com contorno cinza, selo verde "Confirmado" e o botão "Ver plano". Sem acordo, as propostas ficam encolhidas (a última como "recusada") com o aviso "Sem acordo · o plano não começou". Vale para todos os cards de valor do chat: nenhum some depois de combinado. |

## 4. Atendimento

Do valor confirmado até a avaliação, o atendimento segue sempre a mesma ordem: a caminho, chegou, em serviço, concluído.

| RN | Regra |
| --- | --- |
| RN-37 | O Tatu não tem GPS próprio. "Abrir rota" abre o app de navegação que o profissional escolher (Google Maps, Waze ou Apple Mapas), e ele pode deixar um como padrão. |
| RN-38 | O botão "Cheguei" só libera quando o profissional está perto do endereço. Para isso, a localização dele precisa estar ativa. |
| RN-39 | Código na porta: o cliente vê um código de 4 dígitos e passa para o profissional pessoalmente, na chegada. O profissional digita o código no app e o serviço começa sozinho ("Em andamento"). Sem o código certo o serviço não começa. Vale para todo atendimento no local. |
| RN-40 | Serviço no local: ao tocar "Concluir serviço", o profissional tira **1 foto obrigatória do serviço pronto**, pela câmera do app. Fotos ao chegar continuam opcionais. Todas as fotos do app levam data e hora e servem de prova no retorno e na mediação. |
| RN-41 | Ao concluir, os dois se avaliam. O cliente pode editar a avaliação até 7 dias depois. |
| RN-42 | Depois de concluído, a conversa continua aberta. Cliente e profissional voltam a se falar por ela quando quiserem. Mensagem é só conversa: serviço novo só por "Pedir de novo" ou por novo valor confirmado no chat (RN-175 a RN-182). |
| RN-95 | Serviço à distância não tem Visita, rota, "Cheguei" nem código na porta. O valor tem só o Serviço. Confirmado o valor, o pedido vai direto para Em andamento. |
| RN-96 | A entrega à distância é feita pelo chat, com arquivos. O profissional toca em "Enviar entrega", mas quem conclui é o cliente (RN-100). |
| RN-98 | Serviço à distância não mostra o botão de segurança (ninguém vai até ninguém). Denúncia continua pelo menu do chat. |
| RN-99 | À distância, o profissional pode mandar prévias protegidas à vontade, antes da entrega. A prévia abre só no app: não dá para baixar nem encaminhar, print e gravação de tela ficam pretos e a imagem leva uma marca d'água com o nome do cliente. Expira em 24 horas (exemplo). |
| RN-100 | À distância, quem conclui é o cliente. Em cada entrega ele escolhe Aprovar (é cobrado o restante) ou, conforme a entrega, Pedir ajuste ou Pedir reembolso. Sem resposta em 48 horas (exemplo), a entrega é aprovada sozinha. |
| RN-101 | São no máximo 2 entregas por valor. Depois da 1ª: Aprovar ou Pedir ajuste. Depois da 2ª: Aprovar ou Pedir reembolso. |
| RN-102 | Ao enviar o valor à distância, o profissional pode pedir um sinal de até 30% (exemplo). O sinal paga o tempo dele, como a visita no serviço no local. |
| RN-103 | O sinal é cobrado quando o cliente confirma o valor e fica guardado. Vai para o profissional quando ele manda a 1ª entrega, mesmo que o cliente não aprove. |
| RN-104 | No pedido de reembolso, o suporte decide pelo chat (pedido, prévias, ajustes, entregas) em até 2 dias úteis (exemplo): devolve tudo, parte ou nada do restante. O restante fica guardado até a decisão. O sinal fica com o profissional. |
| RN-105 | Se o prazo do valor (RN-89) acabar sem nenhuma entrega, o cliente pode tocar em "Pedir sinal de volta". O pedido vai para o suporte e, sem entrega, o sinal volta para o cliente. O Tatu não paga nada: o sinal ainda estava guardado. |

### Pedir de novo × mensagem no chat (depois do serviço)

| RN | Regra |
| --- | --- |
| RN-175 | Depois de um serviço concluído existem dois caminhos, e só dois: **"Pedir de novo"** (um chamado novo) e a **mensagem no chat** (só conversa). Mandar mensagem nunca cria chamado, valor nem cobrança. |
| RN-176 | "Pedir de novo" fica na Atividade (card e detalhe do concluído) e no chat. Abre o pedido já preenchido com profissão, descrição e endereço do anterior (o cliente pode trocar o endereço). O cliente escolhe "Chamar a [nome]" (se ela estiver online) ou "Chamar qualquer [profissão]". Profissional offline: a primeira opção aparece desativada. |
| RN-177 | Chamando a mesma pessoa, o chamado fica **só para ela por 2 minutos**. O cliente vê "Chamando a [nome]". Se ela recusar ou não responder, o chamado vai para outros profissionais perto, como um pedido normal. |
| RN-178 | O profissional recebe o chamado na tela normal de novo chamado, com a etiqueta verde **"Pediu você de novo · atendeu a [cliente] em [data]"** e o aviso **"Só para você por 2 min. Depois vai para outros."** |
| RN-179 | Aceito, o pedido segue o fluxo normal: valor, confirmação, código, conclusão, cobrança, comissão e avaliação. A conversa é a mesma, mas o atendimento é novo: no chat aparece o divisor **"Novo pedido · [data] · [descrição]"** e a Atividade ganha um card novo. |
| RN-180 | Mensagem no chat de um serviço concluído chega ao profissional como **notificação de mensagem**, nunca como chamado. Para o cliente, acima do campo de mensagem aparece a dica **"Precisa de um novo serviço? Pedir de novo"**. |
| RN-181 | Serviço novo combinado pelo chat: no chat de um serviço concluído, o profissional pode enviar um **Novo valor** (com a descrição do serviço novo). Ele vê "Aguardando [cliente] confirmar · Só vira serviço quando a [cliente] confirmar." Confirmado pelo cliente, aparece no chat o card preto **"Novo serviço iniciado pelo chat · R$ X"** com "Ele aparece na sua Atividade." Vira um atendimento novo nos dois lados, com código, cobrança, comissão e avaliação normais. Sem confirmação, nada é cobrado e nada aparece na Atividade. |
| RN-182 | Não existe serviço no Tatu sem valor confirmado pelo cliente no app. Todo serviço, venha do "Pedir de novo" ou do chat, passa pela confirmação do valor; serviço combinado só na mensagem, sem valor confirmado, não tem garantia, contestação nem cobrança pelo Tatu (ver RN-83 a RN-86 sobre fechar por fora). |

**Textos**

| Situação | Cliente vê | Profissional vê |
| --- | --- | --- |
| Pedir de novo (mesma pessoa) | "Chamando a Luiza" · "Se ela não aceitar em 2 min, chamamos outro encanador perto de você." | Novo chamado com "Pediu você de novo · atendeu a Ana em 12 nov" e "Só para você por 2 min. Depois vai para outros." |
| Pedido aceito | Divisor no chat: "Novo pedido · 24 nov · Vazamento no banheiro" | O mesmo divisor no chat |
| Mensagem depois do serviço | Dica: "Precisa de um novo serviço? Pedir de novo" | Notificação: "Ana: Pode vir sexta trocar o registro?" |
| Novo valor enviado no chat | "Luiza enviou um novo valor" · card "Novo serviço · troca de registro · R$ 150,00" · botão "Confirmar valor" | "Novo valor · R$ 150,00 · Aguardando a Ana confirmar" · "Só vira serviço quando a Ana confirmar." |
| Novo valor confirmado | Card preto "Novo serviço iniciado pelo chat · R$ 150,00" · "Ele aparece na sua Atividade." | O mesmo card preto · serviço novo na Atividade |

## 5. Cancelamentos e contestação

Quem cancela ou falha não transfere o custo para o outro lado nem para o Tatu.

| RN | Regra |
| --- | --- |
| RN-43 | O cliente pode cancelar o pedido sem taxa. Se o profissional já está a caminho, ele é avisado. |
| RN-44 | Se o profissional cancela ou some antes de começar, o app chama outro automaticamente e nada é cobrado do cliente. |
| RN-45 | "Algo errado?" funciona durante todo o prazo de retorno (RN-183), com motivo, descrição e fotos tiradas na hora pela câmera do app. Nas primeiras 24 horas aparece como "Pagamento protegido por 24h"; depois, como "O problema voltou?". É um fluxo só (RN-183 a RN-196). |
| RN-46 | Pedido feito nas primeiras 24 horas: o valor do serviço continua retido até o caso terminar (risco zero para o Tatu). A visita e a gorjeta nunca entram. |
| RN-47 | Todo pedido vai primeiro ao profissional, que pode voltar sem custo (RN-186). O suporte só entra nos 3 casos da RN-190 e decide entre opções fixas (RN-191). O valor devolvido sai do profissional (RN-192). |
| RN-48 | O profissional pode contestar uma avaliação injusta. O suporte revisa em até 3 dias úteis e, se for injusta, ela sai da nota. |
| RN-49 | Contadores automáticos de abuso, para cliente e profissional (RN-193). Ao passar do limite, perde o retorno mediado pelo app ou tem a conta pausada. |
| RN-107 | Depois das 24 horas, o Tatu continua no caso: o cliente pede retorno pelo app até o fim do prazo (RN-183), e o Tatu acompanha, resolve sozinho os casos claros e media os outros. Substitui a regra anterior ("depois de 24 horas o problema é entre cliente e profissional"). |
| RN-108 | O app nunca diz que a garantia acaba em 24 horas. A garantia legal (CDC: 30 dias para serviço não durável, 90 para durável, vício oculto contado da descoberta) é obrigatória e não pode ser reduzida nos termos. O pagamento protegido e o retorno mediado são extras do Tatu, que se somam a ela (CDC, art. 50). Validação jurídica pendente: J-01 a J-05 em `perguntas-para-o-advogado.md`. |
| RN-109 | **(fase 2)** O profissional pode informar no perfil uma garantia própria (ex.: 30 dias). Dentro desse prazo, o cliente que chamar de volta pelo mesmo chat não paga o reparo. A garantia aparece na busca e no perfil. |
| RN-76 | Depois de combinar o valor, o profissional tem 10 minutos para tocar "Estou a caminho". Sem isso, o app pergunta "Ainda vai?" e o cliente vê "Ainda não saiu". |
| RN-77 | Sem resposta ao "Ainda vai?" em 5 minutos, ou com "Não consigo ir", o pedido volta à busca automaticamente e nada é cobrado do cliente. Isso conta como abandono para o profissional. |
| RN-78 | Se o profissional passar do dobro do tempo previsto de chegada, o cliente pode chamar outro sem pagar nada, nem a visita. |
| RN-80 | Quando o profissional toca em "Cheguei", o cliente é avisado e os dois veem um contador de 10 minutos de espera. |
| RN-81 | Se o cliente não aparecer em 10 minutos, o profissional pode tocar em "Cliente não apareceu": o chamado é encerrado e só a visita é cobrada. |

### Algo errado e retorno (depois do serviço)

| RN | Regra |
| --- | --- |
| RN-183 | **Prazo de retorno** por profissão, no catálogo: **90 dias** para serviço durável e **30 dias** para não durável, contados da conclusão. Na dúvida, 90. O cliente vê só a data ("até 02 fev"). Depois do prazo, defeito que só apareceu agora (vício oculto) vai pela Ajuda. Garantia própria maior do profissional (RN-109, fase 2) vale no lugar. |
| RN-184 | Um pedido de retorno por serviço, no mesmo endereço. Fotos **só pela câmera do app**, com data e hora; fotos da galeria não são aceitas. |
| RN-185 | **Repasse preso:** com retorno aberto, os próximos repasses do profissional ficam presos até o valor do serviço. Ganhos mostra "R$ X presos · Retorno da [cliente] aberto · solta ao resolver". Com retorno aberto ou dívida, o profissional não consegue encerrar o perfil. |
| RN-186 | O profissional tem **48 horas** para responder: **Aceitar retorno** (escolhe o horário, RN-213, em até **7 dias** depois do pedido), **É outro problema** (foto no local pela câmera + novo valor, RN-181) ou **Recusar** (motivo obrigatório: não é o mesmo problema, mau uso depois do serviço, não consigo ir até lá, outro motivo). |
| RN-187 | Retorno aceito: card "Retorno · sem custo" na Atividade dos dois. Sem cobrança, sem comissão e sem visita. Começa com o **código na porta** (RN-39). No fim, o cliente responde "Resolveu?"; sem resposta em 48 horas, conta como resolvido. Cliente ausente no dia (fluxo da RN-80 e RN-81): o retorno é dado como cumprido. |
| RN-188 | **Resolução automática a favor do cliente, sem suporte,** quando o profissional não responde em 48 horas, não marca o retorno em 7 dias ou não aparece (sem código na porta). Se os repasses presos cobrem o valor, devolução do serviço; se não cobrem, o Tatu paga outro profissional para refazer, até o valor do serviço. Conta 1 falta. |
| RN-189 | Recusa: o cliente escolhe "Ok, entendi" (encerra) ou "Pedir ajuda ao Tatu". Sem escolha em 7 dias, encerra. |
| RN-190 | **Mediação humana só em 3 casos:** o cliente contesta a recusa; o cliente responde "Não, continua o problema"; o cliente contesta o "É outro problema". Uma mediação por serviço. |
| RN-191 | Na mediação, a IA monta o resumo (foto do serviço pronto, fotos do problema e do local, chat, histórico dos dois) e sugere a decisão. A pessoa do suporte escolhe uma de 4 opções: **refazer com outro profissional · devolver 50% · devolver 100% · não procede**. Prazo de até 3 dias úteis. A decisão chega pelo chat do Tatu e encerra o pedido no app, sem recurso (ela já é de uma pessoa). |
| RN-192 | **Dinheiro:** só o valor do serviço volta; visita e gorjeta, nunca. Do profissional se desconta o que ele recebeu; o Tatu devolve a comissão dele. O desconto sai dos repasses presos e futuros. Dívida sem saldo fica ligada à conta do profissional no Tatu (identificada pelo CPF, só dentro do Tatu; não é negativação em birô de crédito): ele não recebe chamados nem abre outra conta até quitar. Quando o Tatu cobre do próprio bolso, cobre em serviço (outro profissional), nunca em dinheiro. |
| RN-193 | **Faltas e abuso.** Profissional: 1 falta por não responder, não marcar, não aparecer, recusa derrubada na mediação ou "É outro problema" derrubado; 3 faltas em 90 dias (exemplo) pausam a conta. Cliente: 3 pedidos "não procede" em 6 meses (exemplo) tiram o retorno mediado pelo app por 6 meses; reclamações seguem pela Ajuda e os direitos legais continuam. |
| RN-194 | **Chargeback:** o app guarda sozinho o pacote de provas de cada serviço (valor confirmado, código na porta, fotos, chat, confirmação da conclusão) para responder a contestações no cartão. |
| RN-195 | À distância: depois da entrega aprovada, "Algo errado?" funciona igual, mas o retorno é uma nova entrega pelo chat (sem visita nem código). |
| RN-196 | **Reserva:** o Tatu separa todo mês uma reserva (ex.: 1% da comissão) para cobrir os serviços pagos por ele (RN-188) e acompanha esse número. |
| RN-197 | **Termo de garantia no recibo** (CDC, art. 50, parágrafo único): o recibo de cada serviço mostra o bloco "Garantia": "Retorno sem custo até [data] ([30 ou 90] dias)", "Como pedir: Atividade → serviço → Algo errado?", "Seus direitos pelo Código do Consumidor continuam." e o link "Ver termo de garantia" (texto da seção 11 dos Termos). Vai também no PDF e no e-mail do recibo. |
| RN-198 | **Revisão de decisão automática** (LGPD, art. 20): toda decisão tomada só pelo sistema no retorno (devolução automática, falta, retorno dado como cumprido, "resolvido" por falta de resposta, pausa por faltas) mostra **"Pedir revisão"**. O pedido vale por 7 dias e uma pessoa do Tatu revisa em até 3 dias úteis. A decisão da mediação (RN-191) já é de uma pessoa e não tem nova revisão. |
| RN-199 | **Fotos e provas:** as fotos do serviço e do retorno são usadas só como prova (retorno, mediação, chargeback). Ficam guardadas por [5 anos] (exemplo, prazo do CDC para ações por danos, art. 27), com acesso restrito ao suporte, e depois são apagadas. A IA da mediação só resume e sugere; quem decide é uma pessoa. |
| RN-207 | **Card do retorno em Atividade → Em andamento (cliente).** Mesma estrutura dos outros cards: foto com as iniciais, nome, "[profissão] · [descrição do serviço]". **Retorno agendado:** selo verde "Retorno · sem custo" à direita; abaixo de uma linha divisória, a data e a hora completas com ícone de calendário ("Sexta, 27 nov · 14h"), sem cortar; embaixo, "Na hora, passe o código para o [nome]." **A caminho em diante:** pílula escura com o tempo ("8 min"), subtítulo "[profissão] · Retorno · sem custo" (com "Retorno · sem custo" em verde) e a linha de etapas Agendado → A caminho → Retorno → Feito. O card tem a mesma altura nos dois estados. |
| RN-213 | **Agendar o retorno.** No passo 2 do pedido de retorno, o cliente escolhe **até 3 horários** numa grade dos próximos 7 dias por período: **manhã (8h–12h), tarde (12h–18h) e noite (18h–21h)**; horários que já passaram ficam apagados. Chave **"É urgente? Pedir para hoje, se der"**. Ao aceitar, o profissional escolhe uma das opções e a hora dentro do período ("Aceitar · sexta, 27 nov, 9h"): fica marcado, sem confirmação do cliente. Se nenhuma serve, toca em "Sugerir outro horário" e escolhe dia e hora até 7 dias depois do pedido; o cliente recebe no chat "[nome] sugeriu outro horário" com "Confirmar horário" ou "Escolher outro" (volta à grade). Sem horário combinado até o fim do prazo, vale a RN-188 (não marcou). |
| RN-214 | **Remarcar o retorno:** cliente e profissional podem remarcar **uma vez cada**, até **12 horas antes**, com o novo dia dentro do prazo. Quem pede escolhe o dia e o período; o outro escolhe a hora e confirma. Não existe segunda remarcação: faltou, vale a RN-187 (cliente ausente) ou a RN-188 (profissional não veio). |
| RN-215 | **Lembretes e urgência:** os dois recebem lembrete na véspera e 1 hora antes do retorno. Pedido marcado como urgente aparece para o profissional em destaque: "Urgente · a [cliente] pediu hoje, se der". |
| RN-216 | **Deslizar entre abas em Atividade** (cliente e profissional): além de tocar em "Em andamento" e "Concluídos", dá para trocar de aba deslizando o dedo para os lados. A marcação da aba acompanha o dedo. O gesto não começa na borda esquerda (para não brigar com o "voltar" do iPhone) e não dispara durante a rolagem vertical. **Em Ganhos não:** Dia, Semana e Mês continuam só por toque (deslizar ali, no futuro, seria para ir ao período anterior ou ao próximo). |

### Selos do profissional

| RN | Regra |
| --- | --- |
| RN-217 | **Selos, não medalhas.** O Tatu não tem pontos, níveis, ranking, sequência de dias nem medalhas para clientes. O profissional pode ter, além de "Verificado" e "Registro conferido", 3 selos: **Pontual** (chegou no horário combinado em pelo menos 95% dos serviços agendados, entre os últimos 20; só conta serviço com hora marcada: retorno, plano fixo e serviço agendado), **Resolve de primeira** (pelo menos 20 serviços nos últimos 90 dias e nenhum retorno com decisão contra ele, na mediação ou na resolução automática; o pedido de retorno sozinho não conta) e **Clientes voltam** (pelo menos 30% dos clientes, com no mínimo 10 clientes diferentes, pediram de novo ou viraram plano fixo). |
| RN-218 | **Como os selos funcionam.** Calculados só pelo app (código na porta, horários, decisões de retorno, pagamentos), em janela móvel de 90 dias: vêm e vão sozinhos. Não contam clientes ligados ao profissional (mesmo CPF, cartão, aparelho ou endereço). Conta pausada ou suspensa perde todos os selos. |
| RN-219 | **Onde aparecem.** Perfil do profissional (seção "Selos", com uma frase de explicação em cada um) e, em tamanho pequeno, no card de quem aceitou o chamado. O profissional vê "Seus selos" no Perfil, com como cada um funciona e "Você tem" ou "Ainda não", **sem barra de progresso nem "faltam X"**. Selos **só informam**: não mudam quem recebe chamados, não dão desconto nem prioridade. |
| RN-220 | **Visual.** Selo ondulado (mesmo formato do "Verificado"), preto com o ícone branco: Pontual = cronômetro com ✓; Resolve de primeira = alvo com flecha no centro; Clientes voltam = pessoa com seta de volta; Registro conferido = carteirinha com ✓. "Verificado" continua azul. "Ainda não" = selo cinza claro com ícone cinza. Arquivos em `design/icones-selos/`. |
| RN-221 | **Borda animada na caixa da Home (cliente).** A caixa "O que está acontecendo?" tem uma borda de 2 px em grafite (#1C1C1E) com um brilho cinza claro que dá a volta devagar (uma volta a cada 8 segundos). Só gira com a caixa vazia e sem foco; ao tocar para digitar, para e fica grafite. Com "Reduzir movimento" ligado, fica parada. É o único elemento animado desse tipo no app. Alternativa guardada: versão metálica (prata). |

### Pagamento recusado

| RN | Regra |
| --- | --- |
| RN-222 | **Regra de ouro:** o profissional só começa com o pagamento garantido (valor reservado no cartão ou Pix pago). Assim que isso acontece, o card do valor mostra para ele **"✓ Pagamento garantido · pode ir"**. Antes disso, vê "Aguardando o pagamento da [cliente]" e "Não saia ainda". O profissional **nunca vê "cartão recusado"** (privacidade). |
| RN-223 | **Reserva recusada ao confirmar o valor:** o próprio card mostra ao cliente "Cartão recusado · [cartão] · nada foi cobrado" com "Usar outro cartão" e "Pagar com Pix". O atendimento fica parado. Sem pagamento em **10 minutos** (exemplo), o valor expira, o profissional fica livre e ninguém leva falta. **Novo valor durante o serviço** (RN-32) recusado: só a parte nova para; o que já estava combinado continua. |
| RN-224 | **Pix:** pago na confirmação do valor; o código vale **30 minutos**. Pago, o valor fica guardado pelo Tatu até a conclusão (o profissional não recebe antes). Código vencido sem pagamento = mesma regra da RN-223. Devolução, quando houver, volta pelo Pix (RN-36). |
| RN-225 | **Plano fixo:** a reserva de cada visita é feita **na véspera**. Se for recusada, a visita fica **suspensa**: o cliente vê no chat "Não conseguimos reservar R$ X · a visita está suspensa" com "Atualizar pagamento" e o prazo ("até quinta, 20h"); a barra do chat mostra "Visita de [dia] suspensa · Atualizar" em laranja. A profissional vê "Visita de [dia] suspensa · Não precisa ir" e é avisada se o cliente resolver no prazo. Sem resolver, a visita não acontece, ninguém leva falta e não há cobrança. |
| RN-226 | **Cobrança ao concluir:** com a reserva válida, não falha (o dinheiro já estava separado). Falha técnica: o Tatu tenta de novo sozinho, **o profissional recebe normalmente** (o valor estava reservado) e o cliente só vê "Pagamento pendente · Atualize o cartão para fazer novos pedidos" na Home se as tentativas não derem certo; com pendência, não faz pedido novo. **Gorjeta recusada:** "Não deu para enviar a gorjeta. Tentar outro cartão?"; o profissional não é avisado. |
| RN-227 | **Ícones das profissões.** Cada uma das 75 profissões do catálogo tem um ícone próprio (24 × 24, traço 1,8, pontas arredondadas, sem preenchimento, cor do texto), em `design/icones-profissoes/` com o mapa `icones-profissoes.json`. Tamanhos: 52 px na seleção (quadrado arredondado cinza), 40 px em cards e listas (círculo cinza) e 16 px junto de texto. **Sem ícone próprio** (profissão nova ou sugerida): usa o ícone do segmento (9 segmentos); sem segmento, o crachá. O botão "Outros" usa a grade de quadradinhos. Profissão nova no catálogo só entra com ícone, ou cai na alternativa. |

**Textos**

| Situação | Cliente vê | Profissional vê |
| --- | --- | --- |
| Até 24 horas | "Pagamento protegido por 24h · Algo errado? Avise até hoje, 14:20." | — |
| Depois de 24 horas | "O problema voltou? Peça um retorno sem custo até 02 fev." | — |
| Pedido enviado | "Pedido de retorno · Aguardando a Luiza · até 26 nov, 21:00" | "Pedido de retorno · Responda até 26 nov, 21:00" · "Aceitar retorno" · "É outro problema · enviar valor" · "Recusar" · "Sem custo e sem taxa. Marque o retorno em até 7 dias." |
| Retorno aceito | "Retorno aceito · sem custo · Sexta, 28 nov · 14h · Na hora, passe o código para a Luiza." | "Retorno aceito · sem custo · Na hora, peça o código à Ana para começar." |
| Recusa | "Recusado: “não é o mesmo problema”" · "Quer ajuda do Tatu?" · "Pedir ajuda ao Tatu" · "Ok, entendi" | "Por que vai recusar?" · "A Ana pode pedir ajuda ao Tatu. Recusar sem motivo conta como falta." |
| Sem resposta | "A Luiza não respondeu em 48 horas" · "Devolvemos R$ 150,00 · No Visa 4242, em até 7 dias." | Desconto nos repasses e 1 falta |
| Não veio, sem saldo | "O Tatu paga outro encanador · Até R$ 150,00, sem custo para você." | Dívida na conta do Tatu e 1 falta |
| Cliente ausente | "Você não estava no retorno · O retorno foi dado como cumprido." | — |
| Mediação | "O Tatu vai analisar · Respondemos em até 3 dias úteis, pelo chat do Tatu." | — |
| Decisão | "Decisão do Tatu · Devolvemos R$ 150,00" | "Decisão do Tatu · Devolução de R$ 150,00 · O valor será descontado dos seus próximos repasses." · "Esta decisão encerra o pedido." |
| Retorno feito | "A Luiza fez o retorno · O problema foi resolvido?" · "Sem resposta em 48 horas, damos como resolvido." | — |
| Recibo | Bloco "Garantia": "Retorno sem custo até 02 fev (90 dias)" · "Como pedir: Atividade → serviço → Algo errado?" · "Seus direitos pelo Código do Consumidor continuam." · "Ver termo de garantia" | — |
| Decisão automática | "Não foi isso? Pedir revisão" | "Resolvido automaticamente · Devolução de R$ 150,00 · 1 falta registrada · Pedir revisão" · "Algo impediu sua resposta? Peça revisão em até 7 dias. Uma pessoa do Tatu analisa." |
| Repasse preso | — | "R$ 150,00 presos · Retorno da Ana aberto · solta ao resolver" |
| Foto ao concluir | — | "Foto do serviço pronto · Obrigatória para concluir · Ela protege você se a Ana reclamar depois." |

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
| RN-119 | Na conversa do chat só vale o básico: fotos, vídeos curtos e documentos (PDF, imagens). Nunca link, programa (.apk, .exe, .bat) ou script. Arquivo de trabalho grande vai pela entrega (RN-125), com limite maior (ex.: 100 MB). |
| RN-120 | Todo arquivo passa por antivírus e por detecção de nudez antes de chegar ao outro lado. Se for barrado, não é entregue e quem enviou vê "Imagem bloqueada · Só você vê este aviso". |
| RN-121 | Toda imagem e vídeo é comparado com bancos de material de abuso sexual infantil já conhecido (ex.: PhotoDNA, Safer, Content Safety API). Tolerância zero. |
| RN-122 | Se houver suspeita de abuso infantil: o arquivo é bloqueado, a conta é suspensa na hora sem explicar o motivo, as provas são guardadas em sigilo (não apagar) e o caso é comunicado às autoridades (Polícia Federal), como manda o ECA Digital. Nudez de adulto: arquivo bloqueado e aviso; se repetir, a conta é banida. |
| RN-123 | Ao segurar o dedo sobre um arquivo, aparece "Denunciar" (nudez ou conteúdo sexual, envolve menor de idade, arquivo suspeito ou vírus, outro). O arquivo some do chat de quem denunciou e vai para o suporte com prioridade máxima. |
| RN-124 | Links não são permitidos no chat: a mensagem com link não é enviada e aparece "Links não são permitidos no chat. Envie o arquivo direto aqui." Pedidos, descrições e perfis passam por filtro de palavras para impedir anúncio de venda ou troca de arquivos. |
| RN-125 | O que é arriscado só passa pela entrega à distância, nunca pela conversa. Na entrega, o profissional escolhe Arquivo ou Link do site. Link do site vale para qualquer serviço à distância; programa pronto (.apk, .exe) e script/código-fonte só nas profissões de tecnologia (ex.: Programador). |
| RN-126 | Proteções da entrega: antivírus em todo arquivo e verificação de site perigoso em todo link, antes de chegar ao cliente; se der problema, a entrega é barrada. O app nunca abre nem roda o arquivo: o cliente só baixa, depois do aviso "Arquivo executável · abra só se você pediu". A entrega fica registrada; se for vírus, a conta é banida (RN-122). |
| RN-127 | A prévia protegida (RN-99) aceita só imagem, vídeo, PDF ou link de teste. Nada executável. |
| RN-133 | Cliente e profissional podem denunciar um ao outro pelo menu do chat ("Denunciar" / "Denunciar cliente"). Motivos: comportamento inadequado, assédio ou discriminação, golpe ou pagamento por fora, perfil falso, outro. Dá para contar mais (opcional). A denúncia não é mostrada para o denunciado. |
| RN-134 | Qualquer mensagem pode ser denunciada: segurar a mensagem → "Denunciar mensagem". Motivos: assédio ou ofensa, conteúdo sexual, ameaça ou chantagem, golpe ou pagamento por fora, outro. A mensagem some da conversa de quem denunciou (vira "Mensagem denunciada · em análise") e o suporte recebe a mensagem com o contexto da conversa. |
| RN-135 | O suporte analisa toda denúncia. Assédio ou discriminação segue a RN-56 (bloqueio imediato entre os dois). Várias denúncias confirmadas levam a pausa ou suspensão (RN-128 a RN-132). Denúncia falsa feita de propósito e repetida também pune quem denunciou. |
| RN-136 | No chat, tocar no nome ou na foto do profissional (no topo) abre o perfil dele, com "Voltar para a conversa". O mesmo atalho fica no menu do chat ("Ver perfil da Luiza"). |

## 7. Bloqueios e penalidades

As penalidades existem para impedir abuso, nunca para punir quem se protegeu.

| RN | Regra |
| --- | --- |
| RN-63 | Muitas visitas sem serviço pausam a conta do profissional até ele falar com o suporte. Valor de exemplo: 5 das últimas 8 visitas. |
| RN-64 | Cancelar atendimentos com frequência baixa a posição do profissional na fila de chamados. |
| RN-65 | Conta pausada não fica online. O suporte vê o histórico e decide se libera. |
| RN-66 | Banimento é para fraude, identidade falsa e assédio comprovado. |
| RN-79 | Três abandonos em 30 dias pausam a conta do profissional até ele falar com o suporte. |
| RN-82 | Três ausências em 30 dias pausam a conta do cliente até ele falar com o suporte. |
| RN-106 | O app acompanha sinais sem entrega e reembolsos à distância. Exemplo: 3 sinais sem entrega em 30 dias pausam a conta do profissional até falar com o suporte. Entregas vazias só para liberar o sinal contam igual. |
| RN-128 | Pausa (abandonos, ausências, sinais sem entrega, etc.) só impede novos pedidos ou chamados. O que já está em andamento continua normal até o fim. |
| RN-129 | Suspensão (casos graves: abuso, violência, golpe, vírus) encerra na hora todos os atendimentos em andamento da conta suspensa. Ela vê só "Conta suspensa", sem o motivo. |
| RN-130 | Profissional suspenso: o cliente recebe do Tatu no chat "A profissional não pode mais continuar este atendimento. Nada foi cobrado." e o botão "Chamar outro profissional", que abre a busca com o mesmo pedido preenchido. Valor reservado é liberado; sinal guardado (sem entrega) volta ao cliente; repasse de serviço concluído há menos de 24 horas fica preso até o suporte decidir. |
| RN-131 | Cliente suspenso: o profissional recebe do Tatu "Este atendimento foi encerrado pelo Tatu" e recebe pelo que já fez, tirado da reserva do cartão do cliente: a visita se já estava a caminho ou no local; o serviço se já concluiu. O Tatu não paga nada. |
| RN-132 | Nos dois casos o chat fica só para leitura, o nome vira "Conta indisponível" e o histórico é guardado como prova. Parcelas futuras de serviços longos são canceladas; o que já foi pago pelo trabalho feito continua valendo. |

## 8. Avaliações, perfil e anúncios

| RN | Regra |
| --- | --- |
| RN-67 | Antes de aceitar, o cliente vê do profissional: nota, número de serviços, distância, tempo de chegada, fotos de trabalhos, "Sobre" e avaliações. |
| RN-68 | O profissional vê as próprias avaliações em Perfil → Minhas avaliações: média, distribuição por estrelas, elogios mais citados e comentários com filtros. |
| RN-69 | Profissional não responde publicamente às avaliações. Discordância vai pela contestação (RN-48). |
| RN-70 | Anúncios aparecem em dois lugares só: na Home, acima do botão Chamar, e na tela de busca, abaixo da barra de carregamento. |
| RN-71 | O espaço de anúncio mede 353 × 76 e leva o selo "Patrocinado". Sem anúncio, o espaço some. Na Home, some também enquanto o cliente digita. |
| RN-83 | **(adiado)** "Seus profissionais" (lista em Atividade com quem já atendeu o cliente e o botão Chamar) saiu do app por enquanto. Proposta guardada em Decisões em aberto. |
| RN-84 | **(fase 2)** Só serviços feitos pelo app contam para a nota do profissional e para a posição dele nos chamados. |
| RN-115 | Toda conta tem uma conversa oficial com o Tatu, com selo de verificado, fixada no topo de Mensagens, para cliente e profissional. Ela não pode ser apagada. |
| RN-116 | A primeira mensagem que a pessoa recebe no app é a do Tatu: boas-vindas e um atalho para as Dicas Tatu. Ela chega logo depois do cadastro, antes de qualquer pedido ou chamado. |
| RN-117 | A conversa do Tatu é o canal principal de comunicação do Tatu, como o canal oficial de uma empresa no WhatsApp: novidades, mudanças nas regras e avisos importantes chegam por ela. Só o Tatu envia; a pessoa não responde por ali (suporte continua na Ajuda). |
| RN-118 | Dicas Tatu é um espaço de dicas de boa convivência, boa negociação e segurança. Por enquanto mostra "Em breve" e avisa pelo canal do Tatu quando abrir. |
| RN-173 | Cliente e profissional podem enviar sugestões ao Tatu em Perfil → Enviar sugestão: tipo (ideia, algo não funciona, outro), texto de até 500 caracteres e print opcional (passa pela verificação de arquivos, RN-120). A sugestão vai para uma fila do time do Tatu, com o tipo de conta (cliente/profissional). Se virar novidade, o Tatu avisa pelo canal oficial. |
| RN-174 | No modo profissional, a barra de baixo tem 5 abas: Início, Atividade, Ganhos, Mensagens e Perfil. Atividade mostra só serviços (em andamento e concluídos), sem valores. Ganhos concentra o financeiro: total por semana, mês ou ano (já descontada a taxa), próximo Pix, já no Pix, a receber, gorjetas, taxa do Tatu, onde receber e extrato de repasses. |
| RN-155 | A aba Mensagens mostra um contador vermelho com o total de mensagens não lidas, somando todas as conversas, inclusive a do Tatu (acima de 9 aparece "9+"). Já no primeiro acesso aparece "1" (a boas-vindas do Tatu, RN-116). O número diminui ao abrir cada conversa e some quando tudo foi lido. O mesmo número aparece no ícone do app no celular, quando as notificações estão permitidas. |
| RN-165 | Depois do valor confirmado, o cliente acompanha o profissional: "vai sair já" (com o tempo para sair, RN-76), mapa ao vivo com rota e previsão de chegada, "chegando" (menos de 2 min, notificação e código na tela) e "chegou" ("Passe o código"). Enquanto o profissional está a caminho, a Home mostra a faixa "[nome] chega em X min", que abre o mapa. |
| RN-166 | A localização do profissional só é mostrada ao cliente entre "Estou a caminho" e a digitação do código (ou "Cliente não apareceu"). Depois disso para de ser compartilhada. |
| RN-167 | O código errado 3 vezes bloqueia novas tentativas e o app oferece falar com o suporte. O código nunca deve ser passado por mensagem; o app avisa o cliente. Enquanto o código não é digitado, o tempo de espera do cliente (RN-80) continua contando. |
| RN-168 | Ao confirmar o primeiro valor de um atendimento no local, o app sai do chat sozinho: o cliente vai para o acompanhamento ("[nome] vai sair já") e o profissional vai para "Saia em até 10 min", com endereço e "Estou a caminho". À distância, o cliente vai para "Pedido em andamento". O chat continua a um toque (Mensagem). Valores novos durante o serviço continuam sendo confirmados no chat. |
| RN-169 | Depois do código digitado, o cliente vê "A [nome] está trabalhando": hora de início e tempo correndo, Mensagem e Ligar, valor combinado ("cobrado quando você confirmar"), aviso de que novo valor é aprovado no chat e o escudo de segurança. Sem botão de cancelar. A faixa da Home vira "[nome] está trabalhando · X min". |
| RN-170 | Com mais de um profissional ao mesmo tempo, a faixa da Home mostra "X profissionais com você" e abre a Atividade → Em andamento, com um card por profissional e a situação de cada um ao vivo. Com um só profissional, a faixa abre direto a tela dele. Cada atendimento continua separado (código, cobrança e avaliação). |
| RN-171 | Depois de "Concluir serviço", o profissional vê "Aguardando [cliente] confirmar" (com o tempo das 2 horas) e já pode ficar online. Confirmado, vê o valor que vai para o Pix. O "Algo errado?" (RN-45) continua valendo depois da confirmação, até o fim do prazo de retorno (RN-183). |
| RN-172 | A confirmação da conclusão não é um pop-up que some: é uma tela própria ("Serviço concluído", com a contagem das 2 horas). Enquanto o cliente não responder, ela continua disponível pela faixa verde da Home ("Confirme o serviço da [nome]"), pelo card na Atividade ("Aguardando sua confirmação") e pela notificação. Voltar não descarta a confirmação. |
| RN-137 | Acessibilidade · ditado na descrição do pedido: o microfone (à direita na caixa) transforma a fala em texto, que aparece enquanto a pessoa fala; ela confere e edita antes de chamar. Nenhum áudio é enviado. A sugestão de serviço usa o texto. |
| RN-138 | Acessibilidade · ditado no chat (cliente e profissional): o microfone ao lado do campo transforma a fala em texto no próprio campo; a pessoa confere e envia como mensagem de texto. O chat não tem mensagem de áudio. |
| RN-139 | Na descrição do pedido, a caixa tem câmera e clipe à esquerda e microfone à direita. O clipe abre "Escolher da galeria" ou "Arquivo (PDF, documento)". Fotos e arquivos aparecem como miniaturas com X para excluir. Até 5 anexos por pedido (exemplo). Valem os tipos e as verificações do chat (RN-119 a RN-122). O profissional vê os anexos no Novo chamado. |
| RN-140 | Ligação só pelo app e só durante o atendimento: o botão de ligar aparece no topo do chat quando o valor é confirmado e some quando o serviço é concluído. Antes disso não existe botão de ligar (nem no menu do chat). A ligação não mostra o número de ninguém (internet ou número intermediário). |

## 9. Privacidade e dados (LGPD)

Cada dado é usado só para o motivo pelo qual foi pedido.

| RN | Regra |
| --- | --- |
| RN-72 | Qualquer pessoa pode baixar uma cópia dos próprios dados, recebida por e-mail em até 15 dias. Também pode corrigir os dados e excluir a conta. |
| RN-73 | A selfie da verificação é dado biométrico (sensível pela LGPD). Serve só para confirmar a identidade e para apurar denúncias. |
| RN-74 | O gênero informado não aparece para ninguém. |
| RN-75 | Telefone, e-mail e CPF de uma parte nunca aparecem para a outra. O contato acontece pelo chat do Tatu. |
| RN-85 | **(fase 2)** No chat, telefone, e-mail, @ de rede social e links aparecem como "contato oculto". Quem tenta enviar vê o aviso de que o contato não é enviado e por quê. |
| RN-86 | **(fase 2)** O Tatu não pune quem fecha por fora, porque não dá para provar. Ele torna o app a opção mais vantajosa: garantia só pelo app, pagamento garantido ao profissional e o "Pedir de novo" (RN-175 a RN-182). |
| RN-150 | Os Termos de Uso e a Política de Privacidade ficam em `docs/` (fonte única) e são lidos no app em Perfil → Privacidade e termos, para cliente e profissional: versão e data, "O essencial em 1 minuto", índice e cada seção. O aceite é ativo: no cadastro do cliente, caixa desmarcada "Li e concordo com os Termos de Uso e a Política de Privacidade" (com links) e o resumo "O essencial do Tatu"; o botão só libera depois de marcar. O profissional confirma de novo no fim da verificação, com os pontos principais (autônomo, taxa, Pix em 24h, pagamento só pelo app). Versão e data do aceite ficam registradas. |
| RN-151 | Mudança relevante nos documentos é avisada pelo canal oficial do Tatu com pelo menos 15 dias de antecedência (salvo exigência legal ou de segurança). Ao abrir o app depois da data, a pessoa vê "Atualizamos os Termos de uso" com o que mudou e só continua depois de "Concordo e continuar". Pedidos em andamento seguem a versão em que foram feitos. |

## 10. Decisões em aberto

O que ainda não foi decidido. Quando decidir, a regra sobe para a seção certa e sai daqui.

- [ ] **Foto da cliente no modo só mulheres.** Recomendação: a profissional vê só o selo "Cliente verificada", nunca a selfie. Opcional: a cliente escolhe mostrar uma foto de perfil conferida com a selfie. As telas atuais ainda mostram a foto.
- [ ] **Parcelamento.** Valor mínimo, número de parcelas e quem paga os juros (o Tatu não paga). Hoje: a partir de R$ 300, até 6 vezes, como exemplo.
- [ ] **Avaliação em conversas com vários pagamentos.** Avaliar a cada valor concluído ou manter uma avaliação só por profissional, que o cliente atualiza.
- [ ] **Valor da comissão.** 10% é exemplo.
- [ ] **Prazos finais.** Tempo do profissional para aceitar um chamado, tempo do cliente para aceitar (hoje 3 minutos), retenção antes do repasse (hoje 24 horas).
- [ ] **Recuperação de conta.** O que fazer quando a pessoa perde o celular: recuperar pelo e-mail, selfie para profissional, "Sair de todos os aparelhos".
- [ ] **Conta bancária.** Hoje o profissional recebe só por Pix. Avaliar conta bancária depois.
- [ ] **Abandono à distância.** O que acontece quando o profissional aceita e não responde no chat. Sugestão: mesmo "Ainda vai?" da RN-77 e contar como abandono.
- [ ] **Profissões à distância no lançamento.** As telas usam Designer, Programador, Professor, Contador e Advogado como exemplo.
- [ ] **Arquivos e links no chat à distância.** Como conviver com o contato oculto (RN-85, fase 2).
- [ ] **Print no iPhone.** O Android bloqueia print de verdade. O iPhone não deixa bloquear, só esconder o conteúdo no print e na gravação. Foto com outro celular sempre funciona, por isso a marca d'água com o nome do cliente.
- [ ] **Números do serviço à distância.** Sinal de até 30%, prévia de 24 horas, aprovação automática em 48 horas, resposta do suporte em 2 dias úteis: todos são exemplos.
- [ ] **Só menor de idade em casa.** O que o profissional faz quando só um menor abre a porta. Cuidado: profissional pode usar isso como desculpa para cobrar a visita sem trabalhar. Ver mais para frente.
- [ ] **Conferir a idade pelo CPF.** Escolher o serviço que consulta o CPF na Receita e devolve a data de nascimento (ex.: Consulta CPF do Serpro ou outro fornecedor; custo por consulta).
- [ ] **Canal do Tatu.** Se a pessoa pode silenciar o canal, quantas mensagens por mês no máximo, e o conteúdo das Dicas Tatu.
- [ ] **Moderação de arquivos.** Escolher os fornecedores (antivírus, nudez, abuso infantil), quanto tempo guardar as provas e como fazer a comunicação às autoridades. Revisar com advogado.
- [ ] **Acessibilidade · próximas ideias** (registradas, não implementar agora):
  - "Ouvir mensagem": ao segurar uma mensagem, o celular lê em voz alta (baixa visão, dificuldade de leitura).
  - Aviso de acessibilidade no perfil (opcional): "Sou surdo(a) · prefiro mensagens", "Tenho baixa visão", "Uso cadeira de rodas · posso demorar para abrir a porta". Aparece para o outro lado no pedido e no chat; quem demora para abrir a porta ganha mais tempo antes de contar ausência (ex.: 20 min em vez de 10).
  - Base técnica: leitor de tela (VoiceOver/TalkBack) com nome em todos os botões, inclusive mapa e contadores; respeitar o tamanho de letra e o alto contraste do celular; botões grandes; avisos importantes também vibram.
- [ ] **Perfil por seções e certificações (adiado).** Perfil do profissional estilo LinkedIn: cada seção (sobre, especialidades, fotos, certificações) só aparece se estiver preenchida; avaliações e verificação sempre aparecem. Certificações com selo "Informado pelo profissional" ou "Conferido pelo Tatu". Telas de prévia feitas em 17/11/2026, não aprovadas para agora.
- [ ] **Contas com CNPJ (adiado).** Proposta: a conta continua sendo de uma pessoa verificada (CPF); o CNPJ entra como dado opcional. Profissional MEI/CNPJ recebe no Pix do CNPJ e emite nota (selo "Emite nota fiscal"); cliente pode pedir nota para CNPJ (condomínio, loja). Profissional sem CNPJ: avisar "Este profissional não emite nota fiscal". Empresa com equipe e conta de empresa com vários usuários: fase 2. Nota do serviço é do profissional; o Tatu emite só a da comissão. Confirmar com contador.
- [ ] **Plano fixo · detalhes.** Comissão menor no plano fixo como incentivo? Quanto tempo dura uma pausa?
- [ ] **Termos e Política · dados para publicar.** Razão social, CNPJ, endereço, e-mails de suporte e do encarregado (DPO), fornecedores (pagamento, consulta de CPF, verificação, moderação, ditado, ligação, nuvem), prazos de guarda e URL pública. Revisão por advogado antes de publicar.
- [ ] **Entrar com Google e Apple (adiado).** Proposta: "Continuar com Google" e "Continuar com Apple" (a Apple exige a dela se houver login social), aproveitando nome, e-mail confirmado e foto; falta só CPF e aceite; celular confirmado antes do primeiro pedido; e-mail que já tem conta vincula com código, sem duplicar. Layout das telas ainda não aprovado (opções A: folha na boas-vindas, B: tela com 3 botões, C: celular com ícones).
- [ ] **Antecedentes criminais (adiado).** Pedir certidão de antecedentes de quem cuida de criança, idoso ou pessoa com deficiência, ou de todos que vão até a casa do cliente. Atualizar a Política de Privacidade se for adotado.
- [ ] **Uso fora da finalidade (adiado).** Proposta: (1) IA confere se o pedido é um serviço do catálogo e bloqueia termos proibidos ("Esse pedido não é um serviço do Tatu"); (2) profissões sensíveis (ex.: massagem) com regra extra e "acompanhante" fora do catálogo; (3) trava de autopagamento (mesmo CPF, celular, aparelho, cartão ou Pix dos dois lados); (4) revisão de serviços sem chegada/código, valores muito acima do normal e muitos serviços caros entre as mesmas pessoas; (5) teto de valor e sem parcelamento nos primeiros serviços de conta nova; (6) fila de revisão, banimento e comunicação às autoridades; parceiro de pagamentos com antifraude.
- [ ] **Números do retorno.** Exemplos a confirmar: 48 horas para o profissional responder, 7 dias para marcar, 48 horas para o cliente responder "Resolveu?", 12 horas de antecedência para remarcar, 3 dias úteis de mediação, 3 faltas em 90 dias, 3 "não procede" em 6 meses, reserva de 1% da comissão. Tempo para pagar depois de recusado: 10 minutos (exemplo). Classificação 30/90 dias do catálogo a validar com o advogado. Prazo de guarda das fotos (5 anos é exemplo, J-06).
- [ ] **Seus profissionais (adiado).** Lista em Atividade com quem já atendeu o cliente e botão Chamar (RN-83). Saiu do app em 24/11/2026; decidir depois se volta e como.
- [ ] **Último valor sem resposta.** O que acontece quando o cliente não confirma nem recusa o 3º valor. Sugestão: depois de um prazo (ex.: 10 minutos) vale como recusa e o pedido volta à busca (RN-228).
- [ ] **Mais lugares para "Tornar fixa" (adiado).** Ideias avaliadas e guardadas: sugestão "Quer a [nome] sempre?" depois de avaliar com 4 ou 5 estrelas; dica "Chama a [nome] sempre?" no chat a partir do 2º serviço. Testar a de depois de avaliar primeiro se poucos clientes criarem plano.
- [ ] **Números dos selos.** Exemplos a confirmar: 95% de pontualidade nos últimos 20 agendados; 20 serviços em 90 dias sem retorno contra; 30% de recontratação com mínimo de 10 clientes. Validar com o advogado (J-07).
- [ ] **Ligação pelo app.** Escolher como fazer a ligação sem mostrar o número: pela internet (mais barato) ou número intermediário (custo por minuto).

## 11. Problemas mapeados

Situações que podem dar errado no uso real do app. Resolvemos um por vez, em ordem.

| Nº | Problema | Situação | Regras |
| --- | --- | --- | --- |
| P-01 | O profissional aceita e não aparece. | Resolvido | RN-76 a RN-79 |
| P-02 | O profissional chega e o cliente não está. | Resolvido | RN-80 a RN-82 |
| P-03 | Cliente e profissional fecham por fora na próxima vez, sem o app. | Decidido · fase 2 | RN-83 a RN-86 |
| P-04 | O profissional quebra algo na casa durante o serviço. | Adiado: fora do escopo por enquanto | — |
| P-05 | O problema volta dias depois do serviço; o profissional se recusa a voltar; brechas e excesso de análises no suporte. | Resolvido · validação jurídica pendente (J-01 a J-05) | RN-40, RN-45 a RN-49, RN-107, RN-108, RN-183 a RN-199 |
| P-06 | Preço abusivo, principalmente em emergência. | Adiado · decidir depois | — |
| P-07 | Material comprado no meio do serviço, fora do combinado. | A resolver | — |
| P-08 | Cartão recusado na reserva, durante o serviço, na cobrança final e no plano fixo. | Resolvido | RN-146, RN-222 a RN-226 |
| P-09 | Avaliações falsas para inflar a nota. | A resolver | — |
| P-10 | Fraude no cadastro do profissional (documento de outra pessoa). | A resolver | — |
| P-11 | Sem internet no local para tocar "Concluir serviço". | A resolver | — |
| P-12 | Serviço que leva vários dias, semanas ou meses. | Resolvido | RN-42, RN-87 a RN-91 |
| P-13 | Profissional à distância: serviço que não precisa de visita, em que a localização não importa. | Resolvido | RN-92 a RN-98 |
| P-14 | Serviço à distância malfeito: o cliente não gosta da entrega e quer o dinheiro de volta. | Resolvido | RN-96, RN-99 a RN-106 |
| P-15 | Menor de idade usando o app, como cliente ou profissional. | Resolvido em parte · "só menor em casa" para depois | RN-110 a RN-112, RN-114 |
| P-16 | Envio de arquivos maliciosos ou +18, inclusive venda ou troca de material de menores. | Resolvido | RN-119 a RN-124 |
| P-17 | Conta suspensa com atendimentos ainda em andamento. | Resolvido | RN-128 a RN-132 |
| P-18 | Denunciar profissional, cliente e mensagem. | Resolvido | RN-133 a RN-135 |
| P-19 | Acessibilidade. | Em parte · ditado feito; outras ideias em Decisões em aberto | RN-137, RN-138 |
| P-20 | Troca de contato por telefone e anexos na descrição do pedido. | Resolvido | RN-139, RN-140 |
| P-21 | Gorjeta para o profissional. | Resolvido | RN-141 a RN-143 |
| P-22 | Contrato fixo (semanal ou mensal) com um profissional, sem virar vínculo de emprego. | Resolvido | RN-144 a RN-149 |
| P-23 | Termos de Uso e Política de Privacidade completos e sempre atualizados. | Rascunho v1.0 feito · revisão jurídica pendente | RN-150, RN-151 |
| P-24 | Profissões que exigem registro ou documentação. | Resolvido | RN-156 a RN-160 |
| P-25 | Poucas opções de profissões no cadastro do profissional. | Resolvido | RN-161, RN-162 |
| P-26 | Depois do serviço: diferença entre "Pedir de novo" e mandar mensagem no chat; evitar serviços infinitos só pela mensagem. | Resolvido | RN-42, RN-175 a RN-182 |
| P-27 | Plano fixo sem identificação clara nas listas e conversas. | Resolvido | RN-200 a RN-205 |
| P-28 | Card do plano fixo em Atividade → Em andamento desorganizado e fora do padrão. | Resolvido | RN-206 |
| P-29 | Card do retorno em Atividade → Em andamento com pouca informação e data cortada. | Resolvido | RN-207 |
| P-30 | "Tornar fixa" difícil de encontrar (só no perfil e no menu do chat). | Resolvido | RN-144, RN-208, RN-209 |
| P-31 | Valor do plano fixo sem negociação, e "Pedir outro valor" fora do card. | Resolvido | RN-144, RN-148, RN-210 |
| P-32 | Card do plano pobre e sumindo do chat depois de combinado. | Resolvido | RN-211, RN-212 |
| P-33 | Como combinar a data do retorno sem troca infinita de mensagens. | Resolvido | RN-186, RN-213 a RN-215 |
| P-34 | Medalhas e conquistas: reconhecer bons profissionais sem incentivar pressa, volume ou fraude. | Resolvido · validação jurídica pendente (J-07) | RN-217 a RN-220 |
| P-35 | Profissões dividindo ícones genéricos. | Resolvido | RN-227 |
| P-36 | Depois das 3 rodadas, o cliente não tem como recusar o valor. | Resolvido | RN-27, RN-228, RN-229 |

## 12. Histórico de mudanças

| Data | Regras | Mudança |
| --- | --- | --- |
| 26/11/2026 | RN-227 | Ícone próprio para as 75 profissões, ícones de segmento como alternativa e crachá para profissão sem segmento. |
| 26/11/2026 | RN-27, RN-228, RN-229 | Recusa do 3º valor renumerada (era RN-227/RN-228 na v47; o RN-227 passou a ser dos ícones). |
| 26/11/2026 | RN-146, RN-206, RN-222 a RN-226 | Pagamento recusado em cada etapa; "Pagamento garantido" para o profissional; Pix; plano fixo passa a reservar na véspera e cobrar a cada visita. P-08 resolvido. |
| 26/11/2026 | RN-221 | Borda animada em grafite na caixa de descrição da Home. |
| 26/11/2026 | RN-217 a RN-220 | Selos do profissional (Pontual, Resolve de primeira, Clientes voltam), sem medalhas de jogo; só informam, não mudam chamados. |
| 25/11/2026 | RN-216 | Deslizar para trocar de aba em Atividade; em Ganhos não. |
| 25/11/2026 | RN-144 | "Precisa toda semana? Tornar a [nome] fixa" na folha "Pedir de novo" (pedido do Gustavo). |
| 25/11/2026 | RN-210 | O card do plano não mostra mais "Último serviço avulso com a [nome]" (pedido do Gustavo). |
| 25/11/2026 | RN-186, RN-213 a RN-215 | Agendamento do retorno: cliente dá até 3 horários, profissional escolhe um ou sugere outro, remarcar uma vez com 12 h de antecedência, lembretes e urgência. |
| 25/11/2026 | RN-211, RN-212 | Card novo do plano no chat (quem propôs, rodada, semana em bolinhas, economia) e histórico da negociação; card não some depois de combinado. |
| 25/11/2026 | RN-144, RN-148, RN-210 | Valor do plano fixo negociável, até 3 propostas pelo valor por visita; "Pedir outro valor" dentro do card. |
| 25/11/2026 | RN-161 | Botão "Outros" do cadastro com seta para baixo e contorno, sem estado de selecionado. |
| 25/11/2026 | RN-144, RN-208, RN-209 | "Tornar fixa" também segurando a conversa e no card de Concluídos (só profissões com Fixo: Sim no catálogo). Outras ideias adiadas. |
| 25/11/2026 | RN-207 | Novo card do retorno em Atividade → Em andamento: data e hora completas, selo "Retorno · sem custo", dica do código e etapas quando o profissional sai. |
| 25/11/2026 | RN-201, RN-206 | Novo card da visita do plano em Atividade → Em andamento: selo na foto, barra do mês e etapas quando a profissional sai. |
| 24/11/2026 | RN-202 | Botão "Mensagem" na tela do plano fixo. |
| 24/11/2026 | RN-83, RN-86, RN-200 a RN-205 | Identificação do plano fixo: selo único "Plano fixo", barra no chat, fixo × avulso, faixa no dia da visita e estados. "Seus profissionais" adiado. |
| 24/11/2026 | RN-191, RN-192, RN-197 a RN-199 | Ajustes legais do retorno: termo de garantia no recibo, revisão de decisão automática (LGPD art. 20), guarda das fotos, dívida só dentro do Tatu. |
| 24/11/2026 | RN-40, RN-45 a RN-49, RN-107, RN-108, RN-183 a RN-199 | Algo errado e retorno: prazo de 30 ou 90 dias por profissão, fluxo único, retorno pelo profissional primeiro, resolução automática, mediação só em 3 casos com 4 opções fixas, repasse preso, dívida no CPF, foto obrigatória ao concluir, contadores de abuso. |
| 24/11/2026 | RN-42, RN-175 a RN-182 | Pedir de novo (chamado novo, 2 min só para a mesma pessoa) × mensagem no chat (só conversa); serviço novo pelo chat só com novo valor confirmado ("Novo serviço iniciado pelo chat"). |
| 20/11/2026 | RN-174 | Aba Ganhos separada da Atividade no modo profissional. |
| 20/11/2026 | RN-173 | Enviar sugestão ao Tatu pelo Perfil. |
| 19/11/2026 | RN-31, RN-169 a RN-171 | Cliente vê o serviço em andamento; vários profissionais abrem a Atividade; cliente confirma a conclusão (2 horas para confirmar sozinho). |
| 19/11/2026 | RN-168 | Depois de confirmar o valor, cliente e profissional saem do chat e vão direto para o acompanhamento. |
| 18/11/2026 | RN-39, RN-165 a RN-167 | Cliente acompanha o profissional no mapa. O cliente passa o código e o profissional digita para começar o serviço. |
| 18/11/2026 | RN-161, RN-162 | "Outros" no cadastro do profissional igual ao do pedido do cliente (por segmento, com busca) e sugestão de profissão. Especialidades continuam até 3. |
| 18/11/2026 | RN-156 a RN-160 | Profissões reguladas: registro sem foto, conferido na consulta pública, selo no perfil. |
| 18/11/2026 | RN-155 | Contador de mensagens não lidas na aba Mensagens e no ícone do app. |
| 18/11/2026 | RN-150, RN-151 | Termos de Uso e Política de Privacidade em docs/, leitura no app, aceite de nova versão. |
| 18/11/2026 | RN-144 a RN-149 | Plano fixo: "Tornar fixa", valor definido uma vez, cobrança automática no fim do período, limite de 2 visitas por semana no mesmo endereço. |
| 17/11/2026 | RN-141 a RN-143 | Gorjeta opcional na avaliação, 100% para o profissional (só a taxa do cartão). |
| 17/11/2026 | RN-137 a RN-140 | Ditado (fala vira texto) na descrição e no chat, sem mensagem de áudio. Anexos (galeria e arquivo) na descrição. Ligação pelo app só entre a confirmação do valor e a conclusão. |
| 17/11/2026 | RN-133 a RN-136 | Denúncias: pessoa pelo menu do chat (motivos atualizados), mensagem ao segurar, análise do suporte. Ver perfil do profissional pelo topo do chat. |
| 17/11/2026 | RN-128 a RN-132 | Conta pausada ou suspensa com atendimentos em andamento: pausa não afeta, suspensão encerra com regras de dinheiro para cada lado. |
| 17/11/2026 | — | P-06 (preço abusivo) adiado: a proposta não foi aprovada, decidir depois. |
| 17/11/2026 | RN-119, RN-124 a RN-127 | Sem links no chat. Link do site, programa e script só pela entrega à distância, com antivírus, verificação e aviso. |
| 17/11/2026 | RN-119 a RN-124 | Arquivos no chat: tipos permitidos, antivírus, nudez bloqueada, abuso infantil com suspensão e comunicação às autoridades, denúncia, links. |
| 17/11/2026 | RN-115 a RN-118 | Canal oficial do Tatu nas Mensagens: primeira mensagem de boas-vindas, avisos e novidades, atalho para Dicas Tatu. |
| 17/11/2026 | RN-110 a RN-112, RN-114 | Só maiores de 18: idade descoberta pelo CPF, sem campo de data de nascimento. "Só menor em casa" foi para Decisões em aberto. |
| 17/11/2026 | RN-107 a RN-109 | Depois das 24 horas: problema entre cliente e profissional, aviso do CDC nos termos, garantia própria do profissional na fase 2. |
| 17/11/2026 | RN-96, RN-99 a RN-106 | Entrega à distância malfeita: prévia protegida, até 2 entregas, cliente aprova, sinal, reembolso pelo suporte, pausa por sinais sem entrega. |
| 14/11/2026 | RN-92 a RN-98 | Serviço à distância: seletor No local / À distância na Home, busca sem raio, sem visita, entrega pelo chat. |
| 14/11/2026 | RN-42, RN-87 a RN-91 | A conversa não fecha mais depois do serviço. Cada valor combinado é um pagamento, com comissão em cada um. Limite de 7 dias por valor. Parcelamento. |
| 14/11/2026 | — | P-04 (dano na casa) e P-05 (problema volta dias depois) adiados. |
| 14/11/2026 | RN-83 a RN-86 | Contra fechar por fora: Seus profissionais, nota só pelo app, contato oculto no chat. Decidido para a fase 2. |
| 14/11/2026 | — | Nova seção Problemas mapeados (P-01 a P-12). |
| 14/11/2026 | RN-80 a RN-82 | Cliente que não aparece: espera de 10 minutos, visita cobrada e pausa por ausências. |
| 13/11/2026 | RN-76 a RN-79 | Profissional que aceita e não aparece: prazo para sair, devolução à busca, atraso sem custo e pausa por abandonos. |
| 13/11/2026 | — | Documento criado com todas as regras decididas até aqui. |
| 13/11/2026 | RN-26, RN-32, RN-33, RN-45 a RN-47, RN-63 | Valor dividido em Visita e Serviço. Encerrar cobrando só a visita. Contestação em 24 horas. Conta pausada por muitas visitas sem serviço. |
| 13/11/2026 | RN-30, RN-31 | O valor fica reservado no cartão ao confirmar e é cobrado automaticamente ao concluir. Saem a tela de cobrança e o botão Pagar. |
| 13/11/2026 | RN-29, RN-34 | Pagamento só pelo app. Sai o pagamento "por fora". Comissão em todo serviço. |
| 12/11/2026 | RN-57 a RN-61, RN-73, RN-74 | Atendimento entre mulheres, com verificação de identidade. |
| 12/11/2026 | RN-50 a RN-56, RN-62 | Botão de segurança, contatos de confiança e link de acompanhamento. |
| 12/11/2026 | RN-70, RN-71 | Espaços de anúncio na Home e na busca. |
