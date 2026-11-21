# Especificação do Ticket #29: Delegar Deploy do Site ao Kombinat via Generic Packages

## 1. Contexto e Motivação
O workflow `.forgejo/workflows/ci.yml` publicava diretamente no Cloudflare Workers (`npx wrangler deploy`). Com o Kombinat orquestrando entregas a partir dos hooks da Gambi, a CI deve publicar `site/` no Generic Package Registry da forja.

## 2. Requisitos
1. Substituir `npx wrangler deploy` por `cccp package upload site` em `.forgejo/workflows/ci.yml` usando `gambi.2lp.in/lumen/gost-ci-shell:latest`.
2. Atualizar `tests/test_ci_deploy_contract.sh` para exigir `cccp package upload site` e proibir `wrangler` / `worktree add --orphan`.
3. Alinhar `.gost/delivery.toml` (`dir = "site"`).

## 3. Árvore de Decisões (para a Natasha)
- **Zero segredos externos na CI:** Remover `CLOUDFLARE_API_TOKEN` da CI mantém as credenciais de Cloudflare confinadas ao Kombinat.
