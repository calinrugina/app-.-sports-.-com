import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indexul sportului selectat în tab-ul Sports.
final selectedSportIndexProvider = StateProvider<int>((ref) => 0);

/// Când e setat, HomeScreen trebuie să treacă la tab-ul Sports și să selecteze acest index.
/// Folosit la navigare din dropdown (Asset Details) înapoi la app cu un sport ales.
final goToSportsWithIndexProvider = StateProvider<int?>((ref) => null);
