import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/enemies.dart';
import 'package:zoukicchi/data/organs.dart';
import 'package:zoukicchi/models/battle.dart';
import 'package:zoukicchi/models/daily_input.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';

Map<String, OrganStatus> party({int health = 50, int level = 1}) => {
  for (final o in kOrgans) o.id: OrganStatus(health: health, level: level),
};

void main() {
  group('自動戦闘', () {
    test('初期状態でステージ1に勝てる', () {
      final result = Battle(organs: party(), stage: 1, party: kOrgans).run();
      expect(result.won, isTrue, reason: '始めたばかりの人が1戦目で詰むと続かない');
    });

    test('同じ状態なら結果は必ず同じ', () {
      final a = Battle(organs: party(), stage: 3, party: kOrgans).run();
      final b = Battle(organs: party(), stage: 3, party: kOrgans).run();

      expect(a.won, b.won);
      expect(a.turns, b.turns);
      expect(a.enemyHp, b.enemyHp);
    });

    test('健康なほうが強い', () {
      final healthy = Battle(
        organs: party(health: 100),
        stage: 5,
        party: kOrgans,
      ).run();
      final weak = Battle(
        organs: party(health: 20),
        stage: 5,
        party: kOrgans,
      ).run();

      expect(healthy.turns, lessThan(weak.turns), reason: '運動した分だけ早く倒せる');
    });

    test('サボり続けると勝てなくなる', () {
      final neglected = Battle(
        organs: party(health: 20),
        stage: 12,
        party: kOrgans,
      ).run();
      expect(neglected.won, isFalse);
    });

    test('レベルを上げれば同じ健康度でも早く倒せる', () {
      const stage = 14;
      final low = Battle(
        organs: party(health: 60),
        stage: stage,
        party: kOrgans,
      ).run();
      final high = Battle(
        organs: party(health: 60, level: 10),
        stage: stage,
        party: kOrgans,
      ).run();

      expect(high.turns, lessThan(low.turns));
    });

    test('必ず決着するか、上限ターンで打ち切られる', () {
      final result = Battle(
        organs: party(health: 20),
        stage: 40,
        party: kOrgans,
      ).run();
      expect(result.turns, lessThanOrEqualTo(Battle.maxTurns));
    });
  });

  group('ステージ', () {
    test('10の倍数はボス', () {
      expect(enemyForStage(10).isBoss, isTrue);
      expect(enemyForStage(20).isBoss, isTrue);
      expect(enemyForStage(9).isBoss, isFalse);
    });

    test('進むほど敵が強くなる', () {
      expect(stageScale(11), greaterThan(stageScale(1)));
    });

    test('同じ敵は出るたびに呼び名が変わる', () {
      // 同じ名前が並ぶと進んでいる実感が薄れる
      expect(enemyNameForStage(1), '深夜のラーメン');
      expect(enemyNameForStage(7), '深夜のラーメン・改');
    });

    test('1戦目は一番弱い相手', () {
      // 仲間のいないうちに最強の敵が来ると、そこで詰む
      final first = enemyForStage(1);
      final weakest = [...kEnemies]
        ..sort((a, b) => a.baseHp.compareTo(b.baseHp));
      expect(first.id, weakest.first.id);
    });

    test('1周のあいだに全員が出てくる', () {
      for (final loop in [0, 1, 2]) {
        final ids = <String>{};
        for (var pos = 1; pos <= 9; pos++) {
          ids.add(enemyForStage(loop * 10 + pos).id);
        }
        expect(ids.length, kEnemies.length, reason: '${loop + 1}周目に偏りがある');
      }
    });

    test('周が変わると並びも変わる', () {
      final first = [for (var s = 1; s <= 9; s++) enemyForStage(s).id];
      final second = [for (var s = 11; s <= 19; s++) enemyForStage(s).id];
      expect(first, isNot(second));
    });

    test('称号が重複していない', () {
      // 同じ呼び名が二度出ると、上がったのか下がったのか分からない
      final seen = _rankSuffixesSeen();
      expect(seen.length, greaterThan(10), reason: '称号が少なすぎる');
      expect(seen.toSet().length, seen.length, reason: '$seen');
    });

    test('接尾辞を使い切っても名前が作られる', () {
      // 1000階はボス。ここまで来ると称号の一覧を使い切っている
      final enemy = enemyForStage(1000);
      final deep = enemyNameForStage(1000);

      expect(deep, startsWith(enemy.name));
      expect(deep.length, greaterThan(enemy.name.length));
      // 使い切った先は、最後の称号に番号がつく
      expect(RegExp(r'[0-9]+$').hasMatch(deep), isTrue, reason: deep);
    });
  });

  group('仲間の解放', () {
    test('はじめは心臓だけ', () {
      expect(unlockedOrgans({}).map((o) => o.id), ['heart']);
    });

    test('話を読むと増える。クリアしただけでは増えない', () {
      expect(unlockedOrgans({'main:2'}).length, 2);
      expect(
        unlockedOrgans({'main:2', 'main:3', 'main:5', 'main:7'}).length,
        kOrgans.length,
      );
    });

    test('心臓ひとりでもステージ1に勝てる', () {
      // 仲間がいないうちに詰むと、そこで終わってしまう
      final result = Battle(
        organs: party(),
        stage: 1,
        party: [organById('heart')],
      ).run();
      expect(result.won, isTrue);
    });

    test('仲間が多いほど戦力が上がる', () {
      final solo = Battle(
        organs: party(),
        stage: 1,
        party: [organById('heart')],
      );
      final full = Battle(organs: party(), stage: 1, party: kOrgans);

      expect(full.partyMaxHp, greaterThan(solo.partyMaxHp));
    });
  });

  group('進行の記録', () {
    test('勝つと次のステージに進む', () {
      final state = GameState.fresh();
      expect(state.currentStage, 1);

      state.clearStage(1);

      expect(state.clearedStage, 1);
      expect(state.currentStage, 2);
    });

    test('先のステージを飛ばしてクリアできない', () {
      final state = GameState.fresh();
      state.clearStage(5);

      expect(state.clearedStage, 0, reason: '順番に進ませる');
    });

    test('バトルではコインが増えない', () {
      final state = GameState.fresh();
      final before = state.coins;

      state.clearStage(1);

      expect(state.coins, before, reason: 'コインの源は歩数だけ。バトルから配ると歩かずに強くなれてしまう');
    });

    test('進行状況は保存される', () {
      final state = GameState.fresh();
      state.clearStage(1);
      state.clearStage(2);

      expect(GameState.decode(state.encode()).clearedStage, 2);
    });
  });

  group('既読', () {
    test('クリアしただけでは仲間は増えない。読んではじめて増える', () {
      final state = GameState.fresh();
      state.clearStage(1);
      state.clearStage(2);
      expect(state.party.length, 1, reason: 'まだ読んでいない');

      state.markEpisodeRead('main:2');

      expect(state.party.map((o) => o.id), ['heart', 'lung']);
    });

    test('解放済みで未読があるとしるしが立つ', () {
      final state = GameState.fresh();
      expect(state.hasUnreadStory, isFalse);

      state.clearStage(1);
      expect(state.hasUnreadStory, isTrue);

      state.markEpisodeRead('main:1');
      expect(state.hasUnreadStory, isFalse);
    });

    test('既読は保存される', () {
      final state = GameState.fresh();
      state.markEpisodeRead('main:2');
      state.markEpisodeRead('main:3');

      expect(GameState.decode(state.encode()).readEpisodes, {
        'main:2',
        'main:3',
      });
    });

    test('まだ出会っていない子の健康度は減らない', () {
      // 初対面のときにもう弱りきっているのはおかしい
      final state = GameState.fresh();
      for (var i = 0; i < 10; i++) {
        state.today = const DailyInput();
        state.endDay();
      }

      expect(state.statusOf('brain').health, OrganStatus.initialHealth);
      expect(
        state.statusOf('heart').health,
        lessThan(OrganStatus.initialHealth),
      );
    });
  });

  test('はじめの健康度は80', () {
    expect(GameState.fresh().statusOf('heart').health, 80);
  });
}

/// 深夜のラーメンに付いた称号を、出てくる順に集める。
///
/// 一覧そのものは外から見えないので、実際に付く名前から拾う。
List<String> _rankSuffixesSeen() {
  const base = '深夜のラーメン';
  final out = <String>[];
  for (var stage = 1; stage <= 400; stage++) {
    final name = enemyNameForStage(stage);
    if (!name.startsWith(base)) continue;
    final suffix = name.substring(base.length);
    if (suffix.isEmpty) continue;
    if (RegExp(r'[0-9]+$').hasMatch(suffix)) break; // 使い切ったあと
    out.add(suffix);
  }
  return out;
}
