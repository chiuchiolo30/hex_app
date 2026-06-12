import 'package:dartz/dartz.dart';

import '../entities/pokemon_page.dart';
import '../failures/pokemon_failure.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonListUseCase {
  final PokemonRepository repository;

  const GetPokemonListUseCase(this.repository);

  Future<Either<PokemonFailure, PokemonPage>> call({
    required int offset,
    required int limit,
  }) =>
      repository.getPokemonList(offset: offset, limit: limit);
}
