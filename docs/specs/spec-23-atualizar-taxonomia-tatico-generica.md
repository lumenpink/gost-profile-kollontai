# Especificação Técnica — Ticket #23: Atualizar Taxonomia Tático-Genérica no Perfil Kollontai

## 1. Contexto & Motivação
O perfil Kollontai representa o nível tático de engenharia do padrão GOST. Conforme a hierarquia normativa estabelecida, o nível tático deve formalizar os contratos funcionais universais e interfaces abstratas de engenharia (CLI de ciclo de vida local, CLI de forjas e tickets, validador normativo de conformidade), sem conter referências nominais diretas aos binários concretos de infraestrutura (que pertencem estritamente à camada operacional Lilya).

## 2. Decisão Arquitetural
- **Formalização dos Três Contratos Táticos:**
  1. *Contrato da Ferramenta de Ciclo de Vida Local (Maestro Local):* Especifica comandos de branches, transições DD-TDD, commits convencionais rastreados, testes de mutação restritos ao diff, fast-hygiene, merge com verificação de laudo e push.
  2. *Contrato da Ferramenta de Governança de Forja e Abastecimento:* Especifica comandos de criação, consulta, triagem assistida e encerramento de tickets na forja remota, além de inicialização e catálogo.
  3. *Contrato do Validador Normativo de Conformidade:* Especifica a interface de avaliação (`check`), flags de escopo, código semântico de retorno (0 para sucesso, 1 para violação) e testes de integridade (`test`, `eval`).
- **Expurgo Nominal:** Ausência categórica de nomes de binários operacionais concretos (`gossnab`, `lunokhod`) no documento tático.

## 3. Alternativas Descartadas (Para a Natasha)
- **Alternativa Descartada 1: Descrever nomes operacionais (`gossnab`, `lunokhod`) na camada tática.**
  *Motivo do Descarte:* Fere a separação de camadas. A camada tática deve permanecer reutilizável e desacoplada da infraestrutura particular da estação de trabalho.
- **Alternativa Descartada 2: Manter apenas a tabela antiga e monolítica de comandos do `cccp`.**
  *Motivo do Descarte:* Escondia a divisão de competências táticas entre ciclo local, forjas/abastecimento e motor de auditoria.

## 4. Verificação
- Verificação de ausência de nomes operacionais concretos (`gossnab`, `lunokhod`) em `profile.md`.
- Validação das seções e formatação de `profile.md`.
