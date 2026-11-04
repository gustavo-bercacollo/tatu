# Progresso

Atualizar a cada tela ou componente pronto. Ao abrir uma sessão nova: ler `CLAUDE.md` e este arquivo e continuar do "Próximo passo".

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
- 04/11/2026 — Tela **Código SMS** (referência `tatu-tela-3-codigo-sms.html`) entre Celular e Nome. Corrigido: texto dos botões não usava Inter; botão desabilitado com texto `#B0B0B5`.

## Telas comuns
- [x] Boas-vindas ("Como você quer usar o Tatu?") — `features/entrada/boas_vindas_page.dart`
- [x] Celular ("Qual é o seu celular?", máscara (11) 98888-7777, Continuar só com 11 dígitos) — `features/entrada/celular_page.dart`
- [x] Código SMS (6 caixas, contagem 1:00 para reenviar, "Trocar número" volta) — `features/entrada/codigo_page.dart`
- [x] Nome ("Como podemos te chamar?", sobrenome opcional, Continuar só com nome) — `features/entrada/nome_page.dart`

## Telas do cliente (C1–C13)
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
