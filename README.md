# offline_example

An offline-first Flutter application demonstrating local persistence, state management, offline synchronization, and responsive data visualization.

---

## Architecture & Dependencies

This project is configured with a robust offline-first architecture. Below is a breakdown of all installed packages and the technical rationale for each.

### Runtime Dependencies (`pubspec.yaml`)

| Package | Version | Purpose & Rationale |
| :--- | :--- | :--- |
| **`provider`** | `^6.1.5` | **State Management**: Provides predictable reactivity and scoped state distribution across the widget tree, separating business logic from presentation. |
| **`get_it`** | `^9.3.0` | **Service Locator (DI)**: Central registry for decoupling interfaces from concrete implementations (repositories, services, network clients), ensuring high testability. |
| **`injectable`** | `^3.0.0` | **Dependency Injection Annotations**: Works alongside `get_it` for dependency structuring and modular dependency configuration. |
| **`hive`** / **`hive_flutter`** | `^2.2.3` / `^1.1.0` | **Offline Storage**: Lightweight, fast, pure-Dart NoSQL key-value database designed for mobile and desktop, ideal for caching tasks and offline persistence without native SQLite overhead. |
| **`dio`** | `^5.11.1` | **Networking**: Feature-rich HTTP client with interceptors (logging, auth headers, token refresh), global configuration, request cancellation, and robust error handling. |
| **`connectivity_plus`** | `^7.3.2` | **Network Detection**: Listens to network connectivity status (Wi-Fi, mobile, none) to detect online/offline transitions and trigger automatic background data synchronization. |
| **`flutter_secure_storage`** | `^11.2.0` | **Secure Storage**: Encrypted key-value persistence utilizing Android Keystore and iOS Keychain for storing sensitive credentials and access tokens. |
| **`freezed_annotation`** | `^3.1.0` | **Data Model Immutability**: Companion annotations for generating immutable domain models, `copyWith`, union/sealed classes, and value equality. |
| **`json_annotation`** | `^4.12.0` | **JSON Serialization**: Annotations for mapping JSON payloads to Dart models and vice versa with compile-time safety. |
| **`fl_chart`** | `^1.3.1` | **Data Visualization**: Rich, customizable, and animated charts (bar charts, line graphs, pie charts) for metrics and task progress tracking. |
| **`intl`** | `^0.20.3` | **Internationalization & Formatting**: Date, time, currency, and number formatting, supporting localization and human-readable timestamps. |

---

### Dev Dependencies

| Package | Version | Purpose & Rationale |
| :--- | :--- | :--- |
| **`freezed`** | `^3.2.5` | **Code Generator**: Generates boilerplate for immutable models, pattern matching, `toString`, and equality operators. |
| **`json_serializable`** | `^6.14.1` | **Code Generator**: Generates `fromJson` and `toJson` serialization code based on `json_annotation`. |
| **`build_runner`** | `^2.15.1` | **Build System**: Orchestrates and executes code generation tasks across generators. |
| **`mocktail`** | `^1.0.5` | **Unit & Mock Testing**: Clean mocking library inspired by Mockito that does not require code generation, simplifying tests for repositories and HTTP clients. |

---

## SDK Compatibility & Dropped Generators

The current Dart SDK constraint for this project is `^3.10.7`. Two code generation packages were excluded due to SDK version requirements and dependency conflicts:

1. **`injectable_generator`**
   - **Reason**: Requires Dart SDK `>=3.12`.
   - **Resolution**: `get_it` + `injectable` are retained. Service bindings and dependencies are registered manually inside a `configureDependencies()` setup function. This requires only a few lines per service and fully satisfies all Dependency Injection requirements.

2. **`hive_generator`**
   - **Reason**: Has transitive dependency conflicts with `json_serializable 6.14`.
   - **Resolution**: Write the model `TypeAdapter` manually (~20 lines of code). Domain models can continue using `freezed` + `json_serializable` for DTO and domain logic, while the custom `TypeAdapter` manages binary Hive persistence.

### Running Code Generation
To generate model code for `freezed` and `json_serializable`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Windows Development Notice

When building Flutter desktop apps with native plugin dependencies on Windows (such as `connectivity_plus` and `flutter_secure_storage`), Windows requires Developer Mode enabled to allow symlink creation without requiring administrator elevation.

To enable Developer Mode, run in PowerShell or Command Prompt:
```cmd
start ms-settings:developers
```
Toggle **Developer Mode** to **On**.

---

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Launch the application:**
   ```bash
   flutter run
   ```
