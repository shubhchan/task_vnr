# Offline-first Task & Expense Tracker

A Flutter app for logging tasks with expenses, viewing spending summaries, and syncing offline edits when the network returns.

## Setup and build

Requirements: Flutter with Dart 3.10.7 or newer, and an Android device or emulator.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

There is no code generation step. Model, adapter, and state classes are written by hand.

## Architecture

The project uses a feature-first layout with three thin layers per feature.

```
lib/
├── main.dart                  App entry and DI setup
├── app.dart                   Providers, themes, auth gate, navigation
├── core/
│   ├── constants/             Shared constants and timings
│   ├── di/                    get_it registrations
│   ├── error/                 Sealed Result and AppFailure types
│   ├── network/               Dio factory
│   ├── storage/               Hive CE setup
│   ├── theme/                 Material 3 light and dark themes
│   └── utils/                 Debouncer
├── features/
│   ├── auth/                  Login, token storage, session state
│   ├── tasks/                 Task model, repository, list and form UI
│   ├── dashboard/             Budget summary and category chart
│   └── sync/                  Connectivity listener and sync trigger
└── shared/widgets/            Reusable widgets
```

Each feature has a `domain`, `data`, and `presentation` folder where it applies.

- `domain` holds entities and repository interfaces. It imports no Flutter, Hive, or Dio code.
- `data` implements the interfaces and talks to Hive CE, Dio, and secure storage.
- `presentation` holds `ChangeNotifier` classes, screens, and widgets.

Imports point inward toward `domain`. `core` is available to every layer. The full layout guide is in `lib/README.md`.

## State management and DI

`provider` distributes state through `ChangeNotifierProvider` and `ProxyProvider`-style reads with `context.select`.

- `AuthNotifier` owns the session and restores it from secure storage on launch.
- `TaskNotifier` owns the task list, filter, search query, and sync flags.
- `ConnectivityNotifier` watches the network and calls `TaskNotifier.syncPending()` on reconnect.

State classes are immutable and extend `Equatable`. They expose hand-written `copyWith` methods. Widgets read state and call notifier methods; they never call Hive or Dio directly.

`get_it` resolves repositories and services. `configureDependencies()` in `core/di/injection.dart` registers every binding in one place. Tests replace a binding with a mock instead of building the real object graph.

## Offline behaviour

- Reads always come from the local Hive CE box.
- The mock API seeds the box only when it is empty. A failed seed leaves an empty list, so offline first launch still works.
- Creating or editing a task sets `isSynced: false` and shows a Pending Sync badge.
- Reconnecting flips pending tasks to synced after a short simulated delay. The list and dashboard update from the same `TaskState`.
- Swipe-delete is reversible through an Undo SnackBar. Undo re-saves the task, so it returns as pending sync.

## Dependencies

Runtime: `provider`, `get_it`, `dio`, `connectivity_plus`, `flutter_secure_storage`, `hive_ce`, `hive_ce_flutter`, `fl_chart`, `intl`, `equatable`.

Development: `flutter_test`, `flutter_lints`, `mocktail`.

Functional error handling uses Dart 3 sealed classes in `core/error/result.dart`. No external error-handling package is needed.

## Tests

```sh
flutter test
```

The suite covers repository offline fallback and sync, notifier state transitions, and login form validation through a widget test. Mocks use `mocktail`, so no code generation is required.

## Trade-offs

- Manual `copyWith`, `props`, and `TypeAdapter` code replaces `freezed`, `json_serializable`, and `hive_generator`. This avoids code generation entirely and keeps the project easy to read.
- `injectable` annotations are not used without their generator. `get_it` handles DI with explicit registration.
- Sync and login are simulated with delays. No real backend verifies tokens or accepts writes.
- The budget is hardcoded in `AppConstants`. User editing is not in scope.
- Dashboard totals are derived from `TaskState` instead of a separate notifier, which avoids duplicate state.
- Broad `context.watch` rebuilds the current screen. `const` widgets and `ListView.builder` keep the cost low at this scale.

## Current limitations

- The app is built and verified on Android only. iOS sources were not generated and the app was not built or run on iOS because no macOS environment was available.
- The release Android manifest does not declare the INTERNET permission yet. Debug and profile manifests include it, so development builds reach the mock API. A release build needs the permission before the first-launch seed can run.
- Auto-sync runs when connectivity changes from offline to online. Pending tasks that exist at launch while the device is already online wait for the next network change.
- Login and sync are simulated locally. No server validates credentials or accepts writes.
- The budget is fixed in `AppConstants` and cannot be edited in the UI.
- The demo recording is not yet included in the repository.

## Improvements for production

- Replace the mock auth call and sync with a real API, including refresh tokens and retry with backoff.
- Add a real write queue with conflict resolution and server-generated IDs.
- Persist the budget and let the user edit it.
- Use `Selector` or fine-grained providers for larger lists and cache formatted currency values.
- Add crash reporting, structured logging, and end-to-end tests for the offline-to-online flow.
- Make the theme mode user-selectable instead of following the system setting.

## Demo

Attach a short recording that shows offline task creation, the Pending Sync badge, and the badge clearing after connectivity returns.
