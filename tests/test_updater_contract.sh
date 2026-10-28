#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$REPO_DIR/profile.md"

echo "=== [TEST] Auditoria do Contrato de Atualização XDG e Jornaleira (Ticket #5) ==="

check_profile() {
    local target="$1"
    local failed=0

    # 1. Config.env e Intervalo de 12 Horas
    if grep -qF 'config.env' "$target" && grep -qF 'UPDATE_CHECK_INTERVAL_HOURS="12"' "$target"; then
        true
    else
        failed=1
    fi

    # 2. Jornaleira como Gestora Primária (desativação de auto-check nativo)
    if grep -qi "jornaleira" "$target" && grep -qi "gestora primária" "$target"; then
        true
    else
        failed=1
    fi

    # 3. Contrato de Estado em Runtime (update_check.json)
    if grep -qF 'update_check.json' "$target" && grep -qF 'XDG_STATE_HOME' "$target"; then
        true
    else
        failed=1
    fi

    # 4. Preservação do Canal Nightly (Independência entre versão instalada e canal rastreado)
    if grep -qi "preserv" "$target" && grep -qi "nightly" "$target" && grep -qF 'UPDATE_CHANNEL' "$target"; then
        true
    else
        failed=1
    fi

    # 5. Notificação Não-Intrusiva em stderr
    if grep -qF "stderr" "$target" && grep -qi "nova versão disponível" "$target"; then
        true
    else
        failed=1
    fi

    return $failed
}

if check_profile "$PROFILE"; then
    echo "  [PASS] config.env declarado com intervalo padrão de 12 horas"
    echo "  [PASS] Cláusula de gestão primária pela Jornaleira declarada"
    echo "  [PASS] update_check.json e XDG_STATE_HOME declarados"
    echo "  [PASS] Diretiva de persistência do canal nightly declarada"
    echo "  [PASS] Notificação não-intrusiva via stderr declarada"
else
    echo "❌ [FAIL] Auditoria falhou no perfil oficial."
    exit 1
fi

echo "=== [MUTATION] Verificando sensibilidade dos testes normativos a mutações ==="

TMP_MUTANT=$(mktemp)
trap 'rm -f "$TMP_MUTANT"' EXIT

# Mutante 1: Omissão da Jornaleira
sed 's/jornaleira/supervisora/gI' "$PROFILE" > "$TMP_MUTANT"
if check_profile "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante 1 (omissão da Jornaleira) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 1 (omissão da Jornaleira) capturado com precisão"
fi

# Mutante 2: Reversão de 12h para 24h
sed 's/UPDATE_CHECK_INTERVAL_HOURS="12"/UPDATE_CHECK_INTERVAL_HOURS="24"/g' "$PROFILE" > "$TMP_MUTANT"
if check_profile "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante 2 (reversão do intervalo de 12h) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 2 (reversão do intervalo de 12h) capturado com precisão"
fi

# Mutante 3: Remoção da cláusula de persistência do canal
grep -v -i "preserv" "$PROFILE" > "$TMP_MUTANT"
if check_profile "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante 3 (remoção de persistência do canal) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 3 (remoção de persistência do canal) capturado com precisão"
fi

echo "✔ [GREEN TEST] Todas as asserções e mutações foram aprovadas com 100% de conformidade."
exit 0
