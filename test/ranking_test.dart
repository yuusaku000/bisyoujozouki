import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/ranking.dart';
import 'package:zoukicchi/models/organ.dart';

void main() {
  group('順位', () {
    test('決めた場所がそのとおりの％になる', () {
      // 仕様そのもの。ここがずれたら、狙った手応えでなくなる
      expect(stageTopPercent(stageMedian.round()), closeTo(50, 0.5));
      expect(stageTopPercent(stageTop5.round()), closeTo(5, 0.2));
      expect(heartTopPercent(heartMedian), closeTo(50, 0.5));
      expect(heartTopPercent(heartTop5), closeTo(5, 0.2));
    });

    test('進むほど上位になる', () {
      var last = 100.0;
      for (var stage = 0; stage <= 110; stage += 5) {
        final now = stageTopPercent(stage);
        expect(now, lessThan(last), reason: 'ステージ$stage で順位が上がっていない');
        last = now;
      }
    });

    test('その先も下がることはない', () {
      var last = stageTopPercent(110);
      for (var stage = 115; stage <= 600; stage += 5) {
        final now = stageTopPercent(stage);
        expect(now, lessThanOrEqualTo(last), reason: 'ステージ$stage');
        last = now;
      }
    });

    test('つなぎ目で跳ねない', () {
      // 100階の手前と先で式が変わる。そこで数字が飛ばないこと
      expect(
        stageTopPercent(stageTop5.round() + 1),
        closeTo(stageTopPercent(stageTop5.round()), 0.1),
      );
    });

    test('100階から先は上がりにくい', () {
      // 手前の50階ぶんと、その先の50階ぶんで、動く量を比べる
      final before =
          stageTopPercent(stageTop5.round() - 50) -
          stageTopPercent(stageTop5.round());
      final after =
          stageTopPercent(stageTop5.round()) -
          stageTopPercent(stageTop5.round() + 50);

      expect(after, lessThan(before / 10), reason: '前=$before 後=$after');
      // 半分になるのが目安
      expect(
        stageTopPercent(stageTop5.round() + stageTailHalfLife.round()),
        closeTo(stageTopPercent(stageTop5.round()) / 2, 0.1),
      );
    });

    test('はじめのうちは下のほう', () {
      // ステージが少ないほど上位100%に近い
      expect(stageTopPercent(0), greaterThan(99));
      expect(stageTopPercent(20), greaterThan(90));
      expect(stageTopPercent(65), closeTo(50, 1));
    });

    test('親密度も、上げるほど上位になる', () {
      var last = 100.0;
      for (var level = 0.0; level <= 20; level += 0.5) {
        final now = heartTopPercent(level);
        expect(now, lessThan(last), reason: '♡$level で順位が上がっていない');
        last = now;
      }
    });

    test('0%にはならない', () {
      // 「上位0%」は、上に誰もいないことになってしまう
      expect(stageTopPercent(100000), greaterThan(0));
      expect(heartTopPercent(1000), greaterThan(0));
    });

    test('100%を超えない', () {
      expect(stageTopPercent(0), lessThanOrEqualTo(100));
      expect(heartTopPercent(-50), lessThanOrEqualTo(100));
    });

    test('桁は大きさに合わせて変わる', () {
      // まん中で 54.0% とうるさくならず、端では 0% や 100% で潰れない
      expect(formatPercent(54.3), '54');
      expect(formatPercent(4.27), '4.3');
      expect(formatPercent(0.412), '0.41');
      expect(formatPercent(99.887), '99.9');
      expect(formatPercent(0.0781), '0.078');
    });

    test('数階進めば必ず表示が動く', () {
      // 特定の階で一気に上がるのではなく、少しずつ上がっていくこと。
      // 桁の切り方が粗いと、何十階も同じ数字のまま止まって見える
      const limit = 5;
      var flat = 0;
      var last = formatPercent(stageTopPercent(0));

      for (var stage = 1; stage <= 400; stage++) {
        final now = formatPercent(stageTopPercent(stage));
        flat = now == last ? flat + 1 : 0;
        expect(flat, lessThan(limit), reason: 'ステージ$stage あたりで止まっている');
        last = now;
      }
    });

    test('呼び名は上位ほど良くなる', () {
      final titles = [
        for (final p in [80.0, 50.0, 30.0, 10.0, 3.0, 0.5, 0.05]) rankTitle(p),
      ];
      expect(titles.toSet().length, titles.length, reason: '$titles');
      expect(titles.first, 'かけだし');
      expect(titles.last, '伝説');
    });
  });

  group('♡5から先', () {
    test('5で止まらない', () {
      final deep = OrganStatus(affection: OrganStatus.thresholdFor(9));

      expect(deep.hearts, 9);
      expect(deep.extraHearts, 4);
      expect(deep.heartLabel, '5+4');
    });

    test('5までは今までどおりの表記', () {
      final five = OrganStatus(affection: OrganStatus.thresholdFor(5));

      expect(five.hearts, OrganStatus.maxHearts);
      expect(five.extraHearts, 0);
      expect(five.heartLabel, '5');
      expect(five.storyDone, isTrue);
    });

    test('表にある段はこれまでと同じ', () {
      // 物語の開く位置を動かさない
      for (var h = 0; h < OrganStatus.heartThresholds.length; h++) {
        expect(OrganStatus.thresholdFor(h), OrganStatus.heartThresholds[h]);
      }
    });

    test('先へ行くほど1段が重くなる', () {
      var last = 0;
      for (var h = 1; h <= 14; h++) {
        final gap =
            OrganStatus.thresholdFor(h) - OrganStatus.thresholdFor(h - 1);
        expect(gap, greaterThan(last), reason: '♡$h の重さが増えていない');
        last = gap;
      }
    });

    test('どの段でも、つぎまでの残りが出る', () {
      // ♡5で「これ以上ない」と止まると、先の目標が消える
      for (final h in [0, 3, 5, 8, 12]) {
        final at = OrganStatus(affection: OrganStatus.thresholdFor(h));
        expect(at.affectionToNextHeart, greaterThan(0), reason: '♡$h');
        expect(at.heartProgress, closeTo(0, 0.001), reason: '♡$h');
      }
    });
  });
}
