import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/pokemon_list/di/pokemon_list_di.dart';
import 'features/pokemon_list/ui/cubit/pokemon_list_cubit.dart';
import 'features/pokemon_list/ui/screens/pokemon_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configurePokemonListDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => sl<PokemonListCubit>(),
        child: const PokemonListScreen(),
      ),
    );
  }
}
