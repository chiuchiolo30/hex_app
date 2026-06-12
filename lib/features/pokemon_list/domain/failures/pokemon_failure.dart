import 'package:equatable/equatable.dart';

sealed class PokemonFailure extends Equatable {
  const PokemonFailure();
  String get message;
}

class PokemonNetworkFailure extends PokemonFailure {
  const PokemonNetworkFailure();

  @override
  String get message => 'Could not load Pokemon. Check your connection.';

  @override
  List<Object?> get props => [];
}

class PokemonUnexpectedFailure extends PokemonFailure {
  const PokemonUnexpectedFailure({this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String get message => 'An unexpected error occurred.';

  @override
  List<Object?> get props => [error, stackTrace];
}
