import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

class SaveStore {
  static const _key = 'zoukicchi_save_v1';

  Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString(_key);
    if (source == null) return GameState.fresh();
    try {
      return GameState.decode(source);
    } on FormatException {
      return GameState.fresh();
    }
  }

  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.encode());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
