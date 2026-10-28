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

echo "✔ [GREEN TEST] Contrato de deploy do workflow de CI aprovado com sucesso."
exit 0
