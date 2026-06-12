import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pokemon_list_cubit.dart';
import '../cubit/pokemon_list_state.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_list_empty.dart';
import '../widgets/pokemon_list_error.dart';
import '../widgets/pokemon_list_loading.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PokemonListCubit>().loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonListCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: BlocBuilder<PokemonListCubit, PokemonListState>(
        builder: (context, state) {
          return switch (state.status) {
            PokemonListStatus.initial ||
            PokemonListStatus.loading =>
              const PokemonListLoadingWidget(),
            PokemonListStatus.failure => PokemonListErrorWidget(
              message: state.failureMessage ?? 'Something went wrong.',
              onRetry: () =>
                  context.read<PokemonListCubit>().loadFirstPage(),
            ),
            PokemonListStatus.empty => PokemonListEmptyWidget(
              onRefresh: () =>
                  context.read<PokemonListCubit>().loadFirstPage(),
            ),
            PokemonListStatus.success => _buildSuccess(state),
          };
        },
      ),
    );
  }

  Widget _buildSuccess(PokemonListState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.pokemon.length + (_hasBottomWidget(state) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.pokemon.length) {
          return _buildBottomWidget(state, context);
        }
        return PokemonCard(pokemon: state.pokemon[index]);
      },
    );
  }

  bool _hasBottomWidget(PokemonListState state) {
    return state.isLoadingMore ||
        state.paginationFailureMessage != null ||
        state.hasReachedEnd;
  }

  Widget _buildBottomWidget(PokemonListState state, BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.paginationFailureMessage != null) {
      return Center(
        child: TextButton.icon(
          onPressed: () => context.read<PokemonListCubit>().loadNextPage(),
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(state.paginationFailureMessage!),
        ),
      );
    }

    if (state.hasReachedEnd && state.pokemon.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'You\'ve seen them all!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
