# Google Sheet de registo

Criar um Google Sheet dentro de `Classificacao_Documental` com o nome `Registo_Classificacao`.

Na primeira linha da folha, criar exatamente estas colunas:

| Coluna | Conteúdo |
|---|---|
| drive_file_id | ID único do ficheiro no Google Drive |
| file_name | Nome original do ficheiro |
| processed_at | Data/hora de processamento |
| document_type | Tipo documental |
| service | AGUA, ELETRICIDADE, COMUNICACOES ou OUTRO |
| provider | Fornecedor |
| invoice_number | Número da fatura |
| customer_number | Número de cliente/contrato |
| issue_date | Data de emissão |
| amount_due | Valor a pagar |
| currency | Moeda |
| multibanco_entity | Entidade Multibanco |
| multibanco_reference | Referência Multibanco |
| payment_deadline | Data limite de pagamento |
| status | CLASSIFIED, REVIEW ou ERROR |
| confidence | Confiança entre 0 e 1 |
| reasoning_summary | Justificação curta |
| review_reason | Motivo para revisão humana |
| rules_version | Versão das regras aplicadas |

## Regra de idempotência

O campo `drive_file_id` é a chave técnica do registo.

Antes de processar uma fatura, o workflow deve verificar se esse ID já existe no Sheet. Se existir e não houver indicação explícita para reprocessamento, o documento não deve ser processado novamente.

## Formatos recomendados

- Datas: `YYYY-MM-DD`
- `processed_at`: ISO 8601
- `amount_due`: número decimal
- `multibanco_entity`: texto
- `multibanco_reference`: texto
- `confidence`: número entre 0 e 1

Entidade e referência Multibanco devem ser tratadas como texto para preservar eventuais zeros iniciais.
