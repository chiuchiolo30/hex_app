# Tasks: pokemon_list

> Ejecutar en orden. Cada bloque debe estar completo antes de pasar al siguiente.
> Builder: seguir plan.md y context/architecture.md.

---

## Bloque 0 — Dependencies

- [x] Agregar `flutter_bloc` (`flutter pub add flutter_bloc`)
- [x] Agregar `equatable` (`flutter pub add equatable`)
- [x] Agregar `get_it` (`flutter pub add get_it`)
- [x] Agregar `dartz` (`flutter pub add dartz`)
- [x] Agregar `dio` (`flutter pub add dio`)

---

## Bloque 1 — Domain

- [x] Crear entidad `Pokemon` → `domain/entities/pokemon.dart`
- [x] Crear entidad `PokemonPage` → `domain/entities/pokemon_page.dart`
- [x] Crear `PokemonFailure` (sealed: `PokemonNetworkFailure`, `PokemonUnexpectedFailure`) → `domain/failures/pokemon_failure.dart`
- [x] Crear `PokemonRepository` (abstracto) → `domain/repositories/pokemon_repository.dart`
- [x] Crear `GetPokemonListUseCase` → `domain/usecases/get_pokemon_list_usecase.dart`

---

## Bloque 2 — Data

- [x] Crear `PokemonResultDto` → `data/dtos/pokemon_result_dto.dart`
- [x] Crear `PokemonListResponseDto` → `data/dtos/pokemon_list_response_dto.dart`
- [x] Crear `PokemonRemoteDataSource` (abstracto) → `data/datasources/pokemon_remote_datasource.dart`
- [x] Crear `PokemonApiDataSource` (impl con Dio) → `data/datasources/pokemon_api_datasource.dart`
- [x] Crear mapper `PokemonResultMapper` (extensión `toDomain()`) → `data/mappers/pokemon_result_mapper.dart`
- [x] Crear `PokemonRepositoryImpl` → `data/repositories/pokemon_repository_impl.dart`

---

## Bloque 3 — UI

- [x] Crear `PokemonListState` con enum `PokemonListStatus` → `ui/cubit/pokemon_list_state.dart`
- [x] Crear `PokemonListCubit` (loadFirstPage, loadNextPage, guard `_isFetching`) → `ui/cubit/pokemon_list_cubit.dart`
- [x] Crear `PokemonCard` widget → `ui/widgets/pokemon_card.dart`
- [x] Crear `PokemonListLoadingWidget` → `ui/widgets/pokemon_list_loading.dart`
- [x] Crear `PokemonListErrorWidget` → `ui/widgets/pokemon_list_error.dart`
- [x] Crear `PokemonListEmptyWidget` → `ui/widgets/pokemon_list_empty.dart`
- [x] Crear `PokemonListScreen` con todos los estados → `ui/screens/pokemon_list_screen.dart`

---

## Bloque 4 — DI

- [x] Crear `pokemon_list_di.dart` (Dio, DataSource, Repository, UseCase, Cubit) → `di/pokemon_list_di.dart`
- [x] Integrar DI en `main.dart` (configureDependencies, BlocProvider, PokemonListScreen) → `main.dart`

---

## Bloque 5 — Validación

- [x] `dart run tools/architecture_check.dart --path lib/features/pokemon_list` → 0 errores, 0 warnings
- [x] `dart run tools/technical_debt_metrics.dart --path lib/features/pokemon_list` → CC 13, CogC 6, nesting 2
- [x] `dart run tools/technical_debt_metrics.dart --path lib/features/pokemon_list --export-baseline` → baseline exportado
- [x] `dart analyze lib/features/pokemon_list` → No issues found

---

## Bloque 6 — Review

- [ ] Reviewer revisa implementación contra spec.md y plan.md
- [ ] Decisión: APPROVED / APPROVED WITH CHANGES / REJECTED
