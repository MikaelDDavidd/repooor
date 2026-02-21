# Repooor - App de Gestao de Despensa

## Overview
App Flutter de gestao de despensa domestica. Permite registrar produtos, controlar quantidades na despensa, planejar e registrar compras mensais/avulsas, e analisar padroes de consumo. Foco em quantidades, sem tracking de precos.

## Tech Stack
- **Framework**: Flutter / Dart
- **State Management**: Riverpod (flutter_riverpod + riverpod_annotation)
- **Storage**: sqflite (local SQLite)
- **Routing**: GoRouter (go_router)
- **Charts**: fl_chart
- **Code Generation**: build_runner + riverpod_generator
- **IDs**: uuid

## Architecture
Clean Architecture com 4 camadas:

```
lib/
├── core/           # theme, constants, utils, extensions, routes
├── data/           # models, datasources, repository implementations
├── domain/         # entities, repository interfaces, usecases
└── presentation/   # pages, widgets, providers
```

## Data Flow
```
Widget → Provider → UseCase → Repository Interface → Repository Impl → DataSource → sqflite
```

## Design System
Baseado no design de referencia (Group 6893.png):

- **Primary**: #53B175 (verde)
- **Background**: #FFFFFF (principal), #F2F3F2 (secundario)
- **Text Primary**: #181725
- **Text Secondary**: #7C7C7C
- **Cards**: branco, border-radius 12px, sombra sutil
- **Bottom Navigation**: 4-5 tabs
- **UI**: limpa, moderna, espacamento generoso

## Entidades Principais

### Product
- name, categoryId, unit (kg, un, L, etc.)

### Category
- name, icon, color

### PantryItem
- productId, currentQuantity, idealQuantity

### Purchase
- date, type (main / midMonth), items

### PurchaseItem
- productId, quantity

## Principios
- SOLID, DRY, KISS
- Codigo em ingles, sem comentarios
- Single Responsibility rigoroso
- Clean Architecture: domain NUNCA depende de Flutter/data

## Naming Conventions
- Arquivos: `snake_case.dart`
- Classes: `PascalCase`
- Pages: `{name}_page.dart` → `{Name}Page`
- Models: `{entity}_model.dart` → `{Name}Model`
- Entities: `{name}.dart` → `{Name}`
- Repositories: `{name}_repository.dart` (interface) / `{name}_repository_impl.dart` (impl)
- UseCases: `{verb}_{noun}.dart` → `{VerbNoun}`
- Providers: `{scope}_providers.dart`
- DataSources: `{name}_local_ds.dart`
- Widgets compartilhados: `presentation/shared/widgets/`

## Dependencias Chave
```yaml
dependencies:
  flutter_riverpod:
  riverpod_annotation:
  sqflite:
  path:
  go_router:
  fl_chart:
  uuid:

dev_dependencies:
  build_runner:
  riverpod_generator:
  riverpod_lint:
```

## Comandos
```bash
# Rodar o app
flutter run

# Code generation (Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs
```
