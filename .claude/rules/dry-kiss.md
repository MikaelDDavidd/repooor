# DRY & KISS Guidelines

## DRY - Nao Repita

### Widgets
- Widgets compartilhados ficam em `presentation/shared/widgets/`
- Se um widget aparece em 2+ telas, extrair para shared

### Cores e Estilos
- NUNCA hardcodar cores ou estilos nos widgets
- Sempre usar via Theme: `Theme.of(context).colorScheme`, `AppColors`, `AppTextStyles`
- Espacamentos e border-radius via constants quando repetidos

### Categorias
- Categorias default definidas UMA vez em `core/constants/`
- Icones e cores de categorias mapeados em um unico lugar

### Queries SQL
- Nomes de tabelas e colunas como constants no datasource
- Queries complexas extraidas para metodos nomeados

## KISS - Mantenha Simples

### Sem Over-Engineering
- Interfaces/abstractions APENAS para repositories (onde DIP eh necessario)
- Nao criar interfaces para services, utils ou helpers
- Nao criar camadas extras alem das 4 definidas (core, data, domain, presentation)

### Estado
- Usar `AsyncValue` do Riverpod para loading/error/data pattern
- Nao criar classes de estado customizadas quando AsyncValue resolve

### Build Methods
- Build methods com no maximo 50 linhas
- Extrair secoes em metodos privados ou widgets separados se ultrapassar

### Geral
- Nao criar abstractions para uso unico
- Nao adicionar features "para o futuro"
- Se 3 linhas repetidas resolvem, melhor que uma abstraction prematura
- Preferir composicao simples a heranca complexa
