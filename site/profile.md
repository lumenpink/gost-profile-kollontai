# Perfil de Implementação GOST: Kollontai

```yaml
---
id: kollontai
name: "Perfil de Implementação Kollontai"
extends: "https://gost.2lp.in/SPEC.md"
target_gost: "2.0.0"
status: "Ativo / Produção"
---
```

> **Sobre este Perfil:**  
> O perfil **Kollontai** (em homenagem à revolucionária soviética, feminista e diplomata Alexandra Kollontai) define o ferramental concreto de engenharia, a implementação oficial do Maestro de Governança (**`cccp`**), a matriz de versões de compiladores, o protocolo de auto-atualização de binários e a arquitetura de distribuição para projetos aderentes ao padrão **GOST**.  
> Ele é agnóstico a domínios pessoais e identidades individuais, servindo como perfil base para coletivos, laboratórios ou perfis autorais derivados (como o perfil `lumen`).

---

## 1. O Maestro Concreto: `cccp` e `.cccprc`

No perfil Kollontai, a autoridade de governança definida na Seção 6 da norma GOST é materializada pelo binário **`cccp`** (integrado ao sistema de triagem **`divan`**).

### 1.1 Arquivo de Configuração `.cccprc`
Todo repositório sob o perfil Kollontai **DEVE** declarar na raiz (ou herdar via configuração global em `$XDG_CONFIG_HOME/cccp/config.env`) os parâmetros operacionais do Maestro:

```ini
# Idioma primário para triagem de tickets (divan), Laudo da Fase 9 e fallback de i18n
agent_var_lang = portuguese

# Diretivas de Forja Primária (Sobrescritas pelo perfil filho ou pelo repositório)
primary_forge_type = forgejo
primary_owner = <owner>
primary_repo = <slug>

# Espelhos Passivos e Ingestão de Fronteira (Separados por vírgula: codeberg,github)
mirrors = codeberg,github
mirror_owner = <mirror_owner>
```

### 1.2 Mapeamento de Comandos do Maestro (`cccp`)
É estritamente proibido invocar comandos brutos de mutação do Git ou CLIs de terceiros (`tea`, `gh`, `glab`). O ciclo de vida completo opera via `cccp`:

| Subcomando `cccp` | Fase / Escopo | Ação Determinística Executada pelo Maestro |
| :--- | :---: | :--- |
| `cccp init --slug <s> ...` | **Dia Zero** | Cria repo local (`main`), provisiona forja primária e espelhos (`pushurl = no_push`), abre o Ticket `#1` (`chore`), gera anatomia GOST + `.gost/metadata.json`, comita `(closes #1 - ph9)` com Laudo de Gênese, fecha o Ticket `#1` e faz o primeiro push. |
| `cccp ticket create` | **Fase 1** | Cria a issue na forja primária (com tipo, contexto e critérios de aceite) e sincroniza o cache local em `.git/cccp/tickets/<id>.json`. |
| `cccp divan` | **Fase 1** | Sessão assistida de triagem, quebra de épicos e refinamento de tickets. |
| `cccp start <id> [--base <b>]` | **Fase 2** | Lê os metadados do ticket `#<id>`, atualiza a branch base (`main`, `vN` ou `epic/*`) e faz checkout automático para `<tipo>/<id>-<slug>`. |
| `cccp status` | **Fases 1–9** | Inspeciona o histórico da branch ativa e exibe o ticket atual, a fase alcançada (`ph3`..`ph9`) e o próximo passo obrigatório. |
| `cccp commit "<resumo>"` | **Fases 3–8** | Deduz o `<id>` e a fase atual (`ph3`..`ph8`), valida as travas da fase (bloqueia código em `ph3`; exige falha de teste em `ph4`; exige sucesso em `ph5`; impõe ordem `test` $\to$ `refactor` em `ph7`) e formata `<tipo>: <resumo> (ref #<id> - ph<N>)`. |
| `cccp mutate` | **Fase 7** | Executa a ferramenta de teste de mutação da linguagem ativa restrita ao diff da branch (`git diff <base>..HEAD`). |
| `cccp hygiene` / `cccp fix` | **Fase 8** | Executa instantaneamente o linter estático (`-D warnings`) e o verificador/aplicador de formatação determinística das linguagens declaradas no `GOSTVER`. |
| `cccp close "<resumo>"` | **Fase 9** | Exige o corpo estruturado com o **Laudo Textual de Resolução** (`[Resumo]:`, `[Solução]:`, `[Validação]:`), valida a atualização de `CHANGELOG.md`/`site/` e grava o commit final `(closes #<id> - ph9)`. |
| `cccp merge` | **Pós-Fase 9** | Verifica o cumprimento das fases e do Fast Hygiene, integra a branch na base (`main`, `vN` ou `epic/*`), posta o Laudo do commit `ph9` como comentário oficial no ticket encerrando-o na forja e remove a branch local. |
| `cccp epic start|finish <slug>` | **Épicos** | Cria ou finaliza branches persistentes de integração (`epic/<slug>`) para reescritas multi-ticket. |
| `cccp push [--multidev]` | **Publicação** | Bloqueia push de branches efêmeras de ticket (salvo `--multidev`) e envia branches persistentes (`main`, `vN`, `epic/*`) para o `origin`. |
| `cccp release <patch|minor|major>` | **Release** | Executa auditoria pré-tag em container (`act`), consolida o `CHANGELOG.md`, atualiza o `VERSION`, assina a tag Git e publica. |
| `cccp gost sync | check` | **Governança** | Resolve a cascata de perfis (`extends`), propaga o `.gost/metadata.json` e executa as auditorias determinísticas do `rules.json`. |
| `cccp inbox list | review | accept` | **Fronteira** | Gerencia contribuições externas isoladas no namespace de quarentena `refs/heads/inbox/*`. |

---

## 2. Topologia de Forjas, Espelhos e Fronteira

### 2.1 Soberania da Forja Primária e Espelhamento Passivo
1. **Unidirecionalidade Local (`Zero Dual Push`):** O ambiente local mantém o remote `origin` apontando exclusivamente para a forja primária definida no perfil final. A replicação de código para espelhos externos (Codeberg, GitHub) é responsabilidade exclusiva do *Push Mirror* automático da forja primária (`sync_on_commit: true`).
2. **Sinalização de Espelhos e Paridade de Metadados:**
   - O comando `cccp gost sync` mantém `description` (extraído de `summary`), `website` e `topics` (extraídos de `tags` no `.gost/metadata.json`) idênticos entre a forja primária e os espelhos.
   - Nos espelhos secundários, a descrição recebe automaticamente o prefixo canônico:
     `[MIRROR / BACKUP] {summary} — Repositório canônico: {primary_forge_url}`
3. **Configuração Obrigatória de Remotes para Ingestão de PRs:**
   Para permitir que o controlador de fronteira baixe Pull Requests externos sem risco de push acidental para os espelhos, o `.git/config` **DEVE** ser mantido pelo `cccp` no seguinte formato:
   ```ini
   [remote "origin"]
       url = <primary_ssh_url>
       fetch = +refs/heads/*:refs/remotes/origin/*

   [remote "codeberg"]
       url = https://codeberg.org/<mirror_owner>/<slug>.git
       fetch = +refs/pull/*/head:refs/remotes/codeberg/pr/*
       pushurl = no_push

   [remote "github"]
       url = https://github.com/<mirror_owner>/<slug>.git
       fetch = +refs/pull/*/head:refs/remotes/github/pr/*
       pushurl = no_push
   ```

---

## 3. Matriz de Toolchains Homologadas (*Toolchain Pinning*)

As regras arquiteturais (DDD/Hexagonal), estruturas de diretórios, templates de `Dockerfile` e comandos de cada linguagem residem nos módulos `specs/languages/<lang>.md` da norma GOST. O perfil Kollontai fixa as versões mínimas homologadas para execução local e nas imagens da esteira:

| Stack (`GOST_LANGUAGES`) | Versão Canônica / Runtime | Runner de Testes & Cobertura (≥90%) | Mutação (Fase 7) | Linter (`-D warnings`) & Formatador |
| :--- | :--- | :--- | :--- | :--- |
| **`rust`** | `rustc >= 1.99.0` (`edition = "2024"`, target estático `musl`) | `cargo test` + `cargo-llvm-cov` | `cargo-mutants` (`--in-diff`) | `clippy` + `rustfmt` + `cargo-audit` |
| **`php`** | `PHP >= 8.5.0` (compatibilidade reversa `>= 8.2`, `strict_types=1`) | `pest --coverage --min=90` | `infection` (`--git-diff-lines`) | `phpstan --level=max` (target 8.2) + `pint` + `composer audit` |
| **`shell`** | POSIX `/bin/sh` estrito (ou `Bash >= 5.2` justificado) | `shellspec --kcov` | Revisão de borda (Boundary/Subshells) | `shellcheck` + `shfmt -d -i 2 -ci -bn` |
| **`javascript`** | `Node.js >= 24.16.0 LTS` (ESM nativo) + `TypeScript >= 5.8` (`strict`) | `vitest` (v8 coverage) + `playwright` (E2E) | `stryker` | `biome check` + `npm audit` |
| **`r`** | `R >= 4.4.1` + `renv` (lockfile imutável `renv.lock`) | `testthat` (3e) + `covr` | Revisão de invariantes (`NA`/`NaN`/`Inf`) | `lintr` + `styler` + `roxygen2` |
| **`go`** | `Go >= 1.22+` (cgo desabilitado para binário estático puro) | `go test -race` + `go tool cover` | `gremlins` | `golangci-lint` + `gofmt` + `govulncheck` |
| **`python`** | `Python >= 3.12+` (tipagem estrita mypy, Poetry/uv) | `pytest --cov` | `mutatest` | `ruff check/format` + `mypy --strict` + `pip-audit` |

### 3.1 Framework Canônico de Interface Gráfica: Dioxus 0.8
Para aplicações gráficas multiplataforma em Rust (Web WASM, Desktop via Tao/Wry e Mobile Android/iOS), o perfil Kollontai adota o **Dioxus 0.8** (`dioxus = "0.8"`):
* **Ergonomia Mobile Obrigatória:** Respeito a `env(safe-area-inset-top)` / `env(safe-area-inset-bottom)`, alvos de toque mínimos de `48px` com `touch-action: manipulation` e navegação adaptativa (barra inferior em telas `< 640px` e barra lateral compacta em `640px–1024px`).

---

## 4. Protocolo de Auto-Atualização Soberana (XDG) e Manifesto de Distribuição

Todas as ferramentas de linha de comando (CLI) e aplicações desktop distribuídas sob o perfil Kollontai **DEVEM** implementar o protocolo de auto-atualização conectado ao catálogo de distribuição soberano (a **Banca**) e interoperável com a **Jornaleira**.

### 4.1 Caminhos XDG e Formato de Configuração (`config.env`)
Para manter conformidade com a regra anti-bloat da norma GOST (Seção 13.2), a configuração e o cache de estado residem estritamente em caminhos XDG:
1. **Configuração do Usuário:** `${XDG_CONFIG_HOME:-~/.config}/<slug>/config.env`  
   Formato plano canônico `CHAVE="VALOR"` (compatível com POSIX Shell, Rust, Go e C):
   ```sh
   UPDATE_CHANNEL="stable"           # Canal rastreado: "stable" ou "nightly"
   UPDATE_PINNED="false"             # Se "true", bloqueia atualizações e silencia alertas
   UPDATE_PIN_VERSION=""             # Versão fixada quando UPDATE_PINNED="true"
   UPDATE_AUTO_CHECK="true"          # Verificação periódica não-bloqueante em modo autônomo
   UPDATE_CHECK_INTERVAL_HOURS="12"  # Frequência padrão de consulta (12 horas)
   UPDATE_AUTO_UPDATE="false"        # Substituição atômica sem confirmação (opt-in estrito)
   UPDATE_MANAGED_BY_JORNALEIRA=""   # Override: "" (auto-detectar), "true" ou "false"
   ```
   *Precedência de Resolução:* Flags CLI (`--channel`, `--pin`) > Variáveis de ambiente (`<SLUG_UPPER>_UPDATE_*` / `UPDATE_*`) > `${XDG_CONFIG_HOME}/<slug>/config.env` > Padrões normativos Kollontai.

2. **Estado e Cache de Runtime:** `${XDG_STATE_HOME:-~/.local/state}/<slug>/update_check.json`  
   Registro estruturado compartilhado entre o aplicativo e a Jornaleira:
   ```json
   {
     "last_check_timestamp": 1729411200,
     "current_version": "0.1.0",
     "latest_remote_version": "0.1.2",
     "channel": "stable",
     "update_available": true,
     "last_check_status": "success",
     "managed_by": "jornaleira"
   }
   ```

### 4.2 A Jornaleira como Gestora Primária e Comportamento em Runtime
1. **Hegemonia da Jornaleira:** A Jornaleira atua como a gestora primária do ecossistema.  
   * **Detecção:** Se `UPDATE_MANAGED_BY_JORNALEIRA="true"` ou se `command -v jornaleira >/dev/null 2>&1` retornar sucesso (sem override explícito `"false"`):
     * O **auto-check nativo dos aplicativos no startup permanece sumariamente desativado**.
     * Nenhuma requisição de rede ou consulta DNS é disparada durante a invocação normal de comandos do aplicativo.
     * A consulta remota periódica e a substituição de binários passam a ser orquestradas exclusivamente pelos timers e rotinas centrais da Jornaleira.
2. **Modo Autônomo (Sem Jornaleira):**  
   * Se a Jornaleira não estiver presente (ou `UPDATE_MANAGED_BY_JORNALEIRA="false"`), o utilitário assume a responsabilidade de verificar atualizações de forma não-bloqueante no startup caso o intervalo de 12 horas tenha expirado, com timeout estrito de $\le 1\text{s}$ descartando falhas silenciosamente.
3. **Alerta Não-Intrusivo em `stderr`:**  
   Se o arquivo `${XDG_STATE_HOME}/<slug>/update_check.json` indicar `update_available: true`, emite alerta exclusivamente em `stderr` (preservando pipelines em `stdout`):
   * *Quando sob gestão da Jornaleira:*
     ```text
     💡 [<slug>] Nova versão disponível: vX.Y.Z (atual: vA.B.C). Execute 'jornaleira update <slug>' para atualizar.
     ```
   * *Quando em modo autônomo:*
     ```text
     💡 [<slug>] Nova versão disponível: vX.Y.Z (atual: vA.B.C). Execute '<slug> update' para atualizar.
     ```

### 4.3 Contrato de Subcomandos CLI e Persistência de Canais
Todo binário distribuído **DEVE** responder aos subcomandos:
* `<slug> check-update [--channel <stable|nightly>] [--stable] [--nightly]`  
  Realiza consulta remota síncrona não-bloqueante na Banca, atualiza o arquivo `${XDG_STATE_HOME}/<slug>/update_check.json` e informa o status.
* `<slug> update [--channel <stable|nightly>] [--stable] [--nightly] [--pin <ver>] [--force] [--dry-run]`  
  Efetua a substituição atômica pelo binário mais recente da Banca respeitando o canal solicitado.
* `<slug> config show | set-channel <c> | pin [<ver>] | unpin | set-auto-check <bool> | set-auto-update <bool>`  
  Exibe ou altera de forma persistente as opções em `${XDG_CONFIG_HOME}/<slug>/config.env`.

#### **Garantia de Persistência do Canal Nightly:**
* A preferência declarada em `UPDATE_CHANNEL` (em `config.env`) define a assinatura duradoura de atualizações do usuário.
* O comando pontual `<slug> update --stable` (ou `--channel stable`) instala a compilação estável requisitada naquele momento, **mas NUNCA altera o valor de `UPDATE_CHANNEL`** no arquivo `config.env`.
* A reconfiguração persistente do canal exige comando explícito (`<slug> config set-channel stable` ou flag `--save-channel`).
* Enquanto `UPDATE_CHANNEL="nightly"`, o verificador continuará consultando e alertando sobre novas compilações do canal `nightly` assim que publicadas na Banca, mesmo que o executável local em execução seja momentaneamente uma versão estável.

### 4.4 Topologia do Catálogo de Distribuição (Banca) e Retenção Estrita
A esteira de CI publica os binários estáticos e mantém o armazenamento enxuto sob a seguinte estrutura canônica por aplicativo (`<slug>`):
* `<banca_url>/downloads/<slug>/install.sh`: Instalador POSIX puro (`#!/bin/sh`), verifica hash SHA-256 e instala em `~/.local/bin` (ou `/usr/local/bin` se root).
* `<banca_url>/downloads/<slug>/<channel>-latest` e `<channel>-latest.version`: Ponteiros atômicos para a versão ativa de cada canal (`stable` e `nightly`).
* `<banca_url>/downloads/<slug>/index.json`: Manifesto estruturado contendo metadados extraídos do `.gost/metadata.json` (`slug`, `title`, `tagline`, `summary`, `tags`), canais, URLs imutáveis, tamanho em bytes, data ISO-8601 e hashes `sha256`.
* **Política de Retenção e Expurgo Automático:** A publicação na esteira retém estritamente as **5 versões `stable`** mais recentes e as **10 compilações `nightly`** mais recentes, expurgando artefatos antigos automaticamente.

---

## 5. Esteira de CI/CD Hermética (`.forgejo/workflows/ci.yml`)

Em conformidade com a Seção 10 da norma GOST, todo repositório Kollontai possui um único arquivo `.forgejo/workflows/ci.yml` executando em containers locais pré-provisionados (sem downloads externos em runtime), dividido nas filas canônicas:

```yaml
name: "Gosplan Hermetic Pipeline"

on:
  push:
    branches: [main, "v*", "release/v*", "epic/*"]
  pull_request:

jobs:
  test:
    name: "Quality Gate (Lint, Tests, Coverage >= 90%, Audit)"
    runs-on: local-hermetic
    steps:
      - name: "Checkout Code"
        uses: actions/checkout@v4
      - name: "Execute GOST Compliance & Test Suite"
        run: |
          cccp gost check
          cccp test --coverage-min 90

  release:
    name: "Build Static Artifacts & Publish to Banca"
    runs-on: local-hermetic
    needs: [test]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: "Checkout Code"
        uses: actions/checkout@v4
      - name: "Compile & Dispatch to R2 / Banca"
        run: cccp ci publish-artifacts

  deploy:
    name: "Deploy Documentation Site & Containers"
    runs-on: local-hermetic
    needs: [test]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: "Checkout Code"
        uses: actions/checkout@v4
      - name: "Deploy Static Showcase & Orphan Pages"
        run: cccp ci deploy-site
```

* **Isolamento da Quarentena (`inbox/*`):** Para branches `refs/heads/inbox/*`, apenas o job `test` é executado em modo desprivilegiado (sem acesso a secrets de deploy ou chaves da Banca).
* **Publicação Stateless em Branch `pages`:** O espelhamento estático para forjas secundárias utiliza worktree órfã (`git worktree add --orphan -b pages`) com commit único (`docs(site): deploy snapshot [skip ci]`) e `git push --force`, impedindo inflação do histórico Git.

---

## 6. Vitrine Web, Internacionalização e Gerador de Banners

### 6.1 Roteador Estático Cliente (`site/index.html`) para `site_type: doc`
A página raiz atua como roteador leve para os 10 subdiretórios de idioma (`en`, `pt`, `es`, `fr`, `de`, `it`, `ru`, `zh`, `ja`, `ar`), respeitando `localStorage.getItem('doc_lang')`, `navigator.language` e o fallback primário do `.cccprc`:

```html
<script>
  (function() {
    var supported = ['en', 'pt', 'es', 'fr', 'de', 'it', 'ru', 'zh', 'ja', 'ar'];
    var saved = localStorage.getItem('doc_lang');
    if (saved && supported.indexOf(saved) !== -1) {
      window.location.replace(saved + '/');
      return;
    }
    var nav = (navigator.language || 'pt').toLowerCase().substring(0, 2);
    window.location.replace((supported.indexOf(nav) !== -1 ? nav : 'pt') + '/');
  })();
</script>
```

### 6.2 Geração Automatizada do Banner Minimalista (`cccp site banner`)
O banner `site/assets/og_preview.png` (`1200 × 630 px`, Safe Zone 4:3 de `720px–840px` × `500px`) é gerado deterministicamente a partir do `.gost/metadata.json`:
* Renderiza o fundo com `theme.bg_color` e detalhes de contraste com `theme.accent_color`.
* Posiciona o `icon` oficial e imprime exclusivamente a chamada curta **`{title} — {tagline}`** ($\le 65$ caracteres), sem textos secundários.

### 6.3 Template Estrutural do Rodapé Canônico em Duas Linhas
O perfil Kollontai estabelece o contrato de renderização do rodapé nas 10 línguas oficiais, parametrizando as variáveis de identidade (`{author_affirmation_i18n}`, `{author_name}`, `{author_url}`, `{country_i18n}`) que são preenchidas pelo perfil final:

```html
<footer class="gost-footer">
  <p>{author_affirmation_i18n}</p>
  <p>{title} v{version_full} • <a href="{author_url}" target="_blank" rel="noopener">{author_name}</a> • {country_i18n} • <a href="LICENSE">{license_spdx}</a></p>
</footer>
```

---

## 7. Catálogo Local de Descoberta (`~/src/catalog.json`)

Todo repositório inicializado ou sincronizado pelo `cccp` registra seus metadados extraídos do `.gost/metadata.json` no índice central da estação de trabalho (`~/src/catalog.json`):

```json
{
  "slug": "<slug>",
  "title": "<title>",
  "tagline": "<tagline>",
  "summary": "<summary>",
  "tags": ["<tag1>", "<tag2>", "<tag3>"],
  "license": "<spdx>",
  "site_type": "doc",
  "primary_forge": "<primary_forge_url>",
  "website": "<public_site_url>"
}
```
