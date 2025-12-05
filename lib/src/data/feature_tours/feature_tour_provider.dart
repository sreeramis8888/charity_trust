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

  CompletedFeatureToursNotifier(this.ref) : super({});

  Future<void> markTourAsCompleted(String tourId) async {
    state = {...state, tourId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_completed_$tourId', true);
  }

  Future<void> resetTour(String tourId) async {
    state = state.where((id) => id != tourId).toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tour_completed_$tourId');
  }

  Future<bool> isTourCompleted(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tour_completed_$tourId') ?? false;
  }

  Future<void> loadTourStatus(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('tour_completed_$tourId') ?? false;
    if (isCompleted) {
      state = {...state, tourId};
    }
  }
}
