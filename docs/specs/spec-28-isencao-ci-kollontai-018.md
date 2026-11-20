# Especificação do Ticket #28: Isenção de CI Hermética na Regra KOLLONTAI-018

## 1. Contexto e Motivação
A regra `KOLLONTAI-018` (`GIT-HOOKS-MAESTRO-PARITY`) assegura que repositórios Git sob governança GOST possuam os hooks de commit e push gerenciados pelo maestro `cccp`.
Entretanto, em esteiras automatizadas de CI/CD (GitHub Actions, Forgejo Actions), a ação padrão de checkout (`actions/checkout@v4`) clona o repositório git gerando `.git/`, porém sem instanciar hooks locais em `.git/hooks/`.
Como contêineres e runners de CI são ambientes efêmeros de build/auditoria onde commits manuais de desenvolvedores não ocorrem, a ausência de hooks locais disparava falsos positivos bloqueantes durante a execução de `cccp check --strict`.

## 2. Requisitos da Correção
1. A regra `KOLLONTAI-018` deve verificar se o ambiente de execução é uma esteira de Integração Contínua identificável via variáveis de ambiente padrão:
   - `CI == "true"`
   - `GITHUB_ACTIONS == "true"`
   - `FORGEJO_ACTIONS == "true"`
2. Caso qualquer dessas variáveis esteja ativa, a checagem é aprovada imediatamente (`return true`).
3. Em ambientes locais normais de desenvolvimento (sem variáveis de CI ativas), a checagem estrita dos githooks do maestro permanece integralmente em vigor.

## 3. Árvore de Decisões e Registro Arquitetural (para a Natasha)
1. **Detecção no Nível da Regra vs Exigência de `cccp hook -i` nos Workflows:**
   - *Alternativa Considerada:* Exigir que todo workflow de CI no ecossistema execute `cccp hook -i` antes de `cccp check --strict`.
   - *Motivo do Descarte:* Fragilidade de governança. Se um novo repositório esquecer de invocar `cccp hook -i` em sua esteira, a CI quebrará desnecessariamente por uma checagem de hook local do desenvolvedor em um container descartável. A salvaguarda deve estar primariamente na regra canônica.
2. **Uso de `os.getenv`:**
   - *Contexto:* O interpretador Lua do `lunokhod` e as engines embutidas expõem a tabela padrão `os.getenv`.
   - *Decisão:* Utilizar `if os and os.getenv and (os.getenv("CI") == "true" or os.getenv("GITHUB_ACTIONS") == "true" or os.getenv("FORGEJO_ACTIONS") == "true") then return true end` para compatibilidade determinística.
