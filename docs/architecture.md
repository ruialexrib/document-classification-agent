# Arquitetura

## Objetivo funcional

A solução processa faturas de:

- água;
- eletricidade;
- comunicações.

Para cada documento, identifica o serviço e extrai os principais dados de pagamento:

- data de emissão;
- valor a pagar;
- entidade Multibanco;
- referência Multibanco;
- data limite de pagamento.

## Componentes

### Google Drive
Origem das faturas e destino dos ficheiros após processamento.

### n8n
Orquestrador. Executa o workflow de cinco em cinco minutos, chama os serviços necessários e regista os resultados.

### LLM
Executa a leitura semântica, extração e classificação segundo as instruções, skills, taxonomia e schema deste repositório.

### Google Sheets
Registo operacional e de auditoria.

## Separação de responsabilidades

O GitHub contém lógica declarativa e infraestrutura.
O n8n contém a orquestração.
As credenciais permanecem fora do repositório.
