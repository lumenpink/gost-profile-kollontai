# Especificação Técnica — Ticket #7: Segregação de Aliases de Distribuição e Idempotência de Publicação

**Norma de Referência:** GOST 2.0.0  
**Perfil:** Kollontai (`https://kollontai.2lp.in/profile.md`)  
**Data:** 2026-11-06  
**Status:** Aprovado / Em Implementação (Fase 3 DD-TDD)  

---

## 1. Contexto & Motivação

A esteira de integração contínua e publicação de artefatos de distribuição (pacotes genéricos, staticlibs, contêineres e releases na Banca) opera em dois canais canônicos de entrega:
1. **Canal Estável (`stable`)**: Acionado exclusivamente por tags de versão estável (`refs/tags/v*`).
2. **Canal Nightly/Desenvolvimento (`nightly`)**: Acionado por commits de integração na branch principal (`refs/heads/main`).

Anteriormente, artefatos de desenvolvimento eram frequentemente publicados sob aliases desprovidos de sufixo (ex.: `0.1.0` ou `latest`), gerando sobreposição indevida com versões estáveis tagueadas. Além disso, em forjas de pacotes (como os Generic Packages do Forgejo), o envio de arquivos idênticos ou atualizações sob um mesmo alias existente via requisições HTTP PUT sem exclusão prévia resulta em rejeição com erro `HTTP 409 Conflict`.

---

## 2. Requisitos Técnicos

### 2.1 Segregação Estrita de Aliases de Distribuição (Seção 4 de `profile.md`)
1. **Canal Estável (`refs/tags/v*`)**:
   - Exclusividade absoluta sobre a disponibilização de artefatos sob versões limpas (`X.Y.Z`) e sob o alias primário `latest`.
   - É terminantemente vedado a compilações de branches ou commits não tagueados sobrescrever ou registrar artefatos sob versões limpas ou sob `latest`.
2. **Canal Nightly/Desenvolvimento (`main` / `dev.XX`)**:
   - Publicação obrigatória sob a versão canônica exata do build (`X.Y.Z-dev.NN+build`).
   - Disponibilização sob os aliases de canal de desenvolvimento:
     - Alias primário: `latest-dev`
     - Alias nominal base: `${BASE_VERSION}-dev` (ex.: `0.1.0-dev`).
3. **Consumo de Versões Canônicas Recomendado**:
   - Em manifestos de build (`Cargo.toml`, etc.), a fixação em versões canônicas exatas (`=`) é formalmente **recomendada** (*SHOULD* / *DEVERIA*) para garantir imutabilidade e previsibilidade.
   - Não devem ser criadas travas restritivas sintáticas ou de linter que proíbam o consumo prático de aliases quando apropriado, já que a existência de aliases visa oferecer flexibilidade de consumo.

### 2.2 Idempotência de Publicação e Pre-Delete de Aliases (Seção 5 de `profile.md`)
1. **Pre-Delete de Aliases Mutáveis**:
   - Toda esteira de CI/CD que publica artefatos estáticos ou genéricos sob aliases reutilizáveis (`latest-dev`, `${BASE_VERSION}-dev`, `latest`) **DEVE** executar uma operação de limpeza prévia idempotente (ex.: `curl -s -X DELETE ... || true`) antes do envio via PUT.
   - Essa disciplina assegura que a forja receba o upload de forma limpa, prevenindo rejeições por conflito (`HTTP 409 Conflict`).

---

## 3. Plano de Testes (DD-TDD)

- **Fase 4 (Red Test)**: Criar `tests/test_distribution_channels_spec.sh` auditando `profile.md` quanto à presença das regras de:
  - Segregação de aliases (`latest-dev` e `${BASE_VERSION}-dev` no canal nightly).
  - Exclusividade de `latest` no canal estável.
  - Idempotência com pre-delete (`DELETE` prévio).
  - Recomendação (não trava) do uso de versões canônicas.
  Evidenciar que o teste falha contra o arquivo atual.
- **Fase 5 (Green Implement)**: Atualizar `profile.md`, compilar `site/` via `scripts/build_site.py` e atualizar `CHANGELOG.md`.
- **Fase 6 (Refactor)**: Garantir conformidade de estilo e formatação dos scripts e documentos.
- **Fase 7 (Mutation Test)**: Adicionar mutantes a `tests/test_distribution_channels_spec.sh` comprovando que qualquer desvio nas regras de canal ou idempotência é capturado.
- **Fase 8 (Quality Gate)**: Executar todas as suítes de testes locais e auditoria estrita `cccp check --strict`.
- **Fase 9 (Finish & Close)**: Fechamento com Laudo Textual de Resolução após autorização prévia da usuária.

---

## 4. Registro de Execução das Fases

- **Fase 3 (Spec)**: Especificação estruturada e versionada.
- **Fase 4 (Red Test)**: Criado `tests/test_distribution_channels_spec.sh` com 4 falhas comprovadas.
- **Fase 5 (Green Implement)**: Inseridas as cláusulas 4.5 e 5.1 no `profile.md`, recompilado o site e atualizado `CHANGELOG.md`.
- **Fase 6 (Refactor)**: Scripts de teste refatorados e alinhados aos padrões do repositório.
- **Fase 7 (Mutation Test)**: Implementados 3 mutantes sintéticos em `tests/test_distribution_channels_spec.sh` (omissão de `latest-dev`, remoção de pre-delete contra 409 e remoção de recomendação canônica). Todos os mutantes foram eliminados com 100% de precisão.
- **Fase 8 (Quality Gate)**: Todos os testes aprovados e auditoria GOST com 100% de conformidade estrita (`cccp check --strict`).
- **Fase 9 (Finish & Close)**: Ciclo concluído com sucesso.


