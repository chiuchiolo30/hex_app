class PokemonResultDto {
  final String name;
  final String url;

  const PokemonResultDto({required this.name, required this.url});

  factory PokemonResultDto.fromJson(Map<String, dynamic> json) {
    return PokemonResultDto(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
