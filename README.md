# Document Classification Agent

Agente de inteligência artificial para processamento de faturas de água, eletricidade e comunicações. Monitoriza uma pasta do Google Drive, identifica novas faturas, extrai dados estruturados com recurso a um LLM e regista os resultados num Google Sheet.

## O que o agente extrai

Para cada fatura, o agente procura:

- data de emissão;
- tipo de serviço: água, eletricidade ou comunicações;
- fornecedor;
- número da fatura;
- número de cliente/contrato, quando existente;
- valor a pagar;
- moeda;
- entidade Multibanco;
- referência Multibanco;
- data limite de pagamento.

O agente não deve inventar informação. Campos inexistentes ficam a `null`. Documentos ambíguos são enviados para revisão.

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
     └──── encaminhamento por estado ┘
```

O GitHub contém a lógica do agente e a infraestrutura. O n8n assegura a orquestração. O Google Drive contém os documentos. O Google Sheets mantém o registo operacional e de auditoria.

## Pré-requisitos

Antes de iniciar:

- Docker e Docker Compose instalados;
- conta Google com acesso ao Google Drive e Google Sheets;
- credenciais OAuth Google configuráveis no n8n;
- acesso a um LLM através de um endpoint OpenAI-compatible;
- repositório clonado localmente.

## 1. Clonar o projeto

```bash
git clone https://github.com/ruialexrib/document-classification-agent.git
cd document-classification-agent
```

## 2. Criar a estrutura no Google Drive

Criar uma pasta principal:

```text
Classificacao_Documental/
├── Documentos_A_Classificar/
├── Documentos_Processados/
├── Documentos_A_Rever/
├── Documentos_Com_Erro/
└── Registo_Classificacao
```

As quatro primeiras entradas são pastas. `Registo_Classificacao` é um Google Sheet.

### Finalidade das pastas

- `Documentos_A_Classificar`: entrada de novas faturas;
- `Documentos_Processados`: faturas classificadas com sucesso;
- `Documentos_A_Rever`: documentos que exigem revisão humana;
- `Documentos_Com_Erro`: documentos que não puderam ser processados.

## 3. Obter os IDs do Google Drive

Abrir cada pasta no browser. O ID corresponde normalmente ao valor presente no URL depois de `/folders/`.

Exemplo:

```text
https://drive.google.com/drive/folders/1AbCdEfGh...
                                      └─────────┘
                                         ID
```

Fazer o mesmo para o Google Sheet. O ID do Sheet encontra-se normalmente entre `/d/` e `/edit`.

```text
https://docs.google.com/spreadsheets/d/1AbCdEfGh.../edit
                                      └─────────┘
                                         ID
```

## 4. Preparar o Google Sheet

Criar uma folha com o nome:

```text
Registo_Classificacao
```

A primeira linha deve conter exatamente estas colunas:

```text
drive_file_id
file_name
processed_at
document_type
service
provider
invoice_number
customer_number
issue_date
amount_due
currency
multibanco_entity
multibanco_reference
payment_deadline
status
confidence
reasoning_summary
review_reason
rules_version
```

Mais detalhes em `docs/google-sheet.md`.

## 5. Configurar variáveis de ambiente

Criar o ficheiro `.env`:

```bash
cp .env.example .env
```

Preencher:

```env
N8N_PORT=5678
N8N_HOST=localhost
N8N_PROTOCOL=http
GENERIC_TIMEZONE=Europe/Lisbon
TZ=Europe/Lisbon

N8N_ENCRYPTION_KEY=<segredo-longo-e-aleatorio>

GOOGLE_DRIVE_INPUT_FOLDER_ID=<id-Documentos_A_Classificar>
GOOGLE_DRIVE_PROCESSED_FOLDER_ID=<id-Documentos_Processados>
GOOGLE_DRIVE_REVIEW_FOLDER_ID=<id-Documentos_A_Rever>
GOOGLE_DRIVE_ERROR_FOLDER_ID=<id-Documentos_Com_Erro>

GOOGLE_SHEET_ID=<id-do-google-sheet>
GOOGLE_SHEET_NAME=Registo_Classificacao

LLM_BASE_URL=https://api.openai.com/v1
LLM_API_KEY=<chave-api>
LLM_MODEL=<modelo>
```

Nunca fazer commit do ficheiro `.env`.

## 6. Iniciar o n8n

```bash
docker compose up -d
```

Consultar estado:

```bash
docker compose ps
```

Consultar logs:

```bash
docker compose logs -f n8n
```

Por defeito, o n8n fica disponível em:

```text
http://localhost:5678
```

O contentor utiliza volume persistente para os dados do n8n.

## 7. Workflow incluído

O ficheiro:

```text
n8n/workflows/document-classification.json
```

é montado no contentor e importado no arranque pelo script:

```text
docker/n8n/entrypoint.sh
```

O workflow é carregado desativado por segurança.

A periodicidade prevista é de 5 em 5 minutos.

## 8. Configurar credenciais Google no n8n

Na interface do n8n, criar credenciais para:

- Google Drive;
- Google Sheets.

Usar OAuth2 e conceder apenas as permissões necessárias ao funcionamento do workflow.

As credenciais Google não devem ser colocadas no GitHub nem diretamente nos ficheiros do projeto.

Depois de criadas, associar as credenciais aos respetivos nós do workflow.

## 9. Configurar o LLM

A solução está preparada para utilizar um endpoint OpenAI-compatible.

Configurar no `.env`:

- `LLM_BASE_URL`;
- `LLM_API_KEY`;
- `LLM_MODEL`.

Isto permite trocar de fornecedor sem alterar a lógica de classificação, desde que o serviço exponha uma API compatível.

O prompt de extração encontra-se em:

```text
prompts/invoice-extraction.md
```

As regras e o schema estão em:

```text
INSTRUCTIONS.md
skills/
taxonomy/
schemas/classification.schema.json
```

## 10. Estados possíveis

### CLASSIFIED

A fatura foi identificada e os dados foram extraídos com confiança suficiente.

Destino:

```text
Documentos_Processados
```

### REVIEW

Existe ambiguidade ou confiança insuficiente.

Exemplos:

- vários valores plausíveis como total a pagar;
- várias referências Multibanco sem identificação clara da atual;
- serviço não identificável;
- documento parcialmente legível.

Destino:

```text
Documentos_A_Rever
```

### ERROR

Falha técnica ou documento não processável.

Destino:

```text
Documentos_Com_Erro
```

## 11. Output esperado

Exemplo:

```json
{
  "drive_file_id": "example-drive-file-id",
  "file_name": "fatura-eletricidade-setembro-2026.pdf",
  "processed_at": "2026-09-20T12:00:00+01:00",
  "document_type": "FATURA_ELETRICIDADE",
  "service": "ELETRICIDADE",
  "provider": "Fornecedor Exemplo",
  "invoice_number": "FT 2026/12345",
  "customer_number": "987654321",
  "issue_date": "2026-09-10",
  "amount_due": 84.27,
  "currency": "EUR",
  "multibanco_entity": "12345",
  "multibanco_reference": "123456789",
  "payment_deadline": "2026-09-30",
  "status": "CLASSIFIED",
  "confidence": 0.97,
  "reasoning_summary": "A fatura identifica fornecimento de eletricidade e apresenta consumo em kWh, total a pagar e dados Multibanco.",
  "review_reason": null,
  "rules_version": "0.2.0"
}
```

## 12. Evitar processamento duplicado

O `drive_file_id` é o identificador técnico principal.

Antes de classificar uma fatura, o workflow deve confirmar que o mesmo `drive_file_id` ainda não foi processado.

O nome do ficheiro não deve ser utilizado como identificador único.

## 13. Testar antes de ativar

Antes de ativar a execução automática:

1. colocar uma fatura de teste em `Documentos_A_Classificar`;
2. executar o workflow manualmente;
3. confirmar os campos extraídos;
4. confirmar o registo no Google Sheet;
5. confirmar o encaminhamento do ficheiro;
6. testar um documento ambíguo;
7. testar um documento inválido;
8. confirmar que a mesma fatura não é processada duas vezes.

Só depois destes testes deve ser ativado o Schedule Trigger.

## 14. Segurança

Nunca guardar no repositório:

- API keys;
- passwords;
- tokens OAuth;
- credenciais Google;
- credenciais do n8n;
- ficheiros reais com informação confidencial.

Definir uma `N8N_ENCRYPTION_KEY` forte e persistente.

Restringir o acesso à interface do n8n e aplicar o princípio do menor privilégio às credenciais Google.

Mais detalhes em `docs/security.md`.

## 15. Estrutura do repositório

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
├── prompts/
│   └── invoice-extraction.md
├── skills/
├── taxonomy/
├── schemas/
├── examples/
├── tests/
└── docs/
    ├── architecture.md
    ├── google-sheet.md
    ├── workflow-n8n.md
    └── security.md
```

## Estado atual do projeto

A infraestrutura Docker, as regras do agente, o schema, a taxonomia e o workflow base estão definidos.

O workflow n8n ainda deve ser considerado **em desenvolvimento** até estarem implementados e testados todos os nós operacionais de leitura do Drive, controlo de duplicados, chamada ao LLM, escrita no Sheet e movimentação dos ficheiros.

Não ativar o workflow em produção antes dessa validação.

## Desenvolvimento

As alterações devem ser feitas através de branches e Pull Requests.

A branch `main` deve representar uma versão funcional e estável do projeto.
