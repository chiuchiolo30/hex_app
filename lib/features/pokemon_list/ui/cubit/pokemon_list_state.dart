import 'package:equatable/equatable.dart';

import '../../domain/entities/pokemon.dart';

enum PokemonListStatus { initial, loading, success, empty, failure }

class PokemonListState extends Equatable {
  final PokemonListStatus status;
  final List<Pokemon> pokemon;
  final String? failureMessage;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? paginationFailureMessage;

  const PokemonListState({
    required this.status,
    required this.pokemon,
    this.failureMessage,
    required this.isLoadingMore,
    required this.hasReachedEnd,
    this.paginationFailureMessage,
  });

  factory PokemonListState.initial() => const PokemonListState(
    status: PokemonListStatus.initial,
    pokemon: [],
    isLoadingMore: false,
    hasReachedEnd: false,
  );

  PokemonListState copyWith({
    PokemonListStatus? status,
    List<Pokemon>? pokemon,
    String? failureMessage,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? paginationFailureMessage,
  }) {
    return PokemonListState(
      status: status ?? this.status,
      pokemon: pokemon ?? this.pokemon,
      failureMessage: failureMessage ?? this.failureMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      paginationFailureMessage:
          paginationFailureMessage ?? this.paginationFailureMessage,
    );
  }

  PokemonListState loading() => copyWith(
    status: PokemonListStatus.loading,
    failureMessage: null,
    paginationFailureMessage: null,
  );

  PokemonListState failure(String message) => copyWith(
    status: PokemonListStatus.failure,
    failureMessage: message,
  );

  @override
  List<Object?> get props => [
    status,
    pokemon,
    failureMessage,
    isLoadingMore,
    hasReachedEnd,
    paginationFailureMessage,
  ];
}
