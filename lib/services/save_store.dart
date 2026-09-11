import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

class SaveStore {
  static const _key = 'zoukicchi_save_v1';

  /// 読めなければ最初から始める。
  ///
  /// 保存値の取り出し自体が失敗することもあるので、全体を囲っている。
  /// ここで例外が抜けると起動処理が完了せず、ローディング画面のまま固まる。
  Future<GameState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final source = prefs.getString(_key);
      if (source == null) return GameState.fresh();
      return GameState.decode(source);
    } catch (_) {
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
