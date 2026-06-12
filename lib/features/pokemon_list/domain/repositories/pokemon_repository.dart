import 'package:dartz/dartz.dart';

import '../entities/pokemon_page.dart';
import '../failures/pokemon_failure.dart';

abstract class PokemonRepository {
  Future<Either<PokemonFailure, PokemonPage>> getPokemonList({
    required int offset,
    required int limit,
  });
}
