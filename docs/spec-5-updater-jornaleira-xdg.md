# Especificação Técnica — Ticket #5: Padronização do Ciclo de Vida de Updates XDG com Gestão Central pela Jornaleira

**Norma de Referência:** GOST 2.0.0  
**Perfil:** Kollontai (`https://kollontai.2lp.in/profile.md`)  
**Data:** 2026-10-28  
**Status:** Aprovado / Em Implementação (Fase 3 DD-TDD)  

---

## 1. Contexto & Motivação

O perfil **Kollontai** define as normas de distribuição e auto-atualização para ferramentas de linha de comando (CLI) e aplicativos desktop no ecossistema soberano.

Anteriormente, cada utilitário realizava verificações e auto-atualizações de forma isolada, gerando concorrência de rede em inicializações concomitantes e ausência de uma visão sistêmica de inventário e versões. Com a introdução da **Jornaleira** como gestora central de ciclo de vida e pacotes, faz-se necessária a revisão integral da **Seção 4** da especificação normativa Kollontai:

1. **Gestão Primária pela Jornaleira:** Quando a ferramenta `jornaleira` estiver instalada e ativa no sistema, ela assume a responsabilidade pelas consultas remotas e atualizações de background. O auto-check nativo dos aplicativos no startup permanece sumariamente desativado.
2. **Contrato de Configuração Plano (`config.env`):** Padronização universal em `${XDG_CONFIG_HOME:-~/.config}/<slug>/config.env` no formato `VAR="VALOR"` (compatível com POSIX Shell, Rust, Go, C), com periodicidade padrão de 12 horas (reduzida de 24h).
3. **Persistência Estrita do Canal Rastreado:** Separação entre a versão binária instalada em disco e o canal configurado (`UPDATE_CHANNEL`). A instalação pontual de uma versão estável (`<slug> update --stable`) **NUNCA** reescreve a preferência `UPDATE_CHANNEL="nightly"`, preservando o fluxo de atualizações do canal noturno.
4. **Contrato de Estado em Runtime (`update_check.json`):** Registro padronizado em `${XDG_STATE_HOME:-~/.local/state}/<slug>/update_check.json` interoperável entre o aplicativo e a Jornaleira.
5. **Comunicação Não-Intrusiva:** Avisos de versões disponíveis emitidos exclusivamente em `stderr`.

---

## 2. Contrato de Configuração XDG (`config.env`)

### 2.1 Localização e Formato
Todo aplicativo distribuído sob o perfil Kollontai **DEVE** buscar sua configuração de atualização em:
`${XDG_CONFIG_HOME:-~/.config}/<slug>/config.env`

O formato do arquivo é estritamente plano `CHAVE="VALOR"`, sem aninhamentos nem sintaxes proprietárias:
```sh
UPDATE_CHANNEL="stable"           # Canal rastreado: "stable" ou "nightly"
UPDATE_PINNED="false"             # Fixar versão ("true" ou "false")
UPDATE_PIN_VERSION=""             # Versão pinada (ex.: "1.2.0") quando PINNED="true"
UPDATE_AUTO_CHECK="true"          # Habilitar verificação automática em runtime autônomo
UPDATE_CHECK_INTERVAL_HOURS="12"  # Intervalo padrão de consulta (12 horas)
UPDATE_AUTO_UPDATE="false"        # Substituição atômica sem confirmação (opt-in estrito)
UPDATE_MANAGED_BY_JORNALEIRA=""   # Override: "" (auto-detectar), "true" ou "false"
```

### 2.2 Ordem de Precedência
1. Flags na invocação CLI (`--channel`, `--pin`, `--force`)
2. Variáveis de ambiente de processo (`<SLUG_UPPER>_UPDATE_*` ou `UPDATE_*`)
3. Arquivo de configuração de usuário (`${XDG_CONFIG_HOME}/<slug>/config.env`)
4. Padrões normativos do perfil Kollontai

---

## 3. Gestão Centralizada pela Jornaleira e Comportamento em Runtime

### 3.1 Detecção da Gestora
No momento da inicialização, o aplicativo avalia se está sob governança da Jornaleira:
* Se `UPDATE_MANAGED_BY_JORNALEIRA="true"`, ou se a variável estiver vazia/omitida e o binário `jornaleira` estiver presente no `PATH` (`command -v jornaleira >/dev/null 2>&1`):
  * **O auto-check nativo de rede no startup é desativado (short-circuit estrito).**
  * Nenhuma conexão remota é disparada pelo aplicativo durante a execução comum de comandos.
* Se `UPDATE_MANAGED_BY_JORNALEIRA="false"`, ou se `jornaleira` não estiver instalada:
  * O aplicativo opera em modo autônomo: ao expirar o intervalo de 12 horas registrado no arquivo de estado, executa consulta assíncrona não-bloqueante (timeout $\le 1\text{s}$) à Banca.

### 3.2 Alertas Não-Intrusivos em `stderr`
Se o estado local indicar que há atualização disponível (`update_available: true`):
* Em modo gerenciado:
  ```text
  💡 [<slug>] Nova versão disponível: vX.Y.Z (atual: vA.B.C). Execute 'jornaleira update <slug>' para atualizar.
  ```
* Em modo autônomo:
  ```text
  💡 [<slug>] Nova versão disponível: vX.Y.Z (atual: vA.B.C). Execute '<slug> update' para atualizar.
  ```
O texto é emitido exclusivamente em `stderr` para não violar pipelines (`stdout`).

---

## 4. Contrato de Estado em Runtime (`update_check.json`)

O cache de estado de atualizações reside em:
`${XDG_STATE_HOME:-~/.local/state}/<slug>/update_check.json`

Estrutura JSON canônica:
```json
{
  "last_check_timestamp": 1793011055,
  "current_version": "0.1.0",
  "latest_remote_version": "0.1.2",
  "channel": "stable",
  "update_available": true,
  "last_check_status": "success",
  "managed_by": "jornaleira"
}
```

---

## 5. Contrato de Subcomandos CLI e Persistência do Canal

### 5.1 Subcomandos Obrigatórios
Todo utilitário CLI **DEVE** fornecer os subcomandos:
* `<slug> check-update [--channel <stable|nightly>] [--stable] [--nightly]`
* `<slug> update [--channel <stable|nightly>] [--stable] [--nightly] [--pin <ver>] [--force] [--dry-run]`
* `<slug> config show | set-channel <c> | pin [<ver>] | unpin | set-auto-check <bool> | set-auto-update <bool>`

### 5.2 Regra de Persistência do Canal Nightly
* O parâmetro `UPDATE_CHANNEL` define o canal de interesse persistente do usuário.
* Comandos pontuais com flag explícita (como `<slug> update --stable` ou `<slug> update --channel stable`) atualizam o binário para a compilação estável requisitada, **mas NÃO alteram a chave `UPDATE_CHANNEL`** no arquivo `config.env`.
* A reconfiguração persistente do canal é restrita ao subcomando de configuração explícita:
  `<slug> config set-channel <channel>` (ou `--save-channel` durante o update).
* Caso o canal configurado seja `nightly`, o verificador continuará consultando e notificando releases do canal noturno assim que uma compilação mais nova que a versão local estiver disponível na Banca.
