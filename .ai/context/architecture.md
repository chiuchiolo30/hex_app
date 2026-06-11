# ARCHITECTURE CONTRACT (STRICT)

## Purpose

This document defines the mandatory architectural rules for this Flutter app, built under **Hexagonal Architecture (Ports & Adapters)**, a feature-first approach, and enterprise maintainability standards.

Any developer or AI agent working on this project must follow the same approach to building features, separating responsibilities, naming components, and avoiding unnecessary coupling.

---

## Core Principles

The architecture must prioritize:

- maintainability;
- testability;
- low coupling;
- high cohesion;
- clear separation of responsibilities;
- independence between Domain and the technical world (Flutter, HTTP, storage, etc.);
- feature scalability;
- consistency across the app;
- explicit code over "magic" code.

The primary rule is:

```txt
Presentation → Application → Domain
Infrastructure → Domain (implements Domain Ports)

Presentation must never access Infrastructure directly.
Domain must never depend on Application, Infrastructure, or Presentation.
```

The Domain is the **hexagon's core**. Everything else (Presentation on the "driving" side, Infrastructure on the "driven" side) revolves around it and depends on it — never the other way around.

---

## Primary Architectural Style

The project uses:

```txt
Hexagonal Architecture (Ports & Adapters) + Feature-First
```

The main structure must be organized by functional features.

Example:

```txt
lib/
  features/
    login/
      domain/
      application/
      infrastructure/
      presentation/
      di/

    profile/
      domain/
      application/
      infrastructure/
      presentation/
      di/
```

- Each feature must be as independent as possible.
- A feature must be able to evolve without breaking other features.

---

## Allowed Layers

Each feature may have these layers:

```
feature/
  domain/
  application/
  infrastructure/
  presentation/
  di/
```

No alternative naming (`ui/`, `data/`, `domain/usecases/`, etc.) may be mixed in. This project uses exactly these five layer names, consistently.

---

# 1. Domain Layer (The Hexagon Core)

### Responsibility

The `domain` layer contains the business model and the **Ports** (contracts) the rest of the system must honor to interact with it.

It must be the most stable layer.

It must not depend on Flutter, Supabase, Firebase, Dio, SQLite, SharedPreferences, the `application` layer, the `infrastructure` layer, the `presentation` layer, or any technical detail.

### May contain

```
domain/
  entities/
  value_objects/
  repositories/      (Ports — abstract contracts)
  rules/             (domain services / pure business rules)
  failures/
  events/
```

Example:

```
domain/
  entities/
    user.dart

  value_objects/
    email.dart
    password.dart

  repositories/
    auth_repository.dart      (Port)

  failures/
    auth_failure.dart
```

## Mandatory Domain Rules

- Domain does not import Application.
- Domain does not import Infrastructure.
- Domain does not import Presentation.
- Domain does not know DTOs.
- Domain does not know API responses.
- Domain does not know widgets.
- Domain does not know Cubits or Blocs.
- Domain must not depend on infrastructure packages (HTTP clients, Supabase, etc.).
- Domain defines **Ports** (contracts), not implementations.
- Domain Rules (pure business logic) live next to Entities, expressed in business language.

## Entities

Entities represent business concepts.

Example:

```dart
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
```

### Rules:

- Entities must be simple.
- They must represent business language.
- They must avoid technical details.
- They must not use JSON annotations.
- They must not depend on DTOs.
- They may use `Equatable`.
- Do not use `freezed` in entities by default, unless explicitly decided for the project.
- Do not give entities technical suffixes (`Dto`, `Model`, `Response`, `Entity`) — see "Entity Trap" in section 12.

## Value Objects

Value Objects encapsulate domain primitives that carry their own validation/invariants.

Example:

```dart
class Email extends Equatable {
  factory Email(String value) {
    if (!value.contains('@')) {
      throw const FormatException('Invalid email');
    }
    return Email._(value);
  }

  const Email._(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}
```

### Rules:

- Value Objects validate themselves at construction time.
- Value Objects are immutable.
- Value Objects live in `domain/value_objects/`.
- Use Value Objects when a primitive (String, int, etc.) carries business meaning and invariants (e.g. `Email`, `Password`, `Money`). Do not over-engineer trivial fields into Value Objects.

## Ports (Abstract Repositories)

Ports are abstract contracts that define how the Domain expects to interact with the outside world. They are implemented by **Adapters** in the `infrastructure` layer.

Example:

```dart
abstract class AuthRepository {
  Future<Either<AuthFailure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, void>> logout();
}
```

### Rules:

- The contract speaks in business language.
- Returns entities, value objects, or domain types.
- Never returns DTOs.
- Never returns raw responses.
- Never exposes Supabase, Dio, Firebase, SQLite, or any other external/technical detail.
- Ports live in `domain/repositories/` and end in `Repository` (e.g. `AuthRepository`).

## Domain Rules (Domain Services)

When a business rule does not naturally belong to a single Entity or Value Object, it lives in `domain/rules/` as a pure function or pure class.

### Rules:

- Domain Rules are pure Dart — no I/O, no Flutter, no Ports invoked directly (Ports are invoked from `application`, never from `domain/rules`).
- Domain Rules must have a single, clear responsibility, expressed in business language.

---

# 2. Application Layer

### Responsibility

The `application` layer orchestrates Domain Ports to fulfil business actions ("Use Cases"). It is the only layer (besides `infrastructure`, which implements Ports) allowed to depend on `domain`.

It must not depend on Flutter widgets, `infrastructure`, or `presentation`.

### May contain

```
application/
  usecases/
  services/        (Application Services — optional, shared orchestration)
```

Example:

```
application/
  usecases/
    login_usecase.dart
    logout_usecase.dart
```

## Mandatory Application Rules

- Application depends only on `domain` (entities, value objects, Ports, failures).
- Application must not import `infrastructure` (no DTOs, datasources, adapters, API clients).
- Application must not import `presentation` (no widgets, BuildContext, Cubits/Blocs).
- Application must not access datasources directly — only through Domain Ports.
- Application must not contain UI logic, navigation, or message display.

## UseCases

Use cases represent business actions and may extend a base interface.

Example:

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class LoginUseCase implements UseCase<User, LoginParams> {
  const LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<AuthFailure, User>> call(LoginParams params) {
    return _authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
```

### Rules:

- A use case must have a single, clear responsibility.
- Must depend on Domain Ports (`domain/repositories/*`), never on Adapters directly.
- Must return `Either<Failure, T>` when errors are possible.
- Must not access datasources or DTOs directly.
- Must not contain UI logic.
- Must not handle navigation.
- Must not display messages.
- Must not import Flutter widgets.

### UseCase Naming

Use semantic, action-oriented names.

#### Good examples:

```
LoginUseCase
LogoutUseCase
GetCurrentUserProfileUseCase
RefreshTokenUseCase
ValidateSessionUseCase
```

#### Bad examples:

```
AuthUseCase
DataUseCase
CallApiUseCase
ProcessUseCase
HandleUseCase
```

---

# 3. Infrastructure Layer (Adapters)

### Responsibility

The `infrastructure` layer contains the **Adapters**: concrete implementations of Domain Ports, plus everything technical — API clients, DTOs, mappers, and datasources.

Infrastructure knows technical details.

Domain and Application must not know Infrastructure.

### May contain

```
infrastructure/
  api/              (API clients)
  datasources/
  dtos/
  mappers/
  repositories/     (Adapters — implementations of Domain Ports)
```

Example:

```
infrastructure/
  api/
    auth_api_client.dart

  datasources/
    auth_remote_datasource.dart
    auth_local_datasource.dart

  dtos/
    user_dto.dart

  mappers/
    user_dto_mapper.dart

  repositories/
    auth_repository_adapter.dart
```

### Mandatory Infrastructure Rules

- Infrastructure may import Domain (to implement Ports and use Entities/Value Objects/Failures).
- Infrastructure implements the Ports (`*Repository`) defined in Domain via Adapters (`*RepositoryAdapter`).
- Infrastructure contains DTOs and mappers.
- Infrastructure may use Supabase, Dio, Firebase, SQLite, SharedPreferences, etc.
- Infrastructure must not import Presentation.
- Infrastructure must not depend on Cubits or Blocs.
- Infrastructure must not emit visual states.
- Infrastructure must not handle navigation.
- Infrastructure must not show SnackBars, dialogs, or loaders.

### Repository Adapters

Example:

```dart
class AuthRepositoryAdapter implements AuthRepository {
  const AuthRepositoryAdapter({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AuthFailure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      return Right(dto.toEntity());
    } on InvalidCredentialsException {
      return const Left(InvalidCredentialsFailure());
    } catch (error, stackTrace) {
      return Left(AuthUnexpectedFailure(error: error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (error, stackTrace) {
      return Left(AuthUnexpectedFailure(error: error, stackTrace: stackTrace));
    }
  }
}
```

### Rules:

- The Adapter translates technical errors into Domain Failures.
- The Adapter converts DTOs to Entities (via mappers).
- The Adapter must not return DTOs.
- The Adapter must not expose raw exceptions.
- The Adapter must not contain UI logic.
- Every Adapter (`*RepositoryAdapter`) must implement at least one Port (`*Repository`) from `domain/repositories/`.

### Datasources

Datasources are responsible for communicating with external sources.

Example:

```dart
abstract class AuthRemoteDataSource {
  Future<UserDto> login({required String email, required String password});
  Future<void> logout();
}
```

Implementation:

```dart
class AuthApiRemoteDataSource implements AuthRemoteDataSource {
  const AuthApiRemoteDataSource(this._client);

  final AuthApiClient _client;

  @override
  Future<UserDto> login({required String email, required String password}) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    return UserDto.fromJson(json);
  }

  @override
  Future<void> logout() => _client.post('/auth/logout');
}
```

### Rules:

- Datasource may throw technical exceptions.
- Datasource must not return Entities.
- Datasource returns DTOs or technical models.
- Datasource does not decide business rules.
- Datasource does not handle navigation.
- Datasource does not show visual errors.

### DTOs

DTOs represent the shape of external data.

Example:

```dart
class UserDto {
  UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
    );
  }
}
```

### Rules:

- DTOs may use freezed, json_serializable, or manual models.
- DTOs live in `infrastructure/dtos/`.
- DTOs must not reach Presentation.
- DTOs must not be used by Application (UseCases).
- DTOs must be mapped to Entities.

### Mappers

Mappers transform DTOs into entities and vice versa when needed.

Example:

```dart
extension UserDtoMapper on UserDto {
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
    );
  }
}
```

### Rules:

- The mapper must be close to Infrastructure.
- The mapper may import Domain.
- The mapper must not import Presentation.
- The mapper must isolate technical API inconsistencies from the Domain.

---

# 4. Presentation Layer

### Responsibility

The `presentation` layer contains screens, widgets, Cubits/Blocs (state management), and navigation. It is the **driving side** of the hexagon.

Its responsibility is to present information and react to user interactions.

It does not contain deep business rules.

### May contain

```
presentation/
  screens/
  widgets/
  state/        (cubit/bloc + state classes)
  navigation/
```

Example:

```
presentation/
  screens/
    login_screen.dart

  widgets/
    login_form.dart
    login_error_banner.dart

  state/
    login_cubit.dart
    login_state.dart
```

### Mandatory Presentation Rules

- Presentation must not import Infrastructure.
- Presentation must not use Datasources.
- Presentation must not use Repository Adapters.
- Presentation must not use DTOs.
- Presentation must not call APIs directly.
- Presentation must communicate through Cubit/Bloc.
- Cubit/Bloc calls Application UseCases.
- Widgets must not contain business logic.
- Widgets must be small and composable.
- Screens must delegate visual components to widgets.
- Presentation must handle loading, empty, error, and success states.

## Correct Flow

```
Screen
  → Cubit/Bloc
    → UseCase (application)
      → Repository Port (domain)
        → Repository Adapter (infrastructure)
          → DataSource (infrastructure)
            → API / DB / Local Storage
```

## Forbidden Flow

```
Screen
  → Repository Adapter

Screen
  → DataSource

Widget
  → ApiClient / SupabaseClient

Cubit
  → DTO

UseCase
  → DataSource
```

---

# 5. Bloc / Cubit (Presentation State Management)

### Preference

Use `Cubit` for simple and medium-complexity flows.

Use `Bloc` when:

- there are many explicit events;
- the feature has multiple event inputs;
- the flow needs to audit actions;
- complex states are derived from multiple events.

### Cubit Responsibility

The Cubit coordinates the Presentation layer with the Application layer's UseCases.

It may:

- call use cases;
- manage states;
- transform domain results into visual state;
- handle domain failures for the UI to present;
- prepare data for the screen.

It must not:

- call datasources;
- call APIs directly;
- use DTOs;
- contain infrastructure logic;
- manage fine visual details;
- build widgets.

### State

States must be explicit.

Example:

```dart
class LoginState extends Equatable {
  const LoginState({
    required this.status,
    this.user,
    this.failureMessage,
  });

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial);
  }

  final LoginStatus status;
  final User? user;
  final String? failureMessage;

  LoginState loading() {
    return copyWith(status: LoginStatus.loading);
  }

  LoginState success(User user) {
    return copyWith(
      status: LoginStatus.success,
      user: user,
      failureMessage: null,
    );
  }

  LoginState failure(String message) {
    return copyWith(
      status: LoginStatus.failure,
      failureMessage: message,
    );
  }

  LoginState copyWith({
    LoginStatus? status,
    User? user,
    String? failureMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, failureMessage];
}
```

### Rules:

- State must be immutable.
- Use Equatable.
- Avoid ambiguous states.
- Prefer explicit transitions.
- Avoid relying solely on a generic `copyWith` to express important state changes.
- Use factories or semantic methods when they improve clarity.

### Status

Use clear enums.

Example:

```dart
enum LoginStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}
```

### Rules:

- Do not use strings for states.
- Do not mix loading with success.
- Do not represent errors with loose booleans.
- State must allow rendering the UI without complex logic in the widget.

### Cubit Example

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(LoginState.initial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(state.loading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (user) => emit(state.success(user)),
    );
  }
}
```

## 5.1 Communication Between Blocs / Cubits

Blocs and Cubits must not know each other directly.

### Allowed

- `BlocListener` in the Presentation layer that reacts to a Bloc's state and dispatches an event to another.
- A shared UseCase (application layer) called independently by two different Blocs.
- An `EventBus`-style abstraction (defined as a Domain Port, implemented in Infrastructure) to emit domain events that multiple Blocs can listen to.

### Forbidden

- Receiving another Bloc as a constructor parameter of a Bloc.
- Calling `sl.get<AnotherBloc>()` inside an event handler.
- Adding events to another Bloc directly (`otherBloc.add(...)`) from inside a Bloc.
- Mutating the state of a Bloc from another Bloc.

Correct example:

```dart
// In the Presentation layer, BlocListener coordinates two Cubits without coupling them
BlocListener<LoginCubit, LoginState>(
  listener: (context, state) {
    if (state.status == LoginStatus.success) {
      context.read<ProfileCubit>().loadProfile(state.user!.id);
    }
  },
  child: ...,
)
```

Forbidden example:

```dart
// ❌ Cubit injecting another Cubit in its constructor
class ProfileCubit extends Cubit<ProfileState> {
  final LoginCubit loginCubit; // forbidden

  void _onSave() {
    loginCubit.refresh(); // forbidden
  }
}
```

---

# 6. Dependency Injection

### Recommended Tool

Use `get_it`.

Injection must respect this order:

```txt
clients (infrastructure)
  → datasources (infrastructure)
    → repository adapters (infrastructure, implementing domain ports)
      → usecases (application)
        → cubits/blocs (presentation)
```

Example:

```dart
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Clients
  sl.registerLazySingleton<AuthApiClient>(
    () => AuthApiClient(sl()),
  );

  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthApiRemoteDataSource(sl()),
  );

  // Repository Adapters (registered against the Domain Port type)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryAdapter(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerFactory(
    () => LoginUseCase(sl()),
  );

  // Cubits
  sl.registerFactory(
    () => LoginCubit(loginUseCase: sl()),
  );
}
```

### Rules:

- Do not manually instantiate use cases inside widgets.
- Do not manually instantiate repository adapters inside Cubits.
- Do not register implementations before their dependencies.
- Do not use the service locator directly in Domain or Application.
- Avoid `GetIt.I()` inside business logic.
- Dependency composition must be centralized in `di/`.

## GetIt Registration Lifecycle

The registration type determines the instance lifecycle. Misusing it causes silent state bugs.

```
Blocs and Cubits           → registerFactory        (fresh state on each use)
UseCases                    → registerFactory        (stateless, cheap to create)
Repository Adapters         → registerLazySingleton  (stateless, 1 instance is enough)
DataSources                 → registerLazySingleton  (stateless)
HTTP/Supabase clients       → registerLazySingleton  (1 global connection)
Stateless services          → registerLazySingleton
```

### Lifecycle Rules

- `registerLazySingleton(() => XxxCubit(...))` **is forbidden**. A singleton Cubit persists its state across navigations and user sessions.
- `registerSingleton` for Blocs or Cubits **is forbidden** for the same reason.
- Blocs and Cubits must be created with `registerFactory` to guarantee a clean initial state each time the screen instantiates them.
- Use `BlocProvider` in the widget tree — not `sl.get<XxxCubit>()` inside `initState` or `build()`.

Correct example:

```dart
// DI
sl.registerFactory(
  () => LoginCubit(loginUseCase: sl()),
);

// Router or parent screen
BlocProvider(
  create: (_) => sl<LoginCubit>(),
  child: LoginScreen(),
)
```

Forbidden example:

```dart
// ❌ Cubit as singleton — state is never reset
sl.registerLazySingleton(() => LoginCubit(...));

// ❌ GetIt inside initState or build
@override
void initState() {
  super.initState();
  _cubit = sl.get<LoginCubit>(); // forbidden
}
```

---

# 7. Routing

### Responsibility

Routing must handle navigation, not business logic.

Preference:

```txt
GoRouter
```

`go_router_builder` may be used if the project requires it.

### Rules

- Routes must be declarative.
- Do not pass complex objects through routes unnecessarily.
- Avoid relying on `history.state` for critical information.
- For session data, prefer controlled storage or global state injected via Domain Ports.
- Role-based navigation must be decided using authenticated profile information.
- Guards must be simple and predictable.

Role-based navigation example:

```
auth success
  → fetch profile
    → role == admin
      → AdminHomeScreen
    → role == member
      → MemberHomeScreen
    → role == guest
      → GuestHomeScreen
```

---

# 8. Design System and UI

### Primary Rule

All UI must respect the project's Design System.

The UI must not feel like a demo.

It must feel:

```
enterprise
mobile-first
modern
clean
consistent
robust
```

### Mandatory Rules

- Use the application theme.
- Use Design System tokens.
- Use the app's responsive sizing utility (`DSResponsive` or equivalent) for dimensions when available.
- Do not hardcode colors.
- Do not hardcode sizes when tokens are available.
- Do not create isolated styles if a component or token already exists.
- Design all states:
  - initial;
  - loading;
  - empty;
  - error;
  - success.
- Loading must reflect the real process when there are steps.
- Empty states must guide the user.
- Error states must allow recovery.
- Cards must have clear visual hierarchy.
- Forms must have clear validation.
- Buttons must have disabled/loading states.
- Widgets must be reusable.

### Forbidden in Presentation

- Putting business logic inside `build`.
- Making HTTP calls from a widget.
- Querying Supabase/Firebase/Dio directly from Presentation.
- Creating loose colors without a token.
- Duplicating existing Design System components.
- Using technical text for user-facing errors.
- Building screens without empty/error/loading states.

---

# 9. Error Handling

### Recommended Pattern

Use `Failure` in Domain.

Example:

```dart
sealed class AuthFailure extends Equatable {
  const AuthFailure();

  String get message;

  @override
  List<Object?> get props => [];
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure();

  @override
  String get message => 'Invalid email or password.';
}

class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure();

  @override
  String get message => 'We could not reach the server. Check your connection.';
}

class AuthUnexpectedFailure extends AuthFailure {
  const AuthUnexpectedFailure({this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => 'An unexpected error occurred.';
}
```

### Rules:

- Infrastructure captures technical errors.
- Infrastructure (Adapters) transforms technical errors into Domain Failures.
- Domain exposes Failures via Ports.
- Cubit translates Failures into Presentation state.
- Presentation shows understandable messages.
- Do not show stack traces to the user.
- Do not leak technical exceptions into Presentation.

## Typed Either — Mandatory Rule

Every `Either` representing a business result **must have its left type bound to `Failure`**.

```dart
// Correct — the compiler guarantees L is a concrete Failure
Future<Either<AuthFailure, User>> login({required String email, required String password});

// Forbidden — free generics nullify the contract
Future<Either<L, R>> call<L, R>();  // L can be any type
Future<Either<dynamic, dynamic>> call();
```

### Rules:

- `L` in `Either<L, R>` **must always** be a subtype of `Failure`.
- **Forbidden**: `Either<L, R>` with `L` and `R` as unbound type parameters in Domain Ports, Application UseCases, and Infrastructure Adapters/DataSources.
- The Cubit must be able to call `.fold((Failure f) ..., (T value) ...)` with type safety and without casts.

---

# 10. Testing

### Test Priority

```
UseCases (application)
Repository Adapters (infrastructure)
Cubits/Blocs (presentation)
Mappers (infrastructure)
Critical Widgets (presentation)
```

### UseCase Tests

Validate:

- that they call the correct Domain Port (Repository);
- that they propagate `Right` correctly;
- that they propagate `Left` correctly;
- that they do not depend on Infrastructure.

### Repository Adapter Tests

Validate:

- that it invokes the datasource;
- that it converts DTOs to Entities;
- that it translates errors to Failures;
- that it does not expose raw exceptions.

### Cubit Tests

Validate:

- initial state;
- loading;
- success;
- empty;
- failure;
- state sequence;
- behavior on errors.

### Rules

- Use clear mocks/fakes (mock the Domain Port, not the Adapter's internals).
- Do not test irrelevant details.
- Do not depend on real external services.
- Tests must document behavior, not accidental implementation.

---

# 11. Project Structure

This is a **standalone Flutter app** (not a melos monorepo). The structure is:

```
lib/
  core/                 (shared utilities, theme, design system tokens, base classes)
  features/
    login/
      domain/
      application/
      infrastructure/
      presentation/
      di/

    <feature_name>/
      domain/
      application/
      infrastructure/
      presentation/
      di/

tools/
  architecture_check.dart
  technical_debt_metrics.dart

specs/
  <feature_name>/
    spec.md
    plan.md
    tasks.md
    quickstart.md
  templates/

.ai/
  context/
  agents/
  workflows/
  architecture-policies.yaml
```

### Project Structure Rules

- A feature must be as independent as possible from other features.
- Shared code (theme, design system, generic Failure base classes, base UseCase interface, generic Either helpers) lives in `lib/core/`.
- `lib/core/` must not depend on any `lib/features/<feature>/`.
- Features may depend on `lib/core/`, never the reverse.

### Note on Policy Engine Scopes

The governance tooling (`tools/technical_debt_metrics.dart` + `.ai/architecture-policies.yaml`) supports four generic scopes: `feature`, `app`, `package`, `monorepo`. In this standalone app:

- `feature` → a directory under `lib/features/<feature_name>/`.
- `app` → the whole app (`lib/`).
- `package` and `monorepo` → **informational/forward-looking only**. They are part of the generic policy vocabulary in case this app is ever split into a monorepo with shared packages, but there is no monorepo structure today — do not invent `apps/`/`packages/` directories that don't exist.

---

# 12. Naming Conventions

### Files

Use snake_case.

```
login_usecase.dart
auth_repository.dart
auth_repository_adapter.dart
auth_remote_datasource.dart
login_cubit.dart
login_state.dart
```

### Classes

Use PascalCase.

```
LoginUseCase
AuthRepository
AuthRepositoryAdapter
AuthRemoteDataSource
LoginCubit
LoginState
```

### Variables and Methods

Use lowerCamelCase.

```
loginUseCase
selectedUser
isAuthenticated
```

### Expected Suffixes

```
UseCase           (PascalCase in class, _usecase.dart in file)   → application/usecases/
Repository        (Port, abstract)                                → domain/repositories/
RepositoryAdapter (Adapter, implementation)                        → infrastructure/repositories/
RemoteDataSource
LocalDataSource
Dto                                                                 → infrastructure/dtos/
Mapper                                                              → infrastructure/mappers/
Cubit
Bloc
State
Event
Failure                                                             → domain/failures/
```

### UseCase Naming Consistency Rule

- The class always ends in `UseCase` (PascalCase): `LoginUseCase`.
- The file always ends in `_usecase.dart` (snake_case): `login_usecase.dart`.
- **Forbidden** to mix `Usecase`, `usecase`, and `UseCase` in the same project.
- Names must be semantic and action-oriented. See examples in section 2.

### Port / Adapter Naming Consistency Rule

- A Port is named `XRepository` and lives in `domain/repositories/x_repository.dart`.
- Its Adapter is named `XRepositoryAdapter` and lives in `infrastructure/repositories/x_repository_adapter.dart`.
- **Forbidden**: an Adapter without a corresponding Port; a Port with more than one canonical Adapter active at the same time in production code (test fakes are exempt).

### Entity Trap

Domain Entities (`domain/entities/*.dart`) must NOT carry technical suffixes: `Dto`, `Model`, `Response`, `Entity`, `Vo`. A `User` is a `User`, not a `UserEntity` or `UserModel`.

---

# 13. Anti-Coupling Rules

## Prohibition of Static Global Access

Static access to configuration, preferences, or environment variables inside internal layers violates Dependency Inversion and makes code untestable.

### Forbidden in Domain, Application, and Infrastructure

```dart
// ❌ Static access in a DataSource
final branchId = AppPreferences.branchId; // forbidden
final url = dotenv.env['SERVER_URL']!;    // forbidden
final dni = SharedPreferences.getString('dni'); // forbidden
```

### Correct Approach

Define a Port in Domain and inject it:

```dart
// Domain
abstract class ISessionInfo {
  String get userId;
  String get branchId;
}

// Infrastructure — Adapter receives the Port via constructor
class AuthApiRemoteDataSource implements AuthRemoteDataSource {
  const AuthApiRemoteDataSource({
    required this.client,
    required this.session,
  });

  final AuthApiClient client;
  final ISessionInfo session;

  @override
  Future<UserDto> login({required String email, required String password}) async {
    final body = {'email': email, 'password': password, 'branch_id': session.branchId};
    // ...
  }
}
```

### Critical Rule

Presentation does not access Infrastructure.

These imports are forbidden:

```dart
import 'package:app/features/login/infrastructure/repositories/auth_repository_adapter.dart';
import 'package:app/features/login/infrastructure/datasources/auth_remote_datasource.dart';
import 'package:app/features/login/infrastructure/dtos/user_dto.dart';
```

Inside any of:

```
presentation/
screens/
widgets/
state/
```

### Also Forbidden

Domain importing Application, Infrastructure, or Presentation:

```dart
import '../../application/...';
import '../../infrastructure/...';
import '../../presentation/...';
```

Application importing Infrastructure or Presentation:

```dart
import '../../infrastructure/...';
import '../../presentation/...';
```

Infrastructure importing Presentation:

```dart
import '../../presentation/...';
```

`lib/core/` importing `lib/features/...`:

```dart
import 'package:app/features/...';
```

---

# 14. Fitness Functions

Architectural rules are **automatically verified** through the project's tooling.

## 14.1 Validation Script (`tools/architecture_check.dart`)

Run with:

```bash
dart run tools/architecture_check.dart
dart run tools/architecture_check.dart --path lib/features/login
```

Returns exit code 1 if violations are found, enabling CI integration. Validates:

### Rule 1 — Presentation cannot import Infrastructure

```
No file under */presentation/**/*.dart may import from */infrastructure/
```

### Rule 2 — Domain cannot import Application, Infrastructure, or Presentation

```
No file under */domain/**/*.dart may import from */application/, */infrastructure/, or */presentation/
```

### Rule 3 — Application cannot import Infrastructure or Presentation

```
No file under */application/**/*.dart may import from */infrastructure/ or */presentation/
```

### Rule 4 — Infrastructure cannot import Presentation

```
No file under */infrastructure/**/*.dart may import from */presentation/
```

### Rule 5 — DTOs cannot appear outside Infrastructure

```
Classes with the Dto suffix may only exist inside */infrastructure/
```

### Rule 6 — RepositoryAdapter cannot be used from Presentation

```
Classes with the RepositoryAdapter suffix cannot be imported by Presentation
```

### Rule 7 — GetIt is forbidden in Presentation

```
Calls to sl.get<> or sl() cannot appear in files under */presentation/, */screens/, */widgets/, */state/
```

### Rule 8 — Cubits/Blocs cannot be registered as LazySingleton

```
registerLazySingleton with a factory returning a Cubit or Bloc type is forbidden
```

### Rule 9 — Either with free generics is forbidden in Domain, Application, and Infrastructure

```
The pattern Either<L, R> with free type parameters cannot appear in */domain/, */application/, or */infrastructure/
```

### Rule 10 — UseCase files must follow naming convention (AST)

```
Files named *_usecase.dart must declare a class ending in UseCase, located under */application/usecases/
```

### Rule 11 — RepositoryAdapter must implement a Repository Port (AST)

```
Classes ending in RepositoryAdapter must implement at least one interface ending in Repository
```

### Rule 12 — Cubit/Bloc must not depend on other Cubit/Bloc in constructor (AST)

```
Constructor parameters of a Cubit/Bloc class must not be of type Cubit or Bloc
```

### Rule 13 — Datasource must not return Entity types (AST)

```
Methods in classes ending in DataSource must not return Domain Entity types — they must return DTOs or technical models
```

The authoritative, currently-implemented set of rules lives in `tools/architecture_check.dart`. Any rule listed above that is not yet automatable is documented there as a `// TODO:` and does not break script execution.

## 14.2 Real-Time Lint Rules (optional, future work)

If the project later adds a `custom_lint`-based package, activate it in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
custom_lint:
  rules:
    - avoid_get_it_in_presentation
    - avoid_cubit_as_lazy_singleton
    - avoid_untyped_either
    - avoid_direct_cubit_dependency
```

| Rule | Detects | Severity |
|---|---|---|
| `avoid_get_it_in_presentation` | `sl.get<>()` in Presentation/Cubit/Bloc files | error |
| `avoid_cubit_as_lazy_singleton` | `registerLazySingleton` returning Cubit/Bloc | warning |
| `avoid_untyped_either` | `Either<L, R>` with free generics | error |
| `avoid_direct_cubit_dependency` | Field of type Cubit/Bloc inside another Cubit/Bloc | warning |

This package does not exist yet in this standalone app — it is documented here as a TODO for when/if real-time IDE linting is introduced. The static checks in `tools/architecture_check.dart` are authoritative today.

---

# 14.3 Technical Debt Metrics (`tools/technical_debt_metrics.dart`)

Run with:

```bash
dart run tools/technical_debt_metrics.dart
dart run tools/technical_debt_metrics.dart --path lib/features/login
```

Always exits 0 (reporting only — does not block CI). Produces a structured report per scope.

### Metrics collected

| Metric | Description |
|---|---|
| LOC | Lines of code (non-blank, non-comment) |
| Classes | Number of class declarations |
| Functions | Number of method/function declarations |
| CC | Cyclomatic Complexity (per function) |
| CogC | Cognitive Complexity — Sonar/Richards model (per function) |
| Nesting | Max nesting depth (per function) |
| Ca | Afferent coupling — inbound imports |
| Ce | Efferent coupling — outbound imports |
| I | Instability = Ce / (Ca + Ce) |
| A | Abstractness = abstract classes / total classes |
| D | Distance from Main Sequence = \|A + I − 1\| (interpreted by Policy Engine) |
| Hotspots | Functions with highest CC + CogC + Nesting combined score |

### Scopes

| Scope | Example |
|---|---|
| `feature` | A single feature under `lib/features/<feature_name>/` |
| `app` | The whole app (`lib/`) |
| `package` | Reserved for a future shared package (not used today) |
| `monorepo` | Reserved for a future monorepo root (not used today) |

### Thresholds

**CC:** ✅ 0–10 / ⚠️ 11–15 / ❌ 16–24 / 🚨 25+

**CogC:** ✅ 0–10 / ⚠️ 11–20 / ❌ 21–30 / 🚨 31+

**Nesting:** ✅ 0–3 / ⚠️ 4–5 / ❌ 6–7 / 🚨 8+

---

# 14.4 Policy Engine

The Policy Engine applies context-aware thresholds to metrics. Default policy file: `.ai/architecture-policies.yaml`.

```bash
dart run tools/technical_debt_metrics.dart --policy .ai/architecture-policies.yaml
```

### Policy scopes

Each scope (`feature`, `app`, `package`, `monorepo`) may define independent thresholds for:

- `cognitive_complexity.maximum.{warning,error}`
- `nesting_depth.maximum.{warning,error}`
- `cyclomatic_complexity.maximum.{warning,error}`
- `size.loc.{warning,error}`
- `coupling.{ce,instability}.{warning,error}`
- `abstraction.distance.{warning,error,mode}`

### Enforcement modes

| Mode | Behavior |
|---|---|
| `report_only` | Prints policy evaluation, never fails |
| `fail_on_error` | Exits non-zero when any error threshold is exceeded |
| `fail_on_regression` | Exits non-zero only when a metric regressed vs. baseline |

Default: `report_only` for all scopes — **this is enforced as a non-blocking governance signal, not a CI gate**, in this app.

### Distance interpretation

`D` (distance from Main Sequence) is **not** evaluated with fixed global thresholds. Its interpretation is delegated entirely to the Policy Engine per scope. Example: `feature.abstraction.distance.mode = informational` means D is shown but never flagged.

---

# 14.5 Evolutionary Baselines

Baselines capture a metric snapshot for comparison over time.

```bash
# Export a baseline
dart run tools/technical_debt_metrics.dart --path lib/features/login --export-baseline

# Compare against a baseline
dart run tools/technical_debt_metrics.dart --path lib/features/login --compare-baseline
```

### Baseline storage

```
.ai/architecture-baselines/
  features/
    login.metrics.json
  apps/
    hex_app.metrics.json
  packages/
    <package-name>.metrics.json   (reserved, not used today)
  monorepo.metrics.json           (reserved, not used today)
```

### Baseline format (v1)

```json
{
  "version": 1,
  "scope": "feature",
  "name": "login",
  "exportedAt": "2026-01-01T00:00:00Z",
  "metrics": { "loc": 320, "cc_avg": 2.1, "cogc_max": 12 },
  "hotspots": [
    { "function": "LoginCubit::login", "cc": 4, "cogc": 6, "nesting": 2 }
  ]
}
```

### Delta report

The comparison shows metric diffs plus hotspot changes with directional indicators (▲ regression / ▼ improvement / = unchanged).

---

# 14.6 Spec-Driven Development

Spec-Driven Development (SDD) is the practice of writing an explicit, reviewable specification before implementation begins. It is not a documentation exercise — it is the primary context source for AI agents and human developers.

## Principle

```
spec → plan → tasks → implementation → validation
```

Never implement against a verbal requirement.
Always implement against a written, approved spec.

## Feature Levels

| Level | Required files |
|---|---|
| Quick | `spec.md`, `tasks.md` |
| Standard | `spec.md`, `plan.md`, `tasks.md`, `quickstart.md` |
| Complex | Standard + optional `research.md`, `data-model.md`, `contracts/` |

## File Structure

```
specs/
  <feature_name>/
    spec.md
    plan.md
    tasks.md
    quickstart.md

  templates/
    spec.template.md
    plan.template.md
    tasks.template.md
    quickstart.template.md
```

## Integration with AI Agents

| Agent | Reads | Produces |
|---|---|---|
| `architect.agent.md` | `spec.md` + context files | `plan.md` (Domain/Application/Infrastructure/Presentation design) |
| `feature-builder.agent.md` | `plan.md` + `tasks.md` + context files | Implementation |
| `reviewer.agent.md` | `spec.md` + `plan.md` + context files | Review with spec compliance table |

## Integration with Governance

- `plan.md` must reference the current baseline from `.ai/architecture-baselines/`.
- `tasks.md` must include a validation block: `architecture_check` + `technical_debt_metrics` + baseline comparison.
- `quickstart.md` must cover all acceptance criteria from `spec.md` as test scenarios.
- Reviewer must produce a spec compliance table mapping each criterion to an implementation status.

---

# 15. Rules for AI Agents

When an agent works on this project it must:

- read this file before modifying any code;
- respect the existing structure (`domain/application/infrastructure/presentation/di`);
- not invent new architecture or layer names;
- not rename folders without justification;
- not move logic between layers without explaining why;
- not touch Infrastructure when the task is Presentation-only;
- not touch Presentation when the task is Domain/Application/Infrastructure-only;
- not create DTOs in Presentation;
- not create business logic in widgets;
- not create circular dependencies;
- not hardcode visual styles;
- not replace existing patterns with personal preferences;
- not write "demo" code in production screens;
- not implement a Repository Adapter without first defining its Domain Port.

---

# 16. Pre-Completion Checklist

Before considering a feature done, validate:

```
[ ] Presentation does not import Infrastructure.
[ ] Domain does not import Application, Infrastructure, or Presentation.
[ ] Application does not import Infrastructure or Presentation.
[ ] Infrastructure does not import Presentation.
[ ] UseCases depend on Domain Ports (abstract repositories).
[ ] RepositoryAdapter implements a Domain Repository (Port).
[ ] DTOs do not leave Infrastructure.
[ ] There are mappers between DTOs and Entities.
[ ] Cubit/Bloc does not call datasources or adapters directly — only UseCases.
[ ] Presentation handles loading, empty, error, and success states.
[ ] Technical errors are transformed into Failures.
[ ] Either<L, R> uses a concrete L as a subtype of Failure (no free generics).
[ ] Dependency injection respects the correct order (clients → datasources → adapters → usecases → cubits).
[ ] Cubits and Blocs registered with registerFactory, not registerLazySingleton.
[ ] No sl.get<>() inside Cubits, Blocs, Screens, or Widgets.
[ ] No static access to preferences/dotenv inside Domain, Application, or Infrastructure.
[ ] Cubits do not have direct dependencies on other Cubits in their constructor.
[ ] Names follow conventions (UseCase suffix in PascalCase, _usecase.dart file; RepositoryAdapter implementing Repository).
[ ] No heavy business logic in widgets.
[ ] No hardcoded styles when a Design System exists.
[ ] Tests exist at least for critical use cases, cubits, or repository adapters.
[ ] dart run tools/architecture_check.dart passes with no errors.
[ ] dart run tools/technical_debt_metrics.dart reviewed — no unacceptable regressions vs. baseline.
```

---

# 17. Default Decisions

When in doubt, apply these decisions:

```
Simple state                → Cubit
Complex/event-driven state  → Bloc
External data               → DataSource (infrastructure)
Business action              → UseCase (application)
Pure business rule           → Domain Rule (domain/rules)
Business contract            → Repository Port (domain, abstract)
Technical implementation      → RepositoryAdapter (infrastructure)
API ↔ Domain transform        → Mapper
Recoverable error             → Failure
Visual screen                  → Screen
Reusable component             → Widget
Visual style                    → Design System
```

---

# 18. Final Criterion

An implementation is correct if:

- it is easy to understand;
- it respects the `Presentation → Application → Domain` and `Infrastructure → Domain` flow;
- it can be tested without external services (Domain and Application can be tested with fakes for Ports);
- the API/technical implementation can change (a new Adapter) without breaking Presentation or Application;
- the Presentation can change without breaking Infrastructure;
- it maintains business language in Domain and Application;
- it does not mix responsibilities;
- it scales without becoming fragile.

An implementation is not acceptable if it works but breaks the architecture.

The goal is not only that it compiles.

The goal is that the system can grow.
