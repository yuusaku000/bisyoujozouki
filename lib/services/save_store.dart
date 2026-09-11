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
    } catch (_) {
      // 壊れたセーブで起動不能になるくらいなら、最初から始めたほうがまし。
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
