# Document Classification Agent

Agente de inteligência artificial para classificação documental, com monitorização automática de ficheiros no Google Drive, aplicação de regras e skills configuráveis e registo estruturado dos resultados no Google Sheets.

## Objetivo

O projeto automatiza a classificação de documentos colocados numa pasta do Google Drive.

O processo é executado periodicamente através de um workflow n8n containerizado. Sempre que é identificado um novo documento, o sistema:

1. deteta o novo ficheiro;
2. descarrega e extrai o respetivo conteúdo;
3. envia o conteúdo para um modelo de linguagem;
4. aplica as regras de classificação definidas neste repositório;
5. devolve um resultado estruturado;
6. regista o resultado num Google Sheet;
7. encaminha o documento de acordo com o resultado do processamento.

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
```

O GitHub mantém a lógica declarativa do agente. O n8n assegura a orquestração. O Google Drive disponibiliza os documentos e o Google Sheets mantém o registo operacional e de auditoria.

## Estrutura do repositório

```text
document-classification-agent/
├── README.md
├── INSTRUCTIONS.md
├── .env.example
├── .gitignore
├── docker-compose.yml
├── docker/
│   └── n8n/
│       └── entrypoint.sh
├── n8n/
│   └── workflows/
│       └── document-classification.json
├── skills/
├── taxonomy/
├── schemas/
├── examples/
├── tests/
└── docs/
```

## Google Drive

Estrutura prevista:

```text
Classificacao_Documental/
├── Documentos_A_Classificar/
├── Documentos_Processados/
├── Documentos_A_Rever/
├── Documentos_Com_Erro/
└── Registo_Classificacao
```

O `Registo_Classificacao` deverá ser um Google Sheet.

## Estados de processamento

- `CLASSIFIED`: classificação concluída com evidência suficiente.
- `REVIEW`: documento ambíguo, incompleto ou com confiança insuficiente.
- `ERROR`: falha técnica ou impossibilidade de processar o conteúdo.

## Execução com Docker

1. Criar o ficheiro local de configuração:

```bash
cp .env.example .env
```

2. Preencher as variáveis necessárias no `.env`.

3. Iniciar o serviço:

```bash
docker compose up -d
```

4. Abrir o n8n no endereço configurado, por defeito:

```text
http://localhost:5678
```

O entrypoint importa automaticamente o workflow incluído em `n8n/workflows/document-classification.json`.

## Configuração inicial do n8n

Depois do primeiro arranque:

1. criar/configurar as credenciais do Google Drive;
2. criar/configurar as credenciais do Google Sheets;
3. configurar o fornecedor do modelo de linguagem;
4. validar os IDs das pastas e do Google Sheet;
5. executar o workflow manualmente;
6. apenas depois ativar a execução automática.

O workflow base é carregado desativado por segurança.

## Periodicidade

O workflow base utiliza um `Schedule Trigger` com execução de 5 em 5 minutos.

## Idempotência

O sistema deve utilizar o `drive_file_id` como identificador principal de cada documento.

Antes de processar um ficheiro, o workflow deve verificar se esse ID já foi registado, evitando processamentos duplicados.

## Regras do agente

O comportamento global encontra-se em `INSTRUCTIONS.md`.

As operações são divididas em skills independentes:

- extração de dados;
- classificação;
- validação;
- tratamento de incerteza;
- registo do resultado.

A taxonomia e as regras de classificação encontram-se em `taxonomy/`.

## Output

O agente deve devolver um objeto compatível com:

```text
schemas/classification.schema.json
```

Exemplo:

```json
{
  "drive_file_id": "example-drive-file-id",
  "file_name": "FT_2026_00123.pdf",
  "processed_at": "2026-09-20T12:00:00+01:00",
  "document_type": "FATURA",
  "category": null,
  "entity": "Fornecedor Exemplo, Lda.",
  "document_date": "2026-09-18",
  "document_number": "FT 2026/123",
  "amount": 1230.5,
  "currency": "EUR",
  "tax_id": null,
  "status": "CLASSIFIED",
  "confidence": 0.94,
  "reasoning_summary": "O documento identifica-se explicitamente como fatura e contém número, data e total.",
  "review_reason": null,
  "rules_version": "0.1.0"
}
```

## Segurança

Nunca guardar no repositório:

- chaves de API;
- passwords;
- tokens OAuth;
- credenciais Google;
- credenciais n8n;
- documentos reais com informação confidencial.

As credenciais devem ser geridas no n8n e através de variáveis de ambiente.

Definir sempre uma `N8N_ENCRYPTION_KEY` forte e persistente.

## Auditoria

Cada registo deve permitir reconstruir o processamento efetuado, incluindo:

- ID do ficheiro;
- nome original;
- data/hora de processamento;
- classificação;
- confiança;
- estado;
- motivo de revisão;
- versão das regras.

## Desenvolvimento

As alterações devem ser efetuadas através de branches e Pull Requests.

A branch `main` deve representar uma versão funcional e estável do projeto.
