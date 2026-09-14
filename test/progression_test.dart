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
    test('毎日3つ出る', () {
      for (var day = 1; day <= 40; day++) {
        expect(
          missionsForDay(day, _everyone).length,
          kMissionSlots,
          reason: '$day日目',
        );
      }
    });

    test('あるく・のぼる・ととのえるが1つずつ', () {
      // 無作為に引くと、歩く目標ばかりの日ができてしまう
      for (var day = 1; day <= 40; day++) {
        final kinds = missionsForDay(
          day,
          _everyone,
        ).map((m) => m.kind).toList();
        expect(kinds, MissionKind.values, reason: '$day日目の内訳が偏っている');
      }
    });

    test('同じ日なら何度見ても同じ3つ', () {
      expect(
        missionsForDay(7, _everyone).map((m) => m.id),
        missionsForDay(7, _everyone).map((m) => m.id),
      );
    });

    test('日が変われば入れ替わる', () {
      final today = missionsForDay(3, _everyone).map((m) => m.id).toList();
      final tomorrow = missionsForDay(4, _everyone).map((m) => m.id).toList();

      expect(today, isNot(tomorrow));
    });

    test('どの目標もいつかは出る', () {
      // 出番の来ない目標が混じっていると、書いた意味がない
      final seen = <String>{};
      for (var day = 1; day <= 60; day++) {
        seen.addAll(missionsForDay(day, _everyone).map((m) => m.id));
      }
      expect(seen, kMissions.map((m) => m.id).toSet());
    });

    test('まだ会っていない子の記録は求められない', () {
      // 記録の画面に無い項目を目標に出すと、その日は達成しようがない
      final state = GameState.fresh();

      for (var day = 1; day <= 20; day++) {
        state.dayCount = day;
        for (final m in state.missions) {
          expect(
            m.requires.every((id) => state.party.any((o) => o.id == id)),
            isTrue,
            reason: '$day日目に ${m.label} が出ている',
          );
        }
      }
    });

    test('種類がそろわない日は上乗せが出ない', () {
      // 目標がひとつしかない日に鍵が出ると、そこで止まるのが得になる
      final state = GameState.fresh();
      expect(state.missions.length, lessThan(kMissionSlots));
      state.today = const DailyInput(
        steps: 100000,
        stairs: 100,
        ateWell: true,
        rested: true,
        sleptWell: true,
      );

      final result = state.endDay();

      expect(result.clearedMissions, isNotEmpty);
      expect(result.allMissionsCleared, isFalse);
      expect(state.keys, 0);
    });

    test('日数が進むと今日の3つも変わる', () {
      final state = _fullParty();
      final first = state.missions.map((m) => m.id).toList();

      state.endDay();

      expect(state.missions.map((m) => m.id).toList(), isNot(first));
    });

    test('達成した目標だけ報酬が入る', () {
      final state = _fullParty();
      final care = state.missions.firstWhere((m) => m.kind == MissionKind.care);
      // 生活だけ整えた日。歩数も階段も0なので、残り2つは達成しない
      state.today = const DailyInput(
        ateWell: true,
        rested: true,
        sleptWell: true,
      );

      final result = state.endDay();

      expect(result.clearedMissions.map((m) => m.id), [care.id]);
      expect(state.tickets, greaterThan(0));
      expect(result.allMissionsCleared, isFalse);
    });

    test('未達なら何ももらえない', () {
      final state = _fullParty();
      state.today = const DailyInput(steps: 1);

      final result = state.endDay();

      expect(result.clearedMissions, isEmpty);
      expect(state.keys, 0);
      expect(state.tickets, 0);
      expect(result.missionCoins, 0);
      expect(result.allMissionsCleared, isFalse);
    });

    test('3つそろえると上乗せがもらえる', () {
      final state = _fullParty();
      state.today = _clearsAll(state);

      final result = state.endDay();

      expect(result.clearedMissions.length, kMissionSlots);
      expect(result.allMissionsCleared, isTrue);
      expect(state.tickets, greaterThanOrEqualTo(kAllMissionsBonus.tickets));
      expect(
        result.missionCoins,
        greaterThanOrEqualTo(kAllMissionsBonus.coins),
      );
    });

    test('2つまでなら上乗せは出ない', () {
      final state = _fullParty();
      // 歩数だけ抜く。あるくの目標はどれも歩数で判定される
      final all = _clearsAll(state);
      state.today = DailyInput(
        steps: 0,
        stairs: all.stairs,
        ateWell: all.ateWell,
        rested: all.rested,
        sleptWell: all.sleptWell,
      );

      final result = state.endDay();

      expect(result.allMissionsCleared, isFalse);
      expect(result.clearedMissions.length, lessThan(kMissionSlots));
    });

    test('目標のコインは、その日の取り分に足される', () {
      // 見出しの「獲得コイン」に入っていないと、増えた分が合わない
      final state = _fullParty();
      state.today = const DailyInput(
        ateWell: true,
        rested: true,
        sleptWell: true,
      );

      final result = state.endDay();

      expect(result.missionCoins, greaterThan(0));
      expect(result.coinsEarned, result.coins.total + result.missionCoins);
      expect(state.coins, result.coinsEarned);
    });

    test('目標は鍵を出さない', () {
      // 鍵はボスとショップに任せる
      for (final m in kMissions) {
        expect(m.reward.keys, 0, reason: m.label);
      }
      expect(kAllMissionsBonus.keys, 0);
    });

    test('どの目標にもコインがつく', () {
      for (final m in kMissions) {
        expect(m.reward.coins, greaterThan(0), reason: m.label);
      }
    });
  });

  group('勝ったときの取り分', () {
    test('ボスは鍵を落とす', () {
      final state = GameState.fresh();
      state.clearedStage = 9;

      final got = state.clearStage(10);

      expect(got.keys, GameState.bossKeyDrop);
      expect(state.keys, GameState.bossKeyDrop);
    });

    test('通常の敵は鍵を落とさない', () {
      final state = GameState.fresh();

      final got = state.clearStage(1);

      expect(got.keys, 0);
      expect(state.keys, 0);
    });

    test('どの敵を倒してもチケットが出る', () {
      final state = GameState.fresh();

      final got = state.clearStage(1);

      expect(got.tickets, GameState.winTicketDrop);
      expect(state.tickets, GameState.winTicketDrop);
    });

    test('ボスのほうが多い', () {
      final state = GameState.fresh();
      state.clearedStage = 9;

      final got = state.clearStage(10);

      expect(got.tickets, GameState.bossTicketDrop);
      expect(GameState.bossTicketDrop, greaterThan(GameState.winTicketDrop));
    });

    test('勝ってもコインは増えない', () {
      // 強さの源は運動だけ。ここでコインを配ると歩かずに強くなれてしまう
      final state = GameState.fresh();
      final before = state.coins;

      state.clearStage(1);

      expect(state.coins, before);
    });

    test('同じステージを勝ち直しても取り分は出ない', () {
      // 稼ぎ直しができると、チケットが歩数から切り離されてしまう
      final state = GameState.fresh();
      state.clearStage(1);

      final again = state.clearStage(1);

      expect(again.isEmpty, isTrue);
      expect(state.tickets, GameState.winTicketDrop);
    });
  });

  test('鍵とチケットと設定が保存される', () {
    final state = GameState.fresh();
    state.keys = 3;
    state.tickets = 7;
    state.battleSpeed = BattleSpeed.fast;

    final restored = GameState.decode(state.encode());

    expect(restored.keys, 3);
    expect(restored.tickets, 7);
    expect(restored.battleSpeed, BattleSpeed.fast);
  });

  test('限界を解いた回数も保存される', () {
    final state = GameState.fresh();
    state.organs['heart'] = const OrganStatus(ascensions: 2);

    expect(GameState.decode(state.encode()).statusOf('heart').levelCap, 30);
  });
}

/// その日の3つを全部満たす記録。目標の中身が変わっても効くように、
/// 実際に出ている3つから必要な値を組み立てる。
DailyInput _clearsAll(GameState state) {
  const input = DailyInput(
    steps: 100000,
    stairs: 100,
    ateWell: true,
    rested: true,
    sleptWell: true,
  );
  for (final m in state.missions) {
    if (!m.isDone(input, state.stepGoal)) {
      throw StateError('${m.label} を満たせていない');
    }
  }
  return input;
}

const Set<String> _everyone = {'heart', 'lung', 'stomach', 'liver', 'brain'};

/// 五人そろった状態。目標は仲間の顔ぶれで変わるので、
/// 3つ出そろう前提の試験にはこれを使う。
GameState _fullParty() =>
    GameState.fresh()
      ..readEpisodes.addAll(const ['main:2', 'main:3', 'main:5', 'main:7']);
