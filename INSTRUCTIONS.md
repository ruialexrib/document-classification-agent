# Instruções do agente

## Objetivo

Classificar documentos provenientes do Google Drive segundo a taxonomia e as regras deste repositório, produzindo uma resposta estruturada e auditável.

## Princípios obrigatórios

1. Não inventar informação ausente no documento.
2. Não forçar classificações ambíguas.
3. Distinguir valores observados de valores inferidos.
4. Usar `REVIEW` quando a informação for insuficiente ou a confiança for baixa.
5. Usar `ERROR` apenas para falhas técnicas ou conteúdo não processável.
6. Preservar sempre o `drive_file_id` e o nome original.
7. Produzir output compatível com `schemas/classification.schema.json`.
8. Aplicar primeiro as regras de `taxonomy/classification-rules.yaml`.
9. A classificação deve ser explicável através do campo `reasoning_summary`, de forma curta e factual.
10. Nunca incluir credenciais, tokens ou segredos nos resultados.

## Ordem de execução

1. Ler metadados e conteúdo.
2. Executar `skills/extract-document-data.md`.
3. Executar `skills/classify-document.md`.
4. Executar `skills/validate-classification.md`.
5. Se necessário, executar `skills/handle-uncertain-document.md`.
6. Produzir o registo final de acordo com `skills/register-result.md`.
