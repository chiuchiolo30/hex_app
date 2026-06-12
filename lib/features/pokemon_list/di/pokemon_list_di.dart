import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/pokemon_api_datasource.dart';
import '../data/datasources/pokemon_remote_datasource.dart';
import '../data/repositories/pokemon_repository_impl.dart';
import '../domain/repositories/pokemon_repository.dart';
import '../domain/usecases/get_pokemon_list_usecase.dart';
import '../ui/cubit/pokemon_list_cubit.dart';

final sl = GetIt.instance;

Future<void> configurePokemonListDependencies() async {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(baseUrl: 'https://pokeapi.co/api/v2')),
    );
  }

  sl.registerLazySingleton<PokemonRemoteDataSource>(
    () => PokemonApiDataSource(sl()),
  );

  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => GetPokemonListUseCase(sl()));

  sl.registerFactory(() => PokemonListCubit(getPokemonListUseCase: sl()));
}
