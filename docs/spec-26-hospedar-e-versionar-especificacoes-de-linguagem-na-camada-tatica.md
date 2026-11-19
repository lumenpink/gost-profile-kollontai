# Especificação Técnica: Hospedagem e Versionamento de Especificações de Linguagem na Camada Tática (Ticket #26)

## 1. Contexto e Motivação
Em alinhamento com a Metanorma Fundamental GOST v3.0.0 (Ticket #45 no repositório `gost`), a Grundnorm fundamental é neutra e agnóstica a tecnologias ou linguagens de programação.
A competência para homologar toolchains, matrizes de versões de compiladores, contratos de interfaces e padrões arquiteturais de código (Hexagonal, SOLID pragmático, pureza de domínio, XDG, alvos estáticos musl) reside formalmente na **Camada Tática** (`tier: tactical`), exercida pelo perfil **Kollontai**.

## 2. Requisitos Mandatórios

1. **Diretório Canônico de Linguagens (`languages/`):**
   - O repositório Kollontai hospeda as especificações de linguagem homologadas:
     - `languages/rust.md`
     - `languages/javascript.md`
     - `languages/shell.md`
     - `languages/python.md`
     - `languages/go.md`
     - `languages/php.md`
     - `languages/r.md`

2. **Frontmatter YAML Canônico em cada Especificação:**
   Cada especificação em `languages/<lang>.md` deve conter obrigatoriamente o frontmatter com SemVer da norma tática:
   ```yaml
   ---
   standard: "kollontai"
   tier: "tactical"
   language: "<lang>"
   version: "2.1.0"
   locale: "pt-br"
   authority: "Standards Committee"
   published_at: "2026-11-08"
   inherits_from:
     standard: "kollontai"
     tier: "tactical"
     version: "2.1.0"
     base_url: "https://kollontai.2lp.in/2.1.0/"
   ---
   ```

3. **Distribuição Canônica no Portal (`site/`):**
   - Sincronização em `site/languages/<lang>.md` e `site/2.1.0/languages/<lang>.md`.
   - O script de geração do site (`scripts/build_site.py`) deve garantir a publicação idêntica e determinística desses arquivos.

4. **Referência Normativa em `profile.md`:**
   - Adição de seção técnica em `profile.md` explicitando a autoridade da Kollontai sobre as especificações táticas de linguagens.

## 3. Resolução
Implementado e homologado no ciclo DD-TDD Kollontai v2.1.0.
