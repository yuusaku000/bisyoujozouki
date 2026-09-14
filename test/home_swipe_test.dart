import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/screens/home_tab.dart';
import 'package:zoukicchi/services/audio.dart';

/// 五人そろった状態。
GameState _fullParty() => GameState.fresh()
  ..readEpisodes.addAll(const ['main:2', 'main:3', 'main:5', 'main:7'])
  ..tutorialPhase = 2
  ..userName = 'kikuri';

Future<void> _pumpHome(WidgetTester tester, GameState state) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HomeTab(state: state, onChanged: () {}, onReset: () async {}),
    ),
  );
  await tester.pump();
}

/// いま誰を見ているか。吹き出しの立ち絵から拾う。
String _shownOrgan(WidgetTester tester) {
  for (final image in tester.widgetList<Image>(find.byType(Image))) {
    final path = (image.image as AssetImage?)?.assetName ?? '';
    if (path.contains('/organs/') && !path.contains('_face')) {
      return path.split('/organs/')[1].split('/').first;
    }
  }
  return '';
}

/// 立ち絵のあたりを横に振る。
Future<void> _swipe(WidgetTester tester, {required bool left}) async {
  await tester.flingFrom(
    const Offset(400, 260),
    Offset(left ? -240 : 240, 0),
    900,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => Audio.instance.enabled = false);

  group('ホームの横振り', () {
    testWidgets('左に振ると次の子になる', (tester) async {
      final state = _fullParty();
      await _pumpHome(tester, state);
      final first = _shownOrgan(tester);
      expect(first, isNotEmpty);

      await _swipe(tester, left: true);

      expect(_shownOrgan(tester), isNot(first));
    });

    testWidgets('右に振ると戻る', (tester) async {
      final state = _fullParty();
      await _pumpHome(tester, state);
      final first = _shownOrgan(tester);

      await _swipe(tester, left: true);
      await _swipe(tester, left: false);

      expect(_shownOrgan(tester), first);
    });

    testWidgets('端では止まる', (tester) async {
      final state = _fullParty();
      await _pumpHome(tester, state);
      final first = _shownOrgan(tester);

      await _swipe(tester, left: false);

      expect(_shownOrgan(tester), first);
    });
  });
}
