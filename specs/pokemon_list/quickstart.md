# Quickstart: pokemon_list

## Overview

Scroll infinito de Pokémon desde PokeAPI con Clean Architecture en Flutter.

## File structure

```
lib/features/pokemon_list/
  domain/    → entities, failures, repository contract, use case
  data/      → DTOs, datasource (Dio + PokeAPI), mapper, repository impl
  ui/        → Cubit, state, screen, widgets (card, loading, error, empty)
  di/        → GetIt wiring
```

## How to run

```bash
flutter pub get
flutter run
```

The app opens directly on `PokemonListScreen`.

## Acceptance criteria map

| AC | How to test |
|---|---|
| AC1 | Open the app → first 20 Pokémon load from PokeAPI |
| AC2 | Each card shows artwork image and formatted name |
| AC3 | Scroll to bottom → next page loads automatically, no duplicates |
| AC4 | Turn off internet, restart app → full-screen loading indicator shown |
| AC5 | While scrolling, when next page loads → small spinner at bottom of list |
| AC6 | Airplane mode, open app → error message "Could not load Pokémon. Check your connection." + Retry button |
| AC7 | Load first page, then airplane mode, scroll → list stays visible, bottom shows inline retry button |
| AC8 | (Simulated) API returns empty results → "No Pokémon found." + Refresh button |
| AC9 | Scroll to last page (#1000+) → no more loading, "You've seen them all!" shown |
| AC10 | (Simulated) Broken image URL → placeholder Pokéball icon shown instead |

## Architecture validation

```bash
dart run tools/architecture_check.dart --path lib/features/pokemon_list
# Expected: ✅ Sin violaciones arquitectónicas detectadas.

dart run tools/technical_debt_metrics.dart --path lib/features/pokemon_list
# Expected: ⚠️ Aprobado con advertencias (copyWith CC 13, within thresholds)

dart analyze lib/features/pokemon_list
# Expected: No issues found!
```

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | Cubit state management |
| `equatable` | Value equality |
| `get_it` | Dependency injection |
| `dartz` | `Either<Failure, T>` |
| `dio` | HTTP client → PokeAPI |
