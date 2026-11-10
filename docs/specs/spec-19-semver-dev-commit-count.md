# Especificação do Ticket #19: Convenção SemVer de Commit Count no Canal Dev

## Objetivo
Formalizar no perfil tático Kollontai a especificação técnica do formato SemVer 2.0 para compilações do canal de desenvolvimento (`dev`), definindo inequivocamente a semântica do componente `{n}` como a distância em commits a partir da tag estável mais recente.

---

## 1. Contexto e Problema Resolvido
No perfil Kollontai (Seção 4.5), o padrão de versão para o canal `dev` é definido como:
```text
x.y.z-dev.{n}+{YYYYMMDD}.{commit}
```
Historicamente, geradores ou scripts de esteira poderiam interpretar erroneamente o parâmetro `{n}` como o número absoluto acumulado de commits do repositório (`git rev-list --count HEAD`), o que:
1. Desalinha a relação de proximidade semântica com a tag base `vX.Y.Z`.
2. Gera saltos artificiais de numeração em projetos antigos (ex.: `-dev.1482`).
3. Dificulta a percepção do usuário e da ferramenta sobre quantos incrementos de trabalho efetivamente se passaram desde o último release estável.

---

## 2. Requisitos Normativos

1. **Definição de `{n}`:**
   - `{n}` representa estritamente o número de commits entre a tag estável base `vX.Y.Z` e o `HEAD` corrente.
   - Cálculo canônico:
     ```sh
     git rev-list vX.Y.Z..HEAD --count
     ```
   - Alternativamente derivado de `git describe --tags --match "v*.*.*" --long`.
2. **Caso de Coincidência Exata:**
   - Se `HEAD` apontar exatamente para o commit da tag estável `vX.Y.Z`, `{n}` é `0`.
3. **Caso de Ausência de Tag Anterior (Gênese):**
   - Caso o repositório ainda não possua nenhuma tag anterior no formato `v*.*.*`, `{n}` recai sobre o total de commits da raiz até `HEAD` (`git rev-list --count HEAD`), com base `0.0.0-dev.{n}`.
4. **Build Metadata (`+{YYYYMMDD}.{commit}`):**
   - Data no formato ISO sem separadores `YYYYMMDD` (UTC).
   - Identificador do commit abreviado a 7 ou 8 caracteres hexadecimais (`git rev-parse --short HEAD`).
5. **Localização no Perfil:**
   - Documentado na Seção 4.5 de `profile.md` e espelhado em `site/profile.md`.

---

## 3. Árvore de Decisões e Registro Arquitetural (para a Natasha)

1. **Distância da Estável vs Contagem Global:**
   - *Contexto:* Por que não usar o total absoluto de commits do repositório?
   - *Decisão:* A contagem absoluta contamina a semântica de pré-lançamento. Um projeto com 2.000 commits que acaba de lançar a `v2.0.0` não pode gerar uma versão subsequente `2.0.1-dev.2001`, pois daria a ilusão de que 2.000 alterações ocorreram entre a `v2.0.0` e o próximo patch. A distância da estável (`v2.0.0..HEAD`) reinicia o contador para `1`, mantendo a semântica de proximidade.
   - *Alternativa Descartada:* Timestamp Unix puro no pré-release (prejudica ordenação simples por SemVer e legibilidade humana).

2. **Sincronização Bidirecional dos Perfis:**
   - *Decisão:* `profile.md` e `site/profile.md` devem manter paridade de conteúdo, com validação obrigatória no script de conformidade.

---

## 4. Status do Ciclo
- **Fase 3:** Especificação formalizada.
