# Especificação Técnica — Ticket #30: Atualizar Requisito de Compilador para rustc 1.100.0 e Elevar Perfil para 2.2.0

- **Ticket:** [#30](https://gambi.2lp.in/lumen/gost-profile-kollontai/issues/30)
- **Branch:** `feat/30-atualizar-requisito-de-compilador-para-rustc-1-100-0`
- **Autoridade Normativa:** GOST v3.0.0 (`tier: fundamental`, Seção 2.2)

---

## 1. Contexto & Motivação

Com o amadurecimento do ecossistema e o lançamento do Rust 1.100.0, torna-se necessário elevar a régua técnica mínima da toolchain de compilação em toda a stack GOST.

Conforme a Metanorma Fundamental GOST v3.0.0 (Seção 2.2 - Princípio do Encadeamento Linear de Migração), qualquer alteração contratual que imponha novos requisitos mínimos aos repositórios regulados constitui quebra de contrato (*breaking change*). Consequentemente:
1. O perfil tático Kollontai deve avançar de `2.1.0` para `2.2.0`.
2. O artefato canônico `UPGRADE.md` deve ser publicado em `site/2.2.0/UPGRADE.md` com `replaces: "2.1.0"` e `valid_since: "2.1.0"`.
3. As especificações táticas de linguagem em `languages/` avançam para a versão `2.2.0`, fixando `rustc >= 1.100.0` em `languages/rust.md`.
4. O catálogo público `site/versions.json` deve listar `2.2.0` como `latest` preservando o histórico `2.1.0`.

---

## 2. Decisão Arquitetural

### 2.1 Requisito Mínimo da Toolchain Rust
- A especificação `languages/rust.md` e a matriz de linguagens em `profile.md` passam a exigir expressamente `rustc >= 1.100.0` (com target estático `musl` e edição 2024).
- O exemplo de container OCI é atualizado para `rust:1.100-alpine`.

### 2.2 Frontmatter Canônico de `site/2.2.0/UPGRADE.md`
```yaml
---
standard: "kollontai"
tier: "tactical"
version: "2.2.0"
replaces: "2.1.0"
valid_since: "2.1.0"
breaking: true
---
```

### 2.3 Estrutura do Guia de Migração (Quatro Seções Normatizadas)
1. **Quebras de Contrato (*Breaking Changes*):**
   - Elevação do requisito da toolchain Rust para `rustc >= 1.100.0`.
   - Rota canônica versionada das especificações de linguagem: `https://kollontai.2lp.in/2.2.0/languages/<lang>.md`.
2. **Mutação de Regras Declarativas:**
   - Atualização das cláusulas táticas de conformidade da stack `rust`.
3. **Ações Manuais Necessárias:**
   - Atualização do compilador local via `rustup update stable` ou fixação em `1.100.0`.
   - Atualização de imagens Docker e pipelines de CI.
4. **Ações Automatizáveis via Ferramenta:**
   - Sincronização via `cccp profile set kollontai` e `cccp profile assemble`.

### 2.4 Preservação Histórica e Fail-Fast
- `site/2.1.0/` permanece intacto como registro histórico imutável.
- `site/2.2.0/` conterá `RULES.md`, `RULES.toml`, `languages/` e `UPGRADE.md`.
- `site/versions.json` declara `latest: "2.2.0"` e `versions: ["2.1.0", "2.2.0"]`.

---

## 3. Árvore de Decisões e Alternativas Descartadas (Para a Natasha)

- **Alternativa Descartada 1: Atualizar apenas `languages/rust.md` sem elevar a versão SemVer de Kollontai.**
  - *Motivo do Descarte:* Viola a Metanorma GOST v3.0.0. Elevar o requisito do compilador quebra builds de ambientes com rustc anterior, caracterizando *breaking change*. Sem avanço de versão e sem `UPGRADE.md`, ferramentas automatizadas e a Natasha ficariam sem rastreabilidade do motivo da quebra.
- **Alternativa Descartada 2: Substituir o conteúdo de `site/2.1.0/` com as novas regras.**
  - *Motivo do Descarte:* Viola a imutabilidade das rotas versionadas. Repositórios ainda ancorados em `2.1.0` teriam seu contrato alterado silenciosamente sob os pés.
- **Alternativa Descartada 3: Criar retrocompatibilidade mantendo rustc 1.99 como opcional.**
  - *Motivo do Descarte:* Postura fail-fast do ecossistema GOST. Uma matriz difusa de compiladores suportados gera dívida técnica e divergências de comportamento de borrow checker e flags entre desenvolvedoras e CI.

---

## 4. Critérios de Aceite e Matriz de Testes (Fase 4 - Red Test)

1. `test_upgrade_md_spec.sh`:
   - Verifica existência de `site/2.2.0/UPGRADE.md` e conformidade de frontmatter YAML e quatro seções obrigatórias.
   - 4 mutantes eliminados.
2. `test_versions_catalog_spec.sh`:
   - Valida que `site/versions.json` contém `latest: "2.2.0"` e inclui `2.1.0` e `2.2.0`.
   - Valida presença dos arquivos obrigatórios em `site/2.2.0/`.
   - 4 mutantes eliminados.
3. `test_languages_spec.sh`:
   - Valida que todos os 7 arquivos de linguagem possuem `version: "2.2.0"` e rotas sincronizadas em `site/2.2.0/languages/`.
   - Valida requisito `rustc >= 1.100.0` em `languages/rust.md`.
4. `test_kollontai_v2_2_spec.sh`:
   - Valida sincronização entre `profile.md` e `site/2.2.0/RULES.md`.
   - Valida sincronização entre `rules.toml` e `site/2.2.0/RULES.toml`.
   - 9 mutantes eliminados.

---

## 5. Resultados de Validação (Quality Gate)
- **Suíte Normativa:** Todas as 8 suítes de teste em `tests/*.sh` executadas com 100% de sucesso.
- **Cobertura de Mutações:** Mutantes eliminados com sucesso em `test_upgrade_md_spec.sh`, `test_versions_catalog_spec.sh`, `test_languages_spec.sh` e `test_kollontai_v2_1_spec.sh`.
- **Artefato Canônico:** `site/2.2.0/UPGRADE.md` publicado e auditado contra o contrato GOST v3.0.0.
- **Auditoria Strict:** `cccp check --strict` aprovado com 17/17 (100% de conformidade).
