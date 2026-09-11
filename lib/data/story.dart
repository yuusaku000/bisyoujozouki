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
    title: 'はじめて、目が合った',
    lines: [
      StoryLine('深夜のラーメンが、湯気ごと消えていった。'),
      StoryLine('静かになった胸の奥。そこに、彼女は立っていた。'),
      StoryLine('……あ。', speakerId: 'heart'),
      StoryLine('ほんとに、聞こえてるんだ。', speakerId: 'heart'),
      StoryLine('彼女は自分の胸を押さえて、頬を赤くした。'),
      StoryLine('ずるいよ。わたしはずっと、あなたのこと知ってたのに。',
          speakerId: 'heart'),
      StoryLine('生まれた日から、一度も休まずに。ずっと、そばで。',
          speakerId: 'heart'),
      StoryLine('あなたが誰かを好きになった日も、全部わたしが跳ねてたんだよ？',
          speakerId: 'heart'),
      StoryLine('……気づいてくれるの、おそすぎ。', speakerId: 'heart'),
      StoryLine('そう言って、彼女はそっぽを向いた。'),
      StoryLine('けれど、胸の奥の鼓動は、さっきよりずっと速くなっていた。'),
    ],
  ),
  StoryEpisode(
    stage: 2,
    title: '息が、とまるかと思った',
    lines: [
      StoryLine('階段をのぼりきると、うしろで小さな音がした。'),
      StoryLine('はぁっ……はぁっ……ま、待って、ください……', speakerId: 'lung'),
      StoryLine('振り向くと、彼女が膝に手をついていた。'),
      StoryLine('ご、ごめんなさい。わたし、まだ慣れてなくて……', speakerId: 'lung'),
      StoryLine('顔を上げた彼女の目が、少しうるんでいる。'),
      StoryLine('でも、うれしいんです。', speakerId: 'lung'),
      StoryLine('あなたが息を切らすってことは、生きて、動いてるってことだから。',
          speakerId: 'lung'),
      StoryLine('……ずっと、浅い息ばっかりだったから。', speakerId: 'lung'),
      StoryLine('彼女は一歩近づいて、こちらの手をとった。'),
      StoryLine('ね。いっしょに、深呼吸してくれますか。', speakerId: 'lung'),
      StoryLine('触れた指先は、驚くほどあたたかかった。'),
    ],
  ),
  StoryEpisode(
    stage: 3,
    title: 'もっと、かまって',
    lines: [
      StoryLine('エレベーターの扉が閉じ、静けさが戻る。'),
      StoryLine('ねえねえっ、今日のごはん、どうだった？', speakerId: 'stomach'),
      StoryLine('彼女はスプーンを振りながら、距離をつめてきた。'),
      StoryLine('わたしね、味はわからないの。届いたものを溶かすだけだから。',
          speakerId: 'stomach'),
      StoryLine('でもね。', speakerId: 'stomach'),
      StoryLine('あなたが「おいしい」って笑った日は、なんとなくわかるんだ。',
          speakerId: 'stomach'),
      StoryLine('……ふしぎだよね。顔なんて、見えないのに。', speakerId: 'stomach'),
      StoryLine('彼女はこちらを見上げて、少しだけ口をとがらせた。'),
      StoryLine('急いで飲み込まないで。ちゃんと味わって。', speakerId: 'stomach'),
      StoryLine('そのほうが、長く一緒にいられるでしょ？', speakerId: 'stomach'),
    ],
  ),
  StoryEpisode(
    stage: 5,
    title: 'はじめてのおねがい',
    lines: [
      StoryLine('五つ目の敵が崩れ落ちても、彼女は一言も発しなかった。'),
      StoryLine('眼鏡の奥の視線だけが、静かにこちらを向いている。'),
      StoryLine('……わたしのこと、忘れていましたね。', speakerId: 'liver'),
      StoryLine('いいんです。それがわたしの仕事ですから。', speakerId: 'liver'),
      StoryLine('痛みも出さない。悲鳴も上げない。', speakerId: 'liver'),
      StoryLine('気づかれたときには、たいてい手遅れ。', speakerId: 'liver'),
      StoryLine('彼女は眼鏡を外し、めずらしく目を伏せた。'),
      StoryLine('……ひとつだけ、わがままを言っても？', speakerId: 'liver'),
      StoryLine('わたしが何も言わないうちに、休んでください。', speakerId: 'liver'),
      StoryLine('あなたに倒れられたら、わたし……', speakerId: 'liver'),
      StoryLine('言いかけて、彼女は口をつぐんだ。'),
      StoryLine('……いえ。なんでもありません。', speakerId: 'liver'),
    ],
  ),
  StoryEpisode(
    stage: 7,
    title: 'おやすみのまえに',
    lines: [
      StoryLine('夜が更けて、まぶたが重くなってきた。'),
      StoryLine('……ねえ。わたしが何をしてるか、知ってる？', speakerId: 'brain'),
      StoryLine('彼女は本を閉じ、こちらの隣に腰を下ろした。'),
      StoryLine('あなたが眠っているあいだ、今日あったことを片づけてるの。',
          speakerId: 'brain'),
      StoryLine('いる記憶を棚に並べて、いらない汚れを洗い流して。',
          speakerId: 'brain'),
      StoryLine('……ひとつだけ、棚に戻さない記憶があるんだけど。',
          speakerId: 'brain'),
      StoryLine('彼女は視線を落とし、めずらしく言葉に詰まった。'),
      StoryLine('……はじめて声が届いた日のこと。あれだけは、毎晩読み返してる。',
          speakerId: 'brain'),
      StoryLine('……言わなきゃよかった。忘れて。', speakerId: 'brain'),
      StoryLine('おやすみ。ちゃんと、片づけておくから。', speakerId: 'brain'),
    ],
  ),
  StoryEpisode(
    stage: 10,
    title: 'あなたを、わたさない',
    lines: [
      StoryLine('それは、はじめから奥にいた。'),
      StoryLine('黒い塊の表面で、見覚えのあるものが脈打っている。'),
      StoryLine('食べたもの。眠らなかった夜。座っていた時間。'),
      StoryLine('……こいつ、新しく現れたんじゃない。', speakerId: 'heart'),
      StoryLine('あなたが積み上げてきたものが、形になっただけです。',
          speakerId: 'liver'),
      StoryLine('こわい？', speakerId: 'brain'),
      StoryLine('だいじょうぶ。息は、わたしが続かせます。', speakerId: 'lung'),
      StoryLine('おなかも、すかせないよ！', speakerId: 'stomach'),
      StoryLine('心臓の彼女が、一歩前に出た。'),
      StoryLine('……ねえ、聞いて。', speakerId: 'heart'),
      StoryLine('わたし、けっこう独占欲つよいの。知らなかったでしょ。',
          speakerId: 'heart'),
      StoryLine('あなたの最初の一拍も、最後の一拍も、ぜんぶわたしのものなんだから。',
          speakerId: 'heart'),
      StoryLine('こんなやつに、わたすわけないじゃない。', speakerId: 'heart'),
      StoryLine('五人の光が、闇のなかで重なった。'),
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
