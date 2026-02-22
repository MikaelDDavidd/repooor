<div align="center">

# Repooor

**Smart pantry management for your home.**

Track what you have, know what's running low, and never overbuy again.

[![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)]()

</div>

---

## Overview

Repooor is a mobile app that helps you manage your home pantry with zero friction. No cloud accounts, no price tracking, no complexity — just a clear view of what you have, what's running low, and what to buy next.

Everything stays on your device. Your data is yours.

### Key Features

- **Pantry Tracking** — Monitor current vs. ideal quantities with visual stock indicators
- **Smart Shopping Lists** — Auto-suggest items based on pantry deficits
- **Consumption Analytics** — Charts and insights on your buying patterns over time
- **Global Search** — Find any product instantly across pantry and purchase history
- **Data Portability** — Export/import your data as JSON, no lock-in
- **Built-in Calculator** — Quick calculations without leaving the app
- **100% Offline** — Works without internet, all data stored locally

## Screenshots

<div align="center">

> Screenshots coming soon.

<!--
| Home | Pantry | Purchases | Analytics |
|:----:|:------:|:---------:|:---------:|
| ![Home](screenshots/home.png) | ![Pantry](screenshots/pantry.png) | ![Purchases](screenshots/purchases.png) | ![Analytics](screenshots/analytics.png) |
-->

</div>

## Architecture

Built with **Clean Architecture** to keep concerns separated and the codebase maintainable.

```
lib/
├── core/              # Theme, routes, constants, DI
├── domain/            # Entities, repository interfaces, use cases
├── data/              # Models, data sources, repository implementations
└── presentation/      # Pages, widgets, providers
```

### Data Flow

```
UI → Provider → UseCase → Repository (interface) → Repository (impl) → DataSource → SQLite
```

The domain layer is pure Dart with zero external dependencies. Swapping the storage layer (e.g., SQLite to an API) requires no changes to business logic or UI.

### Data Model

```
┌──────────────┐       ┌──────────────────┐
│  categories  │       │    purchases     │
│──────────────│       │──────────────────│
│ id           │       │ id               │
│ name         │       │ date             │
│ icon         │       │ type             │
│ color        │       └────────┬─────────┘
└──────┬───────┘                │
       │                        │
┌──────┴───────┐       ┌───────┴──────────┐
│   products   │       │ purchase_items   │
│──────────────│       │──────────────────│
│ id           │◄──────│ product_id       │
│ name         │       │ purchase_id      │
│ category_id  │       │ quantity         │
│ unit         │       └──────────────────┘
└──────┬───────┘
       │
┌──────┴───────────┐
│  pantry_items    │
│──────────────────│
│ product_id       │
│ current_quantity │
│ ideal_quantity   │
└──────────────────┘
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | [Flutter](https://flutter.dev) |
| State Management | [Riverpod](https://riverpod.dev) |
| Local Storage | [sqflite](https://pub.dev/packages/sqflite) |
| Routing | [GoRouter](https://pub.dev/packages/go_router) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| Code Generation | [build_runner](https://pub.dev/packages/build_runner) + [riverpod_generator](https://pub.dev/packages/riverpod_generator) |

## Getting Started

### Prerequisites

- Flutter 3.38+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.10+

### Installation

```bash
# Clone the repository
git clone https://github.com/MikaelDDavidd/repooor.git
cd repooor

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Development

```bash
# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Run static analysis
flutter analyze

# Run tests
flutter test
```

## Project Structure

```
lib/
├── core/
│   ├── constants/        # Default categories, units
│   ├── di/               # Dependency injection (providers)
│   ├── extensions/       # Dart type extensions
│   ├── routes/           # GoRouter config, shell scaffold
│   ├── theme/            # Colors, text styles, app theme
│   └── utils/            # Pure helper functions
├── data/
│   ├── datasources/      # SQLite operations (one per aggregate)
│   ├── models/           # SQL-serializable models (toMap/fromMap)
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure Dart classes (no dependencies)
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Single-operation business logic
└── presentation/
    ├── analytics/        # Charts and consumption insights
    ├── calculator/       # Built-in calculator (FAB)
    ├── home/             # Dashboard with stock summary
    ├── onboarding/       # First-launch tutorial
    ├── pantry/           # Stock management
    ├── products/         # Product CRUD
    ├── providers/        # Riverpod state providers
    ├── purchase/         # Shopping list management
    ├── search/           # Global product search
    ├── settings/         # Export, import, preferences
    ├── shared/widgets/   # Reusable UI components
    └── splash/           # Launch screen
```

## Features in Detail

### Pantry Management
Track every item with current and ideal quantities. A color-coded progress bar shows stock levels at a glance — red for low (< 50%), yellow for medium (50–99%), green for full. Tap to edit, swipe to delete, or use quick +/- buttons.

### Smart Shopping Lists
Create monthly or mid-month shopping lists. Hit "Suggest" to auto-fill items based on what's running low in your pantry. When you finalize a purchase, quantities are automatically updated in your pantry.

### Consumption Analytics
Understand your buying habits with interactive charts — category distribution (pie), most purchased products (bar), and purchase frequency over time (line). Filter by 7, 30, or 90 days. Tap any category or product to drill down into details.

### Data Export & Import
Back up your entire database as a JSON file and share it via any app on your device. Import it back anytime — works across devices. No cloud, no account needed.

## Contributing

Contributions are welcome. Please open an issue first to discuss what you'd like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

<div align="center">

Built with Flutter

</div>
