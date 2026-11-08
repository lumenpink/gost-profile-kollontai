# Especificação Técnica — Ticket #10
## Padrões Táticos de Conteinerização e Compose (Kollontai v2.1.0)

### 1. Escopo e Propósito
Estabelecer no perfil Kollontai os padrões normativos concretos para empacotamento e orquestração de serviços em conformidade com o GOSPLAN:
1. **Dockerfile/Containerfile Multi-stage:** Compilação hermética estática e runtime minimalista em imagem base enxuta (`alpine` ou `scratch`).
2. **Execução Desprivilegiada Mandatória:** O container DEVE executar sob usuário não-root explicitamente (`user: "1000:1000"`).
3. **Orquestração Declarativa:** Todo serviço possui sua especificação de orquestração em arquivo `compose.yaml` (extensão `.yaml` obrigatória), com `restart: unless-stopped` e `healthcheck` obrigatório.
4. **Isolamento de Rede:** Serviços sem atribuição de gateway externo operam em redes privadas internas isoladas, com portas publicadas estritamente necessárias.
