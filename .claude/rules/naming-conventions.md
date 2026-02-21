# Naming Conventions

## Arquivos
Todos os arquivos Dart usam `snake_case.dart`.

## Classes e Arquivos por Tipo

| Tipo | Arquivo | Classe |
|------|---------|--------|
| Page | `{name}_page.dart` | `{Name}Page` |
| Widget | `{name}_widget.dart` ou `{name}_card.dart` | `{Name}Widget` / `{Name}Card` |
| Entity | `{name}.dart` | `{Name}` |
| Model | `{name}_model.dart` | `{Name}Model` |
| Repository (interface) | `{name}_repository.dart` | `{Name}Repository` |
| Repository (impl) | `{name}_repository_impl.dart` | `{Name}RepositoryImpl` |
| UseCase | `{verb}_{noun}.dart` | `{VerbNoun}` |
| Provider | `{scope}_providers.dart` | - |
| DataSource | `{name}_local_ds.dart` | `{Name}LocalDs` |
| Extension | `{type}_extension.dart` | `{Type}Extension` |

## Estrutura de Pastas

```
lib/
├── core/
│   ├── theme/
│   ├── constants/
│   ├── utils/
│   ├── extensions/
│   └── routes/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── home/
    │   ├── home_page.dart
    │   └── widgets/
    ├── pantry/
    ├── purchase/
    ├── analytics/
    └── shared/
        └── widgets/
```

## Variaveis e Metodos
- Variaveis e metodos: `camelCase`
- Constants: `camelCase` (Dart convention, nao SCREAMING_CASE)
- Privados: prefixo `_`
- Booleans: prefixo `is`, `has`, `should` (ex: `isEmpty`, `hasItems`)

## Banco de Dados (sqflite)
- Tabelas: `snake_case` plural (ex: `products`, `pantry_items`, `purchases`)
- Colunas: `snake_case` (ex: `category_id`, `current_quantity`)
