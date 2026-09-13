import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/lines.dart';
import 'package:zoukicchi/data/chara_story.dart';
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
      expect(unlockedEpisodes(10).length, 10);
      expect(unlockedEpisodes(30).length, kStory.length);
    });

    test('10までは毎ステージ、そこから先は2ステージごと', () {
      final stages = kStory.map((e) => e.stage).toList();

      expect(stages.take(10), List.generate(10, (i) => i + 1));
      expect(stages.skip(10), [12, 14, 16, 18, 20, 22, 24, 26, 28, 30]);
    });

    test('話はステージの順に並んでいる', () {
      // 一覧は配列順に「第N話」を振る。前後すると番号がずれる
      final stages = kStory.map((e) => e.stage).toList();
      expect(stages, [...stages]..sort());
    });

    test('ステージ番号が重複しない', () {
      final stages = kStory.map((e) => e.stage).toList();
      expect(stages.toSet().length, stages.length);
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
      for (final stage in [10, 20, 30]) {
        expect(episodeForStage(stage), isNotNull, reason: 'ステージ$stage に話がない');
      }
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

  group('キャラクターストーリー', () {
    test('全員に話がある', () {
      for (final organ in kOrgans) {
        expect(
          episodesForOrgan(organ.id),
          isNotEmpty,
          reason: '${organ.name}の話が無い',
        );
      }
    });

    test('親密度が足りないと読めない', () {
      int noHearts(String id) => 0;
      expect(unlockedCharaEpisodes(noHearts), isEmpty);
    });

    test('親密度を上げた子の話だけ読める', () {
      int onlyHeart(String id) => id == 'heart' ? 2 : 0;
      final open = unlockedCharaEpisodes(onlyHeart);

      expect(open, isNotEmpty);
      expect(open.every((e) => e.organId == 'heart'), isTrue);
    });

    test('話す臓器はその子自身', () {
      for (final episode in kCharaStory) {
        for (final line in episode.lines) {
          if (line.speakerId != null) {
            expect(
              line.speakerId,
              episode.organId,
              reason: '${episode.title} に他の子が出てくる',
            );
          }
        }
      }
    });

    test('鍵が重複しない', () {
      final keys = kCharaStory.map((e) => e.key).toList();
      expect(keys.toSet().length, keys.length);
    });
  });

  group('呼び名の差し込み', () {
    test('{name} が呼び名に置き換わる', () {
      expect(storyText('ねえ、{name}。', 'kikuri'), 'ねえ、kikuri。');
      expect(storyText('{name}と{name}', 'A'), 'AとA');
    });

    test('名前が無いときは「あなた」に落ちる', () {
      // 名前を消したデータが来ても、文が「、。」で壊れないこと
      expect(storyText('ねえ、{name}。', ''), 'ねえ、あなた。');
      expect(storyText('ねえ、{name}。', '   '), 'ねえ、あなた。');
    });

    test('書き損じた差し込みが残っていない', () {
      // {namae} や {name のような打ち間違いは、そのまま画面に出てしまう
      final all = [
        for (final e in kStory) ...e.lines,
        for (final e in kCharaStory) ...e.lines,
      ];
      for (final line in all) {
        final rest = line.text.replaceAll('{name}', '');
        expect(
          rest.contains('{') || rest.contains('}'),
          isFalse,
          reason: '差し込みが壊れている: ${line.text}',
        );
      }
    });
  });

  group('親密度の段', () {
    test('♡1ではまだ告白しない', () {
      // 最初の一回で言ってしまうと、♡5まで上げる理由がなくなる
      for (final e in kCharaStory.where((e) => e.requiredHearts == 1)) {
        for (final line in e.lines) {
          expect(
            line.text.contains('好き') || line.text.contains('すき'),
            isFalse,
            reason: '${e.title} が♡1で告白している',
          );
        }
      }
    });

    test('♡5では全員が告白する', () {
      for (final organ in kOrgans) {
        final last = kCharaStory.firstWhere(
          (e) => e.organId == organ.id && e.requiredHearts == 5,
        );
        expect(
          last.lines.any(
            (l) => l.text.contains('好き') || l.text.contains('すき'),
          ),
          isTrue,
          reason: '${organ.name}の♡5に告白が無い',
        );
      }
    });

    test('全員に♡1から♡5まで揃っている', () {
      for (final organ in kOrgans) {
        final hearts = episodesForOrgan(organ.id)
            .map((e) => e.requiredHearts)
            .toList();
        expect(hearts, [1, 2, 3, 4, 5], reason: '${organ.name}の段が抜けている');
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
