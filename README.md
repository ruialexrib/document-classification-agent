<div align="center">

# Document Classification Agent

### Agente de IA para classificação e extração automática de dados de faturas

[![n8n](https://img.shields.io/badge/n8n-Automa%C3%A7%C3%A3o-EA4B71?logo=n8n&logoColor=white)](#arranque-com-docker)
[![Google Drive](https://img.shields.io/badge/Google%20Drive-Documentos-4285F4?logo=googledrive&logoColor=white)](#configura%C3%A7%C3%A3o-google)
[![Google Sheets](https://img.shields.io/badge/Google%20Sheets-Registo-34A853?logo=googlesheets&logoColor=white)](#google-sheets)
[![Docker](https://img.shields.io/badge/Docker-n8n-2496ED?logo=docker&logoColor=white)](#arranque-com-docker)
[![GroqCloud](https://img.shields.io/badge/GroqCloud-LLM-F55036)](#configura%C3%A7%C3%A3o-groqcloud)
[![IA](https://img.shields.io/badge/IA-Classifica%C3%A7%C3%A3o-6C63FF)](#princ%C3%ADpio-essencial)

**Água · Eletricidade · Comunicações · Extração de dados · Google Drive · Google Sheets · n8n**

Desenvolvido por [Rui Ribeiro](https://github.com/ruialexrib)

</div>

---

## Sobre

Este repositório contém a configuração, workflow n8n, regras, skills, schemas, exemplos e infraestrutura necessários para executar um agente de classificação documental orientado ao processamento automático de faturas.

O agente monitoriza uma pasta no Google Drive, identifica novas faturas, extrai o respetivo conteúdo, classifica o serviço e regista os principais dados num Google Sheets.

A execução é feita em **n8n**, dentro de um contentor Docker, utilizando **GroqCloud** como provider do modelo de linguagem.

> A IA apoia a leitura, classificação e extração dos dados, mas documentos ambíguos ou com informação insuficiente devem permanecer identificados para revisão humana.

---

## Objetivo

A versão atual processa inicialmente três tipos de faturas:

- água;
- eletricidade;
- comunicações.

Para cada documento procura extrair:

| Campo | Descrição |
| --- | --- |
| Data de emissão | Data em que a fatura foi emitida |
| Serviço | Água, eletricidade ou comunicações |
| Valor a pagar | Montante total efetivamente devido |
| Entidade Multibanco | Entidade associada ao pagamento |
| Referência Multibanco | Referência associada ao pagamento |
| Data limite de pagamento | Data até à qual o pagamento deve ser efetuado |

Sempre que disponíveis de forma explícita, podem também ser recolhidos fornecedor, número da fatura, número de cliente ou contrato e moeda.

---

## Fluxo

```text
Google Drive
Documentos_A_Classificar
        │
        ▼
n8n verifica novos ficheiros
de 5 em 5 minutos
        │
        ▼
Identificar PDF
        │
        ▼
Descarregar documento
        │
        ▼
Extrair texto do PDF
        │
        ▼
Classificar e extrair dados
via GroqCloud
        │
        ▼
Validar resultado
        │
        ▼
Registar no Google Sheets
        │
        ├───────────────┬───────────────┐
        ▼               ▼               ▼
 CLASSIFIED          REVIEW           ERROR
        │               │               │
        ▼               ▼               ▼
 Processados        A_Rever         Com_Erro
```

---

## Pré-requisitos

Antes de iniciar, é necessário ter:

- Git;
- Docker Desktop ou Docker Engine;
- Docker Compose;
- uma conta Google;
- um projeto no Google Cloud;
- uma conta GroqCloud e respetiva API key.

Confirmar Docker:

```bash
docker --version
docker compose version
```

---

## Clonar o repositório

```bash
git clone https://github.com/ruialexrib/document-classification-agent.git
cd document-classification-agent
```

Se estiveres a trabalhar numa branch de desenvolvimento:

```bash
git checkout feat/operational-n8n-workflow
git pull
```

---

## Configuração do ficheiro .env

Criar o ficheiro local:

### Windows

```powershell
copy .env.example .env
```

### Linux/macOS

```bash
cp .env.example .env
```

O ficheiro `.env` não deve ser enviado para o GitHub.

Exemplo:

```env
# n8n
N8N_PORT=5678
N8N_HOST=localhost
N8N_PROTOCOL=http
GENERIC_TIMEZONE=Europe/Lisbon
TZ=Europe/Lisbon

# Segurança n8n
N8N_ENCRYPTION_KEY=colocar-aqui-uma-chave-longa-e-aleatoria

# Google Drive
GOOGLE_DRIVE_INPUT_FOLDER_ID=
GOOGLE_DRIVE_PROCESSED_FOLDER_ID=
GOOGLE_DRIVE_REVIEW_FOLDER_ID=
GOOGLE_DRIVE_ERROR_FOLDER_ID=

# Google Sheets
GOOGLE_SHEET_ID=
GOOGLE_SHEET_NAME=Registo_Classificacao

# GroqCloud
LLM_PROVIDER=groq
LLM_BASE_URL=https://api.groq.com/openai/v1
GROQ_API_KEY=
LLM_MODEL=qwen/qwen3.6-27b

# Email de notificação
NOTIFICATION_EMAIL=
```

O `docker-compose.yml` define adicionalmente:

```env
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
```

Isto é necessário porque o workflow utiliza variáveis de ambiente através de `$env`.

### Gerar N8N_ENCRYPTION_KEY

Pode ser utilizada uma string aleatória longa. Por exemplo, com OpenSSL:

```bash
openssl rand -hex 32
```

A mesma chave deve ser preservada entre reinícios e reinstalações que reutilizem as credenciais do n8n.

---

## Estrutura Google Drive

Criar uma estrutura semelhante a:

```text
Classificacao_Documental/
├── Documentos_A_Classificar/
├── Documentos_Processados/
├── Documentos_A_Rever/
└── Documentos_Com_Erro/
```

Copiar o ID de cada pasta para o `.env`.

Num URL Google Drive semelhante a:

```text
https://drive.google.com/drive/folders/PASTA_ID
```

o valor `PASTA_ID` é o identificador a colocar no `.env`.

---

## Google Sheets

Criar uma folha de cálculo e um separador denominado:

```text
Registo_Classificacao
```

O nome pode ser diferente, desde que coincida com:

```env
GOOGLE_SHEET_NAME=
```

A folha deve conter na primeira linha os seguintes cabeçalhos:

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

O ID da folha encontra-se no URL:

```text
https://docs.google.com/spreadsheets/d/GOOGLE_SHEET_ID/edit
```

Colocar esse valor em:

```env
GOOGLE_SHEET_ID=
```

---

## Configuração Google

### 1. Criar ou selecionar um projeto Google Cloud

Abrir o Google Cloud Console e criar ou selecionar um projeto para o agente.

### 2. Ativar APIs

Em **APIs e serviços**, ativar:

- Google Drive API;
- Google Sheets API;
- Gmail API.

### 3. Configurar Google Auth Platform

Abrir:

```text
Google Auth Platform
```

Configurar:

#### Branding

Definir, por exemplo:

```text
App name: document-classification-agent
User support email: <o teu email>
Developer contact information: <o teu email>
```

#### Audience

Para utilização pessoal com uma conta Gmail:

```text
Audience: External
Publishing status: Testing
```

Em **Test users**, adicionar a conta Google que será utilizada no n8n.

Se a conta não for adicionada, o Google pode devolver:

```text
Erro 403: access_denied
A app está a ser testada e só pode ser acedida por testadores aprovados.
```

### 4. Criar cliente OAuth

Ir a:

```text
Google Auth Platform
→ Clients
→ Create client
→ Web application
```

Configurar o redirect URI:

```text
http://localhost:5678/rest/oauth2-credential/callback
```

Se o n8n estiver disponível noutro hostname ou porta, utilizar exatamente o callback apresentado pelo próprio n8n na criação da credencial.

Guardar:

- Client ID;
- Client Secret.

O mesmo Client ID e Client Secret podem ser utilizados para Google Drive e Google Sheets.

---

## Configuração GroqCloud

Criar uma API key na conta GroqCloud e colocar apenas no ficheiro local `.env`:

```env
GROQ_API_KEY=gsk_...
```

Nunca colocar a chave real em:

- `.env.example`;
- workflow JSON;
- commits;
- issues;
- README.

Configuração esperada:

```env
LLM_PROVIDER=groq
LLM_BASE_URL=https://api.groq.com/openai/v1
LLM_MODEL=qwen/qwen3.6-27b
```

---

## Arranque com Docker

Depois de configurar o `.env`:

```bash
docker compose up -d
```

O n8n fica disponível em:

```text
http://localhost:5678
```

Ver logs:

```bash
docker logs -f document-classification-n8n
```

Parar:

```bash
docker compose down
```

Recriar após alteração de configuração:

```bash
docker compose down
docker compose up -d
```

---

## Importação automática do workflow

O contentor importa automaticamente no arranque:

```text
n8n/workflows/document-classification.json
```

O processo de arranque é:

```text
docker compose up -d
        ↓
preparar contentor
        ↓
importar workflow
        ↓
iniciar n8n
```

Se a importação do workflow falhar, o contentor termina com erro para evitar arrancar silenciosamente sem workflow.

O workflow é importado inicialmente desativado.

---

## Configurar credenciais no n8n

### Google Drive

Abrir um nó Google Drive, por exemplo:

```text
List input files
```

Em **Credential**, criar:

```text
Google Drive OAuth2 API
```

Preencher:

- Client ID;
- Client Secret.

Autorizar a conta Google.

Depois reutilizar a mesma credencial nos nós:

```text
List input files
Download PDF
Move to Processed
Move to Review
Move to Error
```

### Google Sheets

No nó:

```text
Append classification to Google Sheets
```

criar uma credencial:

```text
Google Sheets OAuth2 API
```

Pode utilizar o mesmo Client ID e Client Secret.

Autorizar a mesma conta Google.

> O consentimento OAuth é necessário pelo menos uma vez. Depois, as credenciais ficam persistidas no volume `n8n_data`.

### Gmail

No nó:

```text
Send notification email
```

criar uma credencial:

```text
Gmail OAuth2 API
```

Pode ser utilizado o mesmo projeto Google Cloud, Client ID e Client Secret usados nas restantes integrações Google, desde que a **Gmail API** esteja ativa.

O destinatário não fica gravado no workflow. É lido do ficheiro `.env`:

```env
NOTIFICATION_EMAIL=nome@example.com
```

O email é enviado no fim do processamento, depois de o ficheiro ser encaminhado para a pasta correspondente. Inclui o estado, serviço, fornecedor, número da fatura, datas, valor, dados Multibanco, confiança e eventual motivo de revisão.

---

## Testar o workflow

Antes de ativar a execução automática, utilizar o trigger:

```text
Manual test
```

### Teste recomendado

1. colocar uma única fatura PDF em `Documentos_A_Classificar`;
2. abrir o workflow no n8n;
3. executar `Manual test`;
4. acompanhar os nós;
5. confirmar a linha criada no Google Sheets;
6. confirmar o movimento do ficheiro para a pasta correta.

Percurso esperado:

```text
Manual test
   ↓
Validate configuration
   ↓
List input files
   ↓
Skip already processed
   ↓
Is PDF?
   ↓
Download PDF
   ↓
Extract PDF text
   ↓
Has extractable text?
   ↓
Classify with GroqCloud
   ↓
Validate structured result
   ↓
Append classification to Google Sheets
   ↓
Mark as processed
   ↓
Move to Processed / Review / Error
   ↓
Send notification email
```

---

## Faturas de demonstração

O repositório inclui três faturas fictícias:

```text
examples/demo-invoices/
├── fatura_demo_agua.pdf
├── fatura_demo_eletricidade.pdf
└── fatura_demo_comunicacoes.pdf
```

Podem ser utilizadas para testar a classificação sem recorrer a documentos reais.

Copiar uma das faturas para a pasta Google Drive `Documentos_A_Classificar` e executar `Manual test`.

---

## Resultado esperado

Uma classificação bem sucedida deverá produzir um registo semelhante a:

```json
{
  "drive_file_id": "example-drive-file-id",
  "file_name": "fatura_demo_eletricidade.pdf",
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
  "reasoning_summary": "A fatura identifica fornecimento de eletricidade.",
  "review_reason": null,
  "rules_version": "0.2.0"
}
```

---

## Estados de processamento

| Estado | Significado |
| --- | --- |
| `CLASSIFIED` | Documento processado com evidência suficiente |
| `REVIEW` | Documento ambíguo ou com informação insuficiente |
| `ERROR` | Falha técnica ou impossibilidade de leitura |

A ausência de um campo numa fatura não constitui automaticamente erro.

---

## Ativar execução automática

Depois de validar com sucesso o modo manual:

1. guardar o workflow;
2. ativar/publicar o workflow no n8n;
3. confirmar que o trigger `Every 5 minutes` está ativo.

A partir daí o n8n verificará periodicamente a pasta de entrada.

---

## Troubleshooting

### `access to env vars denied`

Confirmar que o `docker-compose.yml` contém:

```yaml
- N8N_BLOCK_ENV_ACCESS_IN_NODE=false
```

Depois:

```bash
docker compose down
docker compose up -d
```

### `Node does not have any credentials set`

Abrir o nó e selecionar a credencial Google correspondente. O nó `Send notification email` necessita de uma credencial `Gmail OAuth2 API`.

### Google OAuth: `403 access_denied`

Confirmar em:

```text
Google Auth Platform → Audience → Test users
```

que a conta utilizada está adicionada como test user.

### Callback OAuth inválido

Confirmar:

```text
http://localhost:5678/rest/oauth2-credential/callback
```

e comparar com o callback apresentado pelo próprio n8n.

### `SQLITE_CONSTRAINT: NOT NULL constraint failed: workflow_entity.id`

Utilizar a versão atual do workflow existente no repositório. O JSON contém um `id` fixo compatível com a importação CLI do n8n.

### O PDF é enviado para REVIEW apesar de conter texto

Abrir o output de:

```text
Extract PDF text
```

e confirmar que existe o campo:

```text
text
```

A versão atual testa explicitamente se o conteúdo extraído contém pelo menos 20 caracteres.

### PDF digitalizado

Se não existir texto extraível, o workflow encaminha o ficheiro para `REVIEW`. OCR automático ainda não faz parte desta versão.

### Ver logs do contentor

```bash
docker logs --tail 200 document-classification-n8n
```

ou:

```bash
docker logs -f document-classification-n8n
```

---

## Estrutura do repositório

```text
README.md
INSTRUCTIONS.md
docker-compose.yml
.env.example

docker/
└── n8n/
    └── entrypoint.sh

n8n/
└── workflows/
    └── document-classification.json

skills/
├── extract-document-data.md
├── classify-document.md
├── validate-classification.md
├── handle-uncertain-document.md
└── register-result.md

taxonomy/
├── document-types.yaml
└── classification-rules.yaml

schemas/
└── classification.schema.json

examples/
├── classification-example.json
└── demo-invoices/
    ├── README.md
    ├── fatura_demo_agua.pdf
    ├── fatura_demo_eletricidade.pdf
    └── fatura_demo_comunicacoes.pdf

tests/
└── classification-cases.yaml

docs/
├── architecture.md
├── workflow-n8n.md
└── security.md
```

---

## Skills do agente

As skills documentam as responsabilidades funcionais do agente:

| Skill | Responsabilidade |
| --- | --- |
| `extract-document-data` | Extrair os principais campos da fatura |
| `classify-document` | Identificar o tipo de serviço |
| `validate-classification` | Verificar consistência e confiança |
| `handle-uncertain-document` | Encaminhar situações ambíguas para revisão |
| `register-result` | Preparar o registo final |

Na versão atual, as regras essenciais estão embebidas no workflow n8n. As skills constituem a especificação funcional e base para futuras evoluções.

---

## Princípio essencial

O agente não deve inventar nem forçar informação.

Em particular:

- não deve inventar referências Multibanco;
- não deve escolher arbitrariamente entre vários valores;
- não deve confundir subtotal com valor final a pagar;
- não deve confundir data de emissão com data limite de pagamento;
- não deve assumir o tipo de serviço apenas pelo nome do ficheiro;
- não deve esconder situações ambíguas.

Quando existe informação insuficiente, o documento deve ser marcado como `REVIEW`.

---

## Segurança

Nunca devem ser guardados no repositório:

- API keys;
- passwords;
- tokens OAuth;
- Client Secrets;
- credenciais n8n;
- ficheiros `.env` reais;
- documentos reais com informação confidencial.

O `.env` local deve permanecer excluído através do `.gitignore`.

As credenciais OAuth ficam cifradas pelo n8n utilizando a `N8N_ENCRYPTION_KEY`.

---

## Documentação principal

| Documento | Finalidade |
| --- | --- |
| [`INSTRUCTIONS.md`](INSTRUCTIONS.md) | Regras centrais do agente |
| [`taxonomy/document-types.yaml`](taxonomy/document-types.yaml) | Tipos suportados |
| [`taxonomy/classification-rules.yaml`](taxonomy/classification-rules.yaml) | Regras funcionais |
| [`schemas/classification.schema.json`](schemas/classification.schema.json) | Schema do resultado |
| [`docs/architecture.md`](docs/architecture.md) | Arquitetura |
| [`docs/workflow-n8n.md`](docs/workflow-n8n.md) | Funcionamento do workflow |
| [`docs/security.md`](docs/security.md) | Segurança |
| [`tests/classification-cases.yaml`](tests/classification-cases.yaml) | Casos de teste |

---

## Desenvolvimento

As alterações ao projeto devem ser efetuadas através de branches e Pull Requests.

A branch `main` deve representar uma versão funcional e estável do projeto.
