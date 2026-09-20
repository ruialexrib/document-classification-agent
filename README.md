# Document Classification Agent

Agente de inteligência artificial para classificação documental, com monitorização automática de ficheiros no Google Drive, aplicação de regras e skills configuráveis e registo estruturado dos resultados no Google Sheets.

## Objetivo

O projeto pretende automatizar a classificação de documentos colocados numa pasta do Google Drive.

O processo é executado periodicamente através de um workflow n8n containerizado. Sempre que é identificado um novo documento, o sistema:

1. deteta o novo ficheiro;
2. descarrega e extrai o respetivo conteúdo;
3. envia o conteúdo para um modelo de linguagem;
4. aplica as regras de classificação definidas neste repositório;
5. devolve um resultado estruturado;
6. regista o resultado num Google Sheet;
7. encaminha o documento de acordo com o resultado do processamento.

O projeto foi concebido para manter separadas a lógica de classificação e a automatização operacional.

## Arquitetura

```text
                   GitHub
                     │
        instructions / skills / rules
          taxonomy / schemas / tests
                     │
                     ▼
Google Drive ──► n8n ──► LLM ──► validação
     │                               │
     │                               ▼
     │                         Google Sheets
     │                               │
     └──── documentos processados ◄──┘