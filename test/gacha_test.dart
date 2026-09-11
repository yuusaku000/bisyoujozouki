import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/chara_story.dart';
import 'package:zoukicchi/data/presents.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';
import 'package:zoukicchi/models/present.dart';

void main() {
  group('ガチャ', () {
    test('チケットがないと引けない', () {
      final state = GameState.fresh();

      expect(state.pull(ten: false), isEmpty);
      expect(state.inventory, isEmpty);
    });

    test('1回引くとチケットが1枚減り、1つ手に入る', () {
      final state = GameState.fresh()..tickets = 5;

      final got = state.pull(ten: false);

      expect(got.length, 1);
      expect(state.tickets, 4);
      expect(state.countOf(got.first.id), 1);
    });

    test('10連は10枚で10個', () {
      final state = GameState.fresh()..tickets = 10;

      final got = state.pull(ten: true);

      expect(got.length, kGachaTenCost);
      expect(state.tickets, 0);
    });

    test('10連には必ずSR以上が入る', () {
      // 全部Nだったときの徒労感が大きすぎる
      final random = Random(12345);
      for (var i = 0; i < 50; i++) {
        final results = rollTen(random);
        expect(
          results.any((p) => p.rarity.stars >= Rarity.sr.stars),
          isTrue,
          reason: '$i回目にSR以上が出なかった',
        );
      }
    });

    test('チケットが足りなければ10連は引けない', () {
      final state = GameState.fresh()..tickets = 9;

      expect(state.canPullTen, isFalse);
      expect(state.pull(ten: true), isEmpty);
      expect(state.tickets, 9);
    });

    test('引き続ければ天井で必ずSSRが出る', () {
      // 運が悪いだけで永久に出ないのは、引いた回数が報われないということ
      final state = GameState.fresh()..tickets = kPityPulls;
      var got = 0;
      for (var i = 0; i < kPityPulls; i++) {
        final res = state.pull(ten: false);
        if (res.first.rarity == Rarity.ssr) got++;
      }
      expect(got, greaterThanOrEqualTo(1));
    });

    test('SSRが出ると天井の数えが戻る', () {
      final state = GameState.fresh()..tickets = 200;
      for (var i = 0; i < 100; i++) {
        final res = state.pull(ten: false);
        if (res.first.rarity == Rarity.ssr) {
          expect(state.pullsSinceSsr, 0);
          return;
        }
      }
    });

    test('天井までの残りが保存される', () {
      final state = GameState.fresh()..pullsSinceSsr = 17;
      expect(GameState.decode(state.encode()).pullsSinceSsr, 17);
    });

    test('排出率の合計が100%になる', () {
      final total = kGachaWeights.values.reduce((a, b) => a + b);
      expect(total, 100);
    });

    test('どのレアリティにも中身がある', () {
      for (final rarity in Rarity.values) {
        expect(presentsOf(rarity), isNotEmpty, reason: '${rarity.label}が空');
      }
    });
  });

  group('親密度', () {
    test('渡すと上がり、持ち物が減る', () {
      final state = GameState.fresh();
      state.inventory['water'] = 2;
      final present = presentById('water')!;

      final gain = state.givePresent('heart', present);

      expect(gain, present.affection);
      expect(state.statusOf('heart').affection, gain);
      expect(state.countOf('water'), 1);
    });

    test('好物なら効果が倍', () {
      final state = GameState.fresh();
      state.inventory['music_box'] = 1;
      final present = presentById('music_box')!;

      final toHeart = present.affectionFor('heart');
      final toLung = present.affectionFor('lung');

      expect(toHeart, present.affection * 2);
      expect(toLung, present.affection);
    });

    test('持っていないものは渡せない', () {
      final state = GameState.fresh();

      final gain = state.givePresent('heart', presentById('ring')!);

      expect(gain, 0);
      expect(state.statusOf('heart').affection, 0);
    });

    test('使い切ると持ち物から消える', () {
      final state = GameState.fresh();
      state.inventory['water'] = 1;

      state.givePresent('heart', presentById('water')!);

      expect(state.inventory.containsKey('water'), isFalse);
    });

    test('ハートは5つまで', () {
      const maxed = OrganStatus(affection: 99999);

      expect(maxed.hearts, OrganStatus.maxHearts);
      expect(maxed.heartsMaxed, isTrue);
      expect(maxed.affectionToNextHeart, 0);
    });

    test('しきい値ちょうどでハートが増える', () {
      for (var h = 1; h <= OrganStatus.maxHearts; h++) {
        final at = OrganStatus(affection: OrganStatus.heartThresholds[h]);
        final just = OrganStatus(affection: OrganStatus.heartThresholds[h] - 1);

        expect(at.hearts, h);
        expect(just.hearts, h - 1);
      }
    });

    test('プレゼントでレベルも健康度も動かない', () {
      // 親密度と強さは別の軸。渡せば強くなるなら、歩く意味が薄れる
      final state = GameState.fresh();
      state.inventory['ring'] = 1;
      final before = state.statusOf('heart');

      state.givePresent('heart', presentById('ring')!);

      expect(state.statusOf('heart').level, before.level);
      expect(state.statusOf('heart').health, before.health);
    });

    test('親密度と持ち物が保存される', () {
      final state = GameState.fresh();
      state.inventory['tea'] = 3;
      state.organs['lung'] = const OrganStatus(affection: 150);

      final restored = GameState.decode(state.encode());

      expect(restored.countOf('tea'), 3);
      expect(restored.statusOf('lung').affection, 150);
      expect(restored.statusOf('lung').hearts, 2);
    });
  });

  group('キャラ話の解放', () {
    test('ハートが届くと読める', () {
      final state = GameState.fresh();
      expect(unlockedCharaEpisodes(state.heartsOf), isEmpty);

      state.organs['heart'] = OrganStatus(
        affection: OrganStatus.heartThresholds[2],
      );

      final open = unlockedCharaEpisodes(state.heartsOf);
      expect(open, isNotEmpty);
      expect(open.every((e) => e.organId == 'heart'), isTrue);
    });

    test('全員に♡1から♡5まで揃っている', () {
      for (final organ in ['heart', 'lung', 'stomach', 'liver', 'brain']) {
        final hearts = episodesForOrgan(organ).map((e) => e.requiredHearts);
        expect(hearts.toSet(), {1, 2, 3, 4, 5}, reason: '$organ に抜けがある');
      }
    });

    test('一覧に出る順がハートの少ない順になっている', () {
      // 画面は配列順に並べる。♡5が先頭に来ると、読む順が逆になる
      for (final organ in ['heart', 'lung', 'stomach', 'liver', 'brain']) {
        final hearts = episodesForOrgan(
          organ,
        ).map((e) => e.requiredHearts).toList();
        final sorted = [...hearts]..sort();
        expect(hearts, sorted, reason: '$organ の並びが前後している');
      }
    });

    test('♡1から読みはじめられる', () {
      // 最初の1つが♡2からだと、出会ってしばらく何も読めない
      final state = GameState.fresh();
      state.organs['liver'] = OrganStatus(
        affection: OrganStatus.heartThresholds[1],
      );

      final open = unlockedCharaEpisodes(state.heartsOf);
      expect(open, hasLength(1));
      expect(open.single.requiredHearts, 1);
      expect(open.single.organId, 'liver');
    });

    test('鍵が重複しない', () {
      final keys = kCharaStory.map((e) => e.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('必要なハートは5以下', () {
      for (final episode in kCharaStory) {
        expect(
          episode.requiredHearts,
          lessThanOrEqualTo(OrganStatus.maxHearts),
          reason: '${episode.title} が到達不能',
        );
      }
    });
  });
}
