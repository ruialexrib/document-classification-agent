# Workflow n8n

O workflow operacional encontra-se em `n8n/workflows/document-classification.json` e é importado automaticamente no arranque do contentor.

## Fluxo operacional

```text
Every 5 minutes / Manual test
        ↓
Validar configuração
        ↓
Listar ficheiros na pasta de entrada
        ↓
Ignorar IDs já processados
        ↓
É PDF?
   ├── não → REVIEW
   └── sim
        ↓
Descarregar PDF
        ↓
Extrair texto
        ↓
Existe texto suficiente?
   ├── não → REVIEW (OCR necessário)
   └── sim
        ↓
GroqCloud
        ↓
Validar JSON estruturado
        ↓
Google Sheets
        ↓
Marcar ID como processado
        ↓
CLASSIFIED → Processados
REVIEW     → A_Rever
ERROR      → Com_Erro
```

## Periodicidade

O trigger automático executa de cinco em cinco minutos. Existe também um `Manual test` para testar o workflow antes da ativação.

## Provider de IA

O provider definido é o **GroqCloud**:

```env
LLM_PROVIDER=groq
LLM_BASE_URL=https://api.groq.com/openai/v1
GROQ_API_KEY=
LLM_MODEL=qwen/qwen3.6-27b
```

A chave real deve existir apenas no ficheiro local `.env`. Nunca deve ser incluída no repositório.

## Credenciais Google

As credenciais OAuth não são guardadas no JSON do workflow.

Após a primeira importação, é necessário selecionar no n8n:

- uma credencial Google Drive nos nós Google Drive;
- uma credencial Google Sheets no nó de registo.

Depois de configuradas, ficam persistidas no volume `n8n_data`.

## Formatos suportados

A primeira versão operacional suporta faturas em **PDF com texto extraível**.

PDFs digitalizados sem camada de texto são encaminhados para `REVIEW` com indicação de necessidade de OCR.

Outros formatos são igualmente encaminhados para `REVIEW`, sem tentativa de classificação.

## Idempotência

O workflow usa o `drive_file_id` e `workflow static data` para evitar o reprocessamento do mesmo ficheiro.

Após o registo no Google Sheets, o ID é marcado como processado. A memória é limitada aos 5000 IDs mais recentes.

Adicionalmente, os ficheiros processados são retirados da pasta de entrada e movidos para uma das pastas de destino.

## Campos registados

O Google Sheets recebe:

- `drive_file_id`
- `file_name`
- `processed_at`
- `document_type`
- `service`
- `provider`
- `invoice_number`
- `customer_number`
- `issue_date`
- `amount_due`
- `currency`
- `multibanco_entity`
- `multibanco_reference`
- `payment_deadline`
- `status`
- `confidence`
- `reasoning_summary`
- `review_reason`
- `rules_version`

## Ativação recomendada

1. executar `docker compose up -d`;
2. abrir o workflow importado;
3. associar as credenciais Google aos nós;
4. colocar uma fatura PDF na pasta `Documentos_A_Classificar`;
5. executar `Manual test`;
6. validar o registo no Google Sheets e o movimento do ficheiro;
7. ativar o workflow automático.
