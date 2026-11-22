---
standard: "kollontai"
tier: "tactical"
version: "2.2.0"
replaces: "2.1.0"
valid_since: "2.1.0"
breaking: true
---

# Guia de Migração: Perfil Kollontai 2.1.0 ➔ 2.2.0

Este documento formaliza as alterações contratuais e os passos operacionais para elevar um repositório regulado da versão `2.1.0` para a versão `2.2.0` do perfil tático de engenharia Kollontai.

---

## 1. Quebras de Contrato (*Breaking Changes*)

1. **Elevação do Requisito Mínimo da Toolchain Rust:**
   - O compilador mínimo obrigatório para projetos na stack `rust` passa a ser `rustc >= 1.100.0`. Versões anteriores (como `1.99.0`) deixam de ser suportadas pelas imagens de compilação e pelo padrão de hermeticidade.
2. **Versionamento Imutável de Especificações de Linguagem:**
   - As especificações táticas de linguagem passam a ser ancoradas na rota imutável `https://kollontai.2lp.in/2.2.0/languages/<lang>.md`.

---

## 2. Mutação de Regras Declarativas (`.rules/rules.toml`)

- **Modificadas (~):**
  - Atualização dos requisitos táticos de compilação da stack `rust` nas especificações normativas (`languages/rust.md` e `profile.md`).

---

## 3. Ações Manuais Necessárias

1. **Atualizar a Toolchain Local do Rust:**
   ```sh
   rustup update stable
   # ou fixar explicitamente
   rustup default 1.100.0
   ```
2. **Verificar Versão do rustc:**
   ```sh
   rustc --version
   # Deve exibir rustc 1.100.0 ou superior
   ```
3. **Atualizar Imagens Docker / CI:**
   - Em `Dockerfile` ou pipelines CI, atualizar a imagem base para imagens com Rust 1.100.0 (ex.: `gost-ci-cross:latest` atualizada ou `rust:1.100-alpine`).

---

## 4. Ações Automatizáveis via Ferramenta

Execute os comandos do Maestro local para atualizar as definições normativas e sincronizar o perfil:
```sh
cccp profile set kollontai
cccp profile assemble
```
Após a montagem, execute a auditoria rigorosa de conformidade:
```sh
cccp check --strict
```
