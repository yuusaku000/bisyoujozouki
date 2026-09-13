import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/story.dart';
import 'package:zoukicchi/screens/story_screen.dart';

void main() {
  // 差し込みは data 側で正しくても、画面まで名前が渡っていなければ
  // 「あなた」のままになる。そこが切れていないことを見る。
  testWidgets('セリフの中で、入れた名前で呼ばれる', (tester) async {
    const episode = StoryEpisode(
      stage: 1,
      title: 'ためし',
      lines: [StoryLine('ねえ、{name}。', speakerId: 'heart')],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: StoryScreen(episode: episode, userName: 'kikuri'),
      ),
    );

    expect(find.text('ねえ、kikuri。'), findsOneWidget);
  });
}
