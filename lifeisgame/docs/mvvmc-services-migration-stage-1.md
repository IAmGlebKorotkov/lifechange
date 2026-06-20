# MVVM-C + Services Migration: Stage 1 Architecture Map

Date: 2026-06-19

This document captures the current Clean Architecture dependency surface before moving the app to a simpler MVVM-C + Services structure.

## Current Shape

- Swift files in the app/workspace: 144
- Swift lines: about 15.5k
- `Domain`: 25 Swift files
- `Data`: 28 Swift files
- `Modules`: 80 Swift files
- Current architecture: MVVM-C plus a Clean-style `Domain/UseCases` and `Domain/Repositories` layer.
- Target architecture: ViewController -> ViewModel -> Service -> persistence/system APIs, with Coordinators still responsible for navigation and construction.

## Current DI Surface

`lifeisgame/App/DIContainer.swift` currently owns these stored dependencies:

- `UserRepositoryProtocol`
- `TaskRepositoryProtocol`
- `DiaryRepositoryProtocol`
- `AchievementRepositoryProtocol`
- `CalendarServiceProtocol`

It exposes these Clean-style factories:

- `makeLoginUseCase()`
- `makeRegisterUseCase()`
- `makeFetchTasksUseCase()`
- `makeCreateTaskUseCase()`
- `makeToggleTaskCompletionUseCase()`
- `makeUpdateTaskDetailsUseCase()`
- `makeDeleteTaskUseCase()`
- `makeAnalyzeUserDayUseCase()`
- `makeUserRepository()`
- `makeTaskRepository()`
- `makeDiaryRepository()`
- `makeAchievementRepository()`

Target DI surface should move toward:

- `makeAuthService()`
- `makeTaskService()`
- `makeDiaryService()`
- `makeAchievementService()`
- `makeAnalysisService()`
- `makeCalendarEventService()` if an abstraction remains useful

## Clean Layer Inventory

### Auth

Current files:

- `Domain/UseCases/Auth/LoginUseCase.swift`
- `Domain/UseCases/Auth/RegisterUseCase.swift`
- `Domain/Repositories/UserRepositoryProtocol.swift`
- `Data/Repositories/UserRepository.swift`

Target:

- `AuthService`

Candidate API:

```swift
func login(email: String, password: String) throws -> User
func register(name: String, email: String, birthDate: Date?, password: String) throws -> User
func fetchUser(byID id: UUID) throws -> User?
func fetchUser(byEmail email: String) throws -> User?
```

### Tasks

Current files:

- `Domain/UseCases/Tasks/CreateTaskUseCase.swift`
- `Domain/UseCases/Tasks/FetchTasksUseCase.swift`
- `Domain/UseCases/Tasks/ToggleTaskCompletionUseCase.swift`
- `Domain/UseCases/Tasks/UpdateTaskDetailsUseCase.swift`
- `Domain/UseCases/Tasks/DeleteTaskUseCase.swift`
- `Domain/UseCases/Tasks/TaskScheduling.swift`
- `Domain/Repositories/TaskRepositoryProtocol.swift`
- `Data/Repositories/TaskRepository.swift`

Target:

- `TaskService`
- optional internal `TaskScheduler`/`TaskScheduling` helper

Candidate API:

```swift
func fetchTasks(userID: UUID, date: Date, completion: @escaping ([TaskItem]) -> Void)
func fetchTasks(userID: UUID, from startDate: Date, to endDate: Date) throws -> [TaskItem]
func createTask(input: TaskInput, userID: UUID, completion: @escaping (Result<TaskItem, Error>) -> Void)
func updateTaskDetails(input: UpdateTaskInput) throws -> TaskItem
func toggleCompletion(taskID: UUID) throws
func setCompleted(taskID: UUID) throws
func deleteTask(taskID: UUID) throws
func lateBoundary(for task: TaskItem) -> Date?
func splitTaskAtLateBoundary(_ task: TaskItem, userID: UUID) throws -> [TaskItem]
```

Important blocker:

- `CreateTaskUseCase.Input` and `CreateTaskUseCase.SubtaskInput` leak into Add Task UI files. These should become service-level DTOs, for example `TaskService.TaskInput` and `TaskService.SubtaskInput`, or standalone `TaskInput`/`SubtaskInput`.

### Diary

Current files:

- `Domain/Repositories/DiaryRepositoryProtocol.swift`
- `Data/Repositories/DiaryRepository.swift`

Target:

- `DiaryService`

Candidate API:

```swift
func saveEmotionEntries(_ entries: [EmotionDiaryInput], forUserID userID: UUID, on date: Date) throws -> [EmotionDiaryEntry]
func saveSleepEntry(bedtime: Date, wakeTime: Date, forUserID userID: UUID, on date: Date) throws -> SleepDiaryEntry
func fetchEmotionEntries(forUserID userID: UUID) throws -> [EmotionDiaryEntry]
func fetchSleepEntries(forUserID userID: UUID) throws -> [SleepDiaryEntry]
func hasEmotionEntry(forUserID userID: UUID, on date: Date) throws -> Bool
func hasSleepEntry(forUserID userID: UUID, on date: Date) throws -> Bool
```

### Achievements

Current files:

- `Domain/Repositories/AchievementRepositoryProtocol.swift`
- `Data/Repositories/AchievementRepository.swift`

Target:

- `AchievementService`

Candidate API:

```swift
func fetchAchievements(forUserID userID: UUID) throws -> [AchievementItem]
func markOpened(achievementID: UUID, forUserID userID: UUID) throws -> AchievementItem
func recordFocusSession(forUserID userID: UUID, taskID: UUID?, startedAt: Date, endedAt: Date) throws
```

### Analysis

Current files:

- `Domain/UseCases/Analysis/AnalyzeUserDayUseCase.swift`
- `Domain/Analysis/UserAnalysisEngine.swift`
- `Domain/Analysis/UserAnalysisModels.swift`

Target:

- `AnalysisService`
- `UserAnalysisEngine` can remain as an internal helper.

Candidate API:

```swift
func analyzeDay(userID: UUID, date: Date, completion: @escaping (Result<UserAnalysisResult, Error>) -> Void)
```

### Validation

Current files:

- `Domain/UseCases/LoginValidationUseCase.swift`
- `Domain/UseCases/RegistrationValidationUseCase.swift`
- `Domain/UseCases/TaskValidationUseCase.swift`
- `Domain/UseCases/SubtaskValidationUseCase.swift`

Target:

- Move or rename to validators, for example `LoginValidator`, `RegistrationValidator`, `TaskValidator`, `SubtaskValidator`.
- These are UI/form validation helpers, not services.

## Current Consumers By Area

### App

- `AppCoordinator`
  - refreshes notifications with `container.makeDiaryRepository()`
  - completes tasks from URLs/activities with `container.makeTaskRepository().setCompletion(...)`
  - creates Face ID screen with `container.makeUserRepository()`
- `DIContainer`
  - central source of all use cases and repository protocols.

### Auth

- `AuthCoordinator`
  - creates `LoginViewModel` with `makeLoginUseCase()` and `makeUserRepository()`
  - creates `RegistrationViewModel` with `makeRegisterUseCase()`
- `LoginViewModel`
  - depends on `LoginUseCase`
  - depends on `UserRepositoryProtocol`
- `RegistrationViewModel`
  - depends on `RegisterUseCase`
- `FaceIDUnlockViewController`
  - depends on `UserRepositoryProtocol`
- `LoginViewController`
  - uses `LoginValidationUseCase`
- `RegistrationViewController`
  - uses `RegistrationValidationUseCase`

Recommended first migration target: `AuthService`, because the dependency surface is small and mostly isolated.

### Add Task / Calendar / Focus

- `CalendarCoordinator`
  - creates `CalendarViewModel` with fetch/toggle/delete task use cases
  - creates `AddTaskCoordinator` with `CreateTaskUseCase`
  - creates `EditTaskViewController` with `UpdateTaskDetailsUseCase`
- `CalendarViewModel`
  - depends on `FetchTasksUseCase`
  - depends on `ToggleTaskCompletionUseCase`
  - depends on `DeleteTaskUseCase`
- `EditTaskViewController`
  - depends on `UpdateTaskDetailsUseCase`
  - uses `UpdateTaskDetailsUseCase.Input`
- `AddTaskCoordinator`
  - depends on `CreateTaskUseCase`
  - calls `execute`, `lateBoundary`, and `splitTaskAtLateBoundary`
- `AddTaskViewController`, `AddSubtaskViewController`, `HardTaskFormView`
  - use `CreateTaskUseCase.Input` and `CreateTaskUseCase.SubtaskInput`
  - use task/subtask validation use cases
- `FocusViewModel`
  - depends on `FetchTasksUseCase`
  - depends on `ToggleTaskCompletionUseCase`
  - depends on `AchievementRepositoryProtocol`

Recommended migration target after Auth: `TaskService`, but only after extracting/renaming task DTOs away from `CreateTaskUseCase`.

### Diary / Profile / Notifications

- `DiaryCoordinator`
  - creates `DiaryViewController` with `makeDiaryRepository()`
- `DiaryViewController`
  - depends on `DiaryRepositoryProtocol`
- `ProfileCoordinator`
  - creates `ProfileViewModel` with `makeUserRepository()` and `makeDiaryRepository()`
- `ProfileViewModel`
  - depends on `UserRepositoryProtocol`
  - depends on `DiaryRepositoryProtocol`
- `LocalNotificationService`
  - accepts `DiaryRepositoryProtocol`

Recommended migration target: `DiaryService`, then update `ProfileViewModel`, `DiaryViewController`, and notification refresh calls.

### Statistics / Achievements

- `StatisticsCoordinator`
  - creates overview stats with `makeDiaryRepository()` and `makeTaskRepository()`
- `StatisticsViewController`
  - depends on `DiaryRepositoryProtocol`
  - depends on `TaskRepositoryProtocol`
- `GeneralStatsCoordinator`
  - creates `GeneralStatsViewModel` with `makeAnalyzeUserDayUseCase()`, `makeUserRepository()`, `makeDiaryRepository()`, and `makeTaskRepository()`
  - creates `AchievementsView` with `makeAchievementRepository()`
  - creates `FocusViewModel` with fetch/toggle use cases and achievement repository
- `GeneralStatsViewModel`
  - depends on `AnalyzeUserDayUseCase`
  - depends on `UserRepositoryProtocol`
  - depends on `DiaryRepositoryProtocol`
  - depends on `TaskRepositoryProtocol`
- `AchievementsView`
  - accepts `AchievementRepositoryProtocol`
  - has a default `AchievementRepository()`
- `AchievementsViewModel`
  - depends on `AchievementRepositoryProtocol`

Recommended migration targets:

1. `AchievementService`
2. `AnalysisService`
3. Statistics screens can then depend on services directly or a later `StatisticsService` if duplication appears.

## Recommended Migration Order

1. Add service files while keeping existing use cases/repositories compiling.
2. Migrate Auth to `AuthService`.
3. Extract task DTOs from `CreateTaskUseCase` names.
4. Migrate Add Task, Calendar, Edit Task, App task completion, and Focus to `TaskService`.
5. Migrate Diary, Profile, and notification reminder refresh to `DiaryService`.
6. Migrate Achievements and Focus achievement recording to `AchievementService`.
7. Migrate General Stats analysis to `AnalysisService`.
8. Move validators out of `Domain/UseCases` naming.
9. Delete unused use cases/protocols after `rg "UseCase|RepositoryProtocol"` returns no production consumers.
10. Clean `DIContainer` to expose services only.

## Risk Notes

- Task creation is the riskiest area. `CreateTaskUseCase` owns scheduling, calendar merge, event creation, hard task subtask creation, and late-boundary splitting.
- Add Task UI currently depends on nested DTO types from `CreateTaskUseCase`; this creates compile pressure when deleting the use case.
- Some screens currently bypass ViewModel and take repository protocols directly (`DiaryViewController`, `StatisticsViewController`, `AchievementsView`). They can still migrate to services without redesigning the UI layer immediately.
- `CalendarServiceProtocol` is already service-like. It can remain as an EventKit seam, but it should not live under `Domain/Services` after the Clean layer is removed.
- `RepositoryError` is used across the current data/domain boundary. It should either stay as a data/service error or be renamed later.

## Stage 1 Exit Criteria

Stage 1 is complete when:

- the current Clean dependency surface is documented;
- every direct use case/repository protocol consumer is mapped;
- target services and first-pass APIs are named;
- the next implementation stage has a clear first target.

The recommended Stage 2 target is `AuthService`.
