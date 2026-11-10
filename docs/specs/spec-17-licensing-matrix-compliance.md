# Especificação do Ticket #17: Regra KOLLONTAI-017 (LICENSING-MATRIX-COMPLIANCE)

## Objetivo
Formalizar no perfil tático Kollontai a verificação automatizada da política de licenciamento do ecossistema GOST (`legal-licenses`), garantindo que todo repositório possua um arquivo de licença raiz canônico (`GPL-3.0` como padrão, `AGPL-3.0`, `Apache-2.0` ou `CC-BY-SA-4.0`) e que eventuais satélites (`LICENSE-MEDIA`, `LICENSE-LOGO`, `LICENSE-APACHE`) estejam estritamente em conformidade com a matriz autorizada.

## Requisitos da Regra KOLLONTAI-017
1. **Identificador:** `KOLLONTAI-017`
2. **Nome:** `LICENSING-MATRIX-COMPLIANCE`
3. **Severidade:** `error`
4. **Escopo:** `project`
5. **Critérios de Aceite:**
   - O arquivo `LICENSE` (ou `LICENSE.md`) deve obrigatoriamente existir na raiz do repositório.
   - O texto da licença raiz deve identificar claramente uma das licenças admitidas:
     - GNU General Public License v3.0 (`GPL-3.0`) - padrão para aplicações e sistemas
     - GNU Affero General Public License v3.0 (`AGPL-3.0`) - para daemons/serviços de rede
     - Apache License 2.0 (`Apache-2.0`) - para bibliotecas, utilitários simples e SDKs
     - Creative Commons Attribution-ShareAlike 4.0 (`CC-BY-SA-4.0`) - para especificações e normas
   - Se arquivos satélites existirem na raiz, devem seguir a matriz modular:
     - `LICENSE-MEDIA`: deve declarar `CC-BY-SA-4.0`
     - `LICENSE-LOGO`: deve declarar `CC-BY-ND-4.0`
     - `LICENSE-APACHE`: deve declarar `Apache-2.0`
   - Satélites com nomes arbitrários não homologados são proibidos.
6. **Localização e Mensagens:**
   - `locales/pt-br.toml` com chaves para ausência de `LICENSE` e licença não autorizada.
