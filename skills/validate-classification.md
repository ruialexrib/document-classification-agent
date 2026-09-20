# Skill: Validar extração e classificação

## Validações estruturais

- O `drive_file_id` está presente.
- O estado é `CLASSIFIED`, `REVIEW` ou `ERROR`.
- A confiança está entre 0 e 1.
- O `service` é um dos valores permitidos.
- O resultado é compatível com `schemas/classification.schema.json`.

## Validações semânticas

Para `CLASSIFIED`, devem existir evidências suficientes para o tipo de serviço.

Os seguintes campos devem ser procurados em todas as faturas:

- `issue_date`;
- `amount_due`;
- `multibanco_entity`;
- `multibanco_reference`;
- `payment_deadline`.

A ausência de um campo não constitui automaticamente erro. O campo deve ficar `null`.

Usar `REVIEW` quando:

- existirem valores concorrentes para o total a pagar;
- existirem várias referências de pagamento sem ser possível identificar a atual;
- o serviço não puder ser determinado com segurança;
- o texto extraído estiver incompleto;
- a confiança for inferior a 0.80.

Usar `ERROR` apenas quando o documento não puder ser processado tecnicamente.
