import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/sounds.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/services/audio.dart';

void main() {
  group('音のファイル', () {
    // 鳴らし損ねても落とさない作りにしてある。つまり綴りを間違えても
    // 何も起きないまま無音になる。実在することはここで見るしかない。
    test('効果音がすべて置いてある', () {
      for (final sfx in Sfx.values) {
        expect(
          File('assets/${sfx.asset}').existsSync(),
          isTrue,
          reason: '${sfx.name} の assets/${sfx.asset} が無い',
        );
      }
    });

    test('BGMがすべて置いてある', () {
      for (final bgm in Bgm.values) {
        expect(
          File('assets/${bgm.asset}').existsSync(),
          isTrue,
          reason: '${bgm.name} の assets/${bgm.asset} が無い',
        );
      }
    });

    test('pubspec に音の場所が登録されている', () {
      // 置いてあっても、ここに書かないと端末には入らない
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('assets/audio/sfx/'));
      expect(pubspec, contains('assets/audio/bgm/'));
    });

    test('出どころを残してある', () {
      // 公開しているので、license の分かるものしか入れない
      final credits = File('assets/audio/CREDITS.md').readAsStringSync();
      expect(credits, contains('CC0'));
      for (final sfx in Sfx.values) {
        expect(
          credits,
          contains(sfx.asset.split('/').last),
          reason: '${sfx.name} の出どころが書かれていない',
        );
      }
    });
  });

  group('音の設定', () {
    test('はじめは両方とも鳴る', () {
      final state = GameState.fresh();

      expect(state.sfxOn, isTrue);
      expect(state.bgmOn, isTrue);
    });

    test('切った設定が保存される', () {
      final state = GameState.fresh()
        ..sfxOn = false
        ..bgmOn = false;

      final restored = GameState.decode(state.encode());

      expect(restored.sfxOn, isFalse);
      expect(restored.bgmOn, isFalse);
    });

    test('はじめの音量は決められた大きさ', () {
      final state = GameState.fresh();

      expect(state.sfxVolume, Audio.defaultSfxVolume);
      expect(state.bgmVolume, Audio.defaultBgmVolume);
    });

    test('音量が保存される', () {
      final state = GameState.fresh()
        ..sfxVolume = 0.25
        ..bgmVolume = 0.0;

      final restored = GameState.decode(state.encode());

      expect(restored.sfxVolume, 0.25);
      expect(restored.bgmVolume, 0.0);
    });

    test('音量を知らない古いセーブは、これまでの大きさで読む', () {
      final old = GameState.fresh().encode();
      final stripped = old.replaceAll(
        RegExp(r'"(sfx|bgm)Volume":[0-9.]+,'),
        '',
      );

      final restored = GameState.decode(stripped);

      expect(restored.sfxVolume, Audio.defaultSfxVolume);
      expect(restored.bgmVolume, Audio.defaultBgmVolume);
    });

    test('音を知らない古いセーブは、鳴る側で読む', () {
      final old = GameState.fresh().encode();
      final stripped = old
          .replaceAll('"sfxOn":true,', '')
          .replaceAll('"bgmOn":true,', '');

      final restored = GameState.decode(stripped);

      expect(restored.sfxOn, isTrue);
      expect(restored.bgmOn, isTrue);
    });
  });
}
