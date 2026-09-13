import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/widgets/tap_effect.dart';

void main() {
  group('触ったときの効果', () {
    testWidgets('触るまでは何も描かない', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TapEffects(child: SizedBox.expand())),
      );

      expect(find.byKey(TapEffects.layerKey), findsNothing);
    });

    testWidgets('触ると出る', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TapEffects(child: SizedBox.expand())),
      );

      await tester.tapAt(const Offset(120, 200));
      await tester.pump();

      expect(find.byKey(TapEffects.layerKey), findsOneWidget);
    });

    testWidgets('下のボタンの反応を奪わない', (tester) async {
      // 触った合図を出すために、押せなくなっては本末転倒
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TapEffects(
            child: Center(
              child: ElevatedButton(
                onPressed: () => pressed = true,
                child: const Text('押す'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('押す'));
      await tester.pump();

      expect(pressed, isTrue);
      expect(find.byKey(TapEffects.layerKey), findsOneWidget);
    });

    testWidgets('しばらくすると消える', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TapEffects(child: SizedBox.expand())),
      );

      await tester.tapAt(const Offset(120, 200));
      await tester.pump();
      expect(find.byKey(TapEffects.layerKey), findsOneWidget);

      // 消えるまで回す。時計は本物の時刻を見ているので、実際に待つ
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(TapEffects.layerKey), findsNothing);
    });
  });
}
