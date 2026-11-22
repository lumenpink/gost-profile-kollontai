---
standard: "kollontai"
tier: "tactical"
language: "python"
version: "2.2.0"
locale: "pt-br"
authority: "Standards Committee"
published_at: "2026-11-08"
inherits_from:
  standard: "kollontai"
  tier: "tactical"
  version: "2.2.0"
  base_url: "https://kollontai.2lp.in/2.2.0/"
---

# GOST Language Specification: Python
**Identificador da Stack:** `python`  
**Padrão Base:** GOST `2.0.0`

---

## 1. Visão Geral e Filosofia
Esta especificação define os requisitos de engenharia, tipagem estática e padrões para desenvolvimento em **Python** (versão 3.12 ou superior) no ecossistema GOST.

O ecossistema impõe tipagem estática obrigatória (`mypy --strict`), linters e formatadores modernos de alto desempenho (`ruff`), empacotamento declarativo com **Poetry** ou **uv**, e imutabilidade estrutural com `@dataclass(frozen=True)`.

---

## 2. Ferramental Mandatório de Testes & Qualidade

| Requisito GOST | Ferramenta Padrão | Comando de Validação no CI |
|---|---|---|
| **Test Runner** | **Pytest** | `pytest` |
| **Cobertura (≥ 90%)** | **pytest-cov** | `pytest --cov=src --cov-fail-under=90` |
| **Testes de Mutação** | **mutmut** / **cosmic-ray** | `mutmut run --paths-to-mutate=src/` |
| **Análise Estática & Tipos** | **Mypy** (Strict) | `mypy --strict src tests` |
| **Linter (Zero Warnings)** | **Ruff Check** | `ruff check src tests` |
| **Formatação Determinística** | **Ruff Format** | `ruff format --check src tests` |
| **Auditoria de Segurança** | **pip-audit** | `pip-audit` |

---

## 3. Gestão de Dependências (Twelve-Factor)
1. **Lockfile Obrigatório:** O arquivo `poetry.lock` (ou `uv.lock`) **DEVE** estar commitado na raiz do repositório.
2. **Ambiente Virtual Isolado:** A execução e validação ocorrem estritamente dentro de virtualenv hermético sem pacotes globais do sistema:
   ```bash
   poetry install --no-root --sync
   ```
3. **Anti-Bloat:** Proibição de inclusão de dependências externas para utilitários triviais já disponíveis na biblioteca padrão de Python 3.12 (`pathlib`, `tomllib`, `dataclasses`, `typing`).

---

## 4. Arquitetura de Domínio & SOLID Pragmático (Regra GOST-27)
1. **Pureza de Domínio (Zero I/O no Core):** O diretório `src/domain/` é estritamente puro. Em conformidade com a Regra `GOST-27`, é expressamente proibido importar `sqlite3`, `requests`, `fastapi`, `os` ou `sys` dentro dos modelos e regras centrais do Core.
2. **Estrutura de Pastas Canônica:**
   ```text
   src/
   ├── domain/             # Entidades (@dataclass(frozen=True)), enums nativos, protocolos (Portas)
   │   ├── models.py
   │   └── ports.py        # Protocolos typing.Protocol para I/O
   ├── application/        # Casos de uso e serviços de aplicação
   │   └── use_cases.py
   └── adapters/           # Adaptadores de infraestrutura e I/O
       ├── in_memory.py    # Fakes em memória para testes herméticos
       ├── sqlite.py       # Persistência concreta
       └── cli.py          # Interface de linha de comando
   tests/
   ├── unit/               # Testes com Fakes em memória (execução em milissegundos)
   └── integration/        # Testes com adaptadores reais
   ```
3. **In-Memory Fakes:** Testes unitários de domínio utilizam implementações em memória baseadas em dicionários nativos (`dict[str, Entity]`), garantindo testes herméticos e compartilhando suíte de testes de contrato (LSP) com adaptadores de produção.
4. **Imutabilidade e Tipos Estritos:** Entidades de domínio empregam `@dataclass(frozen=True)` ou `NamedTuple` com anotações completas de tipos.

---

## 5. Padrões de Sistema e Containers OCI
1. **Conformidade XDG:**
   Resolução de diretórios respeita variáveis de ambiente com fallback para `$HOME`:
   ```python
   import os
   from pathlib import Path

   def get_config_dir(app_name: str) -> Path:
       base = os.getenv("XDG_CONFIG_HOME")
       if base:
           return Path(base) / app_name
       return Path.home() / ".config" / app_name
   ```
2. **Dockerfile Canônico (Multi-stage + Alpine Non-Root):**
   ```dockerfile
   FROM python:3.12-alpine AS builder
   WORKDIR /app
   RUN pip install --no-cache-dir poetry
   COPY pyproject.toml poetry.lock ./
   RUN poetry export -f requirements.txt --output requirements.txt --without-hashes
   RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

   FROM python:3.12-alpine
   RUN adduser -D -u 1000 appuser
   USER 1000:1000
   WORKDIR /app
   COPY --from=builder /install /usr/local
   COPY --chown=appuser:appuser src ./src
   ENTRYPOINT ["python", "-m", "src.main"]
   ```
3. **Streams:** Dados úteis emitidos para `sys.stdout`; mensagens informativas e logs para `sys.stderr`.
