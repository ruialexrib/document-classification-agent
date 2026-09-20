# Skill: Classificar fatura por serviço

## Objetivo

Determinar se o documento é uma fatura e, sendo-o, classificar o serviço como água, eletricidade ou comunicações.

## Valores possíveis

- `AGUA`
- `ELETRICIDADE`
- `COMUNICACOES`
- `OUTRO`
- `null` quando não se trate de uma fatura

## Procedimento

1. Confirmar que o documento apresenta características de fatura.
2. Identificar o fornecedor e a natureza do serviço.
3. Procurar evidências explícitas no conteúdo.
4. Aplicar `taxonomy/classification-rules.yaml`.
5. Determinar a confiança.
6. Se existirem classificações concorrentes ou evidência insuficiente, usar `REVIEW`.

## Exemplos de evidência

### Água
- água;
- saneamento;
- consumo em m³;
- abastecimento;
- serviços municipalizados de água.

### Eletricidade
- eletricidade;
- energia;
- consumo em kWh;
- potência contratada;
- CPE.

### Comunicações
- telecomunicações;
- internet;
- telefone;
- televisão;
- pacote de serviços;
- dados móveis.

## Regra fundamental

O nome do fornecedor pode ser utilizado como evidência auxiliar, mas a classificação deve ser sustentada pelo conteúdo da fatura.
