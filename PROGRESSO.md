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
- [ ] P1–P5 Cadastro (dados, profissão, Pix, verificação)
- [ ] P6–P7 Home (primeira vez, offline, online)
- [ ] P8 Novo chamado
- [ ] P9 Chat
- [ ] P10 Andamento
- [ ] P11 Cobrança
- [ ] P12 Atividade e ganhos
- [ ] P13 Perfil
