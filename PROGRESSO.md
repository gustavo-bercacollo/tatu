# Progresso

Atualizar a cada tela ou componente pronto. Ao abrir uma sessão nova: ler `CLAUDE.md` e este arquivo e continuar do "Próximo passo".

## Fluxo de entrada no app
Boas-vindas → Preciso de um serviço → Celular (ou Usar e-mail → E-mail) → Código → Nome → Home. Entrar → Celular/E-mail → Código → Home.

## Próximo passo
Próxima tela: Gustavo envia a referência. Construir **uma tela por vez, junto com ele** (não adiantar outras telas). Hoje: "Preciso de um serviço" → Celular → Código SMS → Nome. "Quero trabalhar", "Entrar" e o Continuar do Nome mostram "em breve". Sem backend: qualquer código de 6 dígitos é aceito e "Reenviar" só reinicia a contagem.

## Feito
- 03/11/2026 — Repositório conectado ao GitHub; Python 3.12, Flutter 3.47 e GitHub CLI instalados.
- 03/11/2026 — Stack decidida (Flutter + FastAPI + MongoDB); projeto Flutter criado em `app/` (app de exemplo roda no Chrome); esqueleto do backend em `backend/` (`/health` ok).
- 03/11/2026 — Quadro de tarefas "Tatu – MVP" com 21 issues no GitHub.
- 04/11/2026 — Guia de design, Manifesto atualizado e 60 SVGs das telas adicionados (`docs/`, `design/`).
- 04/11/2026 — Tema (`TatuColors`, `tatuTheme()`), fonte Inter embutida, ícones Tabler, componente `OptionCard` e tela de **Boas-vindas** (comum aos dois modos, referência `boas_vindas_escolha_perfil.html`).
- 04/11/2026 — Tela **Celular** (referência `tatu-tela-2-celular.html`) e componentes `TatuField` (campo do guia) e `BackCircleButton`; botão principal com estado desabilitado no tema.
- 04/11/2026 — Tela **Nome** (referência `tatu-tela-4-nome.html`); esqueleto `CadastroScaffold` + `CadastroNota` compartilhado pelas telas de cadastro.
- 04/11/2026 — **Fluxograma** de todas as telas (cliente + profissional, toques, status) publicado: https://claude.ai/artifact/UbvPYpEqyP5sWj9cbtvT7B. Fonte em `docs/fluxo/`. Atualizar a cada mudança de tela (ver CLAUDE.md).
- 04/11/2026 — Tela **Código SMS** (referência `tatu-tela-3-codigo-sms.html`) entre Celular e Nome. Corrigido: texto dos botões não usava Inter; botão desabilitado com texto `#B0B0B5`.

## Telas comuns
- [x] Boas-vindas ("Como você quer usar o Tatu?") — `features/entrada/boas_vindas_page.dart`
- [x] Celular ("Qual é o seu celular?", máscara (11) 98888-7777, Continuar só com 11 dígitos) — `features/entrada/celular_page.dart`
- [x] Código SMS (6 caixas, contagem 1:00 para reenviar, "Trocar número" volta) — `features/entrada/codigo_page.dart`
- [x] Celular com botão "Usar e-mail"
- [x] E-mail e Código por e-mail — `email_page.dart`, `CodigoPage.email`. Depois do código: tela que pede o celular ainda não desenhada ("em breve")
- [x] Entrar (`CelularPage.entrar`): "Criar conta" → cadastro; Continuar → Código SMS → depois de entrar ainda não desenhado; "Usar e-mail" → mesmas telas E-mail e Código por e-mail
- [x] Nome ("Como podemos te chamar?", sobrenome opcional, Continuar só com nome) — `features/entrada/nome_page.dart`

## Telas do cliente (C1–C13)
- [x] C3 Home vazia + C4 IA marcou — `features/cliente/home_page.dart` (referências `tatu-home-cliente.html` e `tatu-home-ia-marcou.html`; verdinho "Profissionais ativos" embaixo, junto do botão). IA simulada em `data/sugestao_servico.dart`. Falta: conflito (C5), Outros (C6/C7), endereço, perfil, abas, Chamar → Procurando
- [x] C13 Perfil do cliente — `features/cliente/perfil_page.dart` (abre pelo avatar; "Trocar para modo profissional" e demais linhas ainda "em breve"; Sair da conta → Boas-vindas). Componentes `GrupoLista`/`ItemLista` e `AbasCliente` em `shared/widgets`
- Troca de modo desenhada (só no fluxograma): Perfil do profissional com "Trocar para modo cliente", folha "Ficar offline e trocar?" (P21b) e "Termine o serviço antes de trocar" (P25b)
- [x] C4 Endereço (7 telas) — `features/cliente/endereco/`: folha "Onde é o serviço?" (pelo topo da Home), Buscar endereço, Confirme no mapa, Localização desativada, Endereços (pelo Perfil), Endereços vazio, Editar endereço. Dados simulados em `data/enderecos.dart` (`enderecos`, ChangeNotifier). Falta: mapa e localização reais, "Abrir Ajustes"
- [x] Pagamento (6 telas) — `features/cliente/pagamento/`: Pagamento (lista e vazio), Novo cartão (normal e recusado), Cartão (detalhe), folha Remover. Pelo Perfil → Pagamento. Dados simulados em `data/pagamentos.dart` (recusa cartões terminados em 0002). Falta: ler cartão com a câmera
- [x] Minhas avaliações (4 telas) — `features/cliente/avaliacoes/`: Recebidas (média, barras, tags, recentes), Enviadas, vazio, detalhe. Pelo Perfil. Dados simulados em `data/avaliacoes.dart`. Falta: contestar e recibo do serviço
- [x] Notificações (3 telas) — `features/cliente/notificacoes/`: lista com "Ativar todas", desativadas no celular (aviso vermelho), folha "Desligar este aviso?" (só avisos de pedido). Pelo Perfil (mostra Ativadas/Desativadas). Dados simulados em `data/notificacoes.dart`. Componentes `GrupoCartao`/`LinhaInterruptor`. Falta: permissão real e "Abrir Ajustes"
- [x] Foto do perfil (5 telas) — `features/cliente/foto/`: folha "Foto do perfil" (toque no avatar do Perfil), Escolha um avatar (6 avatares 3D em `assets/avatares/`, 512 px), Ajustar foto (arrastar + zoom, recorta em círculo), aviso "Foto atualizada", Câmera desativada. Câmera/galeria pelo `image_picker`. Dados simulados em `data/perfil.dart` (foto fica só na memória). Home mostra o mesmo avatar. Falta: guardar a foto no backend e "Abrir Ajustes"
- [x] Dados da conta (9 telas) — `features/cliente/conta/`: Dados da conta (✓ confirmados), Seu nome, Novo celular + código (Confirmar), Seu e-mail + código, aviso "Celular atualizado", Excluir sua conta?, folha "Excluir de vez?", Agora não dá para excluir (pedido em andamento). Pelo Perfil. Dados simulados em `data/conta.dart` (nome usado na Home e no Perfil). Componentes `CampoCelular` e `CartaoBotao`; `CodigoPage` aceita `botao`/`onConfirmado`. Falta: excluir de verdade (backend) e "Ver pedido em andamento"
- [x] Ajuda e suporte (8 telas) — `features/cliente/ajuda/`: Ajuda (busca, Falar com o suporte, assuntos, perguntas frequentes), Assunto, Artigo ("Isso ajudou?"), Busca (resultados e nada encontrado), Suporte: Sobre o que é?, Qual pedido?, Chat com o suporte (atendente simulado). Pelo Perfil. Dados em `data/ajuda.dart`. Componentes `OpcaoSelecionavel`/`BolinhaEscolha`/`LinkAzul`, `LinhaSimples`, `TelaPermissaoCorpo`; `CampoBusca` com borda de foco. Falta: textos dos outros artigos, assuntos Conta/Segurança/Pedidos, foto no chat, chat real
- [x] Privacidade e termos (7 telas) — `features/cliente/privacidade/`: Privacidade e termos, Termos de uso, Política de privacidade, Permissões, Seus dados e direitos, Baixar meus dados, Pedido recebido. Pelo Perfil. Textos em `data/documentos.dart`. Componentes `CartaoAcao`/`IconeCirculo`; `TelaPermissao` com versão de sucesso e sem voltar; `CadastroScaffold` sem botão. Falta: textos jurídicos completos, "Abrir Ajustes", envio real dos dados
- [x] Atividade (9 telas) — `features/cliente/atividade/`: Em andamento (etapas + busca em segundo plano), Concluídos (por mês), vazios, Ninguém aceitou ainda, Pedido em andamento, folha Cancelar pedido, Pedido cancelado, Pedido concluído. Aba Atividade funciona (Home e Perfil, `features/cliente/abas.dart`). Dados em `data/pedidos.dart`. Componentes `LinhaDoTempo`/`SeloVerde`, `LinhaRotuloValor`; `EstadoVazio` com botão. Falta: Mensagem/Ligar, Recibo, Avaliar, Tentar de novo (Procurando)
- [x] Mensagens (10 telas) — `features/cliente/mensagens/`: lista (Em andamento/Anteriores, busca, não lidas), com cobrança pendente, vazio, chat com o profissional (foto, não enviada sem internet, encerrada), folha anexar foto, folha de opções, Denunciar, Denúncia enviada. Aba Mensagens funciona. Dados em `data/conversas.dart`. Componentes de chat em `shared/widgets/chat.dart` (o chat do suporte também usa). Falta: Ligar, Pagar, chat real
- [x] Chamar profissional (7 telas) — `features/cliente/chamar/`: fotos na descrição (câmera/galeria, até 3), "Chamar" confere localização (C76), região (C77), celular de quem se cadastrou pelo e-mail (folha C75) e pedido igual a caminho (folha C78); "Imprevisto" (C80) e "Chamando outro profissional" com mapa e radar (C79). Celular/e-mail opcionais na conta (`conta.cadastrou`): sem e-mail, pedimos em Baixar meus dados e Dados da conta ("Adicionar"). Dados em `data/chamado.dart`. Componentes `FolhaOpcoes`, `perguntar`, `MapaFalso`. Falta: telas Procurando (C10–C12) e quando o C80 aparece (servidor)
- [x] Procurando (C10–C12) — `chamar/procurando_page.dart` + `ninguem_ativo_page.dart`: "Chamar" e "Chamar outro" abrem a busca com mapa e radar; aos 60 s expande, aos 90 s vira "Ninguém ativo" (busca em segundo plano na Atividade, onde "Tentar de novo" reabre a busca). O "x" também deixa em segundo plano. "Chamando outro profissional" usa a mesma tela. Falta: C13 Profissional encontrado em diante
- [x] Outros serviços (6 telas) — `features/cliente/outros/`: folha com mais pedidos, grupos e busca (resultados e nada encontrado), "Não sei qual serviço". Na Home, o escolhido fica no lugar do chip "Outros" (com setinha); "Não sei" pede a descrição e chama "profissional". Catálogo em `data/servicos.dart`. `TatuChip` com `seta`; `ItemLista` com `detalhe`. Falta: C05 conflito IA × escolha manual
- [x] Botões da Atividade (8 telas) — Concluídos com Pedir de novo / Recibo / Avaliar (ou estrelas) e pedido cancelado; Avaliar (C22) e Sua avaliação (editar); Recibo e Comprovante (pago por fora; "Enviar por e-mail" pede o e-mail se faltar); folha Pedir de novo (mesmo profissional online/offline ou qualquer um) e Chamando o mesmo profissional (2 min, depois chama os outros). `EstrelasEscolha`, `SeloVerde(aviso:)`, `TopoTela`/`TelaInterna` com `acaoIcone`. Falta: baixar PDF e compartilhar
- [x] Ajustes — botão enviar no chat (como no WhatsApp, preto quando há texto); ícones nos botões da Atividade (numa linha só); status em andamento com nome, serviço · descrição, selo preto com o tempo e etapas na horizontal (`LinhaDoTempoHorizontal`, `SeloPreto`); busca em segundo plano em cartão (ícone do serviço, descrição, selo "Buscando", "há 12 min", Cancelar pedido; `iconeServico`, `SeloVerde(pequeno:)`).
- [x] Padronização: `TatuMedidas`, `TatuTexto`, `TelaInterna`, `EstadoVazio`, `mostrarFolha`/`confirmar`, `LinhaIcone` (ver CLAUDE.md)
- [ ] C1 Abertura
- [ ] C3 Home (vazia, IA marcou, conflito, Outros)
- [ ] C4 Endereço
- [ ] C5 Procurando (início, expandindo, ninguém ativo)
- [ ] C6 Profissional encontrado
- [ ] C7 Perfil do profissional
- [ ] C8 Chat / valor
- [ ] C9 Cobrança
- [ ] C10 Pagamento e avaliação
- [ ] C11 Atividade
- [ ] C12 Mensagens
- [ ] C13 Perfil do cliente

## Telas do profissional (P1–P13)
- [x] P1–P5 Cadastro do profissional (`features/profissional/cadastro/`, dados em `data/profissional.dart`): boas-vindas → Seus dados (CPF conferido, SMS com a tela de código do cliente) → Quais serviços (até 3; "Outros" usa a folha do cliente em modo profissão) → Especialidades por serviço ("Encanador · 1 de 2", "Próximo: Eletricista") → Suas profissões → Pix (CPF/celular/e-mail/aleatória; confirmando → ✓ chave salva; erro de chave de outra pessoa; Taxas do Tatu 10% provisório; Fazer isso depois) → Verificação (câmera ao vivo pelo pacote `camera` dentro do quadro: traseira no documento, frontal na selfie, uma tela só para as 3 fotos; sem câmera ao vivo cai no `image_picker`; cada foto com “Usar esta foto / Tirar outra”; fotos em `profissional.fotoFrente/fotoVerso/selfie`) → Em análise (Ativar avisos aprova em 3 s, simulado) / Refazer foto / Reprovado / Aprovado
- [x] Home do profissional (mapa, offline/online, dica da primeira vez, lembrete do Pix), Perfil do profissional (com "Trocar para modo cliente" e folha "Ficar offline e trocar?"), Região de atendimento e Prévia do perfil. "Trocar para modo profissional" abre a Home quando já há cadastro
- [x] Serviço do profissional (`features/profissional/servico/andamento_page.dart`): A caminho (rota, “Cheguei” libera perto), Você chegou, Serviço em andamento.
- [x] Novo chamado (P22, painel branco sobre o mapa com contagem de 30 s; chega 5 s depois de ficar online, simulado) e Chat do profissional (P23, respostas prontas) em `features/profissional/chamado/`
- [x] Combinar valor no chat do profissional: folha “Quanto vai custar?” (valor em centavos, material incluso, quanto recebe), cartão “Seu valor · 1 de 3”, proposta da cliente (aceitar ou enviar outro), valor combinado com endereço liberado → “Estou a caminho” abre o A caminho; 3 rodadas sem acordo → “Sem acordo de valor”. Cliente simulado em `chat_profissional_page.dart`
- [x] Atividade do profissional (ganhos da semana no topo, Em andamento/Concluídos, selos Aguardando/Pago/Por fora) e Ganhos (Hoje/Semana/Mês, barras da semana, taxas) em `features/profissional/atividade/`, dados em `data/ganhos.dart`. Abas do profissional (`features/profissional/abas.dart`) na Home e na Atividade
- [x] Sobre você (`features/profissional/perfil/sobre_page.dart`): até 300 caracteres, “Melhorar com IA” com folha de sugestão (`MelhoriaTexto` simulada em `data/sobre_ia.dart`), bloqueio de telefone, e-mail e redes sociais (`contatoProibido`)
- [x] Fotos de trabalhos (`perfil/fotos_trabalho_page.dart`, dados em `data/fotos_trabalho.dart`): vazio, grade 3×, até 12, adicionar (câmera/galeria) → Nova foto (legenda, serviço) → em análise (aprovada em 4 s, simulado), recusada (enviar outra/remover), remover, arrastar para reordenar. A prévia mostra só as aprovadas
- [x] Mensagens do profissional (`profissional/mensagens/`, dados em `data/conversas_profissional.dart`): lista com busca, selos e vazio; chat com opções (toque no nome), cancelar atendimento (com aviso de posição), denunciar cliente, conversa encerrada. Abas do profissional com Perfil (4 abas)
- [x] Perfil do profissional com o topo igual ao do cliente: foto ou avatar (mesma foto do modo cliente, `AvatarUsuario(nome:)`), nome com selo e nota; também na Home e na Prévia. 
- [x] Toque do chamado (`assets/sons/chamado.wav`, marimba gerada aqui; `ToqueChamado` com `audioplayers`, em loop no Novo chamado). Abas do profissional voltaram a 3; o Perfil abre pela foto da Home
- Falta do profissional: cobrar o cliente, avaliar o cliente
- [ ] P6–P7 Home (primeira vez, offline, online)
- [ ] P8 Novo chamado
- [ ] P9 Chat
- [ ] P10 Andamento
- [ ] P11 Cobrança
- [ ] P12 Atividade e ganhos
- [ ] P13 Perfil
