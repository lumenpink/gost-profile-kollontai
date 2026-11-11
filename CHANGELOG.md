# Changelog

## [Unreleased]

### Features
- **catalog:** disponibilizar catalogo versions.json e rotas versionadas (closes #20)
- **docs:** esclarecer convenção de commit count relativo para canal dev (closes #19)
- **rules:** normatizar paridade de git hooks com o maestro via KOLLONTAI-018 (closes #18)
- **rules:** criar regra KOLLONTAI-017 de matriz de licenciamento (closes #17)
- **site:** disponibilizar rules.toml em site/rules.toml (closes #16)
- **site:** sincronizar site/profile.md e purgar termos proibidos do site (closes #15)
- **rules:** criar regra KOLLONTAI-016 de proibição de dependências via path (closes #14)
- **rules:** sanear catálogo tático com os 15 decretos de engenharia (closes #13)
- **rules:** implementar regra KOLLONTAI-010 smoke test pos-build (closes #12)
- **rules:** introduzir validadores de contratos de api e containerizacao com scope project (closes #11)

## [2.1.0] - 2026-11-08

### Features
- **docker:** estabelecer padroes taticos de conteinerizacao e compose (closes #10)
- **spec:** subordinar perfil Kollontai ao GOSPLAN v1.0.0 com tier tático (closes #9)
- **rules:** migrar catálogo de validação para rules.toml com scripts Lua e locales (ref #9)
- **hygiene:** purgar terminologias proibidas e adotar frontmatter universal (ref #9)

## [2.0.0] - 2026-10-26

### Features
- **spec:** alinhar perfil Kollontai com a norma GOST v2.0.0 (closes #4)
- **spec:** institucionalizar o Maestro cccp e parametrizar .cccprc (ref #4)
- **spec:** fixar matriz de toolchain pinning para Rust, PHP, Shell, JS/TS, R, Go e Python (ref #4)
- **spec:** padronizar protocolos de auto-atualizacao XDG e catalogo da Banca (ref #4)
- **spec:** estabelecer esteira hermetica ci.yml de 3 filas e isolamento inbox/* (ref #4)
- **spec:** expurgar Watchtower e obrigatoriedade de act em pre-push (ref #4)

## [Unreleased]

### Features
- **spec(channels):** padronizar canais stable e dev com contrato de esteira desacoplada (closes #8)
- **spec(channels):** normatizar segregação de aliases de distribuição (latest vs latest-dev e X.Y.Z-dev) e idempotência de publicação com pre-delete contra HTTP 409 (#7)

### Bug Fixes
- **ci:** remover step legado de pages e consolidar deploy no Cloudflare Workers (#6)

### Features
- **spec(updater):** padronizar ciclo de vida de updates XDG com gestão central pela Jornaleira e persistência de canal (#5)

### Bug Fixes
  - (footer) ajustar definicoes canonicas dos rodapes com timestamp ISO UTC (closes #1)

### Features
  - (spec) sincronizar conformidade com GOST 1.5.0 e anatomia (closes #3)
  - (spec) adicionar rodape canonico multilingue e auto-update watchtower
  - initial release do perfil de implementacao lumen

## Previous Releases

