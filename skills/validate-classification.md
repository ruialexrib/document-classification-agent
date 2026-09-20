# Skill: Validar classificação

## Validações
- O tipo documental existe na taxonomia.
- O estado é `CLASSIFIED`, `REVIEW` ou `ERROR`.
- A confiança está entre 0 e 1.
- O `drive_file_id` está presente.
- Campos obrigatórios do schema estão presentes.
- `CLASSIFIED` exige evidência suficiente.
- Classificações abaixo do limiar configurado devem ser `REVIEW`.

## Limiar inicial
Usar 0.80 como limiar inicial de confiança, sujeito a calibração pelos testes.
