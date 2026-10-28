#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW="$REPO_DIR/.forgejo/workflows/ci.yml"

echo "=== [TEST] Auditoria do Contrato de Deploy de CI (Ticket #6) ==="

check_workflow() {
    local target="$1"
    local failed=0

    # 1. Presença do Deploy Cloudflare Workers
    if grep -qF "npx wrangler deploy" "$target" && grep -qF "CLOUDFLARE_API_TOKEN" "$target"; then
        true
    else
        failed=1
    fi

    # 2. Ausência terminante de worktree add --orphan e push para pages
    if grep -qF "worktree add --orphan" "$target" || grep -qF "git push --force origin pages" "$target"; then
        failed=1
    fi

    return $failed
}

if check_workflow "$WORKFLOW"; then
    echo "  [PASS] Deploy Cloudflare Workers configurado corretamente"
    echo "  [PASS] Step quebrado de Codeberg Pages ausente do workflow"
else
    echo "❌ [FAIL] Workflow de CI ainda contém etapas incompatíveis ou ausência de Cloudflare."
    exit 1
fi

echo "=== [MUTATION] Verificando sensibilidade dos testes normativos a mutações ==="

TMP_MUTANT=$(mktemp)
trap 'rm -f "$TMP_MUTANT"' EXIT

# Mutante 1: Reintrodução de worktree add --orphan
sed 's/npx wrangler deploy/git worktree add --orphan -b pages \/tmp/g' "$WORKFLOW" > "$TMP_MUTANT"
if check_workflow "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante 1 (reintrodução de worktree orphan) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 1 (reintrodução de worktree orphan) capturado com precisão"
fi

# Mutante 2: Remoção do deploy Cloudflare
sed 's/npx wrangler deploy/echo skip/g' "$WORKFLOW" > "$TMP_MUTANT"
if check_workflow "$TMP_MUTANT"; then
    echo "  [FAIL] Mutante 2 (remoção de wrangler deploy) não foi capturado!"
    exit 1
else
    echo "  [PASS] Mutante 2 (remoção de wrangler deploy) capturado com precisão"
fi

echo "✔ [GREEN TEST] Todas as asserções e mutações foram aprovadas com 100% de conformidade."
exit 0
