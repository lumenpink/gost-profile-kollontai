# Especificação Técnica: Subordinação do Perfil Kollontai ao GOSPLAN e Migração de Regras Tridigitais (Ticket #9)

## 1. Contexto e Motivação
Com a positivação da Metanorma Fundamental GOST v3.0.0 e do Plano Estratégico GOSPLAN v1.0.0, a norma tática Kollontai assume formalmente sua posição na hierarquia da Tríade Normativa Fechada:
`Fundamental (GOST)` -> `Estratégica (GOSPLAN)` -> `Tática (Kollontai)` -> `Operacional (Lilya)` -> `Local (Customizado)`.

## 2. Requisitos Mandatórios
1. **Frontmatter Universal em Inglês:**
   - `standard: "kollontai"`
   - `tier: "tactical"`
   - `version: "2.1.0"`
   - `locale: "pt-br"`
   - `authority: "Standards Committee"`
   - `published_at: "2026-11-08"`
   - `inherits_from`:
     - `standard: "gosplan"`
     - `tier: "strategic"`
     - `version: "1.0.0"`
     - `base_url: "https://gosplan.2lp.in/1.0.0/"`

2. **Purga Terminológica:**
   - Substituição de qualquer menção imperialista (ex.: "Soberania") por "Autoridade da Forja Primária" ou "Centralidade da Forja Primária".

3. **Catálogo Declarativo de Regras Tridigitais (`rules.toml`):**
   - Regras tridigitais no padrão `KOLLONTAI-001` a `KOLLONTAI-999`.
   - Scripts de validação desacoplados em Lua utilizando estritamente a API canônica sob o namespace `gost.*`.
   - Catálogo de localização correspondente em `locales/pt-br.toml`.

4. **Regras Táticas Definidas:**
   - `KOLLONTAI-001`: Existência e integridade do arquivo `.cccprc` na raiz do repositório ou herança global.
   - `KOLLONTAI-002`: Existência da declaração de `primary_forge_type` no `.cccprc`.
   - `KOLLONTAI-003`: Declaração de `agent_var_lang` no `.cccprc`.
   - `KOLLONTAI-004`: Ausência de termos proibidos (ex.: imperialistas) na documentação do projeto.
   - `KOLLONTAI-005`: Existência do arquivo de versionamento canônico `VERSION`.
   - `KOLLONTAI-006`: Existência do histórico de mudanças `CHANGELOG.md`.
   - `KOLLONTAI-007`: Existência de configuração `.editorconfig` na raiz.
