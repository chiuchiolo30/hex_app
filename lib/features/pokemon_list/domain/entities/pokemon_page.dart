import 'package:equatable/equatable.dart';

import 'pokemon.dart';

class PokemonPage extends Equatable {
  final List<Pokemon> pokemon;
  final bool hasNextPage;

  const PokemonPage({
    required this.pokemon,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [pokemon, hasNextPage];
}
