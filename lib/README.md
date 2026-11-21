# Project structure

This app uses a feature-first layout with three thin layers per feature.
Each feature owns its screens, state, and data access.
Shared code lives in `core` and `shared`.

```
lib/
├── main.dart                  # Entry point: init services, run app
├── app.dart                   # MaterialApp, theme, routes
│
├── core/                      # Cross-cutting concerns (no UI)
│   ├── constants/             # App-wide constants and keys
│   ├── di/                    # get_it service registration
│   ├── error/                 # Sealed Result and Failure types
│   ├── network/               # Dio client and connectivity service
│   ├── storage/               # Hive setup and secure storage wrapper
│   ├── theme/                 # Material 3 light and dark themes
│   └── utils/                 # Debouncer, formatters, helpers
│
├── features/                  # One folder per feature
│   ├── auth/
│   │   ├── data/              # Repository implementation, datasources
│   │   ├── domain/            # Repository interface, entities
│   │   └── presentation/      # Screens, widgets, ChangeNotifier
│   │
│   ├── tasks/
│   │   ├── data/              # Task model, Hive and API datasources
│   │   ├── domain/            # Task entity, TaskRepository interface
│   │   └── presentation/      # List, form, notifier, widgets
│   │
│   ├── dashboard/
│   │   └── presentation/      # Summary card, chart, notifier
│   │
│   └── sync/
│       ├── data/              # Sync service and queue
│       └── presentation/      # Connectivity notifier, sync badge
│
└── shared/
    └── widgets/               # Reusable UI used by many features
```

## The three layers

- `domain` is the centre. It holds plain entities and repository interfaces.
  It does not import Flutter, Hive, or Dio.
- `data` implements the domain interfaces. It talks to Hive, Dio, and secure storage.
- `presentation` holds `ChangeNotifier` classes, screens, and widgets.
  Widgets read state through Provider and call notifier methods.

## Dependency rule

Imports point inward: `presentation` -> `domain`, and `data` -> `domain`.
`domain` imports nothing from `data` or `presentation`.
`core` is available to every layer.

## Where state lives

- `TaskNotifier` (tasks) holds the task list, filters, and search query.
- `AuthNotifier` (auth) holds the login state and token.
- `ConnectivityNotifier` (sync) watches the network and triggers sync.
- `DashboardNotifier` reads tasks and exposes the summary totals.

State classes are immutable `freezed` objects.
Notifiers extend `ChangeNotifier` and expose one state object each.
