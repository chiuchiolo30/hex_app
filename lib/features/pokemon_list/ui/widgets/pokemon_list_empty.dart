import 'package:flutter/material.dart';

class PokemonListEmptyWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const PokemonListEmptyWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pokémon found.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try again later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
