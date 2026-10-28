#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$REPO_DIR/profile.md"

echo "=== [TEST] Auditoria do Contrato de Atualização XDG e Jornaleira (Ticket #5) ==="

FAILED=0

# 1. Config.env e Intervalo de 12 Horas
if grep -qF 'config.env' "$PROFILE" && grep -qF 'UPDATE_CHECK_INTERVAL_HOURS="12"' "$PROFILE"; then
    echo "  [PASS] config.env declarado com intervalo padrão de 12 horas"
else
    echo "  [FAIL] config.env ausente ou intervalo de 12h não configurado no profile.md"
    FAILED=1
fi

# 2. Jornaleira como Gestora Primária (desativação de auto-check nativo)
if grep -qi "jornaleira" "$PROFILE" && grep -qi "gestora primária" "$PROFILE"; then
    echo "  [PASS] Cláusula de gestão primária pela Jornaleira declarada"
else
    echo "  [FAIL] Cláusula da Jornaleira como gestora primária ausente no profile.md"
    FAILED=1
fi

# 3. Contrato de Estado em Runtime (update_check.json)
if grep -qF 'update_check.json' "$PROFILE" && grep -qF 'XDG_STATE_HOME' "$PROFILE"; then
    echo "  [PASS] update_check.json e XDG_STATE_HOME declarados"
else
    echo "  [FAIL] update_check.json ou XDG_STATE_HOME ausente no profile.md"
    FAILED=1
fi

# 4. Preservação do Canal Nightly (Independência entre versão instalada e canal rastreado)
if grep -qi "preserv" "$PROFILE" && grep -qi "nightly" "$PROFILE" && grep -qF 'UPDATE_CHANNEL' "$PROFILE"; then
    echo "  [PASS] Diretiva de persistência do canal nightly declarada"
else
    echo "  [FAIL] Diretiva de persistência do canal nightly ausente no profile.md"
    FAILED=1
fi

# 5. Notificação Não-Intrusiva em stderr
if grep -qF "stderr" "$PROFILE" && grep -qi "nova versão disponível" "$PROFILE"; then
    echo "  [PASS] Notificação não-intrusiva via stderr declarada"
else
    echo "  [FAIL] Notificação via stderr ausente no profile.md"
    FAILED=1
fi

if [ $FAILED -ne 0 ]; then
    echo "❌ [RED TEST] Auditoria falhou como esperado na Fase 4."
    exit 1
fi

echo "✔ [GREEN TEST] Todas as cláusulas do contrato de update foram validadas."
exit 0
