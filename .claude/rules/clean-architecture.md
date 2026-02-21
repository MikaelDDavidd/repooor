# Clean Architecture Rules

## Dependencias Entre Camadas

### Permitido
- `presentation` → `domain`
- `data` → `domain`

### PROIBIDO
- `presentation` → `data` (NUNCA importar data/ em presentation/)
- `domain` → qualquer coisa (Dart puro, sem Flutter imports, sem packages externos)

A ligacao entre presentation e data acontece via dependency injection nos providers Riverpod.

## Camada: domain/
- **Entities**: classes puras Dart, imutaveis, sem annotations, sem dependencia externa
- **Repository interfaces**: abstract classes definindo contratos
- **UseCases**: uma classe por operacao, metodo unico `call()`

## Camada: data/
- **Models**: classes com serializacao SQL. Metodos obrigatorios:
  - `toMap()` → `Map<String, dynamic>` (para sqflite)
  - `fromMap(Map<String, dynamic>)` → factory constructor
  - `toEntity()` → converte para entity do domain
  - `fromEntity(Entity)` → factory constructor a partir da entity
- **Repository Impl**: implementa a interface do domain, usa DataSource
- **DataSource**: operacoes diretas no sqflite, retorna Models

## Camada: presentation/
- **Pages**: telas completas, usam providers para acessar dados
- **Widgets**: componentes visuais reutilizaveis
- **Providers**: ponte entre UI e domain (usecases), usam Riverpod

## Camada: core/
- **Theme**: AppTheme, AppColors, AppTextStyles
- **Constants**: valores fixos (categorias, unidades)
- **Utils**: funcoes auxiliares puras
- **Extensions**: extension methods em tipos basicos
- **Routes**: configuracao do GoRouter
