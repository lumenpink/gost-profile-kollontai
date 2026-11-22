---
standard: "kollontai"
tier: "tactical"
language: "go"
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

# GOST Language Specification: Go
**Identificador da Stack:** `go`  
**Padrão Base:** GOST `2.0.0`

---

## 1. Visão Geral e Filosofia
Esta especificação define os requisitos de engenharia, ferramentas e padrões para desenvolvimento em **Go** (versão 1.22 ou superior) no ecossistema GOST.

O desenvolvimento em Go prioriza simplicidade, compilação estática atômica (`CGO_ENABLED=0`), concorrência estruturada e ausência de dependências de runtime em contêineres (`FROM scratch`).

---

## 2. Ferramental Mandatório de Testes & Qualidade

| Requisito GOST | Ferramenta Padrão | Comando de Validação no CI |
|---|---|---|
| **Test Runner** | **go test** | `go test -v -race ./...` |
| **Cobertura (≥ 90%)** | **go test cover** | `go test -coverprofile=coverage.out -fail-under 90 ./...` |
| **Testes de Mutação** | **go-mutators** / **gremlins** | `gremlins unleash --diff` |
| **Linter (Zero Warnings)** | **golangci-lint** | `golangci-lint run --issues-exit-code=1` |
| **Formatação Determinística** | **gofmt** / **goimports** | `test -z "$(gofmt -s -l .)"` |
| **Auditoria de Segurança** | **govulncheck** | `govulncheck ./...` |

---

## 3. Gestão de Dependências (Twelve-Factor)
1. **Módulos Congelados:** Os arquivos `go.mod` e `go.sum` **DEVE** estar commitados na raiz.
2. **Build Hermético e Reprodutível:**
   ```bash
   go mod verify
   CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app/bin/app ./cmd/app
   ```
3. **Anti-Bloat:** Evitar frameworks pesados ou bibliotecas externas desnecessárias para tarefas cobertas pela biblioteca padrão de Go.

---

## 4. Arquitetura de Domínio & SOLID Pragmático (Regra GOST-27)
1. **Pureza de Domínio (Zero I/O no Core):** O diretório `internal/domain/` é estritamente puro. Em conformidade com a Regra `GOST-27`, é terminantemente proibido importar `net/http`, `database/sql`, `os` ou `io/fs` dentro do Core de negócio.
2. **Estrutura Canônica:**
   ```text
   .
   ├── cmd/
   │   └── app/
   │       └── main.go         # Composition root e injeção de dependências
   ├── internal/
   │   ├── domain/             # Entidades puras, regras de negócio e interfaces (Portas)
   │   │   ├── model.go
   │   │   └── ports.go        # Interfaces para repositórios e serviços
   │   ├── application/        # Casos de uso e orquestração
   │   │   └── usecase.go
   │   └── adapters/           # Implementações concretas de I/O
   │       ├── inmemory/       # Fakes em memória para testes instantâneos
   │       ├── sqlite/         # Persistência concreta
   │       └── http/           # Handlers e routers HTTP
   ```
3. **In-Memory Fakes:** Testes unitários de domínio utilizam implementações em memória baseadas em mapas e slices nativos (`sync.Map` ou `map[string]Entity`), compartilhando os mesmos testes de contrato com adaptadores reais.
4. **Parse, Don't Validate:** Validação e parsing de requisições ocorrem nos adaptadores de borda (`cmd/` e `adapters/http`).

---

## 5. Padrões de Sistema e Containers OCI
1. **Conformidade XDG:**
   Resolução de diretórios respeita variáveis de ambiente com fallback para `$HOME`:
   ```go
   func ConfigDir(appName string) string {
       if dir := os.Getenv("XDG_CONFIG_HOME"); dir != "" {
           return filepath.Join(dir, appName)
       }
       home, _ := os.UserHomeDir()
       return filepath.Join(home, ".config", appName)
   }
   ```
2. **Dockerfile Canônico (Multi-stage + Scratch Estático):**
   ```dockerfile
   FROM golang:1.22-alpine AS builder
   RUN apk add --no-cache ca-certificates
   WORKDIR /build
   COPY go.mod go.sum ./
   RUN go mod download
   COPY . .
   RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /build/app ./cmd/app

   FROM scratch
   USER 1000:1000
   COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
   COPY --from=builder /build/app /usr/local/bin/app
   ENTRYPOINT ["/usr/local/bin/app"]
   ```
3. **Streams:** Dados estruturados em `os.Stdout`; logs operacionais e mensagens de diagnóstico em `os.Stderr`.
