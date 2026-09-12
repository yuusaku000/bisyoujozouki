import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/advice.dart';
import 'package:zoukicchi/data/organs.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/models/organ.dart';
import 'package:zoukicchi/models/vitals.dart';

void main() {
  group('計測値', () {
    test('全員ぶん、2つずつ出る', () {
      for (final organ in kOrgans) {
        final vitals = kVitals.read(organ, const OrganStatus(), 1);
        expect(vitals, hasLength(2), reason: '${organ.name} の指標が足りない');
        expect(vitals.first.label, isNotEmpty);
      }
    });

    test('同じ日に開き直しても同じ値', () {
      // 開くたびに数字が動くと、測っているように見えない
      final organ = organById('heart');
      const status = OrganStatus(health: 70);

      expect(
        kVitals.read(organ, status, 12).first.value,
        kVitals.read(organ, status, 12).first.value,
      );
    });

    test('日が変われば値も動く', () {
      final organ = organById('heart');
      const status = OrganStatus(health: 70);
      final days = {
        for (var d = 1; d <= 20; d++)
          kVitals.read(organ, status, d).first.value,
      };
      expect(days.length, greaterThan(1));
    });

    test('健康度が高いほど心拍が下がる', () {
      final organ = organById('heart');
      final good = int.parse(
        kVitals.read(organ, const OrganStatus(health: 100), 5).first.value,
      );
      final bad = int.parse(
        kVitals.read(organ, const OrganStatus(health: 20), 5).first.value,
      );

      expect(good, lessThan(bad));
    });

    test('表示する目安と、良し悪しの判定がずれていない', () {
      // 目安60〜75と書きながら59を緑で出していた。読む側が混乱する
      final heart = kVitals.read(
        organById('heart'),
        const OrganStatus(health: 100),
        5,
      );
      expect(heart.first.normal, '50〜75');
      expect(int.parse(heart.first.value), greaterThanOrEqualTo(50));
      expect(int.parse(heart.first.value), lessThanOrEqualTo(75));
    });

    test('元気なら目安の範囲に収まる', () {
      for (final organ in kOrgans) {
        final vitals = kVitals.read(organ, const OrganStatus(health: 100), 3);
        for (final vital in vitals) {
          expect(
            vital.inRange,
            isTrue,
            reason: '${organ.name} の${vital.label}が ${vital.value} で範囲外',
          );
        }
      }
    });

    test('不調なら目安を外れる', () {
      for (final organ in kOrgans) {
        final vitals = kVitals.read(organ, const OrganStatus(health: 20), 3);
        expect(
          vitals.any((v) => !v.inRange),
          isTrue,
          reason: '${organ.name} が不調でも全部範囲内になっている',
        );
      }
    });
  });

  group('推移', () {
    test('健康度の記録は1日を締めるたびに増える', () {
      final state = GameState.fresh();
      expect(state.healthLog, isEmpty);

      state.endDay();
      state.endDay();

      for (final organ in state.party) {
        expect(state.healthLog[organ.id], hasLength(2));
      }
    });

    test('まだ会っていない子は記録しない', () {
      final state = GameState.fresh();
      state.endDay();

      expect(state.healthLog.containsKey('brain'), isFalse);
    });

    test('古いぶんは捨てる', () {
      final state = GameState.fresh();
      for (var i = 0; i < GameState.logDays + 6; i++) {
        state.endDay();
      }

      expect(state.healthLog['heart'], hasLength(GameState.logDays));
    });

    test('記録が保存される', () {
      final state = GameState.fresh();
      state.endDay();

      final restored = GameState.decode(state.encode());
      expect(restored.healthLog['heart'], state.healthLog['heart']);
    });

    test('増えて良い指標かが指標ごとに決まっている', () {
      // 推測で決めると、心拍が上がったのを緑で出すような間違いが起きる
      final vitals = {
        for (final organ in kOrgans)
          for (final v in kVitals.read(organ, const OrganStatus(), 1))
            v.label: v.higherIsBetter,
      };

      expect(vitals['安静時心拍'], isFalse);
      expect(vitals['呼吸数'], isFalse);
      expect(vitals['食後に落ち着くまで'], isFalse);
      expect(vitals['心拍変動'], isTrue);
      expect(vitals['血中酸素'], isTrue);
      expect(vitals['睡眠スコア'], isTrue);
      expect(vitals['深い眠り'], isTrue);
      expect(vitals['休めた時間'], isTrue);
    });
  });

  group('アドバイス', () {
    test('全員、全状態ぶん揃っている', () {
      for (final organ in kOrgans) {
        for (final condition in Condition.values) {
          expect(
            adviceFor(organ.id, condition),
            isNotEmpty,
            reason: '${organ.name} の${condition.label}がない',
          );
          expect(kAdvice[organ.id]?[condition], isNotNull);
        }
      }
    });

    test('状態ごとに違うことを言う', () {
      for (final organ in kOrgans) {
        final said = {for (final c in Condition.values) adviceFor(organ.id, c)};
        expect(said, hasLength(Condition.values.length));
      }
    });
  });
}
