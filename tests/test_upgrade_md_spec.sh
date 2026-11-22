#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [TEST] Validação do Artefato site/2.2.0/UPGRADE.md (Ticket #30) ==="

check_upgrade_md() {
    local root="$1"
    local failed=0
    local up_file="$root/site/2.2.0/UPGRADE.md"

    # 1. Existência e não-vazio
    if [ ! -f "$up_file" ]; then
        echo "  [FAIL] site/2.2.0/UPGRADE.md não encontrado"
        return 1
    fi

    # 2. Ausência na raiz de site/ (fail-fast, apenas em subdiretório versionado)
    if [ -f "$root/site/UPGRADE.md" ]; then
        echo "  [FAIL] site/UPGRADE.md solto na raiz proibido (deve residir exclusivamente em site/{version}/)"
        failed=1
    fi

    # 3. Validação do Frontmatter YAML estrito
    python3 -c '
import sys
with open("'$up_file'", "r", encoding="utf-8") as f:
    content = f.read()

assert content.startswith("---\n"), "UPGRADE.md deve iniciar com frontmatter delimitado por ---"
parts = content.split("---\n", 2)
assert len(parts) >= 3, "Frontmatter YAML malformado"
fm = parts[1]

assert "standard: \"kollontai\"" in fm, "standard deve ser kollontai"
assert "tier: \"tactical\"" in fm, "tier deve ser tactical"
assert "version: \"2.2.0\"" in fm, "version deve ser 2.2.0"
assert "replaces: \"2.1.0\"" in fm, "replaces deve ser 2.1.0"
assert "valid_since: \"2.1.0\"" in fm, "valid_since deve ser 2.1.0"
assert "breaking: true" in fm, "breaking deve ser true"

assert "Quebras de Contrato" in content, "Seção Quebras de Contrato ausente"
assert "Mutação de Regras" in content, "Seção Mutação de Regras ausente"
assert "Ações Manuais" in content, "Seção Ações Manuais ausente"
assert "Ações Automatizáveis" in content, "Seção Ações Automatizáveis ausente"
assert "1.100.0" in content, "Menção ao rustc 1.100.0 ausente"
' || failed=1

    return $failed
}

if check_upgrade_md "$REPO_ROOT"; then
    echo "  [PASS] site/2.2.0/UPGRADE.md está em estrita conformidade normativa!"
else
    echo "❌ [FAIL] Auditoria falhou (comportamento RED esperado na Fase 4)."
    exit 1
fi

echo "=== [MUTATION] Verificando sensibilidade dos testes de UPGRADE.md a mutações ==="

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/site/2.2.0"
cp "$REPO_ROOT/site/2.2.0/UPGRADE.md" "$TMP_DIR/site/2.2.0/"

# Mutante 1: Omissão de valid_since no frontmatter
grep -v 'valid_since:' "$TMP_DIR/site/2.2.0/UPGRADE.md" > "$TMP_DIR/site/2.2.0/UPGRADE_mut.md"
mv "$TMP_DIR/site/2.2.0/UPGRADE_mut.md" "$TMP_DIR/site/2.2.0/UPGRADE.md"
if check_upgrade_md "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 1 (omissão de valid_since) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 1 (omissão de valid_since) capturado com precisão"
fi

# Restaura UPGRADE.md
cp "$REPO_ROOT/site/2.2.0/UPGRADE.md" "$TMP_DIR/site/2.2.0/"

# Mutante 2: Omissão de replaces no frontmatter
grep -v 'replaces:' "$TMP_DIR/site/2.2.0/UPGRADE.md" > "$TMP_DIR/site/2.2.0/UPGRADE_mut.md"
mv "$TMP_DIR/site/2.2.0/UPGRADE_mut.md" "$TMP_DIR/site/2.2.0/UPGRADE.md"
if check_upgrade_md "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 2 (omissão de replaces) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 2 (omissão de replaces) capturado com precisão"
fi

# Restaura UPGRADE.md
cp "$REPO_ROOT/site/2.2.0/UPGRADE.md" "$TMP_DIR/site/2.2.0/"

# Mutante 3: Injeção de UPGRADE.md solto na raiz de site/
touch "$TMP_DIR/site/UPGRADE.md"
if check_upgrade_md "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 3 (UPGRADE.md solto na raiz) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 3 (UPGRADE.md solto na raiz) capturado com precisão"
fi
rm -f "$TMP_DIR/site/UPGRADE.md"

# Mutante 4: Remoção de seção obrigatória ("Quebras de Contrato")
grep -v 'Quebras de Contrato' "$TMP_DIR/site/2.2.0/UPGRADE.md" > "$TMP_DIR/site/2.2.0/UPGRADE_mut.md"
mv "$TMP_DIR/site/2.2.0/UPGRADE_mut.md" "$TMP_DIR/site/2.2.0/UPGRADE.md"
if check_upgrade_md "$TMP_DIR" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 4 (remoção de Quebras de Contrato) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 4 (remoção de Quebras de Contrato) capturado com precisão"
fi

echo "✔ [GREEN TEST] Todas as asserções e mutações do contrato UPGRADE.md foram aprovadas!"
exit 0
