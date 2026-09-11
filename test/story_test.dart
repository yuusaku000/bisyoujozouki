import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/lines.dart';
import 'package:zoukicchi/data/enemies.dart';
import 'package:zoukicchi/data/organs.dart';
import 'package:zoukicchi/data/story.dart';
import 'package:zoukicchi/models/organ.dart';

void main() {
  group('セリフ', () {
    test('全臓器・全状態にセリフがある', () {
      for (final organ in kOrgans) {
        for (final condition in Condition.values) {
          final lines = kOrganLines[organ.id]?[condition];
          expect(
            lines,
            isNotNull,
            reason: '${organ.name}の${condition.label}のセリフが無い',
          );
          expect(lines, isNotEmpty);
        }
      }
    });

    test('タップするたびに別のセリフになる', () {
      final seen = <String>{};
      for (var i = 0; i < 4; i++) {
        seen.add(lineFor('heart', Condition.genki, i));
      }
      expect(seen.length, greaterThan(1));
    });

    test('同じ日に開き直しても同じセリフ', () {
      expect(
        lineFor('heart', Condition.genki, 7),
        lineFor('heart', Condition.genki, 7),
      );
    });
  });

  group('ストーリー', () {
    test('クリアしたステージまでが解放される', () {
      expect(unlockedEpisodes(0), isEmpty);
      expect(unlockedEpisodes(1).length, 1);
      expect(unlockedEpisodes(10).length, kStory.length);
    });

    test('話す臓器はすべて実在する', () {
      final ids = kOrgans.map((o) => o.id).toSet();
      for (final episode in kStory) {
        for (final line in episode.lines) {
          if (line.speakerId != null) {
            expect(
              ids,
              contains(line.speakerId),
              reason: '${episode.title} に知らない話者がいる',
            );
          }
        }
      }
    });

    test('ボスのステージに話がある', () {
      expect(episodeForStage(10), isNotNull);
    });

    test('指定された敵はすべて実在する', () {
      for (final episode in kStory) {
        for (final line in episode.lines) {
          if (line.enemyId != null) {
            expect(
              enemyById(line.enemyId!),
              isNotNull,
              reason: '${episode.title} に知らない敵がいる',
            );
          }
        }
      }
    });

    test('ボス前後の話にはボスが姿を見せる', () {
      // 相手が見えないまま「この先に何かいる」と言われても伝わらない
      for (final stage in [9, 10]) {
        final episode = episodeForStage(stage)!;
        expect(
          episode.lines.any((l) => l.enemyId == 'boss_seikatsu'),
          isTrue,
          reason: '${episode.title} にボスが出てこない',
        );
      }
    });
  });

  test('顔アイコンが全臓器・全状態ぶん揃っている', () {
    final missing = <String>[];
    for (final organ in kOrgans) {
      for (final condition in Condition.values) {
        final path = organ.facePath(condition);
        if (!File(path).existsSync()) missing.add(path);
      }
    }
    expect(missing, isEmpty);
  });
}
