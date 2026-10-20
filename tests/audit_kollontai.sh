#!/bin/bash
set -eo pipefail

REPO_DIR="/home/lumen/src/gost-profile-kollontai"

echo "=== [TEST] Auditoria de Conformidade Kollontai GOST 1.5.0 ==="

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

# 3. Norma Base em profile.md
if grep -qF '**Norma Base:** GOST `1.5.0`' "$REPO_DIR/profile.md"; then
    echo "  [PASS] Norma Base em profile.md atualizada para 1.5.0"
else
    echo "  [FAIL] Norma Base em profile.md desatualizada (esperado 'GOST \`1.5.0\`')"
    FAILED=1
fi

# 4. GOSTVER
if grep -qF 'GOST_VERSION="1.5.0"' "$REPO_DIR/GOSTVER"; then
    echo "  [PASS] GOSTVER atualizado para 1.5.0"
else
    echo "  [FAIL] GOSTVER não contém GOST_VERSION=\"1.5.0\""
    FAILED=1
fi

if [ $FAILED -ne 0 ]; then
    echo "❌ [RED TEST] Auditoria falhou: conformidade incompleta com GOST 1.5.0."
    exit 1
fi

echo "✔ [GREEN TEST] Auditoria aprovada: conformidade com GOST 1.5.0 verificada."
exit 0
