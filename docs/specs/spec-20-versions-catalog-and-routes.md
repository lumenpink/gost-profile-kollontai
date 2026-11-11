# Especificação do Ticket #20: Catálogo versions.json e Rotas Versionadas da Norma Kollontai

**Ticket:** #20  
**Fase:** Fase 3 (Spec)  
**Status:** Em Elaboração  
**Autor:** Lumen Pink / Antigravity  

---

## 1. Contexto e Motivação

No modelo agnóstico universal baseado no padrão `.rules/`, o perfil de referência tática Kollontai (`https://kollontai.2lp.in`) disponibiliza na borda:
1. O catálogo estático de versões (`versions.json`) na raiz do domínio para auto-descoberta pelo Maestro `cccp`.
2. As rotas estáticas versionadas determinísticas `site/2.1.0/` contendo `RULES.md` e `RULES.toml`.

---

## 2. Requisitos Técnicos

### 2.1 Catálogo Estático `site/versions.json`
O arquivo `site/versions.json` servido na rota raiz (`https://kollontai.2lp.in/versions.json`):
```json
{
  "standard": "kollontai",
  "tier": "tactical",
  "latest": "2.1.0",
  "versions": [
    "2.1.0"
  ]
}
```

### 2.2 Rotas Canônicas da Norma
1. **Padrão Agnóstico Moderno:**
   - Raiz: `site/RULES.md` e `site/RULES.toml`.
   - Versionado: `site/2.1.0/RULES.md` e `site/2.1.0/RULES.toml`.
2. **Preservação Retrocompatível:**
   - Manter `site/profile.md`, `site/rules.toml` e subdiretório `site/2.1.0/profile.md` e `site/2.1.0/rules.toml`.

---

## 3. Árvore de Decisões Arquiteturais (para a Natasha)

1. **Por que padronizar Kollontai com a mesma estrutura de Lilya?**
   - *Decisão:* Toda camada normativa do ecossistema deve seguir o mesmo contrato de publicação estática. Isso permite que tanto perfis operacionais quanto táticos sejam consumidos ou inspecionados de maneira idêntica.

---

## 4. Plano de Validação
- **Fase 4 (Red Test):** Script `tests/test_versions_catalog_spec.sh`.
- **Fase 5 (Green Implement):** Criação dos arquivos em `site/`.
- **Fase 7 (Mutation Test):** Mutação na chave `latest` e nas rotas.
- **Fase 8 (Quality Gate):** Suíte de testes normativos de Kollontai.
