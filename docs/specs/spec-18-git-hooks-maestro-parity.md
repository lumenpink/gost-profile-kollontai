# Especificação do Ticket #18: Regra KOLLONTAI-018 (GIT-HOOKS-MAESTRO-PARITY)

## Objetivo
Formalizar no perfil tático Kollontai a verificação automatizada de conformidade dos git hooks locais com o maestro `cccp`, garantindo que todo repositório Git sob governança possua os hooks essenciais instalados e ativamente gerenciados para preservar a integridade dos commits, rastreabilidade de tickets e gates locais de pré-envio.

---

## Requisitos da Regra KOLLONTAI-018

1. **Identificador:** `KOLLONTAI-018`
2. **Nome Canônico:** `GIT-HOOKS-MAESTRO-PARITY`
3. **Severidade:** `error`
4. **Escopo:** `project`
5. **Critérios de Aceite:**
   - **Isenção de Ambientes sem Git:** Se o diretório/arquivo `.git` não existir (ex.: bundles exportados em CI fechada), a verificação é aprovada silenciosamente (`return true`).
   - **Descoberta do Diretório de Hooks:**
     - Inspeciona o arquivo `.git/config` caso exista.
     - Se `core.hooksPath` estiver definido, resolve o caminho indicado (absoluto ou relativo à raiz).
     - Se não definido, adota o caminho canônico padrão `.git/hooks`.
   - **Hooks Essenciais Auditados:**
     - `commit-msg`: Integridade de Conventional Commits e rastreabilidade de tickets.
     - `pre-commit`: Bloqueio de commits manuais sem o maestro.
     - `pre-push`: Execução compulsória do gate de CI local antes do envio.
   - **Validação de Cada Hook:**
     - O arquivo do hook DEVE existir no diretório de hooks correspondente.
     - O conteúdo do arquivo DEVE conter a assinatura de gestão do maestro (`cccp-hook-` ou `cccp hook`).
     - Scripts arbitrários não gerenciados ou arquivos de hook ausentes provocam reprovação imediata (`Fail`).
6. **Mensagens Prescritivas:**
   - `ERR_GIT_HOOK_MISSING`: *"Git hook '{hook}' is missing. Run 'cccp hook install' to install maestro hooks."*
   - `ERR_GIT_HOOK_NOT_MANAGED`: *"Git hook '{hook}' is not managed by the cccp maestro. Run 'cccp hook install --force' to synchronize hooks."*

---

## Árvore de Decisões e Registro Arquitetural (para a Natasha)

1. **Bypass em ausência de `.git`:**
   - *Contexto:* Ambientes de auditoria em contêineres e tarballs de release exportados não contêm metadados Git.
   - *Decisão:* Retornar aprovação imediata para evitar falsos positivos fora de repositórios de trabalho ativos.

2. **Resolução de `core.hooksPath`:**
   - *Contexto:* Projetos podem adotar diretórios de hooks versionados (ex.: `.gost/hooks` ou `.hooks`).
   - *Decisão:* Fazer parsing simples de `hooksPath` em `.git/config`, caindo para `.git/hooks` como fallback canônico.

3. **Verificação por Assinatura vs Hash Exato:**
   - *Contexto:* Stubs de hook variam de versão para versão do `cccp` (ex.: `# cccp-hook-version: X.Y.Z`).
   - *Decisão:* Procurar tokens de controle (`cccp-hook-` ou `cccp hook`) em vez de exigir hash SHA256 estático, garantindo interoperabilidade entre diferentes releases do maestro.
   - *Alternativa Descartada:* Exigir hash exato bloquearia auditorias toda vez que o binário do maestro fosse atualizado na máquina da desenvolvedora.

---

## Status do Ciclo
- **Fase 9 Concluída:** Regra implementada, documentada e verificada por testes de conformidade e mutação.
