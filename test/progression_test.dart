import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/missions.dart';
import 'package:zoukicchi/models/daily_input.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';

GameState richState() => GameState.fresh()..coins = 10000000;

void main() {
  group('レベルの壁', () {
    test('上限は10刻み', () {
      expect(const OrganStatus().levelCap, 10);
      expect(const OrganStatus(ascensions: 1).levelCap, 20);
      expect(const OrganStatus(ascensions: 2).levelCap, 30);
    });

    test('上限に達するとコインがあっても上げられない', () {
      final state = richState();
      for (var i = 0; i < 20; i++) {
        state.levelUp('heart');
      }

      expect(state.statusOf('heart').level, 10);
      expect(state.canLevelUp('heart'), isFalse, reason: '鍵が要る');
    });

    test('鍵を払うと先へ進める', () {
      final state = richState();
      for (var i = 0; i < 20; i++) {
        state.levelUp('heart');
      }
      state.keys = 1;

      state.ascend('heart');

      expect(state.keys, 0);
      expect(state.statusOf('heart').levelCap, 20);
      expect(state.canLevelUp('heart'), isTrue);
    });

    test('限界を解いてもレベルも健康度も動かない', () {
      final state = richState();
      for (var i = 0; i < 20; i++) {
        state.levelUp('heart');
      }
      final before = state.statusOf('heart');
      state.keys = 1;

      state.ascend('heart');

      expect(state.statusOf('heart').level, before.level);
      expect(state.statusOf('heart').health, before.health);
    });

    test('鍵が足りなければ何も起きない', () {
      final state = richState();
      for (var i = 0; i < 20; i++) {
        state.levelUp('heart');
      }

      state.ascend('heart');

      expect(state.statusOf('heart').levelCap, 10);
    });

    test('先へ行くほど必要な鍵が増える', () {
      expect(const OrganStatus().keysToAscend, 1);
      expect(const OrganStatus(ascensions: 1).keysToAscend, 2);
      expect(const OrganStatus(ascensions: 2).keysToAscend, 3);
    });
  });

  group('ミッション', () {
    test('選べるのは決まった数まで', () {
      final state = GameState.fresh();
      for (final m in kMissions) {
        if (state.missionIds.length < kMissionSlots) state.missionIds.add(m.id);
      }
      expect(state.missionIds.length, kMissionSlots);
    });

    test('達成した目標の報酬が入る', () {
      final state = GameState.fresh();
      state.missionIds = ['long_walk', 'eat'];
      state.today = const DailyInput(steps: 8000, ateWell: true);

      final result = state.endDay();

      expect(result.clearedMissions.length, 2);
      expect(state.keys, 1, reason: '8000歩は鍵が出る');
      expect(state.tickets, 1);
    });

    test('未達の目標では何ももらえない', () {
      final state = GameState.fresh();
      state.missionIds = ['long_walk'];
      state.today = const DailyInput(steps: 100);

      final result = state.endDay();

      expect(result.clearedMissions, isEmpty);
      expect(state.keys, 0);
    });

    test('1日を終えると選び直しになる', () {
      final state = GameState.fresh();
      state.missionIds = ['eat'];
      state.today = const DailyInput(ateWell: true);

      state.endDay();

      expect(state.missionIds, isEmpty);
      expect(state.hasMissions, isFalse);
    });

    test('報酬でコインは増えない', () {
      // コインの源は歩数だけ、という決まりを崩さない
      final state = GameState.fresh();
      state.missionIds = ['eat', 'rest', 'sleep'];
      state.today = const DailyInput(
        ateWell: true,
        rested: true,
        sleptWell: true,
      );

      final result = state.endDay();

      expect(result.coinsEarned, 0);
      expect(state.coins, 0);
    });
  });

  group('鍵の入手', () {
    test('ボスを倒すと落とす', () {
      final state = GameState.fresh();
      state.clearedStage = 9;

      final got = state.clearStage(10);

      expect(got, GameState.bossKeyDrop);
      expect(state.keys, GameState.bossKeyDrop);
    });

    test('通常の敵は落とさない', () {
      final state = GameState.fresh();

      final got = state.clearStage(1);

      expect(got, 0);
      expect(state.keys, 0);
    });
  });

  test('鍵とチケットと設定が保存される', () {
    final state = GameState.fresh();
    state.keys = 3;
    state.tickets = 7;
    state.battleSpeed = BattleSpeed.fast;
    state.missionIds = ['eat'];

    final restored = GameState.decode(state.encode());

    expect(restored.keys, 3);
    expect(restored.tickets, 7);
    expect(restored.battleSpeed, BattleSpeed.fast);
    expect(restored.missionIds, ['eat']);
  });

  test('限界を解いた回数も保存される', () {
    final state = GameState.fresh();
    state.organs['heart'] = const OrganStatus(ascensions: 2);

    expect(GameState.decode(state.encode()).statusOf('heart').levelCap, 30);
  });
}
