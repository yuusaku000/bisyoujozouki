import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/models/battle.dart';
import 'package:zoukicchi/models/game_state.dart';

void main() {
  group('案内', () {
    test('はじめは案内前から始まる', () {
      final state = GameState.fresh();
      expect(state.tutorialPhase, 0);
      expect(state.tutorialDone, isFalse);
    });

    test('最初の一戦に、はじめたばかりの状態で勝てる', () {
      // 勝てないと第1話が開かず、案内で読ませる流れが成立しない
      final state = GameState.fresh();

      final result = Battle(
        organs: state.organs,
        stage: 1,
        party: state.party,
      ).run();

      expect(state.party, hasLength(1));
      expect(result.won, isTrue);
    });

    test('進み具合が保存される', () {
      final state = GameState.fresh()..tutorialPhase = 1;
      expect(GameState.decode(state.encode()).tutorialPhase, 1);
    });

    test('古いセーブの見終わりフラグを引き継ぐ', () {
      // 真偽値だけ持っていた頃のセーブでも、案内を出し直さない
      final old = GameState.fresh().encode().replaceFirst(
        '"tutorialPhase":0',
        '"tutorialDone":true',
      );
      expect(GameState.decode(old).tutorialDone, isTrue);
    });

    test('開発者モードは初期状態では切れている', () {
      expect(GameState.fresh().devMode, isFalse);
      final on = GameState.fresh()..devMode = true;
      expect(GameState.decode(on.encode()).devMode, isTrue);
    });
  });
}
