# 📰 Business Intelligence News App

A Flutter application that delivers business news intelligence using the [NewsAPI.org](https://newsapi.org) public API. It is built with **Clean Architecture**, **Riverpod** for state management, and **Hive** for local persistence.

---

## 🎯 Goal & Core Expectations

This project was built for the **Flutter Assignment, Junior Developer (Mini News Intelligence App)**. Each core expectation maps to a concrete decision:

| Expectation | How it is addressed |
|---|---|
| **Clean UI** | Business-focused look, clear typography, loading indicators, and placeholder images when network images fail |
| **Scalable folder structure** | Feature-first structure with presentation, domain, and data separation |
| **Proper state management** | Riverpod (`Notifier` / `NotifierProvider`) with immutable state and unidirectional data flow |
| **API integration** | Dio HTTP client with timeouts, query parameter builders, and compile-time API key injection |
| **Local persistence** | Hive boxes for favorites (offline) and the login session |
| **Error handling** | Typed `Failure` hierarchy (network, API key, rate limit, server, cache) with retry actions in the UI |

---

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK 3.19.0+
- Dart SDK 3.3.0+ (sound null safety)
- Internet connection for live API data

### 2. Clone and install
```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd news_api_app
flutter pub get
```

### 3. Run the app

**Option A: VS Code (one click)**
Open the repository root in VS Code, press `F5`, and select **Flutter Assessment (Debug)**. The configuration in `.vscode/launch.json` is used.

**Option B: Terminal**
A fallback free-tier test key is defined in `NetworkConstants` so reviewers can run the app immediately:
```bash
flutter run
```

**Option C: Your own API key (recommended)**
Get a free key from [newsapi.org](https://newsapi.org) and pass it at build time:
```bash
flutter run --dart-define=NEWS_API_KEY=YOUR_ACTUAL_API_KEY
```

> **Note:** The fallback key is a free-tier key included only to simplify review. For any real deployment, remove it and supply the key through `--dart-define`.

---

## 🔑 Login Credentials (Screen 1)

The app starts with a login screen. There is no backend, so validation is local:

- **Email:** any valid email format (e.g. `analyst@intelligence.com`)
- **Password:** any string of 6 or more characters (e.g. `securePass123`)

The session is stored in Hive (`authBox`) by `AuthLocalDataSource`. On relaunch, `AuthGate` reads it and skips the login screen if a session exists.

---

## 📱 Functional Scope

| # | Screen | Requirement | Implementation |
|---|---|---|---|
| 1 | **Authentication** | Simple login, persist login state | Form validation (email format, 6+ character password). Session saved in Hive (`authBox`) and read on startup by `AuthGate`. |
| 2 | **News Feed** | Category listing, pagination, pull-to-refresh | Horizontal category filter chips, infinite scroll that loads the next page before the list ends, and `RefreshIndicator` for pull-to-refresh. |
| 3 | **Search** | Search via API, efficient filtering | Dedicated screen using the API search endpoint, with loading, results, empty, and error states plus pagination. |
| 4 | **Article Detail** | Full article view, save as favorite | Shows the article image, title, publisher, and content, with a favorite toggle in the AppBar. |
| 5 | **Favorites** | Offline persistent storage | Stored in Hive (`favoritesBox`), available without internet, with swipe-to-delete. |

---

## 🏛 Architecture

The app follows Clean Architecture with three layers. Dependencies point inward, so the domain layer does not depend on Flutter or any data source.

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│   (Screens, Widgets, Riverpod Notifiers, UI States)         │
└──────────────────────────────┬──────────────────────────────┘
                               │ Calls Use Cases / Observes State
┌──────────────────────────────▼──────────────────────────────┐
│                        Domain Layer                         │
│     (Entities, Use Cases, Repository Contracts)             │
└──────────────────────────────▲──────────────────────────────┘
                               │ Implements Contracts
┌──────────────────────────────┴──────────────────────────────┐
│                         Data Layer                          │
│   (Data Sources, API Models / DTOs, Repository Impls)       │
└─────────────────────────────────────────────────────────────┘
```

> The `home` feature (news fetching) uses all three layers in full. The smaller features (`auth`, `search`, `article_details`, `favorites`) keep their logic lightweight and reuse the shared domain and providers where it makes sense, to avoid unnecessary boilerplate.

---

## 📂 Folder Structure

```
lib/
├── core/
│   ├── error.dart                      # Failure hierarchy (Network, ApiKey, RateLimit, Server, Cache)
│   └── network/
│       ├── network.dart                # Dio client setup and timeouts
│       └── network_constants.dart      # Base URL, endpoints, API key
├── feature/
│   ├── auth/                           # 1. Authentication
│   │   ├── data/
│   │   │   └── auth_local_data_source.dart
│   │   └── presentation/
│   │       ├── auth_controller.dart
│   │       ├── auth_gate.dart
│   │       └── login_screen.dart
│   ├── home/                           # 2. News Feed
│   │   ├── data/
│   │   │   ├── data_model/             # ArticleModel, ArticleNewPageModel (DTOs)
│   │   │   ├── article_remote_data_source.dart
│   │   │   ├── article_remote_data_source_impl.dart
│   │   │   └── article_news_repo_impl.dart
│   │   ├── domain/
│   │   │   ├── entity/                 # ArticleEntity, NewPageEntity
│   │   │   ├── news_repo.dart          # Abstract repository contract
│   │   │   └── use_case/               # NewsArticleUseCase, SearchNewsUseCase
│   │   └── presentation/
│   │       ├── state/                  # NewsController, NewsState, providers
│   │       └── view/
│   │           └── home_page_screen.dart
│   ├── search/                         # 3. Search
│   │   └── presentation/
│   │       ├── search_controller.dart
│   │       └── search_screen.dart
│   ├── article_details/                # 4. Article Detail
│   │   └── presentation/
│   │       └── article_detail_screen.dart
│   └── favorites/                      # 5. Favorites
│       ├── data/
│       │   └── fav_data_source.dart    # Hive CRUD operations
│       └── presentation/
│           ├── fav_controller.dart
│           └── favorite_screen.dart
└── main.dart                           # Hive init and ProviderScope
```

---

## 💡 Key Technical Decisions

### 1. State Management: Riverpod
- **Predictable state:** immutable, typed state objects replace `setState` and `ChangeNotifier`.
- **Decoupled logic:** providers do not depend on `BuildContext`, so business logic is easy to test.
- **Clear lifecycle:** `Notifier` / `NotifierProvider` handle loading, success, and error transitions in one place.

### 2. Local Storage: Hive
- **Lightweight and fast:** a pure-Dart key-value store with no native dependencies, well suited to storing articles and small session data.
- **Two separate boxes:** `favoritesBox` for offline favorites and `authBox` for the login session.

### 3. API Integration: Dio and `--dart-define`
- **Dio** gives timeouts, query parameter handling, and consistent error interception.
- **API key injection** through `--dart-define=NEWS_API_KEY=...` keeps real keys out of version control.
- The API provider is **NewsAPI.org** (top-headlines endpoint for the feed, everything endpoint for search).

### 4. Error Handling
Errors are caught in the data layer and mapped to typed failures:

| Failure | Cause | What the user sees |
|---|---|---|
| `NetworkFailure` | No connection or timeout | "Check your connection" message with a **Retry** button |
| `ApiKeyFailure` | Invalid or missing API key | Message explaining the key is invalid |
| `RateLimitFailure` | Too many requests (free tier) | "Try again later" message |
| `ServerFailure` | Bad response or 5xx | Generic error message with **Retry** |
| `CacheFailure` | Hive read/write problem | Message when favorites cannot be loaded or saved |

Raw HTTP exceptions never reach the UI, and every screen has its own loading, empty, and error state.

---

## ⚠️ Known Limitations & Future Improvements

- The NewsAPI free tier limits requests and result counts, so deep pagination may stop early.
- The news feed is not cached offline; only favorites are available without internet.
- Authentication is local only (no backend).
- Unit and widget tests for use cases and controllers are planned.
- Possible additions: feed caching with Hive, dark mode, and localization.

---

## 🧾 Commit Convention

Commits follow a simple convention for a readable history:

```
feat: add login screen with Hive session persistence
fix: prevent duplicate articles during pagination
refactor: move failure mapping into the data source
docs: update README with architecture overview
```