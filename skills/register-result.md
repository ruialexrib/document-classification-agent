# Skill: Registar resultado

O resultado final deve ser um único objeto compatível com `schemas/classification.schema.json`.

## Campos centrais do registo

- `drive_file_id`
- `file_name`
- `processed_at`
- `service`
- `issue_date`
- `amount_due`
- `multibanco_entity`
- `multibanco_reference`
- `payment_deadline`
- `status`
- `confidence`
- `rules_version`

## Campos complementares

- `document_type`
- `provider`
- `invoice_number`
- `customer_number`
- `currency`
- `reasoning_summary`
- `review_reason`

O registo destina-se a ser acrescentado a um Google Sheet para auditoria, controlo e eventual acompanhamento de pagamentos.

O `drive_file_id` deve ser usado como identificador técnico principal para evitar duplicações.
