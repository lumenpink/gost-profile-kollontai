# Especificação Técnica — Ticket #24: Formalizar Contratos de CD e Fronteira e Purgar Perfil Lumen

## 1. Contexto & Motivação
O perfil Kollontai especifica os contratos de engenharia e interfaces táticas universais do ecossistema GOST. Com a formalização dos 5 papéis abstratos, é mandatório positivar os contratos de *Entrega Contínua e Despacho de Artefatos (CD)* e de *Controlador de Fronteira e Sincronia de Espelhos*. Adicionalmente, deve-se expurgar todas as referências residuais à nomenclatura legada "perfil Lumen".

## 2. Decisão Arquitetural
- **Formalização dos Contratos Táticos de CD e Fronteira:**
  - *Subseção 1.4 (Entrega Contínua):* Operações funcionais de ingestão de staging efêmero, validação SHA-256 e assinaturas, despacho a storage público, purga de staging na forja, deploy SSH com rollback e propagação em cascata.
  - *Subseção 1.5 (Fronteira):* Sincronização passiva de espelhos com paridade de metadados, reconciliação anti-drift de webhooks, quarentena de PRs em `inbox/*` e limpeza de branches órfãs.
- **Expurgo do Termo Legado:**
  - Substituição sistemática de "perfil Lumen" por "perfil Lilya" em toda a documentação e metadados.

## 3. Alternativas Descartadas (Para a Natasha)
- **Alternativa Descartada 1: Embutir tarefas de CD e deploy na ferramenta de ciclo local.**
  *Motivo do Descarte:* Fere o princípio de hermeticidade e isolamento. Builds pesados e deploys via SSH devem operar em containers na esteira ou nós dedicados, nunca no fluxo de trabalho de commit local.
- **Alternativa Descartada 2: Manter a menção a "perfil Lumen" para fins de histórico.**
  *Motivo do Descarte:* Gera confusão de taxonomia na resolução de perfis (`GOST_PROFILE_URL`). A norma positiva unicamente Lilya.

## 4. Verificação
- Verificação de ausência de "perfil lumen" via grep insensível a maiúsculas.
- Validação estrutural de `profile.md`.
