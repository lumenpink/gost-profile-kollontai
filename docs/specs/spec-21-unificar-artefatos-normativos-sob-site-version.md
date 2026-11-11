# Especificação Técnica: Unificação de Artefatos Normativos sob site/{version}/ (Ticket #21)

## 1. Contexto e Motivação
A publicação do perfil Kollontai mantinha artefatos duplicados na raiz do diretório `site/` (`site/RULES.md`, `site/RULES.toml`, `site/rules.toml`, `site/profile.md`, `site/kollontai.md`) além dos mesmos arquivos sob o subdiretório versionado `site/{version}/` (`site/2.1.0/`).
Essa duplicidade gerava rotas conflitantes, ocultava versões obsoletas e criava débito técnico na resolução das normas pelos clientes (`cccp` e ferramentas externas).

## 2. Decisões Arquiteturais e Alternativas Descartadas (Para a Natasha)
- **Local Canônico Exclusivo para Artefatos Normativos:**
  - *Decisão:* Os artefatos normativos compilados (`RULES.md` e `RULES.toml`) devem residir estritamente no subdiretório de versão `site/{version}/`. Na raiz de `site/`, permanecem apenas o catálogo de versões `site/versions.json`, assets do portal web e o indexador `site/index.html`.
  - *Alternativa descartada:* Manter cópias espelho na raiz de `site/`. Descartada porque mascarava requisições a versões obsoletas e violava o determinismo estrito `{url}/{version}/RULES.toml`.
- **Limpeza de Nomenclatura Obsoleta em `site/{version}/`:**
  - *Decisão:* No subdiretório `site/{version}/`, manter exclusivamente `RULES.md` e `RULES.toml`. Arquivos legados como `profile.md` e `rules.toml` em caixa baixa são expurgados.
  - *Alternativa descartada:* Manter links simbólicos ou arquivos legados. Descartada pois gerava ruído e redundância sem propósito.

## 3. Plano de Fases (DD-TDD)
- **Fase 4 (Red Test):** Atualizar `tests/test_versions_catalog_spec.sh` para falhar se houver `site/RULES.md` ou `site/RULES.toml` na raiz, e garantir que apenas `site/{version}/RULES.md` e `site/{version}/RULES.toml` existam.
- **Fase 5 (Green Implement):** Remover os arquivos duplicados da raiz de `site/` e do subdiretório versionado.
- **Fase 7 (Mutation Test):** Testes de mutação garantindo que a tentativa de consultar a raiz retorne ausência dos arquivos normativos.
- **Fase 8 (Quality Gate):** Validação de todos os testes shell do repositório (`bash tests/*.sh`).
- **Fase 9 (Close):** Laudo de fechamento e merge na `main`.
