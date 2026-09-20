# Workflow n8n

O workflow base encontra-se em `n8n/workflows/document-classification.json` e é importado no arranque do contentor.

## Periodicidade
A execução está preparada para uma cadência de cinco minutos.

## Configuração necessária
1. Configurar credenciais Google Drive e Google Sheets no n8n.
2. Preencher os IDs das pastas no ficheiro `.env`.
3. Configurar o endpoint e a chave do LLM.
4. Rever o Google Sheet de destino.
5. Ativar o workflow depois de validar uma execução manual.

## Idempotência
O `drive_file_id` deve ser usado para impedir o processamento repetido do mesmo ficheiro.

## Pastas previstas
- Documentos_A_Classificar
- Documentos_Processados
- Documentos_A_Rever
- Documentos_Com_Erro
