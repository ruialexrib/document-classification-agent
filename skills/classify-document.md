# Skill: Classificar documento

## Objetivo
Atribuir um tipo e uma categoria documental segundo a taxonomia definida no repositório.

## Procedimento
1. Identificar evidências explícitas no documento.
2. Comparar essas evidências com `taxonomy/document-types.yaml`.
3. Aplicar `taxonomy/classification-rules.yaml`.
4. Determinar o nível de confiança.
5. Se existirem classificações plausíveis concorrentes, usar `REVIEW`.

## Proibições
- Não escolher uma categoria apenas para evitar `REVIEW`.
- Não inferir factos materiais sem evidência documental.
