# Especificação do Ticket #16: Disponibilizar rules.toml em site/rules.toml

## Objetivo
Garantir que as regras declarativas em `rules.toml` do perfil Kollontai estejam acessíveis via HTTP no caminho `/rules.toml` do domínio de publicação (`kollontai.2lp.in`), sincronizando `rules.toml` para `site/rules.toml`.

## Requisitos
1. O arquivo `site/rules.toml` deve existir e seu conteúdo deve ser idêntico ao de `rules.toml` na raiz.
2. Os testes automatizados em `tests/test_kollontai_v2_1_spec.sh` devem auditar a existência e a paridade estrita de `site/rules.toml`.
3. Deve haver mutante dedicado para assegurar que qualquer alteração em `rules.toml` sem sincronização em `site/rules.toml` seja barrada.
