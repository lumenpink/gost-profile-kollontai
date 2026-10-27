#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== [TEST] Auditoria de Conformidade Kollontai GOST 2.0.0 ==="

FAILED=0

# 1. Editorconfig
if [ -f "$REPO_DIR/.editorconfig" ]; then
    echo "  [PASS] Arquivo .editorconfig presente na raiz"
else
    echo "  [FAIL] Arquivo .editorconfig ausente na raiz"
    FAILED=1
fi

# 2. Especificação modular de linguagem
if [ -s "$REPO_DIR/.gost/languages/shell.md" ]; then
    echo "  [PASS] Especificação .gost/languages/shell.md presente e não-vazia"
else
    echo "  [FAIL] Especificação .gost/languages/shell.md ausente ou vazia"
    FAILED=1
fi

# 3. Norma Base e target_gost em profile.md
if grep -qF 'target_gost: "2.0.0"' "$REPO_DIR/profile.md"; then
    echo "  [PASS] target_gost em profile.md atualizado para 2.0.0"
else
    echo "  [FAIL] target_gost em profile.md desatualizado (esperado 'target_gost: \"2.0.0\"')"
    FAILED=1
fi

# 4. GOSTVER
if grep -qF 'GOST_VERSION="2.0.0"' "$REPO_DIR/GOSTVER"; then
    echo "  [PASS] GOSTVER atualizado para 2.0.0"
else
    echo "  [FAIL] GOSTVER não contém GOST_VERSION=\"2.0.0\""
    FAILED=1
fi

# 5. Expurgo do Watchtower (Regra GOST-15)
if grep -qi "watchtower" "$REPO_DIR/profile.md"; then
    echo "  [FAIL] Watchtower ainda referenciado em profile.md"
    FAILED=1
else
    echo "  [PASS] Watchtower expurgado com sucesso de profile.md"
fi

# 6. Expurgo do act no pre-push
if grep -qi "act -j test" "$REPO_DIR/profile.md"; then
    echo "  [FAIL] act em pre-push ainda exigido em profile.md"
    FAILED=1
else
    echo "  [PASS] act em pre-push expurgado de profile.md"
fi

# 7. Ausência de acoplamento pessoal a lumenpink no profile.md
if grep -qi "autor: lumenpink" "$REPO_DIR/profile.md"; then
    echo "  [FAIL] Acoplamento nominal a lumenpink em profile.md"
    FAILED=1
else
    echo "  [PASS] Perfil desacoplado de identidades nominais"
fi

# 8. Mutation Tests
echo "=== [MUTATION] Verificando sensibilidade a mutações ==="
TMP_MUTANT=$(mktemp)
trap 'rm -f "$TMP_MUTANT"' EXIT

grep -v 'target_gost: "2.0.0"' "$REPO_DIR/profile.md" > "$TMP_MUTANT"
if grep -qF 'target_gost: "2.0.0"' "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante A falhou ao ser gerado"
    FAILED=1
else
    echo "  [PASS] Mutante A (versão revertida) detectado com sucesso"
fi

if [ $FAILED -ne 0 ]; then
    echo "❌ [FAIL] Auditoria ou mutantes falharam."
    exit 1
fi

echo "✔ [GREEN TEST] Auditoria e mutantes aprovados com 100% de conformidade."
exit 0
