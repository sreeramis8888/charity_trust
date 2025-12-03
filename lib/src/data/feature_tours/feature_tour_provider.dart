import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final completedFeatureToursProvider =
    StateNotifierProvider<CompletedFeatureToursNotifier, Set<String>>((ref) {
  return CompletedFeatureToursNotifier(ref);
});

class CompletedFeatureToursNotifier extends StateNotifier<Set<String>> {
  final Ref ref;

  CompletedFeatureToursNotifier(this.ref) : super({}) {
    _loadCompletedTours();
  }

  Future<void> _loadCompletedTours() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList('completed_feature_tours') ?? [];
    state = completed.toSet();
  }

  Future<void> markTourAsCompleted(String tourId) async {
    state = {...state, tourId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_feature_tours', state.toList());
  }

  Future<void> resetTour(String tourId) async {
    state = state.where((id) => id != tourId).toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_feature_tours', state.toList());
  }

  bool isTourCompleted(String tourId) => state.contains(tourId);
}
