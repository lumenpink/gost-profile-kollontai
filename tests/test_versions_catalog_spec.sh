#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [TEST] Auditoria do Catálogo versions.json e Rotas Versionadas (Kollontai #20) ==="

check_versions_catalog() {
    local root="$1"
    local failed=0

    # 1. site/versions.json existe e é válido
    local vjson="$root/site/versions.json"
    if [ ! -f "$vjson" ]; then
        echo "  [FAIL] site/versions.json não encontrado"
        failed=1
    else
        if grep -q '"latest": "2.1.0"' "$vjson" && grep -q '"standard": "kollontai"' "$vjson"; then
            true
        else
            echo "  [FAIL] site/versions.json não declara latest 2.1.0 ou standard kollontai"
            failed=1
        fi
    fi

    # 2. site/RULES.md e site/RULES.toml na raiz
    if [ ! -f "$root/site/RULES.md" ]; then
        echo "  [FAIL] site/RULES.md ausente na raiz do site"
        failed=1
    fi
    if [ ! -f "$root/site/RULES.toml" ]; then
        echo "  [FAIL] site/RULES.toml ausente na raiz do site"
        failed=1
    fi

    # 3. site/2.1.0/RULES.md e site/2.1.0/RULES.toml no subdiretório versionado
    if [ ! -f "$root/site/2.1.0/RULES.md" ]; then
        echo "  [FAIL] site/2.1.0/RULES.md ausente no subdiretório versionado"
        failed=1
    fi
    if [ ! -f "$root/site/2.1.0/RULES.toml" ]; then
        echo "  [FAIL] site/2.1.0/RULES.toml ausente no subdiretório versionado"
        failed=1
    fi

    return $failed
}

if check_versions_catalog "$REPO_ROOT"; then
    echo "  [PASS] Catálogo versions.json e rotas versionadas estão em conformidade!"
else
    echo "❌ [FAIL] Auditoria falhou (comportamento RED esperado)."
    exit 1
fi
