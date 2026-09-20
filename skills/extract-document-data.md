# Skill: Extrair dados da fatura

## Objetivo

Extrair os principais elementos comuns a faturas de água, eletricidade e comunicações.

## Campos obrigatórios de extração

- `issue_date`: data de emissão da fatura;
- `service`: tipo de serviço identificado;
- `amount_due`: valor total a pagar;
- `multibanco_entity`: entidade Multibanco;
- `multibanco_reference`: referência Multibanco;
- `payment_deadline`: data limite de pagamento.

## Campos complementares

Sempre que existirem de forma explícita, podem ainda ser extraídos:

- `provider`: entidade fornecedora;
- `invoice_number`: número da fatura;
- `customer_number`: número de cliente ou contrato;
- `currency`: moeda.

## Regras de extração

1. Não preencher campos por suposição.
2. Informação inexistente deve ser `null`.
3. Datas devem usar formato ISO 8601 `YYYY-MM-DD`.
4. `amount_due` deve conter apenas o valor numérico efetivamente a pagar.
5. Não confundir subtotal, valor sem IVA, consumos parciais ou saldo anterior com o valor total a pagar.
6. `multibanco_entity` e `multibanco_reference` devem ser preservados como texto para não perder zeros iniciais.
7. `payment_deadline` deve representar a data limite de pagamento.
8. Se existirem vários blocos de pagamento, selecionar o que corresponde à fatura atual; se não for possível determinar com segurança, devolver `REVIEW`.
9. O tipo de serviço deve respeitar os valores definidos na taxonomia.
