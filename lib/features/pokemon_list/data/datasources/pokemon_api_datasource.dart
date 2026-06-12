import 'package:dio/dio.dart';

import '../dtos/pokemon_list_response_dto.dart';
import 'pokemon_remote_datasource.dart';

class PokemonApiDataSource implements PokemonRemoteDataSource {
  final Dio dio;

  const PokemonApiDataSource(this.dio);

  @override
  Future<PokemonListResponseDto> getPokemonList({
    required int offset,
    required int limit,
  }) async {
    final response = await dio.get(
      '/pokemon',
      queryParameters: {'offset': offset, 'limit': limit},
    );
    return PokemonListResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
