# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a CocoaPods-based Xcode project. Open `Budgi.xcworkspace` (not `.xcodeproj`) to build.

```bash
# Install dependencies
pod install

# Open the workspace
open Budgi.xcworkspace
```

Build and test via Xcode or `xcodebuild`:
```bash
# Build
xcodebuild -workspace Budgi.xcworkspace -scheme Budgi -sdk iphonesimulator build

# Run tests
xcodebuild -workspace Budgi.xcworkspace -scheme Budgi -sdk iphonesimulator test

# Run a single test class
xcodebuild -workspace Budgi.xcworkspace -scheme Budgi -sdk iphonesimulator test -only-testing:BudgiTests/BudgiTests
```

No linting is configured.

## Architecture: RIBs

The app uses Uber's **RIBs** (Router-Interactor-Builder) architecture. Each feature is a "RIB" module:

- **Builder**: Constructs all components of a RIB. Accepts a parent `Component` (dependency container) and returns a `Router`. Defines the `Dependency` protocol listing what it needs from the parent.
- **Component**: Holds the module's own dependencies and implements child `Dependency` protocols. Extends `Component<Dependency>`.
- **Interactor**: Business logic. Extends `PresentableInteractor<Presenter>`. Receives user actions, drives state, communicates upward via a `Listener` protocol.
- **Router**: Navigation. Attaches/detaches child RIBs in response to interactor calls.
- **ViewController / View**: UI only. Calls interactor methods on user actions; renders state updates from the interactor.

### RIB Tree

```
AppRootRouter (LaunchRouter)
└── MainTabBarController
    ├── CalendarRouter
    │   ├── TransactionInputRouter  (modal)
    │   └── TransactionDetailRouter (modal)
    └── SettingRouter
```

`SceneDelegate` bootstraps the tree by calling `AppRootBuilder.build()` and launching via `LaunchRouter`.

### Adding a New Feature

1. Create a folder under `Budgi/Pages/FeatureName/`
2. Create: `FeatureNameBuilder.swift`, `FeatureNameInteractor.swift`, `FeatureNameRouter.swift`, `FeatureNameViewController.swift`, `FeatureNameView.swift`
3. Add the builder to the parent's `Component` and inject it in the parent `Builder`
4. Attach/detach via the parent `Router`

## Data Layer

**Core Data** is the only persistence mechanism, managed by `CoreDataManager` (singleton).

- Model file: `Pages/TransactionInput/Core Data/Model/TransactionDataModel.xcdatamodeld`
- Entity: `Transaction` — fields: `id` (UUID), `amount` (Double), `categoryId` (String), `date` (Date), `memo` (String)
- `CoreDataManager` exposes: `fetchTransactions()`, `createTransaction(...)`, `updateTransaction(...)`, `deleteTransaction(...)`

## UI Conventions

- All layouts use **SnapKit** (programmatic constraints, no Storyboards/XIBs)
- Views are constructed in a separate `*View.swift` file; `*ViewController.swift` owns the view and bridges to the interactor
- The `.do { }` builder pattern (from `Utils/Sets.swift`) is used for property configuration:
  ```swift
  let label = UILabel().do {
      $0.text = "Hello"
      $0.font = .systemFont(ofSize: 14)
  }
  ```

## Domain Models

Located in `Pages/Calender/Models/`:
- `Category` — name + `CategoryType`
- `CategoryType` — `.income` / `.expense`
- `CalendarDay` — date + list of `DayTransaction`
- `DayTransaction` — transaction data used in calendar display
