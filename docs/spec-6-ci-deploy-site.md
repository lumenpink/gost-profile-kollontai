# Especificação Técnica — Ticket #6: Remoção de Fallback Quebrado de Pages e Deploy Cloudflare

**Norma de Referência:** GOST 2.0.0  
**Perfil:** Kollontai (`https://kollontai.2lp.in/profile.md`)  
**Data:** 2026-10-28  
**Status:** Aprovado / Em Implementação (Fase 3 DD-TDD)  

---

## 1. Contexto & Motivação

O job `Deploy Documentation Site` no workflow `.forgejo/workflows/ci.yml` falhava na execução em containers do runner (Debian Bookworm com Git 2.39.5) com o seguinte erro:
```text
error: unknown option `orphan'
usage: git worktree add [-f] [--detach] [--checkout] [--lock [--reason <string>]]
```

A flag `--orphan` para `git worktree add` é exclusiva do Git 2.42+. Além disso, a forja Codeberg foi descontinuada e o site estático `kollontai.2lp.in` é servido nativamente via Cloudflare Workers (`wrangler.jsonc` com assets em `./site`).

---

## 2. Requisitos Técnicos

1. **Expurgo da Etapa de Pages Quebrada:**
   - Remover integralmente o step `Deploy to Codeberg Pages (Stateless Orphan Force Push)` do arquivo `.forgejo/workflows/ci.yml`.
   - Nenhuma invocação de `worktree add --orphan` ou push para a branch `pages` deve permanecer no workflow.

2. **Consolidação do Deploy Cloudflare Workers:**
   - Manter a etapa `Deploy to Cloudflare Workers (kollontai.2lp.in)` com verificação prévia da presença dos tokens (`CLOUDFLARE_API_TOKEN` e `CLOUDFLARE_ACCOUNT_ID`).
   - Se as credenciais estiverem ausentes no runner, emitir aviso amigável sem interromper a esteira com erro.

3. **Validação de Integridade do Site:**
   - Assegurar que os arquivos canônicos `site/index.html`, `site/profile.md`, `site/kollontai.md` e `site/_headers` continuam sendo rigorosamente auditados pelo job `test`.
