import '../../domain/entities/pokemon.dart';
import '../dtos/pokemon_result_dto.dart';

extension PokemonResultMapper on PokemonResultDto {
  Pokemon toDomain() {
    final id = _extractIdFromUrl(url);
    return Pokemon(
      id: id,
      name: _formatName(name),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      pokedexNumber: '#${id.toString().padLeft(3, '0')}',
    );
  }

  static int _extractIdFromUrl(String url) {
    final segments = url.split('/')..removeWhere((s) => s.isEmpty);
    return int.parse(segments.last);
  }

  static String _formatName(String name) {
    return name
        .split('-')
        .map((word) =>
            word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
        .join(' ');
  }
}
