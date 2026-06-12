import 'package:flutter/material.dart';

class PokemonListLoadingWidget extends StatelessWidget {
  const PokemonListLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
