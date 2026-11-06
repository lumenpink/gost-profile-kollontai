#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$REPO_DIR/profile.md"

echo "=== [TEST] Auditoria de Segregação de Aliases e Idempotência (Ticket #7) ==="

check_profile_channels() {
    local target="$1"
    local failed=0

    # 1. Exclusividade do alias 'latest' e versões limpas no canal estável
    if grep -qi "canal estável" "$target" && grep -qF "latest" "$target" && grep -qi "exclusiv" "$target"; then
        true
    else
        echo "  [FAIL] Cláusula de exclusividade do alias 'latest' no canal estável ausente"
        failed=1
    fi

    # 2. Aliases segregados de desenvolvimento: latest-dev e BASE_VERSION-dev
    if grep -qF "latest-dev" "$target" && grep -E -q "(\$\{BASE_VERSION\}|X\.Y\.Z)-dev" "$target"; then
        true
    else
        echo "  [FAIL] Cláusula de aliases segregados de desenvolvimento (latest-dev e X.Y.Z-dev) ausente"
        failed=1
    fi

    # 3. Idempotência na publicação com deleção prévia (pre-delete) e prevenção de HTTP 409
    if grep -qi "idempotên" "$target" && grep -qi "delete" "$target" && grep -qF "409" "$target"; then
        true
    else
        echo "  [FAIL] Cláusula de idempotência com deleção prévia de aliases mutáveis (evitando HTTP 409) ausente"
        failed=1
    fi

    # 4. Uso de versão canônica como recomendação (não trava mandatória)
    if grep -qi "versões canônicas" "$target" && grep -qi "recomenda" "$target"; then
        true
    else
        echo "  [FAIL] Cláusula de recomendação de uso de versões canônicas ausente"
        failed=1
    fi

    return $failed
}

if check_profile_channels "$PROFILE"; then
    echo "  [PASS] Todas as cláusulas de segregação de aliases e idempotência estão presentes!"
else
    echo "❌ [FAIL] Auditoria falhou no perfil oficial."
    exit 1
fi

echo "=== [MUTATION] Verificando sensibilidade dos testes normativos a mutações ==="

TMP_MUTANT=$(mktemp)
trap 'rm -f "$TMP_MUTANT"' EXIT

# Mutante 1: Omissão do alias de desenvolvimento latest-dev
sed 's/latest-dev/latest/g' "$PROFILE" > "$TMP_MUTANT"
if check_profile_channels "$TMP_MUTANT" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 1 (omissão do alias latest-dev) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 1 (omissão do alias latest-dev) capturado com precisão"
fi

# Mutante 2: Remoção do pre-delete idempotente e menção a HTTP 409
sed 's/HTTP 409 Conflict/HTTP 200 OK/g' "$PROFILE" > "$TMP_MUTANT"
if check_profile_channels "$TMP_MUTANT" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 2 (remoção de prevenção a HTTP 409) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 2 (remoção de prevenção a HTTP 409) capturado com precisão"
fi

# Mutante 3: Remoção da recomendação de versões canônicas
sed -E 's/versões canônicas/versões quaisquer/gI' "$PROFILE" > "$TMP_MUTANT"
if check_profile_channels "$TMP_MUTANT" >/dev/null 2>&1; then
    echo "  [FAIL] Mutante 3 (remoção de recomendação canônica) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 3 (remoção de recomendação canônica) capturado com precisão"
fi

echo "✔ [GREEN TEST] Todas as asserções e mutações foram aprovadas com 100% de conformidade."
exit 0

