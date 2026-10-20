# Especificação Técnica — Ticket #3: Atualização do Perfil Kollontai para GOST 1.5.0

**Norma de Referência:** GOST 1.5.0  
**Perfil:** Kollontai (`https://kollontai.2lp.in/profile.md`)  
**Data:** 2026-10-20  
**Status:** Aprovado / Em Implementação  

---

## 1. Contexto & Motivação

O perfil **Kollontai** é o perfil base soberano que serve de fundação para toda a infraestrutura técnica e perfis derivados (incluindo o perfil Lumen). Com o lançamento do **GOST 1.5.0**, faz-se necessária a sincronização integral do repositório:
1. Elevação da declaração de conformidade normativa em `GOSTVER` e `profile.md` para `1.5.0`.
2. Regularização anatômica da raiz com a inclusão de `.editorconfig`.
3. Sincronização das especificações canônicas de linguagem em `.gost/languages/shell.md`.
4. Recompilação da especificação cascateada consolidada em `.gost/GOST.md`.
5. Validação rigorosa via `cccp check --strict` atingindo 100% de conformidade Gosplan.

---

## 2. Requisitos de Conformidade

### 2.1 Anatomia da Raiz
- Presença obrigatória de `.editorconfig` conforme o padrão GOST-02.

### 2.2 Sincronização e Linguagens
- Execução de `cccp sync` para hidratar `.gost/languages/shell.md` com a especificação oficial da norma 1.5.0.

### 2.3 Perfil Kollontai (`profile.md`)
- Atualização do cabeçalho normativo: `**Norma Base:** GOST 1.5.0`.
- Montagem limpa em `.gost/GOST.md` via `cccp profile assemble`.
