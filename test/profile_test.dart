import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/avatars.dart';
import 'package:zoukicchi/models/game_state.dart';

void main() {
  group('プロフィール', () {
    test('はじめは名前がなく、一度は尋ねられる', () {
      final state = GameState.fresh();
      expect(state.userName, isEmpty);
      expect(state.hasName, isFalse);
    });

    test('空白だけの名前は名前として扱わない', () {
      final state = GameState.fresh()..userName = '   ';
      expect(state.hasName, isFalse);
    });

    test('名前とアイコンが保存される', () {
      final state = GameState.fresh()
        ..userName = 'kikuri'
        ..avatarId = 'enemy:ramen';

      final restored = GameState.decode(state.encode());
      expect(restored.userName, 'kikuri');
      expect(restored.avatarId, 'enemy:ramen');
    });

    test('はじめは心臓だけが選べる', () {
      final state = GameState.fresh();
      final choices = availableAvatars(state);

      expect(choices, hasLength(1));
      expect(choices.single.id, kDefaultAvatar);
      expect(avatarOf(state).id, kDefaultAvatar);
    });

    test('仲間が増えると選べる顔も増える', () {
      final state = GameState.fresh();
      state.readEpisodes.addAll(['main:2', 'main:3']);

      final ids = organAvatars(state).map((a) => a.id);
      expect(ids, contains('organ:lung'));
      expect(ids, contains('organ:stomach'));
      expect(ids, isNot(contains('organ:brain')));
    });

    test('敵は倒すまで選べない', () {
      final state = GameState.fresh();
      expect(enemyAvatars(state), isEmpty);

      state.clearedStage = 1;
      final ids = enemyAvatars(state).map((a) => a.id);
      expect(ids, hasLength(1));
      expect(ids.single, startsWith('enemy:'));
    });

    test('ボスまで倒すとボスも選べる', () {
      final state = GameState.fresh()..clearedStage = 10;
      expect(
        enemyAvatars(state).map((a) => a.id),
        contains('enemy:boss_seikatsu'),
      );
    });

    test('持っていないアイコンが入っていても心臓に戻る', () {
      // セーブを直接いじられたときに、絵の出ない丸が残らないように
      final state = GameState.fresh()..avatarId = 'enemy:boss_seikatsu';
      expect(avatarOf(state).id, kDefaultAvatar);
    });

    test('選べるアイコンはすべて絵の場所を持っている', () {
      final state = GameState.fresh()
        ..clearedStage = 30
        ..readEpisodes.addAll(['main:2', 'main:3', 'main:5', 'main:7']);

      for (final avatar in availableAvatars(state)) {
        expect(avatar.imagePath, endsWith('.png'), reason: avatar.name);
        expect(avatar.name, isNotEmpty);
      }
    });
  });
}
