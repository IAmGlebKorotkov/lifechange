# MVVM-C + Services Current State

Date: 2026-06-20

This document captures the app architecture after migrating away from the previous MVVM-C + Clean-style dependency surface and tightening screens to a stricter MVVM-C + Services flow.

## Target Shape

The production app now follows this dependency direction:

```text
Coordinator -> ViewController -> ViewModel -> Service -> Repository/system API
```

Coordinators own navigation and module construction. View controllers own UIKit layout and user interaction binding. View models receive app services, validators, and app/system state helpers; they prepare data, validate input, and run service operations. Repositories are now an implementation detail of the data/service layer.

## UI Layer Rules

Feature screens are expected to follow these rules:

- `ViewController`: UIKit layout, animations, table/collection delegates, reading field values, showing alerts/sheets.
- `ViewModel`: validation, current screen state, formatting view data, service calls, session-dependent decisions.
- `Coordinator`: module construction, navigation, modal/sheet presentation, cross-screen callbacks.
- `Service`: app operations and integration with repositories/system APIs.

The main screens now follow this split, including auth, diary, calendar edit task, add task/subtask, notifications, Face ID unlock, profile state, and statistics overview.

## DI Surface

`DIContainer` exposes only services:

- `makeAuthService()`
- `makeTaskService()`
- `makeDiaryService()`
- `makeAnalysisService()`
- `makeAchievementService()`

It no longer exposes:

- `make*UseCase()`
- `make*Repository()`

## Services

The current app services are:

- `AuthService`
- `TaskService`
- `DiaryService`
- `AnalysisService`
- `AchievementService`
- `LocalNotificationService`
- `CalendarEventService`

`TaskScheduling.swift` lives beside `TaskService`, because it is task-service implementation logic rather than a Clean use case.

## Domain

`Domain` now contains app-level data and logic that is not a repository/use-case boundary:

- `Domain/Entities`
- `Domain/Analysis`
- `Domain/Validation`

Validators were renamed from `*ValidationUseCase` to `*Validator`.

Validators are consumed by view models rather than directly by view controllers.

## Data

Repository protocols now live with repository implementations under `Data/Repositories`:

- `UserRepositoryProtocol`
- `TaskRepositoryProtocol`
- `DiaryRepositoryProtocol`
- `AchievementRepositoryProtocol`

`CalendarServiceProtocol` lives under `Data/Services`.

## Cleanup Status

There are no Swift files left under the old Clean folders:

- `Domain/UseCases`
- `Domain/Repositories`
- `Domain/Services`

The old folders may still exist on disk because empty directories and macOS service files are not part of the Swift build.

Direct service/singleton access has been removed from feature `ViewController` files. App-level lifecycle coordination can still use app state at the root coordinator boundary.

## Verification

The migration was checked with:

```sh
rg -n "RepositoryProtocol|CalendarServiceProtocol|UseCase|make.*Repository" lifeisgame/App lifeisgame/Modules -g '*.swift'
xcrun swiftc -parse ...
xcodebuild -project lifeisgame.xcodeproj -scheme lifeisgame -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build
```

The full Xcode build succeeded.
