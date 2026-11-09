#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$REPO_DIR/profile.md"
RULES="$REPO_DIR/rules.toml"
LOCALES="$REPO_DIR/locales/pt-br.toml"
VERSION_FILE="$REPO_DIR/VERSION"

echo "=== [TEST] Auditoria de Conformidade Kollontai v2.1.0 (Ticket #9) ==="

FAILED=0

# 1. Frontmatter universal e subordinação a GOSPLAN
if grep -qF 'standard: "kollontai"' "$PROFILE" && \
   grep -qF 'tier: "tactical"' "$PROFILE" && \
   grep -qF 'standard: "gosplan"' "$PROFILE" && \
   grep -qF 'base_url: "https://gosplan.2lp.in/1.0.0/"' "$PROFILE"; then
    echo "  [PASS] Frontmatter universal com herança de gosplan conforme"
else
    echo "  [FAIL] Frontmatter universal ausente ou incorreto em profile.md"
    FAILED=1
fi

# 2. Ausência de termos proibidos (imperialismo / soberania)
if grep -qi "soberan" "$PROFILE"; then
    echo "  [FAIL] Termo proibido encontrado em profile.md"
    FAILED=1
else
    echo "  [PASS] Termos proibidos ausentes em profile.md"
fi

# 3. rules.toml presente e estruturado
if [ -f "$RULES" ]; then
    if grep -qF "[rules.KOLLONTAI-001]" "$RULES" && \
       grep -qF "gost." "$RULES"; then
        echo "  [PASS] rules.toml presente com regras KOLLONTAI e namespace gost.*"
    else
        echo "  [FAIL] rules.toml não possui regras KOLLONTAI ou namespace gost.*"
        FAILED=1
    fi
else
    echo "  [FAIL] rules.toml ausente"
    FAILED=1
fi

# 4. locales/pt-br.toml presente
if [ -f "$LOCALES" ] && grep -qF "[rules.KOLLONTAI-001]" "$LOCALES"; then
    echo "  [PASS] locales/pt-br.toml presente com catalogo de mensagens"
else
    echo "  [FAIL] locales/pt-br.toml ausente ou invalido"
    FAILED=1
fi

# 5. VERSION deve ser 2.1.0
if [ -f "$VERSION_FILE" ] && [ "$(cat "$VERSION_FILE" | tr -d '[:space:]')" = "2.1.0" ]; then
    echo "  [PASS] VERSION fixado em 2.1.0"
else
    echo "  [FAIL] VERSION nao e 2.1.0"
    FAILED=1
fi

# 6. Padrões Táticos de Conteinerização e Compose (#10)
if grep -qF "Padrões Táticos de Conteinerização Obrigatória" "$PROFILE" && \
   grep -qF 'user: "1000:1000"' "$PROFILE" && \
   grep -qF 'compose.yaml' "$PROFILE"; then
    echo "  [PASS] Padrões de conteinerização e compose presentes em profile.md"
else
    echo "  [FAIL] Padrões de conteinerização ausentes em profile.md"
    FAILED=1
fi

# 7. Regras KOLLONTAI-008 e KOLLONTAI-009 em rules.toml e locales
if grep -qF "[rules.KOLLONTAI-008]" "$RULES" && \
   grep -qF "[rules.KOLLONTAI-009]" "$RULES" && \
   grep -qF "[rules.KOLLONTAI-008]" "$LOCALES" && \
   grep -qF "[rules.KOLLONTAI-009]" "$LOCALES"; then
    echo "  [PASS] KOLLONTAI-008 e KOLLONTAI-009 presentes em rules.toml e locales"
else
    echo "  [FAIL] KOLLONTAI-008 ou KOLLONTAI-009 ausentes em rules.toml ou locales"
    FAILED=1
fi


# 6. Verificação de Mutantes
echo "=== [MUTATION] Verificando sensibilidade a mutações ==="
TMP_MUT=$(mktemp)
trap 'rm -f "$TMP_MUT"' EXIT

# Mutante 1: remoção de inherits_from
grep -v 'standard: "gosplan"' "$PROFILE" > "$TMP_MUT"
if grep -qF 'standard: "gosplan"' "$TMP_MUT"; then
    echo "  [FAIL] Mutante 1 (gosplan ausente) sobreviveu"
    FAILED=1
else
    echo "  [PASS] Mutante 1 (gosplan ausente) detectado"
fi

# Mutante 2: injeção de termo proibido
cat "$PROFILE" > "$TMP_MUT"
echo "soberania nacional" >> "$TMP_MUT"
if grep -qi "soberan" "$TMP_MUT"; then
    echo "  [PASS] Mutante 2 (termo proibido injetado) detectado"
else
    echo "  [FAIL] Mutante 2 não detectado"
    FAILED=1
fi

# Mutante 3: remoção de padrões de conteinerização
grep -v 'user: "1000:1000"' "$PROFILE" > "$TMP_MUT"
if grep -qF 'user: "1000:1000"' "$TMP_MUT"; then
    echo "  [FAIL] Mutante 3 (user desprivilegiado ausente) sobreviveu"
    FAILED=1
else
    echo "  [PASS] Mutante 3 (user desprivilegiado ausente) detectado"
fi

if [ $FAILED -ne 0 ]; then
    echo "=== [RESULT] FALHA NA AUDITORIA ==="
    exit 1
fi

echo "=== [RESULT] TODOS OS TESTES PASSARAM COM SUCESSO ==="
exit 0
