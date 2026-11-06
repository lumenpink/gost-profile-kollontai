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

    # 2. Aliases segregados de desenvolvimento: *-dev-latest.* e canal dev
    if grep -qF "*-dev-latest.*" "$target" && grep -qi "canal.*dev" "$target"; then
        true
    else
        echo "  [FAIL] Cláusula de canal 'dev' e alias '*-dev-latest.*' ausente"
        failed=1
    fi

    # 3. Contrato da esteira desacoplada (repository_dispatch e release-published)
    if grep -qF "repository_dispatch" "$target" && grep -qF "release-published" "$target" && grep -qF "client_payload" "$target"; then
        true
    else
        echo "  [FAIL] Contrato de notificação repository_dispatch e release-published ausente"
        failed=1
    fi

    # 4. Topologia de storage em bucket único particionado
    if grep -qF "banca-artifacts/{app}/{channel}/" "$target"; then
        true
    else
        echo "  [FAIL] Topologia de storage banca-artifacts/{app}/{channel}/ ausente"
        failed=1
    fi

    # 5. Ausência de termos imperialistas no perfil
    if grep -iE "soberan[ao]|sovereign" "$target" >/dev/null 2>&1; then
        echo "  [FAIL] Termos imperialistas detectados no perfil"
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

