import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/achievements.dart';
import 'package:zoukicchi/data/chara_story.dart';
import 'package:zoukicchi/data/organs.dart';
import 'package:zoukicchi/data/story.dart';
import 'package:zoukicchi/models/daily_input.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';

void main() {
  group('達成', () {
    test('IDが重複しない', () {
      final ids = kAchievements.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('全部どこかのまとまりに入っている', () {
      final grouped = {
        for (final g in AchieveGroup.values)
          ...achievementsIn(g).map((a) => a.id),
      };
      expect(grouped.length, kAchievements.length);
    });

    test('はじめは何も達成していない', () {
      final state = GameState.fresh();
      expect(kAchievements.where((a) => a.isDone(state)), isEmpty);
      expect(claimable(state), isEmpty);
    });

    test('1日を締めると最初のひとつが達成される', () {
      final state = GameState.fresh();
      state.endDay();

      final first = kAchievements.firstWhere((a) => a.id == 'first_day');
      expect(first.isDone(state), isTrue);
      expect(claimable(state).map((a) => a.id), contains('first_day'));
    });

    test('歩数は累計で貯まり、保存される', () {
      final state = GameState.fresh();
      state.today = const DailyInput(steps: 4000);
      state.endDay();
      state.today = const DailyInput(steps: 6000);
      state.endDay();

      expect(state.totalSteps, 10000);
      expect(GameState.decode(state.encode()).totalSteps, 10000);
    });

    test('受け取ったものは記録され、保存される', () {
      final state = GameState.fresh()..claimedAchievements.add('first_day');

      expect(
        GameState.decode(state.encode()).claimedAchievements,
        contains('first_day'),
      );
    });

    test('受け取ると、受け取れるものから消える', () {
      final state = GameState.fresh();
      state.endDay();

      expect(claimable(state), isNotEmpty);
      for (final a in [...claimable(state)]) {
        state.claimedAchievements.add(a.id);
      }
      expect(claimable(state), isEmpty);
    });

    test('全員♡5でだけ「選べない」が達成される', () {
      final state = GameState.fresh();
      final all = kAchievements.firstWhere((a) => a.id == 'heart_all');

      for (final organ in kOrgans.take(4)) {
        state.organs[organ.id] = OrganStatus(
          affection: OrganStatus.heartThresholds[OrganStatus.maxHearts],
        );
      }
      expect(all.isDone(state), isFalse, reason: '4人でも達成になっている');

      state.organs[kOrgans.last.id] = OrganStatus(
        affection: OrganStatus.heartThresholds[OrganStatus.maxHearts],
      );
      expect(all.isDone(state), isTrue);
    });

    test('全話を読むと「語り部」が達成される', () {
      final state = GameState.fresh();
      final teller = kAchievements.firstWhere((a) => a.id == 'read_all');

      state.readEpisodes.addAll(kStory.map((e) => e.key));
      expect(teller.isDone(state), isFalse, reason: '本編だけで達成になっている');

      state.readEpisodes.addAll(kCharaStory.map((e) => e.key));
      expect(teller.isDone(state), isTrue);
    });

    test('報酬は鍵とチケットだけ', () {
      // コインの源は歩数だけ、という決まりを崩さない
      for (final a in kAchievements) {
        expect(a.reward.keys + a.reward.tickets, greaterThan(0));
        expect(a.reward.label, isNotEmpty);
      }
    });
  });
}
