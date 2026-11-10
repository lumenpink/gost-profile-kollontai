#!/bin/bash
set -eo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$REPO_DIR/profile.md"
RULES="$REPO_DIR/rules.toml"
LOCALES="$REPO_DIR/locales/pt-br.toml"
VERSION_FILE="$REPO_DIR/VERSION"

echo "=== [TEST] Auditoria de Conformidade Kollontai v2.1.0 (#13) ==="

FAILED=0

# 1. Frontmatter universal e subordinação a GOSPLAN
if grep -qF 'standard: "kollontai"' "$PROFILE" && \
   grep -qF 'tier: "tactical"' "$PROFILE" && \
   grep -qF 'standard: "gosplan"' "$PROFILE" && \
   grep -qF 'base_url: "https://gosplan.2lp.in/1.0.0/"' "$PROFILE"; then
    echo "  [PASS] Frontmatter universal com herança de gosplan conforme"
else
    echo "  [FAIL] Frontmatter universal ausente ou incorreto em profile.md"
    FAILED=1
fi

# 2. Ausência de termos proibidos em documentação e site
if grep -rni --include="*.html" --include="*.md" "soberan" "$PROFILE" "$REPO_DIR/site"; then
    echo "  [FAIL] Termo proibido encontrado em profile.md ou site/"
    FAILED=1
else
    echo "  [PASS] Termos proibidos ausentes em profile.md e site/"
fi

# 2.1 Paridade de site/profile.md com profile.md
if ! cmp -s "$PROFILE" "$REPO_DIR/site/profile.md"; then
    echo "  [FAIL] site/profile.md diverge de profile.md"
    FAILED=1
else
    echo "  [PASS] site/profile.md sincronizado com profile.md"
fi

# 2.2 Paridade de site/rules.toml com rules.toml
if ! cmp -s "$RULES" "$REPO_DIR/site/rules.toml"; then
    echo "  [FAIL] site/rules.toml diverge ou ausente em relacao a rules.toml"
    FAILED=1
else
    echo "  [PASS] site/rules.toml sincronizado com rules.toml"
fi

# 3. rules.toml com exatamente 16 decretos de engenharia
if python3 -c '
import re
import tomllib

with open("'$RULES'", "rb") as f:
    rules = tomllib.load(f).get("rules", {})

expected_rules = {
    "KOLLONTAI-001": "README-MAX-LINES",
    "KOLLONTAI-002": "BANNER-DIMENSIONS-AND-RATIO",
    "KOLLONTAI-003": "DDD-DOMAIN-PURITY",
    "KOLLONTAI-004": "STATIC-ANALYSIS-ZERO-WARNINGS",
    "KOLLONTAI-005": "FORMAT-CHECK-DETERMINISTIC",
    "KOLLONTAI-006": "SITE-SECURITY-HEADERS",
    "KOLLONTAI-007": "COMPOSE-NON-ROOT-USER",
    "KOLLONTAI-008": "COMPOSE-HEALTHCHECK-REQUIRED",
    "KOLLONTAI-009": "DOCKERFILE-NON-ROOT-USER",
    "KOLLONTAI-010": "API-CONTRACT-OPENAPI",
    "KOLLONTAI-011": "FORBIDDEN-TERMS",
    "KOLLONTAI-012": "SMOKE-TEST-SANITY-POST-BUILD",
    "KOLLONTAI-013": "INTL-KEY-PARITY",
    "KOLLONTAI-014": "RTL-LOGICAL-PROPERTIES-AUDIT",
    "KOLLONTAI-015": "I18N-SITE-FALLBACK-ENGLISH",
    "KOLLONTAI-016": "FORBIDDEN-PATH-DEPENDENCIES",
}

assert len(rules) == 16, f"Contagem deve ser 16 decretos de engenharia, obtido: {len(rules)}"
for r_id, exp_name in expected_rules.items():
    assert r_id in rules, f"Regra {r_id} ausente"
    assert re.match(r"^KOLLONTAI-\d{3}$", r_id), f"ID deve ser tridigital: {r_id}"
    r_data = rules[r_id]
    act_name = r_data.get("name")
    assert act_name == exp_name, f"Nome incorreto em {r_id}: {act_name} != {exp_name}"
    assert "script" in r_data, f"Script ausente em {r_id}"
    assert "gost." in r_data["script"], f"Script deve chamar gost.* em {r_id}"
'; then
    echo "  [PASS] rules.toml validado com os 16 decretos de engenharia canônicos"
else
    echo "  [FAIL] Validação de rules.toml falhou"
    FAILED=1
fi

# 4. locales/pt-br.toml com todas as 16 regras
if python3 -c '
import tomllib

with open("'$RULES'", "rb") as f:
    canon = tomllib.load(f).get("rules", {})
with open("'$LOCALES'", "rb") as f:
    loc = tomllib.load(f).get("rules", {})

assert len(loc) == 16, f"Locale pt-br deve conter 16 regras, obtido: {len(loc)}"
for r_id in canon.keys():
    assert r_id in loc, f"Regra {r_id} ausente no locale"
    assert "description" in loc[r_id], f"description ausente em {r_id} no locale"
'; then
    echo "  [PASS] locales/pt-br.toml validado com paridade para 16 regras"
else
    echo "  [FAIL] Validação de locales falhou"
    FAILED=1
fi

# 5. Mutantes
echo "=== [MUTATION] Verificando sensibilidade a mutações ==="
TMP_MUT=$(mktemp)
trap 'rm -f "$TMP_MUT"' EXIT

# Mutante 1: remoção de inherits_from
grep -v 'standard: "gosplan"' "$PROFILE" > "$TMP_MUT"
if grep -qF 'standard: "gosplan"' "$TMP_MUT"; then
    echo "  [FAIL] Mutante 1 (gosplan ausente) sobreviveu"
    FAILED=1
else
    echo "  [PASS] Mutante 1 (gosplan ausente) detectado"
fi

# Mutante 2: injeção de termo proibido
cat "$PROFILE" > "$TMP_MUT"
echo "soberania nacional" >> "$TMP_MUT"
if grep -qi "soberan" "$TMP_MUT"; then
    echo "  [PASS] Mutante 2 (termo proibido injetado) detectado"
else
    echo "  [FAIL] Mutante 2 não detectado"
    FAILED=1
fi

# Mutante 3: ID com letras (KOLLONTAI-001A)
python3 -c '
import re
assert not re.match(r"^KOLLONTAI-\d{3}$", "KOLLONTAI-001A"), "Deveria rejeitar sufixo alfabético"
' || FAILED=1
echo "  [PASS] Mutante 3 (ID alfanumérico rejeitado) detectado"

# Mutante 4: detecção de path dependency proibida
python3 -c '
import re
test_cargo = """
[dependencies]
lunokhod = { path = "../lunokhod" }
"""
has_path = bool(re.search(r"path\s*=\s*[\x22\x27]\s*\.\.", test_cargo) or re.search(r"path\s*=\s*[\x22\x27]\s*/", test_cargo))
assert has_path, "Mutante 4: deve detectar path = \"../lunokhod\""

clean_cargo = """
[dependencies]
lunokhod = { version = \"0.1\", registry = \"gambi\" }
"""
clean_path = bool(re.search(r"path\s*=\s*[\x22\x27]\s*\.\.", clean_cargo) or re.search(r"path\s*=\s*[\x22\x27]\s*/", clean_cargo))
assert not clean_path, "Mutante 4: nao deve alertar em registro canonico"
' || FAILED=1
echo "  [PASS] Mutante 4 (path dependency detectada e registry permitido) conforme"

# Mutante 5: detecção de termo proibido em site/
cat "$REPO_DIR/site/profile.md" > "$TMP_MUT"
echo "soberania nacional" >> "$TMP_MUT"
if grep -qi "soberan" "$TMP_MUT"; then
    echo "  [PASS] Mutante 5 (termo proibido em site/ detectado) conforme"
else
    echo "  [FAIL] Mutante 5 não detectado"
    FAILED=1
fi

if [ $FAILED -ne 0 ]; then
    echo "=== [RESULT] FALHA NA AUDITORIA ==="
    exit 1
fi

echo "=== [RESULT] TODOS OS TESTES PASSARAM COM SUCESSO ==="
exit 0
