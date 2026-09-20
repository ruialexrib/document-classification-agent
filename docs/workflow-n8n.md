# Workflow n8n

O workflow base encontra-se em `n8n/workflows/document-classification.json` e é importado no arranque do contentor.

## Periodicidade

A execução está preparada para uma cadência de cinco minutos.

## Provider de IA

O provider definido para o projeto é o **GroqCloud**.

A API da Groq é compatível com a API OpenAI para este tipo de integração.

Configuração prevista:

```env
LLM_PROVIDER=groq
LLM_BASE_URL=https://api.groq.com/openai/v1
GROQ_API_KEY=
LLM_MODEL=qwen/qwen3.6-27b
```

A chave real deve existir apenas no ficheiro local `.env` ou no gestor de credenciais do n8n. Nunca deve ser incluída no repositório.

## Configuração necessária

1. Configurar credenciais Google Drive e Google Sheets no n8n.
2. Preencher os IDs das pastas no ficheiro `.env`.
3. Criar uma API key no GroqCloud.
4. Preencher `GROQ_API_KEY` apenas no ambiente local.
5. Confirmar o modelo definido em `LLM_MODEL`.
6. Rever o Google Sheet de destino.
7. Ativar o workflow apenas depois de validar uma execução manual.

## Modelo inicial

O projeto usa inicialmente:

```text
qwen/qwen3.6-27b
```

O modelo pode ser substituído por outro modelo ativo no GroqCloud sem alterar a restante arquitetura, desde que seja adequado a extração estruturada e JSON.

## Idempotência

O `drive_file_id` deve ser usado para impedir o processamento repetido do mesmo ficheiro.

## Pastas previstas

- Documentos_A_Classificar
- Documentos_Processados
- Documentos_A_Rever
- Documentos_Com_Erro
