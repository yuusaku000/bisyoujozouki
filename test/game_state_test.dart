import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/models/daily_input.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';

/// 目標ぴったり歩いた日を n 日続ける。
void walkGoodDays(GameState state, int days) {
  for (var i = 0; i < days; i++) {
    state.today = DailyInput(steps: state.stepGoal);
    state.endDay();
  }
}

void main() {
  group('健康度', () {
    test('目標を達成すると上がり、サボると下がる', () {
      final state = GameState.fresh();

      state.today = DailyInput(steps: state.stepGoal);
      expect(state.endDay().healthDeltas['heart'], HealthRule.achieved);

      state.today = const DailyInput(steps: 0);
      expect(state.endDay().healthDeltas['heart'], HealthRule.missed);
    });

    test('目標の半分以上なら少しだけ上がる', () {
      final state = GameState.fresh();
      state.today = DailyInput(steps: state.stepGoal ~/ 2);

      expect(state.endDay().healthDeltas['heart'], HealthRule.partial);
    });

    test('下限20を割らない', () {
      final state = GameState.fresh();
      for (var i = 0; i < 30; i++) {
        state.today = const DailyInput();
        state.endDay();
      }

      expect(state.statusOf('heart').health, OrganStatus.minHealth);
    });

    test('上限100を超えない', () {
      final state = GameState.fresh();
      walkGoodDays(state, 30);

      expect(state.statusOf('heart').health, OrganStatus.maxHealth);
    });

    test('自己申告の臓器は達成か未達かの二択', () {
      final state = GameState.fresh();

      state.today = const DailyInput(ateWell: true, rested: false);
      final result = state.endDay();

      expect(result.healthDeltas['stomach'], HealthRule.achieved);
      expect(result.healthDeltas['liver'], HealthRule.missed);
    });

    test('臓器ごとに見ている指標が違う', () {
      final state = GameState.fresh();
      // 階段だけ達成。心臓は歩数を見ているので下がる
      state.today = const DailyInput(steps: 0, stairs: DailyInput.stairsGoal);
      final result = state.endDay();

      expect(result.healthDeltas['lung'], HealthRule.achieved);
      expect(result.healthDeltas['heart'], HealthRule.missed);
    });
  });

  group('コイン', () {
    test('1歩1コイン、階段はボーナス', () {
      const input = DailyInput(steps: 3000, stairs: 4);
      expect(input.coinsEarned, 3000 + 4 * 50);
    });

    test('人間にありえない歩数は上限で止める', () {
      // 手入力なので青天井にすると経済が壊れる
      final absurd =
          const DailyInput().copyWith(steps: 999999999, stairs: 99999);

      expect(absurd.steps, DailyInput.maxSteps);
      expect(absurd.stairs, DailyInput.maxStairs);
    });

    test('保存データが改竄されていても上限で止める', () {
      final loaded = DailyInput.fromJson({'steps': 1 << 40, 'stairs': 1 << 20});

      expect(loaded.steps, DailyInput.maxSteps);
      expect(loaded.stairs, DailyInput.maxStairs);
    });

    test('1日を終えると所持コインに加算される', () {
      final state = GameState.fresh();
      state.today = const DailyInput(steps: 1200);

      expect(state.endDay().coinsEarned, 1200);
      expect(state.coins, 1200);
    });
  });

  group('目標の自動調整', () {
    test('7日続けると目標が上がる', () {
      final state = GameState.fresh();
      walkGoodDays(state, GameState.daysToRaiseGoal);

      expect(state.stepGoal,
          GameState.initialStepGoal + GameState.goalStepUp);
    });

    test('3日続けて未達だと目標が下がる', () {
      final state = GameState.fresh();
      walkGoodDays(state, GameState.daysToRaiseGoal); // 4000歩まで上げる

      for (var i = 0; i < GameState.daysToLowerGoal; i++) {
        state.today = const DailyInput();
        state.endDay();
      }

      expect(state.stepGoal, GameState.initialStepGoal);
    });

    test('下限より下には落ちない', () {
      final state = GameState.fresh();
      for (var i = 0; i < 30; i++) {
        state.today = const DailyInput();
        state.endDay();
      }

      expect(state.stepGoal, greaterThanOrEqualTo(GameState.minStepGoal));
    });
  });

  group('レベル', () {
    test('コインを払って上げると、健康度は変わらない', () {
      final state = GameState.fresh();
      state.coins = 10000;
      final healthBefore = state.statusOf('heart').health;

      state.levelUp('heart');

      expect(state.statusOf('heart').level, 2);
      expect(state.statusOf('heart').health, healthBefore);
      expect(state.coins, 10000 - 500);
    });

    test('コインが足りなければ何も起きない', () {
      final state = GameState.fresh();
      state.coins = 100;

      state.levelUp('heart');

      expect(state.statusOf('heart').level, 1);
      expect(state.coins, 100);
    });

    test('サボって健康度が落ちても、上げたレベルは残る', () {
      final state = GameState.fresh();
      state.coins = 10000;
      state.levelUp('heart');

      for (var i = 0; i < 20; i++) {
        state.today = const DailyInput();
        state.endDay();
      }

      expect(state.statusOf('heart').health, OrganStatus.minHealth);
      expect(state.statusOf('heart').level, 2, reason: '積み上げは消えない');
    });
  });

  group('戦闘力', () {
    test('健康度が落ちると弱くなる', () {
      const healthy = OrganStatus(health: 100, level: 1);
      const weak = OrganStatus(health: 20, level: 1);

      expect(weak.power(100), lessThan(healthy.power(100)));
    });

    test('レベルが高ければ、サボった経験者でも初心者より強い', () {
      const veteran = OrganStatus(health: 20, level: 20);
      const beginner = OrganStatus(health: 50, level: 1);

      expect(veteran.power(100), greaterThan(beginner.power(100)));
    });
  });

  test('保存して読み直しても状態が変わらない', () {
    final state = GameState.fresh();
    state.coins = 4321;
    state.levelUp('lung');
    state.today = const DailyInput(steps: 900, ateWell: true);

    final restored = GameState.decode(state.encode());

    expect(restored.coins, state.coins);
    expect(restored.statusOf('lung').level, state.statusOf('lung').level);
    expect(restored.today.steps, 900);
    expect(restored.today.ateWell, isTrue);
  });
}
