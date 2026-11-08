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

if [ $FAILED -ne 0 ]; then
    echo "=== [RESULT] FALHA NA AUDITORIA ==="
    exit 1
fi

echo "=== [RESULT] TODOS OS TESTES PASSARAM COM SUCESSO ==="
exit 0
