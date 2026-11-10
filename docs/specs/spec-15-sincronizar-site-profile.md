# Spec #15: Sincronização de site/profile.md e Expurgo de Termos Proibidos

## 1. Contexto e Motivação
A publicação do perfil Kollontai via Cloudflare Workers (`kollontai.2lp.in`) utiliza o diretório `./site/` como raiz de distribuição estática.
Os arquivos `site/profile.md`, `site/kollontai.md` e `site/index.html` mantinham termos imperialistas ("soberania") e versão desatualizada (2.0.0), violando a auditoria de cascata normativa do `cccp`.

## 2. Escopo
1. Sincronizar integralmente `site/profile.md` e `site/kollontai.md` com o arquivo canônico `profile.md` v2.1.0.
2. Purgar referências a "Soberania" em `site/index.html`, substituindo por "Centralidade da Forja Primária".
3. Expandir a suíte de conformidade para auditar o diretório `site/` contra termos proibidos e paridade de `site/profile.md`.
