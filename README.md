# gost-profile-kollontai

Perfil de Implementação de Infraestrutura e Ferramental Kollontai para a norma **[GOST](https://codeberg.org/lumenpink/gost)**.

## 📌 Sobre

Este repositório contém a especificação concreta das escolhas de tecnologia, automação, forja de código, testes, CI/CD e implantação adotadas no perfil Kollontai.

## 🚀 Como Usar no Padrão GOST

Em projetos que adotam o padrão GOST sob o perfil Kollontai, declare a URL deste perfil no arquivo `GOSTVER` na raiz do seu repositório:

```bash
# GOSTVER — Declaração de Conformidade com o Padrão GOST
GOST_VERSION="1.3.0"
GOST_PROFILE_URL="https://kollontai.2lp.in/profile.md"
GOST_LANGUAGES="shell,rust,php"
```

O CLI `cccp` utiliza essa diretiva para auditar e sincronizar as regras de conformidade com o ecossistema.

## 📄 Conteúdo do Perfil

O documento canônico completo está publicado na borda em:
👉 **[kollontai.2lp.in](https://kollontai.2lp.in)** (HTML) ou **[`kollontai.2lp.in/profile.md`](https://kollontai.2lp.in/profile.md)** (Raw Markdown)
Localmente no repositório: **[`profile.md`](./profile.md)**

Tópicos cobertos:
1. Forja de código e repositórios remotos (Codeberg/Forgejo)
2. Gestão de commits e hooks (`cccp`)
3. Publicação web e documentação (`*.2lp.in` via Cloudflare Workers & Codeberg Pages)
4. Stack e ferramental padrão de testes (ShellSpec, Cargo/Clippy/Tarpaulin, Pest/Infection/PHPStan, Playwright)
5. Pipeline de CI/CD (`.forgejo/workflows/ci.yml` e validação local via `act`)
6. Registro no catálogo central (`~/src/catalog.json`)
7. Ciclo DD-TDD e comandos de agentes de IA (`DCPD`, `DCP`, `PLAN`, `TDD`, etc.)
8. Internacionalização (i18n, RTL e matriz das 10 línguas)
9. Banners e cards sociais (Safe Zone 4:3)
10. Arquitetura pragmática & estrutura de diretórios
11. Padrões de sistema e containers (XDG, configs em env, Dockerfiles multi-stage)

## ⚖️ Licença

Licenciado sob [Creative Commons Atribuição-CompartilhaIgual 4.0 Internacional (CC-BY-SA 4.0)](./LICENSE).
