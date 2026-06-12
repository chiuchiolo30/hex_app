import 'pokemon_result_dto.dart';

class PokemonListResponseDto {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonResultDto> results;

  const PokemonListResponseDto({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponseDto.fromJson(Map<String, dynamic> json) {
    return PokemonListResponseDto(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((r) => PokemonResultDto.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
