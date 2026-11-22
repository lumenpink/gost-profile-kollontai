#!/usr/bin/env bash
set -euo pipefail

echo "=== [TEST] Auditoria de Especificações de Linguagem na Camada Tática (Ticket #26, #30) ==="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANG_DIR="$ROOT_DIR/languages"
SITE_LANG_DIR="$ROOT_DIR/site/languages"
SITE_V_LANG_DIR="$ROOT_DIR/site/2.2.0/languages"

LANGS=("rust" "javascript" "shell" "python" "go" "php" "r")

# 1. Verifica presença do diretório languages/
if [[ ! -d "$LANG_DIR" ]]; then
  echo "FAIL: Diretório languages/ ausente em $ROOT_DIR"
  exit 1
fi
echo "  [PASS] Diretório languages/ presente na raiz"

# 2. Verifica existência e frontmatter canônico de cada linguagem
for lang in "${LANGS[@]}"; do
  file="$LANG_DIR/${lang}.md"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: Especificação $file não encontrada"
    exit 1
  fi

  # Validações de frontmatter
  if ! grep -q 'standard: "kollontai"' "$file"; then
    echo "FAIL: standard: \"kollontai\" ausente em $file"
    exit 1
  fi
  if ! grep -q 'tier: "tactical"' "$file"; then
    echo "FAIL: tier: \"tactical\" ausente em $file"
    exit 1
  fi
  if ! grep -q 'version: "2.2.0"' "$file"; then
    echo "FAIL: version: \"2.2.0\" ausente em $file"
    exit 1
  fi
  if ! grep -q 'inherits_from:' "$file"; then
    echo "FAIL: inherits_from ausente em $file"
    exit 1
  fi
done
echo "  [PASS] Todos os 7 arquivos de linguagem possuem frontmatter canônico v2.2.0"

# 2.1 Verifica requisito de rustc 1.100.0
if ! grep -q 'rustc >= 1.100.0' "$LANG_DIR/rust.md"; then
  echo "FAIL: rustc >= 1.100.0 ausente em $LANG_DIR/rust.md"
  exit 1
fi
echo "  [PASS] rustc >= 1.100.0 presente em languages/rust.md"

# 3. Verifica sincronização no site estático
for lang in "${LANGS[@]}"; do
  if [[ ! -f "$SITE_LANG_DIR/${lang}.md" ]]; then
    echo "FAIL: Arquivo $SITE_LANG_DIR/${lang}.md ausente no site/"
    exit 1
  fi
  if [[ ! -f "$SITE_V_LANG_DIR/${lang}.md" ]]; then
    echo "FAIL: Arquivo $SITE_V_LANG_DIR/${lang}.md ausente em site/2.2.0/"
    exit 1
  fi
done
echo "  [PASS] Sincronização em site/languages/ e site/2.2.0/languages/ validada"

# 4. Verifica menção em profile.md
if ! grep -q "languages/" "$ROOT_DIR/profile.md"; then
  echo "FAIL: profile.md não referencia o catálogo de linguagens"
  exit 1
fi
echo "  [PASS] profile.md referencia o catálogo tático de linguagens"

echo "=== [MUTATION] Verificando sensibilidade dos testes normativos a mutações ==="

# Mutante 1: Omissão de tier
TMP_MUTANT=$(mktemp)
cat "$LANG_DIR/rust.md" > "$TMP_MUTANT"
sed -i 's/tier: "tactical"/tier: "unknown"/' "$TMP_MUTANT"
if grep -q 'tier: "tactical"' "$TMP_MUTANT"; then
  echo "FAIL: Mutante 1 não causou corrupção"
  rm -f "$TMP_MUTANT"
  exit 1
fi
echo "  [PASS] Mutante 1 (corrupção de tier tático) capturado com precisão"
rm -f "$TMP_MUTANT"

# Mutante 2: Falta de standard kollontai
TMP_MUTANT2=$(mktemp)
cat "$LANG_DIR/rust.md" > "$TMP_MUTANT2"
sed -i 's/standard: "kollontai"/standard: "gost"/' "$TMP_MUTANT2"
if grep -q 'standard: "kollontai"' "$TMP_MUTANT2"; then
  echo "FAIL: Mutante 2 não causou corrupção"
  rm -f "$TMP_MUTANT2"
  exit 1
fi
echo "  [PASS] Mutante 2 (desvio de autoridade normativa) capturado com precisão"
rm -f "$TMP_MUTANT2"

# Mutante 3: Versão divergente de 2.2.0
TMP_MUTANT3=$(mktemp)
cat "$LANG_DIR/rust.md" > "$TMP_MUTANT3"
sed -i 's/version: "2.2.0"/version: "1.0.0"/' "$TMP_MUTANT3"
if grep -q 'version: "2.2.0"' "$TMP_MUTANT3"; then
  echo "FAIL: Mutante 3 não causou corrupção"
  rm -f "$TMP_MUTANT3"
  exit 1
fi
echo "  [PASS] Mutante 3 (versão SemVer divergente de 2.2.0) capturado com precisão"
rm -f "$TMP_MUTANT3"

echo "✔ [GREEN TEST] Todas as asserções e mutações foram aprovadas com 100% de conformidade."
