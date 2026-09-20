# Arquitetura

## Componentes

### Google Drive
Origem dos documentos e destino dos ficheiros após processamento.

### n8n
Orquestrador. Executa o workflow de cinco em cinco minutos, chama serviços externos e regista resultados.

### LLM
Executa extração e classificação segundo as instruções, skills, taxonomia e schema deste repositório.

### Google Sheets
Registo operacional e de auditoria.

## Separação de responsabilidades

O GitHub contém lógica declarativa e infraestrutura.
O n8n contém a orquestração.
As credenciais permanecem fora do repositório.
