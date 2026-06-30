import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Suivi local de progression (on-device, marche aussi pour les visiteurs sans
/// compte) : rites accomplis + douas lues. La synchro serveur reste un TODO ;
/// ce store garantit qu'un élément marqué « terminé » est immédiatement et
/// durablement identifié comme tel dans l'app.
class LocalProgressState {
  final Set<String> completedRituals;
  final Set<String> readDuas;
  const LocalProgressState({this.completedRituals = const {}, this.readDuas = const {}});

  LocalProgressState copyWith({Set<String>? completedRituals, Set<String>? readDuas}) =>
      LocalProgressState(
        completedRituals: completedRituals ?? this.completedRituals,
        readDuas: readDuas ?? this.readDuas,
      );

  bool isRitualDone(String id) => completedRituals.contains(id);
  bool isDuaRead(String id) => readDuas.contains(id);
}

class LocalProgressNotifier extends StateNotifier<LocalProgressState> {
  LocalProgressNotifier() : super(const LocalProgressState()) {
    _load();
  }

  static const _ritualsKey = 'completed_rituals';
  static const _duasKey = 'read_duas';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = LocalProgressState(
      completedRituals: (prefs.getStringList(_ritualsKey) ?? const []).toSet(),
      readDuas: (prefs.getStringList(_duasKey) ?? const []).toSet(),
    );
  }

  Future<void> setRitualDone(String id, bool done) async {
    final next = {...state.completedRituals};
    done ? next.add(id) : next.remove(id);
    state = state.copyWith(completedRituals: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ritualsKey, next.toList());
  }

  Future<void> toggleRitual(String id) => setRitualDone(id, !state.isRitualDone(id));

  Future<void> setDuaRead(String id, bool read) async {
    if (state.isDuaRead(id) == read) return;
    final next = {...state.readDuas};
    read ? next.add(id) : next.remove(id);
    state = state.copyWith(readDuas: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_duasKey, next.toList());
  }

  Future<void> toggleDua(String id) => setDuaRead(id, !state.isDuaRead(id));
}

final localProgressProvider =
    StateNotifierProvider<LocalProgressNotifier, LocalProgressState>(
        (ref) => LocalProgressNotifier());
