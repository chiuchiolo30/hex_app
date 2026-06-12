import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_pokemon_list_usecase.dart';
import 'pokemon_list_state.dart';

class PokemonListCubit extends Cubit<PokemonListState> {
  final GetPokemonListUseCase getPokemonListUseCase;

  PokemonListCubit({required this.getPokemonListUseCase})
    : super(PokemonListState.initial());

  static const _limit = 20;
  int _offset = 0;
  bool _isFetching = false;

  Future<void> loadFirstPage() async {
    _offset = 0;
    _isFetching = true;
    emit(state.loading());

    final result = await getPokemonListUseCase(offset: _offset, limit: _limit);
    result.fold(
      (failure) => emit(state.failure(failure.message)),
      (page) {
        _offset += _limit;
        if (page.pokemon.isEmpty) {
          emit(state.copyWith(status: PokemonListStatus.empty));
        } else {
          emit(
            state.copyWith(
              status: PokemonListStatus.success,
              pokemon: page.pokemon,
              hasReachedEnd: !page.hasNextPage,
            ),
          );
        }
      },
    );
    _isFetching = false;
  }

  Future<void> loadNextPage() async {
    if (_isFetching || state.hasReachedEnd) return;
    _isFetching = true;
    emit(
      state.copyWith(isLoadingMore: true, paginationFailureMessage: null),
    );

    final result = await getPokemonListUseCase(offset: _offset, limit: _limit);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          paginationFailureMessage: failure.message,
        ),
      ),
      (page) {
        _offset += _limit;
        emit(
          state.copyWith(
            pokemon: [...state.pokemon, ...page.pokemon],
            isLoadingMore: false,
            hasReachedEnd: !page.hasNextPage,
          ),
        );
      },
    );
    _isFetching = false;
  }
}
