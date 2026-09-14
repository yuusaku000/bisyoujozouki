import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/models/game_state.dart';
import 'package:zoukicchi/screens/grow_tab.dart';
import 'package:zoukicchi/services/audio.dart';

/// 五人そろった状態。
GameState _fullParty() =>
    GameState.fresh()
      ..readEpisodes.addAll(const ['main:2', 'main:3', 'main:5', 'main:7']);

Future<void> _pumpGrow(WidgetTester tester, GameState state) async {
  await tester.pumpWidget(
    MaterialApp(
      home: GrowTab(state: state, onChanged: () {}),
    ),
  );
  await tester.pump();
}

/// 立ち絵のあたりを横に振る。画面の真ん中は下の札にかかることがある。
Future<void> _swipe(WidgetTester tester, {required bool left}) async {
  await tester.flingFrom(
    const Offset(400, 140),
    Offset(left ? -240 : 240, 0),
    900,
  );
  await tester.pumpAndSettle();
}

/// いま誰の画面か。名前は下の札にも出るので、大きい見出しのほうで見る。
String _shown(WidgetTester tester) {
  final panel = tester.widgetList<Text>(find.byType(Text));
  for (final text in panel) {
    if (text.style?.fontSize == 20) return text.data ?? '';
  }
  return '';
}

void main() {
  setUpAll(() => Audio.instance.enabled = false);

  group('育成の横振り', () {
    testWidgets('左に振ると次の子になる', (tester) async {
      final state = _fullParty();
      await _pumpGrow(tester, state);
      final first = _shown(tester);

      await _swipe(tester, left: true);

      expect(_shown(tester), isNot(first));
    });

    testWidgets('右に振ると戻る', (tester) async {
      final state = _fullParty();
      await _pumpGrow(tester, state);
      final first = _shown(tester);

      await _swipe(tester, left: true);
      await _swipe(tester, left: false);

      expect(_shown(tester), first);
    });

    testWidgets('端では止まる', (tester) async {
      // 先頭で右に振っても、いない子の画面にならない
      final state = _fullParty();
      await _pumpGrow(tester, state);
      final first = _shown(tester);

      await _swipe(tester, left: false);

      expect(_shown(tester), first);
    });
  });
}
