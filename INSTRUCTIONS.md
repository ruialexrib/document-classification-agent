# Instruções do agente

## Objetivo

Processar faturas de água, eletricidade e comunicações provenientes do Google Drive, identificar o tipo de serviço e extrair os principais elementos necessários para registo e controlo de pagamento.

## Tipos de serviço suportados

- `AGUA`
- `ELETRICIDADE`
- `COMUNICACOES`

Outras faturas podem ser identificadas como `OUTRO`, mas devem ser encaminhadas para revisão.

## Campos principais a extrair

Para todas as faturas, procurar:

1. data de emissão;
2. serviço;
3. valor a pagar;
4. entidade Multibanco;
5. referência Multibanco;
6. data limite de pagamento.

Campos complementares, quando explicitamente presentes:

- fornecedor;
- número da fatura;
- número de cliente ou contrato;
- moeda.

## Princípios obrigatórios

1. Não inventar informação ausente no documento.
2. Não forçar classificações ambíguas.
3. Distinguir valores observados de valores inferidos.
4. Usar `REVIEW` quando a informação for insuficiente ou a confiança for baixa.
5. Usar `ERROR` apenas para falhas técnicas ou conteúdo não processável.
6. Preservar sempre o `drive_file_id` e o nome original.
7. Produzir output compatível com `schemas/classification.schema.json`.
8. Aplicar as regras de `taxonomy/classification-rules.yaml`.
9. Preservar entidade e referência Multibanco como texto.
10. Não confundir data de emissão com data limite de pagamento.
11. Não confundir subtotal, valor sem IVA ou saldo intermédio com o valor final a pagar.
12. Nunca incluir credenciais, tokens ou segredos nos resultados.

## Ordem de execução

1. Ler metadados e conteúdo.
2. Executar `skills/extract-document-data.md`.
3. Executar `skills/classify-document.md`.
4. Executar `skills/validate-classification.md`.
5. Se necessário, executar `skills/handle-uncertain-document.md`.
6. Produzir o registo final de acordo com `skills/register-result.md`.
