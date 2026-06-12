# Plan Técnico: pokemon_list

> Generado por: architect.agent.md
> Basado en: spec.md
> Contexto leído: architecture.md, conventions.md, design.md

---

## Resumen de arquitectura

Feature de lista paginada de Pokémon consumiendo PokeAPI REST. Clean Architecture con feature-first: domain (entities, usecase, repository abstracto), data (DTOs, datasource Dio, mapper, repository impl), UI (Cubit + screen + widgets de estado). Paginación infinita con guard contra requests duplicados. Todos los estados UX implementados (loading, success, empty, error, loading more, inline retry).

---

## Capas involucradas

```
domain/
  entities/
    pokemon.dart
    pokemon_page.dart
  repositories/
    pokemon_repository.dart
  usecases/
    get_pokemon_list_usecase.dart
  failures/
    pokemon_failure.dart

data/
  datasources/
    pokemon_remote_datasource.dart
    pokemon_api_datasource.dart
  dtos/
    pokemon_result_dto.dart
    pokemon_list_response_dto.dart
  mappers/
    pokemon_result_mapper.dart
  repositories/
    pokemon_repository_impl.dart

ui/
  screens/
    pokemon_list_screen.dart
  widgets/
    pokemon_card.dart
    pokemon_list_loading.dart
    pokemon_list_error.dart
    pokemon_list_empty.dart
  cubit/
    pokemon_list_state.dart
    pokemon_list_cubit.dart

di/
  pokemon_list_di.dart
```

---

## Domain Design

### Entidades

- **Pokemon**: `id` (int), `name` (String, formateado), `imageUrl` (String), `pokedexNumber` (String, ej: "#001")
- **PokemonPage**: `pokemon` (List<Pokemon>), `hasNextPage` (bool)

### Repository (abstracto)

```dart
abstract class PokemonRepository {
  Future<Either<PokemonFailure, PokemonPage>> getPokemonList({
    required int offset,
    required int limit,
  });
}
```

### UseCases

| UseCase | Input | Output |
|---|---|---|
| `GetPokemonListUseCase` | `offset: int, limit: int` | `Either<PokemonFailure, PokemonPage>` |

### Failures

```dart
sealed class PokemonFailure ...
  - PokemonNetworkFailure (DioException → network error)
  - PokemonUnexpectedFailure (catch-all)
```

---

## Data Design

### DTOs

- **PokemonResultDto**: `name` (String), `url` (String) — del array `results[]` de PokeAPI
- **PokemonListResponseDto**: `count`, `next`, `previous`, `results` — respuesta completa

### DataSources

| DataSource | Tipo | Método |
|---|---|---|
| `PokemonRemoteDataSource` | abstract remote | `getPokemonList(offset, limit)` |
| `PokemonApiDataSource` | impl con Dio | `GET /pokemon?limit=&offset=` → `PokemonListResponseDto` |

### RepositoryImpl

Transformaciones: `DioException` → `PokemonNetworkFailure`, `Exception` → `PokemonUnexpectedFailure`. Mapeo DTO → Entity vía `PokemonResultMapper.toDomain()`.

---

## UI Design

### Screen
- `PokemonListScreen` con `PokemonListCubit`

### Estados

```dart
enum PokemonListStatus { initial, loading, success, empty, failure }
```

Additional state fields: `isLoadingMore`, `hasReachedEnd`, `paginationFailureMessage`

### Flujo

```
PokemonListScreen
  → PokemonListCubit
    → GetPokemonListUseCase
      → PokemonRepository
        → PokemonApiDataSource (Dio)
          → PokeAPI
```

---

## Decisiones técnicas

- Usar Cubit (no Bloc) porque el flujo es lineal (loadFirstPage, loadNextPage) sin eventos concurrentes.
- `PokemonPage` como entidad de dominio para transportar `hasNextPage` sin exponer el DTO de respuesta.
- `_isFetching` como guard en Cubit para evitar requests duplicados de paginación.
- Widgets de estado (loading, error, empty) extraídos a archivos independientes para mantener la screen compuesta de widgets pequeños.
- Dio como HTTP client estándar del proyecto.

---

## Validación de arquitectura

- [x] UI no importa Data.
- [x] Domain no depende de infraestructura.
- [x] DTOs no salen de Data.
- [x] UseCases usan repository abstracto.
- [x] Either con L concreto como subtipo de Failure (`PokemonFailure`).
- [x] Cubit registrado como Factory.
- [x] Sin GetIt en UI/Cubit.
- [x] Sin Bloc-to-Bloc coupling.
