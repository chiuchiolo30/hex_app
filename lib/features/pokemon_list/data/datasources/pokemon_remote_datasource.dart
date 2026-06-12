import '../dtos/pokemon_list_response_dto.dart';

abstract class PokemonRemoteDataSource {
  Future<PokemonListResponseDto> getPokemonList({
    required int offset,
    required int limit,
  });
}
