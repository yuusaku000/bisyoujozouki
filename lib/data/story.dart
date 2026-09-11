class StoryLine {
  const StoryLine(this.text, {this.speakerId});

  /// nullなら地の文。
  final String? speakerId;
  final String text;
}

class StoryEpisode {
  const StoryEpisode({
    required this.stage,
    required this.title,
    required this.lines,
  });

  /// このステージをクリアすると解放される。
  final int stage;
  final String title;
  final List<StoryLine> lines;
}

/// バトルの報酬。コインを配らない代わりに、ここが進む。
const List<StoryEpisode> kStory = [
  StoryEpisode(
    stage: 1,
    title: '目が覚めた',
    lines: [
      StoryLine('深夜のラーメンが、湯気ごと消えていった。'),
      StoryLine('静かになった胸の奥から、声がした。'),
      StoryLine('……あ。聞こえてる？', speakerId: 'heart'),
      StoryLine('ずっと動いてたんだよ、わたし。あなたが生まれた日から、一度も止まらずに。',
          speakerId: 'heart'),
      StoryLine('でも、気づいてもらえたのは今日がはじめて。', speakerId: 'heart'),
      StoryLine('彼女は少し照れたように、胸の前で手を組んだ。'),
      StoryLine('……これからは、たまにでいいから。こっちを見て。', speakerId: 'heart'),
    ],
  ),
  StoryEpisode(
    stage: 2,
    title: '息の音',
    lines: [
      StoryLine('階段をのぼると、誰かが後ろで息を切らしていた。'),
      StoryLine('はぁっ、はぁっ……ま、待って……', speakerId: 'lung'),
      StoryLine('……ごめんね、わたし、まだ慣れてなくて。', speakerId: 'lung'),
      StoryLine('でもね、うれしいの。', speakerId: 'lung'),
      StoryLine('あなたが息を切らすってことは、動いてるってことだから。', speakerId: 'lung'),
      StoryLine('ずっと、浅い息ばっかりだったもんね。', speakerId: 'lung'),
      StoryLine('彼女は胸いっぱいに空気を吸って、笑った。'),
    ],
  ),
  StoryEpisode(
    stage: 3,
    title: 'いただきます',
    lines: [
      StoryLine('エレベーターの扉が閉じ、静かになった。'),
      StoryLine('ねえねえ、今日のごはん、おいしかったね！', speakerId: 'stomach'),
      StoryLine('わたし、味はわからないの。届いたものを溶かすだけだから。',
          speakerId: 'stomach'),
      StoryLine('でも、あなたが「おいしい」って思った日は、なんとなくわかるんだ。',
          speakerId: 'stomach'),
      StoryLine('……ふしぎだよね。', speakerId: 'stomach'),
      StoryLine('だから、急いで飲み込まないで。ちゃんと味わってね。', speakerId: 'stomach'),
    ],
  ),
  StoryEpisode(
    stage: 5,
    title: '黙っていた人',
    lines: [
      StoryLine('五つ目の敵が崩れ落ちたあと、誰も声を上げなかった。'),
      StoryLine('眼鏡の奥から、静かな視線がこちらを向いた。'),
      StoryLine('……わたしのこと、忘れてましたね。', speakerId: 'liver'),
      StoryLine('いいんです。それがわたしの仕事ですから。', speakerId: 'liver'),
      StoryLine('痛みも出さない。悲鳴も上げない。気づかれたときには、たいてい手遅れ。',
          speakerId: 'liver'),
      StoryLine('だからね。', speakerId: 'liver'),
      StoryLine('わたしが何も言わないうちに、休んでください。', speakerId: 'liver'),
      StoryLine('それが、いちばん助かります。', speakerId: 'liver'),
    ],
  ),
  StoryEpisode(
    stage: 7,
    title: '眠りの底',
    lines: [
      StoryLine('夜が更けて、まぶたが重くなってきた。'),
      StoryLine('……ねえ。わたしが何をしてるか、知ってる？', speakerId: 'brain'),
      StoryLine('あなたが眠っているあいだ、今日あったことを片づけてるの。',
          speakerId: 'brain'),
      StoryLine('いる記憶を棚に並べて、いらない汚れを洗い流して。', speakerId: 'brain'),
      StoryLine('寝ないとね、それが全部、明日に持ち越しになる。', speakerId: 'brain'),
      StoryLine('机の上が散らかったまま、朝が来ちゃうの。', speakerId: 'brain'),
      StoryLine('……だから、おやすみ。ちゃんと、片づけておくから。', speakerId: 'brain'),
    ],
  ),
  StoryEpisode(
    stage: 10,
    title: 'ずっとそこにいたもの',
    lines: [
      StoryLine('それは、はじめから奥にいた。'),
      StoryLine('黒い塊の表面で、見覚えのあるものが脈打っている。'),
      StoryLine('食べたもの。眠らなかった夜。座っていた時間。'),
      StoryLine('……こいつ、新しく現れたんじゃない。', speakerId: 'heart'),
      StoryLine('あなたが積み上げてきたものが、形になっただけ。', speakerId: 'liver'),
      StoryLine('こわい？', speakerId: 'brain'),
      StoryLine('でも、だいじょうぶ。', speakerId: 'lung'),
      StoryLine('だってあなた、ここまで歩いてきたじゃない。', speakerId: 'stomach'),
      StoryLine('五人が、前に出た。'),
    ],
  ),
];

StoryEpisode? episodeForStage(int stage) {
  for (final e in kStory) {
    if (e.stage == stage) return e;
  }
  return null;
}

List<StoryEpisode> unlockedEpisodes(int clearedStage) =>
    kStory.where((e) => e.stage <= clearedStage).toList();
