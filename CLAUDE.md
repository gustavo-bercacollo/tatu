# Tatu

App brasileiro que liga quem precisa de ajuda urgente em casa (encanador, eletricista, pedreiro…) ao profissional disponível mais perto, no estilo Uber/iFood. Diferencial: velocidade, **um profissional por vez**, sem orçamentos para comparar. O app será mostrado a investidores.

Fundador: Gustavo. Fala português; quer respostas **curtas e diretas**. Textos do app 100% em português do Brasil.

Ao abrir uma sessão nova: ler este arquivo e o `PROGRESSO.md`, e continuar de onde parou.

## Fontes da verdade
1. `docs/guia-de-design.md`: princípios, cores, tipografia, medidas, tema em Dart (`TatuColors` / `tatuTheme()`), componentes, mapa de telas (C1–C13 cliente, P1–P13 profissional), regras de negócio, textos, decisões em aberto. **Ler inteiro antes de construir telas.**
2. `design/user/` (28 telas do cliente) e `design/worker/` (32 do profissional): SVGs 393×852, numerados na ordem do fluxo. `design/index.html` mostra todas lado a lado.
3. `docs/Manifesto-Tatu.pdf`: visão, mercado, negócio.

SVG e guia divergem → regras do guia, visual do SVG. Dúvida real → perguntar ao Gustavo.
Figma: https://www.figma.com/design/zprQlhIOqkpKJ5esa3zean/Tatu (telas originais; as novas só existem nos SVGs).

## Estilo (resumo)
**Marca: só o nome "tatu" centralizado** (Inter 700, 44 px). Nunca usar ícone/quadrado com ponto verde nem frase junto do nome.
Minimalista, iPhone/Mac. Fundo branco, cinzas translúcidos, texto preto, botão principal preto em pílula (56 px), sem cor de marca. Verde `#34C759` online/pago; azul `#007AFF` verificado/links; vermelho `#FF3B30` erro. Fonte Inter (SF Pro no iOS). Margem 20 px (24 no cadastro). Ícones de traço fino. Avatares só com iniciais.

## Regras que não podem ser quebradas
- Pedido enviado **ao mesmo tempo** a todos os profissionais ativos; raio expande sozinho em 60–90 s ("Expandindo a busca para sua região…"); sem ninguém ativo, a busca continua em segundo plano e avisa quando alguém **aceita**. Nunca tela parada.
- O cliente **não configura raio**.
- IA marca o serviço (✦) pela descrição; escolha manual nunca é sobrescrita; conflito só gera folha de confirmação.
- Profissional envia valor; cliente confirma ou pede outro (até 3 rodadas). **Endereço exato só depois do valor confirmado.**
- Faixa de preço é estimativa da plataforma (região + serviço), sempre rotulada como estimativa.
- Pagar pelo app é opcional (cartão até 6x ou Pix). "Por fora" exige confirmação da outra parte. Comissão só no pagamento pelo app.
- Profissional: até 3 profissões × 3 especialidades; Pix no nome do CPF; verificação (documento só por câmera + selfie), reprovação corrigível ou definitiva. App sempre abre **offline**.
- Avaliação mútua; perfil mostra 3 avaliações em carrossel + "Ver todas".

## Stack
- **App:** Flutter / Dart, um app só com modo cliente e modo profissional (decidido). Se precisar separar depois: dois entrypoints no mesmo projeto.
- **Fase atual: só front-end.** Usar dados falsos (mocks) atrás de repositórios/interfaces, para trocar pelo backend depois.
- **Backend (depois):** Python / FastAPI + WebSocket; worker ARQ + Redis; MongoDB Atlas via PyMongo (banco `tatu`, busca por raio com `2dsphere`). Esqueleto já existe em `backend/`.
- Hospedagem inicial gratuita (Atlas M0, Render/Railway, Upstash). Publicar primeiro no Android.

## Estrutura
```
docs/          guia-de-design.md, Manifesto-Tatu.pdf
design/        SVGs das telas (user/, worker/) + index.html
app/           Flutter (package `tatu`, org `com.tatu`)
  lib/main.dart                 TatuApp (tema + tela inicial)
  lib/core/theme/               tatu_colors.dart, tatu_theme.dart
  lib/shared/widgets/           componentes reutilizáveis (option_card, tatu_field, back_circle_button, cadastro_scaffold…)
  lib/features/entrada/         telas comuns aos dois modos (boas_vindas_page.dart)
  lib/features/cliente/         telas do cliente (C3–C13)
  lib/features/profissional/    telas do profissional (P1–P13)
  assets/fonts/                 Inter 400/500/600/700 (embutida; não usar google_fonts, é incompatível)
backend/       Python (venv em backend/.venv): app/main.py, config, db, models, routers, services, worker
```
Ícones: `flutter_tabler_icons` (`TablerIcons.*`). Arquivos de tela: `<nome>_page.dart`. Ainda não adotados (decidir quando houver 2+ telas): rotas com `go_router`, estado com Riverpod, mocks em `lib/data/mock`.

## Fluxograma das telas (mostrado a devs e investidores — manter sempre atualizado)
Publicado em https://claude.ai/artifact/UbvPYpEqyP5sWj9cbtvT7B. Fonte: `docs/fluxo/index.html` (dados em `TELAS_RAW` e `LIGACOES` no topo do script), imagens do app em `docs/fluxo/app/`, mapa de arquivos para publicar em `docs/fluxo/arquivos.json`.
**A cada mudança em qualquer tela** (nova, alterada, novo toque ou destino):
1. Atualizar `TELAS_RAW`/`LIGACOES` e a data `ATUALIZADO`. Status: `app` (no app, imagem real), `desenho` (só desenho), `andamento` (destino de um toque que ainda não tem tela — **nunca inventar** tela).
2. Tela nova no app → acrescentar em `app/tool/capturas_test.dart` e rodar `flutter test tool/capturas_test.dart --update-goldens` (dentro de `app/`).
3. Imagem nova → acrescentar em `arquivos.json`. Republicar com o Artifact (mesmo arquivo `docs/fluxo/index.html`, `root` = raiz do repo, `files` = conteúdo de `arquivos.json`) para manter o mesmo link.

## Como trabalhar
- Uma tela ou componente por vez. Cada tela a partir do SVG correspondente, com os estados do guia (vazio, carregando, erro).
- Commit a cada tela/componente pronto; atualizar `PROGRESSO.md`.
- Ordem: 1) tema + Inter + componentes base → 2) fluxo do cliente (Home → Endereço → Procurando → Encontrado → Perfil → Chat/valor → Pagamento → Avaliação → Atividade/Mensagens/Perfil) → 3) fluxo do profissional (Cadastro → Home on/offline → Novo chamado → Chat → Andamento → Cobrança → Ganhos → Perfil) → 4) mocks simulando a busca para demo.

## Comandos
- App: `cd app` → `flutter run -d chrome` · `flutter analyze` · `flutter test`. Erro estranho de compilação → `flutter clean` e rodar de novo.
- Celular do Gustavo (mesmo Wi-Fi, http://192.168.1.173:8080): `cd app` → `flutter build web --release --no-web-resources-cdn` e servir com `py tool/serve_web.py` (aba de terminal "app celular"; manda `no-store` para o celular não mostrar versão velha; CanvasKit local, sem baixar do Google). Depois de cada mudança, só rodar o build de novo; o servidor continua. **Não usar** `flutter run -d web-server` para o celular: o modo debug fica em branco pela rede e o `--release` dele quebra no Windows.
- API: `cd backend` → `.venv\Scripts\python -m uvicorn app.main:app --reload` (`/health`)
- Worker: `cd backend` → `.venv\Scripts\arq app.worker.main.WorkerSettings` (precisa de Redis)
- Flutter em `C:\src\flutter`; GitHub CLI em `%LOCALAPPDATA%\Programs\gh\bin\gh.exe`. Android Studio não instalado.
- Tarefas: GitHub Project "Tatu – MVP" (https://github.com/users/gustavo-bercacollo/projects/3), colunas Backlog / A fazer / Fazendo / Feito.

## Decisões em aberto (perguntar antes de travar)
Login por SMS ou e-mail+senha · verificação obrigatória para ficar online · comissão e freemium · prazo de repasse · prazos (validade do pedido, confirmação do cliente, contagem do chamado, tentativas de verificação) · avatar com iniciais ou foto · barra de navegação do Android · nome oficial.
