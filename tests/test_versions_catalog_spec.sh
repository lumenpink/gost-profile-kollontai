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

    # 2. Ausência estrita de artefatos normativos soltos na raiz de site/
    if [ -f "$root/site/RULES.md" ] || [ -f "$root/site/RULES.toml" ] || [ -f "$root/site/rules.toml" ] || [ -f "$root/site/profile.md" ] || [ -f "$root/site/kollontai.md" ]; then
        echo "  [FAIL] Artefatos normativos soltos na raiz de site/ encontrados (devem residir exclusivamente em site/{version}/)"
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

echo "=== [MUTATION] Verificando sensibilidade dos testes a mutações ==="

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/site/2.1.0"
cp "$REPO_ROOT/site/versions.json" "$TMP_DIR/site/"
cp "$REPO_ROOT/site/RULES.md" "$TMP_DIR/site/"
cp "$REPO_ROOT/site/RULES.toml" "$TMP_DIR/site/"
cp "$REPO_ROOT/site/2.1.0/RULES.md" "$TMP_DIR/site/2.1.0/"
cp "$REPO_ROOT/site/2.1.0/RULES.toml" "$TMP_DIR/site/2.1.0/"

# Mutante 1: Versão latest alterada
sed -E 's/"latest": "2.1.0"/"latest": "9.9.9"/' "$TMP_DIR/site/versions.json" > "$TMP_DIR/site/versions_mut.json"
mv "$TMP_DIR/site/versions_mut.json" "$TMP_DIR/site/versions.json"
if check_versions_catalog "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 1 (latest divergente) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 1 (latest divergente) capturado com precisão"
fi

# Restaura versions.json
cp "$REPO_ROOT/site/versions.json" "$TMP_DIR/site/"

# Mutante 2: Remoção de RULES.md na raiz
rm "$TMP_DIR/site/RULES.md"
if check_versions_catalog "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 2 (remoção de RULES.md) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 2 (remoção de RULES.md) capturado com precisão"
fi

# Restaura RULES.md
cp "$REPO_ROOT/site/RULES.md" "$TMP_DIR/site/"

# Mutante 3: Remoção de RULES.toml em 2.1.0
rm "$TMP_DIR/site/2.1.0/RULES.toml"
if check_versions_catalog "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 3 (remoção de 2.1.0/RULES.toml) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 3 (remoção de 2.1.0/RULES.toml) capturado com precisão"
fi

echo "✔ [GREEN TEST] Todas as asserções e mutações foram aprovadas com 100% de conformidade."
exit 0
