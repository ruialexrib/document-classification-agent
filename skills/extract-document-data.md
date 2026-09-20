# Skill: Extrair dados do documento

## Objetivo
Extrair apenas dados suportados pelo conteúdo do documento.

## Campos preferenciais
- entidade;
- data do documento;
- número do documento;
- valor total;
- moeda;
- NIF/NIPC, quando existente;
- assunto ou descrição curta.

## Regras
- Não preencher campos por suposição.
- Datas devem usar ISO 8601 (`YYYY-MM-DD`) sempre que possível.
- Valores monetários devem ser números, sem símbolos.
- Informação inexistente deve ser `null`.
