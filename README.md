<div align="center">

# Document Classification Agent

### Agente de IA para classificação e extração automática de dados de faturas

[![n8n](https://img.shields.io/badge/n8n-Automa%C3%A7%C3%A3o-EA4B71?logo=n8n&logoColor=white)](#execu%C3%A7%C3%A3o)
[![Google Drive](https://img.shields.io/badge/Google%20Drive-Documentos-4285F4?logo=googledrive&logoColor=white)](#google-drive)
[![Google Sheets](https://img.shields.io/badge/Google%20Sheets-Registo-34A853?logo=googlesheets&logoColor=white)](#resultado)
[![Docker](https://img.shields.io/badge/Docker-n8n-2496ED?logo=docker&logoColor=white)](#execu%C3%A7%C3%A3o)
[![IA](https://img.shields.io/badge/IA-Classifica%C3%A7%C3%A3o-6C63FF)](#princ%C3%ADpio-essencial)

**Água · Eletricidade · Comunicações · Extração de dados · Google Drive · Google Sheets · n8n**

Desenvolvido por [Rui Ribeiro](https://github.com/ruialexrib)

</div>

---

## Sobre

Este repositório contém as instruções, skills, regras, schemas, exemplos, testes e infraestrutura necessários para executar um **agente de classificação documental** orientado ao processamento automático de faturas.

O agente monitoriza uma pasta no Google Drive, identifica novas faturas, classifica o respetivo serviço e extrai os principais dados necessários para registo e controlo de pagamento.

O processo é orquestrado por **n8n**, executado em Docker, com verificação periódica de novos documentos.

> A IA apoia a leitura, classificação e extração dos dados, mas documentos ambíguos ou com informação insuficiente devem permanecer identificados para revisão humana.

---

## Objetivo

O agente foi concebido inicialmente para processar três tipos de faturas:

- água;
- eletricidade;
- comunicações.

Para cada documento, procura identificar e extrair:

| Campo | Descrição |
| --- | --- |
| Data de emissão | Data em que a fatura foi emitida |
| Serviço | Água, eletricidade ou comunicações |
| Valor a pagar | Montante total efetivamente devido |
| Entidade Multibanco | Entidade associada ao pagamento |
| Referência Multibanco | Referência associada ao pagamento |
| Data limite de pagamento | Data até à qual o pagamento deve ser efetuado |

Sempre que disponíveis de forma explícita, podem também ser recolhidos:

- fornecedor;
- número da fatura;
- número de cliente ou contrato;
- moeda.

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
Identificar documento
        │
        ▼
Extrair conteúdo
        │
        ▼
Classificar serviço
Água / Eletricidade / Comunicações
        │
        ▼
Extrair dados da fatura
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

## Resultado

Cada documento processado origina um registo estruturado no Google Sheets.

| Campo | Exemplo |
| --- | --- |
| Serviço | `ELETRICIDADE` |
| Data de emissão | `2026-09-10` |
| Valor a pagar | `84.27` |
| Entidade Multibanco | `12345` |
| Referência Multibanco | `123456789` |
| Data limite | `2026-09-30` |
| Estado | `CLASSIFIED` |
| Confiança | `0.97` |

Exemplo de output estruturado:

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

---

## Estados de processamento

| Estado | Significado |
| --- | --- |
| `CLASSIFIED` | Documento processado com evidência suficiente |
| `REVIEW` | Documento ambíguo ou com informação insuficiente |
| `ERROR` | Falha técnica ou impossibilidade de leitura |

A ausência de um campo numa fatura não constitui automaticamente erro. Sempre que o valor não estiver disponível de forma segura, o campo deve permanecer `null`.

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
└── classification-example.json

tests/
└── classification-cases.yaml

docs/
├── architecture.md
├── workflow-n8n.md
└── security.md
```

---

## Skills do agente

Cada skill tem uma responsabilidade específica.

| Skill | Responsabilidade |
| --- | --- |
| `extract-document-data` | Extrair os principais campos da fatura |
| `classify-document` | Identificar o tipo de serviço |
| `validate-classification` | Verificar consistência e confiança |
| `handle-uncertain-document` | Encaminhar situações ambíguas para revisão |
| `register-result` | Preparar o registo final para o Google Sheets |

---

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

O `drive_file_id` é utilizado como identificador técnico principal de cada documento para evitar processamentos duplicados.

---

## Execução

### 1. Criar configuração local

```bash
cp .env.example .env
```

Preencher as variáveis necessárias no ficheiro `.env`.

### 2. Iniciar o n8n

```bash
docker compose up -d
```

Por defeito, o n8n ficará disponível em:

```text
http://localhost:5678
```

### 3. Importação automática do workflow

O contentor importa no arranque:

```text
n8n/workflows/document-classification.json
```

O workflow é disponibilizado inicialmente **desativado**, para permitir configurar e testar as credenciais antes da execução automática.

---

## Configuração do n8n

Após o primeiro arranque:

1. configurar as credenciais do Google Drive;
2. configurar as credenciais do Google Sheets;
3. configurar o fornecedor do modelo de linguagem;
4. indicar os IDs das pastas;
5. indicar o Google Sheet de destino;
6. executar o workflow manualmente;
7. validar o resultado;
8. ativar o workflow.

A execução automática está preparada para uma cadência de **5 em 5 minutos**.

---

## Princípio essencial

O agente **não deve inventar nem forçar informação**.

Em particular:

- não deve inferir uma referência Multibanco inexistente;
- não deve escolher arbitrariamente entre vários valores;
- não deve confundir subtotal com valor final a pagar;
- não deve confundir data de emissão com data limite de pagamento;
- não deve assumir o tipo de serviço apenas pelo nome do ficheiro;
- não deve esconder situações ambíguas.

Quando existem alternativas plausíveis ou informação insuficiente, o documento deve ser marcado como `REVIEW`.

Este princípio procura garantir:

- transparência;
- rastreabilidade;
- auditabilidade;
- qualidade dos dados;
- controlo humano sobre situações ambíguas.

---

## Segurança

Nunca devem ser guardados no repositório:

- chaves de API;
- passwords;
- tokens OAuth;
- credenciais Google;
- credenciais n8n;
- documentos reais com informação confidencial.

As credenciais devem ser geridas através das variáveis de ambiente e do gestor de credenciais do n8n.

Deve ser utilizada uma `N8N_ENCRYPTION_KEY` forte e persistente.

---

## Documentação principal

| Documento | Finalidade |
| --- | --- |
| [`INSTRUCTIONS.md`](INSTRUCTIONS.md) | Regras centrais do agente |
| [`taxonomy/document-types.yaml`](taxonomy/document-types.yaml) | Tipos de documentos e serviços suportados |
| [`taxonomy/classification-rules.yaml`](taxonomy/classification-rules.yaml) | Regras funcionais de classificação |
| [`schemas/classification.schema.json`](schemas/classification.schema.json) | Estrutura obrigatória do resultado |
| [`docs/architecture.md`](docs/architecture.md) | Arquitetura da solução |
| [`docs/workflow-n8n.md`](docs/workflow-n8n.md) | Funcionamento do workflow |
| [`docs/security.md`](docs/security.md) | Regras de segurança |
| [`tests/classification-cases.yaml`](tests/classification-cases.yaml) | Casos de teste |

---

## Desenvolvimento

As alterações ao projeto devem ser efetuadas através de branches e Pull Requests.

A branch `main` deve representar uma versão funcional e estável do projeto.
