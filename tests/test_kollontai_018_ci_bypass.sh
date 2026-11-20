#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== [TEST] KOLLONTAI-018: Isenção de CI Hermética ==="

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Simular ambiente de repositório git recém-clonado na CI sem hooks locais
mkdir -p "$TMP_DIR/.git/hooks"
mkdir -p "$TMP_DIR/.gost"
cp "$REPO_DIR/rules.toml" "$TMP_DIR/.gost/rules.toml"

# Criar arquivos minimos de metadados
cat << 'EOF' > "$TMP_DIR/.gost/GOST.md"
---
standard: "gost"
version: "3.0.0"
profile: "https://kollontai.2lp.in/2.1.0/profile.md"
languages: "shell"
---
# Test Repo
EOF

# 1. Sem variáveis de CI: DEVE FALHAR porque os hooks não existem
OUT_LOCAL=$(env -u CI -u GITHUB_ACTIONS -u FORGEJO_ACTIONS lunokhod -d "$TMP_DIR" check --scope project 2>&1 || true)
if echo "$OUT_LOCAL" | grep -q "KOLLONTAI-018.*GIT-HOOKS-MAESTRO-PARITY" && echo "$OUT_LOCAL" | grep -q "commit-msg.*missing"; then
    echo "  [PASS] Ambiente local sem hooks reprovado corretamente em KOLLONTAI-018"
else
    echo "  [FAIL] Deveria reprovar KOLLONTAI-018 quando hooks estão ausentes localmente"
    echo "$OUT_LOCAL"
    exit 1
fi

# 2. Com CI=true: DEVE PASSAR (ignorar ausência de hooks)
OUT_CI=$(CI=true env -u GITHUB_ACTIONS -u FORGEJO_ACTIONS lunokhod -d "$TMP_DIR" check --scope project 2>&1 || true)
if echo "$OUT_CI" | grep -q "KOLLONTAI-018.*GIT-HOOKS-MAESTRO-PARITY" && echo "$OUT_CI" | grep -q "commit-msg.*missing"; then
    echo "  [FAIL] CI=true não deveria falhar em KOLLONTAI-018 (ausência de bypass detectada)"
    exit 1
else
    echo "  [PASS] CI=true dispensa verificação de hooks locais com sucesso"
fi

# 3. Com FORGEJO_ACTIONS=true: DEVE PASSAR
if FORGEJO_ACTIONS=true env -u CI -u GITHUB_ACTIONS lunokhod -d "$TMP_DIR" check --scope project 2>&1 | grep -q "KOLLONTAI-018.*Fail"; then
    echo "  [FAIL] FORGEJO_ACTIONS=true não deveria falhar em KOLLONTAI-018"
    exit 1
else
    echo "  [PASS] FORGEJO_ACTIONS=true dispensa verificação de hooks locais com sucesso"
fi

echo "=== [SUCCESS] Todos os cenários de KOLLONTAI-018 aprovados ==="
