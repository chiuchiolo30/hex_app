import 'package:equatable/equatable.dart';

class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final String pokedexNumber;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pokedexNumber,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, pokedexNumber];
}
