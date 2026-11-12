---
standard: "kollontai"
tier: "tactical"
version: "2.1.0"
locale: "pt-br"
authority: "Standards Committee"
published_at: "2026-11-08"
inherits_from:
  standard: "gosplan"
  tier: "strategic"
  version: "1.0.0"
  base_url: "https://gosplan.2lp.in/1.0.0/"
---

# Perfil de Implementação GOST: Kollontai

> **Sobre este Perfil:**  
> O perfil **Kollontai** (em homenagem à revolucionária soviética, feminista e diplomata Alexandra Kollontai) define o ferramental tático de engenharia, os contratos de interface do ecossistema de governança, a matriz de versões de compiladores, o protocolo de auto-atualização de binários e a arquitetura de distribuição para projetos aderentes ao padrão **GOST**.  
> Ele é agnóstico a domínios pessoais e identidades individuais, servindo como perfil base para coletivos, laboratórios ou perfis autorais derivados.

---

## 1. Contratos e Interfaces do Ecossistema Tático de Governança

No perfil Kollontai, a governança definida na norma GOST é decomposta em três interfaces táticas funcionais e universais:

### 1.1 Contrato da Ferramenta de Ciclo de Vida Local (Maestro Local)
Responsável exclusivo pela orquestração do ciclo de vida local do repositório, execução das 9 fases DD-TDD, interceptação de convenções de commit, higiene de código e integração segura de branches.

#### Contrato de Comandos do Maestro Local:
| Comando / Ação | Fase / Escopo | Contrato Funcional |
| :--- | :---: | :--- |
| `start <id> [--base <b>]` | **Fase 2** | Lê os metadados do ticket `#<id>`, atualiza a base (`main`, `vN` ou `epic/*`) e cria/alterna para a branch de trabalho `<tipo>/<id>-<slug>`. |
| `status` | **Fases 1–9** | Inspeciona o histórico da branch ativa, audita a fase alcançada (`ph3`..`ph9`) e indica o próximo passo obrigatório. |
| `commit "<resumo>"` | **Fases 3–8** | Deduz o ticket e a fase atual (`ph3`..`ph8`), valida as travas da fase e grava o commit convencional com `<tipo>: <resumo> (ref #<id> - ph<N>)`. |
| `mutate` | **Fase 7** | Executa a ferramenta de teste de mutação da linguagem restrita ao diff da branch. |
| `hygiene` / `fix` | **Fase 8** | Executa formatadores determinísticos e linters estáticos com tolerância zero a avisos (`-D warnings`). |
| `close "<resumo>"` | **Fase 9** | Exige o corpo com o **Laudo Textual de Resolução** (`[Resumo]:`, `[Solução]:`, `[Validação]:`) e grava o commit canônico de fechamento `(closes #<id> - ph9)`. |
| `merge` | **Pós-Fase 9** | Valida a presença da tag canônica `(closes #<id>)` e integra localmente a branch de trabalho na base (`main`), eliminando a branch local efêmera. |
| `push [--multidev]` | **Publicação** | Bloqueia push de branches efêmeras de ticket e envia branches persistentes (`main`, `vN`, `epic/*`) ao remote autorizado. |
| `release <patch|minor|major>` | **Release** | Executa auditoria pré-tag, consolida `CHANGELOG.md`, atualiza `VERSION` e sela a tag semântica. |

### 1.2 Contrato da Ferramenta de Governança de Forja e Abastecimento
Responsável pela interface com forjas remotas (API), ciclo de vida de issues/tickets, triagem assistida e catalogação multi-repositório.

#### Contrato de Comandos de Forja e Abastecimento:
| Comando / Ação | Finalidade | Contrato Funcional |
| :--- | :--- | :--- |
| `init` / `new` | **Dia Zero** | Inicializa repositório local e remoto na forja primária, gera anatomia inicial e registra no catálogo. |
| `ticket create` | **Abertura** | Cria issue na forja com tipo semântico, contexto e critérios de aceite. |
| `ticket list` | **Consulta** | Lista issues ativas com filtros por estado, marco ou responsável. |
| `ticket comment` | **Comentário** | Insere anotações ou laudos de progresso na issue remota. |
| `ticket close` | **Encerramento** | Fecha formalmente a issue na forja com mensagem conclusiva. |
| `divan` / `triage` | **Triagem Assistida** | Sessão interativa assistida por modelo de inteligência para refinamento e planejamento. |
| `catalog scan` / `list` | **Inventário** | Varre workspaces e cataloga repositórios e seus metadados (`.gost/metadata.json`). |
| `batch push` | **Operação em Lote** | Executa envio de atualizações sincronizadas através dos repositórios do catálogo. |

### 1.3 Contrato do Validador Normativo de Conformidade
Responsável pela avaliação de regras declarativas (`rules.toml`) e emissão de laudos padronizados de conformidade.

#### Contrato de Comandos do Validador:
| Comando / Ação | Contrato Funcional |
| :--- | :--- |
| `check [--strict] [--lang <l>] [--scope <s>] [--json]` | Avalia regras declaradas com filtros de escopo (`project`, `post-build`, etc.) e emite laudos em texto ou JSON. Retorna código 0 em aprovação e código 1 em falha (ou avisos em modo estrito). |
| `test` | Valida sintaxe e integridade das regras declarativas do catálogo local. |
| `eval <expressão>` | Executa script ou expressão isolada com acesso aos primitivos de runtime normativos. |

---

## 2. Topologia de Forjas, Espelhos e Fronteira

### 2.1 Autoridade da Forja Primária e Espelhamento Passivo
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

## 4. Protocolo de Auto-Atualização (XDG) e Manifesto de Distribuição

Todas as ferramentas de linha de comando (CLI) e aplicações desktop distribuídas sob o perfil Kollontai **DEVEM** implementar o protocolo de auto-atualização conectado ao catálogo de distribuição central (a **Banca**) e interoperável com a **Jornaleira**.

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

#### **Garantia de Persistência do Canal Dev / Nightly:**
* A preferência declarada em `UPDATE_CHANNEL` (em `config.env`) define a assinatura duradoura de atualizações do usuário (`stable` ou `dev`/`nightly`).
* O comando pontual `<slug> update --stable` (ou `--channel stable`) instala a compilação estável requisitada naquele momento, **mas NUNCA altera o valor de `UPDATE_CHANNEL`** no arquivo `config.env`.
* A reconfiguração persistente do canal exige comando explícito (`<slug> config set-channel stable` ou flag `--save-channel`).
* Enquanto `UPDATE_CHANNEL="dev"` (ou `"nightly"`), o verificador continuará consultando e alertando sobre novas compilações do canal `dev` assim que publicadas na Banca, mesmo que o executável local em execução seja momentaneamente uma versão estável.

### 4.4 Topologia de Armazenamento e Distribuição Desacoplada
A esteira de publicação opera sob o modelo **Produtor–Curador Desacoplado**:
* **Produtor (Repositório do Software):** Compila o código na esteira, calcula os hashes de integridade (SHA-256), envia os artefatos diretamente para o storage de distribuição, atualiza a cópia de alias e despacha um evento de notificação via API (`repository_dispatch`).
* **Curador (Repositório Central da Banca):** Ouve os eventos via esteira (`repository_dispatch`), executa auditoria estrita de existência e integridade dos arquivos novos e do histórico ativo, gerencia a retenção no storage conforme o perfil operacional (Lilya), atualiza o catálogo (`catalog.json`) e realiza o deploy.
* **Topologia do Storage (Bucket Único Particionado):**
  Todos os artefatos são mantidos sob o prefixo `banca-artifacts/{app}/{channel}/`:
  - `{app}-{versao}-{target}.{ext}` e respectivo `.sha256`
  - Cópias físicas de alias sobrescritas: `{app}-latest-{target}.{ext}` (em `stable`) ou `{app}-dev-latest-{target}.{ext}` (em `dev`), juntamente com seus arquivos `.sha256`.

### 4.5 Nomenclatura de Canais e Aliases Canônicos
A publicação e o consumo de artefatos de distribuição respeitam os canais canônicos:
1. **Canal Estável (`stable`):**
   - Rótulo na interface: *Versão Recomendada*.
   - Sufixo / padrão de versão: SemVer 2.0 (`x.y.z`).
   - Alias canônico: `*-latest.*` (ex.: `{app}-latest-{target}.{ext}`).
   - Possui **exclusividade absoluta** sobre o alias primário `latest` e versões desprovidas de sufixo.
2. **Canal de Desenvolvimento (`dev`):**
   - Rótulo na interface: *Versão Experimental*.
   - Sufixo / padrão de versão: `x.y.z-dev.{n}+{YYYYMMDD}.{commit}`.
   - **Semântica Canônica de `{n}` (Commit Count):** O contador `{n}` representa estritamente o número de commits desde a última tag estável (`git rev-list vX.Y.Z..HEAD --count`), mensurando a distância relativa do incremento em relação à versão estável base. É expressamente proibido utilizar a contagem acumulada absoluta de commits do repositório (`git rev-list --count HEAD`), prevenindo contaminações e saltos artificiais de numeração no SemVer. Quando o `HEAD` coincidir com a tag estável, `{n}` é `0`. Se o repositório não possuir tags estáveis anteriores (estado inaugural/gênese), `{n}` recai sobre a contagem a partir da gênese sobre a base `0.0.0-dev.{n}`.
   - Alias canônico: `*-dev-latest.*` (ex.: `{app}-dev-latest-{target}.{ext}`).
3. **Consumo de Versões Canônicas Recomendado:**
   - Em manifestos de build (`Cargo.toml`, etc.), a fixação em versões canônicas exatas (`=`) é formalmente **recomendada** (*SHOULD* / *DEVERIA*) para garantir reprodutibilidade hermética em cascata.
4. **Tolerância Zero a Links Quebrados:**
   - Se qualquer artefato declarado (novo ou histórico ativo) falhar na verificação de rede ou apresentar divergência de checksum, a publicação do catálogo é abortada imediatamente.

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

### 5.1 Contrato de Notificação via API (`repository_dispatch`)
O repositório produtor do software notifica a esteira central da Banca via chamada HTTP:
`POST /api/v1/repos/{owner}/banca/dispatches` com `event_type: "release-published"`.

#### Schema do Payload (`client_payload`):
```json
{
  "event_type": "release-published",
  "client_payload": {
    "app": "slug",
    "channel": "stable",
    "version": "x.y.z",
    "commit": "hash",
    "repo_slug": "owner/slug",
    "run_id": "1842",
    "assets": [
      {
        "filename": "app-0.1.0-linux-x86_64.tar.gz",
        "alias": "app-latest-linux-x86_64.tar.gz",
        "type": "archive",
        "format": "tar.gz",
        "target": "linux-x86_64",
        "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      }
    ]
  }
}
```

### 5.2 Idempotência na Publicação e Pre-Delete de Aliases Mutáveis
Para forjas de pacotes que rejeitam sobrescrita direta de arquivos com o mesmo nome sob uma versão (como os Generic Packages do Forgejo, gerando erros `HTTP 409 Conflict`), a esteira de CI/CD **DEVE** garantir idempotência:
* Antes de executar o envio (`PUT`) para aliases mutáveis (`latest-dev`, `${BASE_VERSION}-dev`, `latest`), a esteira deve executar uma limpeza prévia com deleção idempotente (`curl -s -X DELETE ... || true`).
* Essa prática previne falhas espúrias de publicação e assegura que a forja atualize o ponteiro do alias sem interrupções.

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

### 6.2 Geração Determinística do Banner Minimalista
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

Todo repositório inicializado ou sincronizado pelo ferramental de governança registra seus metadados extraídos do `.gost/metadata.json` no índice central da estação de trabalho (`~/src/catalog.json`):

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

---

## 8. Padrões Táticos de Conteinerização Obrigatória de Serviços

Em cumprimento à diretriz estratégica do GOSPLAN, todo serviço de backend, microsserviço ou daemon distribuído no perfil Kollontai DEVE atender aos seguintes padrões de conteinerização:

### 8.1 Anatomia de Imagem (`Dockerfile` / `Containerfile`)
1. **Multi-Stage Hermético:** O estágio de build compila o software hermeticamente; o estágio final copia apenas o binário compilado e artefatos estritamente necessários para uma imagem base minimalista (`alpine` ou `scratch`).
2. **Execução Desprivilegiada Mandatória:** O container DEVE executar sob usuário não-root explicitamente (`user: "1000:1000"`). É proibida a execução contínua como `root`.
3. **Imutabilidade e Efemeridade:** O sistema de arquivos do container é considerado volátil, delegando persistência a volumes nomeados ou bind-mounts explicitados no compose.

### 8.2 Orquestração Declarativa Local (`compose.yaml`)
1. **Extensão Canônica:** A declaração de orquestração utiliza estritamente o nome `compose.yaml` (sendo expressamente banido o uso da extensão obsoleta `.yml`).
2. **Política de Reinício e Healthcheck:** Todo serviço em produção declara `restart: unless-stopped` e uma probe ativa de integridade (`healthcheck` com `interval`, `timeout` e `retries`).
3. **Isolamento de Rede:** Serviços internos operam em redes privadas OCI (`networks: default: internal: true` ou isoladas). Portas só devem ser expostas se o serviço for explicitamente um ponto de ingresso público.

---

## 9. Padrão Tático de Sanidade Pós-Compilação (*Smoke Tests*)

Todo artefato executável gerado no perfil Kollontai está sujeito a validação no escopo canônico `post-build`:

1. **Execução Dinâmica Rápida:** O binário gerado é executado com argumentos de inspeção inofensivos em tempo limite estrito ($\le 3$ segundos).
2. **Prevenção de Falhas Críticas:** O teste detecta e bloqueia falhas de segmentação (`SIGSEGV` / sinal 11), *panics* imediatos de runtime ou ausência de dependências dinâmicas compartilhadas (*shared libraries* faltantes no ambiente).
3. **Isolamento e Limpeza:** A execução não deve deixar processos zumbis ou arquivos temporários não tratados no host.


---

## 10. Decretos Regulamentadores de Engenharia (KOLLONTAI-001 a KOLLONTAI-018)

O catálogo tático do perfil Kollontai estabelece parâmetros objetivos de engenharia e conformidade técnica para todos os projetos subordinados:

| ID | Nome Canônico | Escopo | Descrição Sumária |
| :--- | :--- | :--- | :--- |
| **KOLLONTAI-001** | `README-MAX-LINES` | `project` | Teto rigoroso de 50 linhas para o arquivo `README.md`. |
| **KOLLONTAI-002** | `BANNER-DIMENSIONS-AND-RATIO` | `project` | Banner institucional exatamente em 1200x630 (proporção 1.91:1) com safe zone. |
| **KOLLONTAI-003** | `DDD-DOMAIN-PURITY` | `project` | Pureza de domínio: `src/domain/` com zero I/O, rede ou dependências de frameworks. |
| **KOLLONTAI-004** | `STATIC-ANALYSIS-ZERO-WARNINGS` | `ci` | Linters e análise estática executando com zero advertências (`-D warnings` ou `--strict`). |
| **KOLLONTAI-005** | `FORMAT-CHECK-DETERMINISTIC` | `ci` | Verificação determinística de formatação de código (`fmt --check`) na esteira. |
| **KOLLONTAI-006** | `SITE-SECURITY-HEADERS` | `project` | Cabeçalhos de segurança HTTP em `site/_headers` (anti-sniffing e anti-framing). |
| **KOLLONTAI-007** | `COMPOSE-NON-ROOT-USER` | `project` | Usuário desprivilegiado `user: "1000:1000"` obrigatório em manifestos compose. |
| **KOLLONTAI-008** | `COMPOSE-HEALTHCHECK-REQUIRED` | `project` | Sonda de integridade ativa (`healthcheck:`) obrigatória em manifestos compose. |
| **KOLLONTAI-009** | `DOCKERFILE-NON-ROOT-USER` | `project` | Usuário desprivilegiado `USER 1000:1000` obrigatório em Dockerfiles. |
| **KOLLONTAI-010** | `API-CONTRACT-OPENAPI` | `project` | Contratos de API em `docs/openapi.yaml` ou `docs/external/` em padrão OpenAPI 3.x. |
| **KOLLONTAI-011** | `FORBIDDEN-TERMS` | `docs` | Tabela curada de termos proibidos (sem etiqueta imperialista na norma). |
| **KOLLONTAI-012** | `SMOKE-TEST-SANITY-POST-BUILD` | `post-build` | Smoke test pós-compilação atestando ausência de SIGSEGV (139) e panics. |
| **KOLLONTAI-013** | `INTL-KEY-PARITY` | `project` | Paridade genérica de chaves entre dicionários das línguas listadas em `LANGUAGES`. |
| **KOLLONTAI-014** | `RTL-LOGICAL-PROPERTIES-AUDIT` | `project` | Auditoria de propriedades lógicas CSS e atributo `dir="rtl"` para idiomas RTL. |
| **KOLLONTAI-015** | `I18N-SITE-FALLBACK-ENGLISH` | `project` | Roteador cliente do site adota inglês (`en`) como fallback na ausência do idioma do visitante. |
| **KOLLONTAI-016** | `FORBIDDEN-PATH-DEPENDENCIES` | `project` | Proibição de dependências locais via caminho (path = "...") em manifestos de pacotes. |
| **KOLLONTAI-017** | `LICENSING-MATRIX-COMPLIANCE` | `project` | Conformidade da matriz de licenciamento (GPL-3.0 padrão em software e satélites modulares). |
| **KOLLONTAI-018** | `GIT-HOOKS-MAESTRO-PARITY` | `project` | Hooks essenciais do Git instalados e ativamente gerenciados pelo maestro `cccp`. |
