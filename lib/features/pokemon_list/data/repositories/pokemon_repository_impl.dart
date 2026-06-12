import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/pokemon_page.dart';
import '../../domain/failures/pokemon_failure.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_remote_datasource.dart';
import '../mappers/pokemon_result_mapper.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;

  const PokemonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<PokemonFailure, PokemonPage>> getPokemonList({
    required int offset,
    required int limit,
  }) async {
    try {
      final dto = await remoteDataSource.getPokemonList(
        offset: offset,
        limit: limit,
      );
      final pokemon = dto.results.map((r) => r.toDomain()).toList();
      return Right(
        PokemonPage(pokemon: pokemon, hasNextPage: dto.next != null),
      );
    } on DioException {
      return const Left(PokemonNetworkFailure());
    } catch (e, st) {
      return Left(PokemonUnexpectedFailure(error: e, stackTrace: st));
    }
  }
}
