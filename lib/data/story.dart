import '../models/organ.dart';

class StoryLine {
  const StoryLine(
    this.text, {
    this.speakerId,
    this.face = Condition.futsuu,
    this.enemyId,
  });

  /// nullなら地の文。
  final String? speakerId;
  final String text;

  /// その行での表情。1枚絵のまま喋り続けると芝居が死ぬ。
  final Condition face;

  /// 画面に出す敵。指定すると臓器の立ち絵の代わりにこちらが立つ。
  /// 相手の姿が見えないまま「この先に何かいる」と言われても伝わらない。
  final String? enemyId;
}

/// 表情の別名。キャラストーリー側から Condition を直接触らせないため。
/// セリフにつける表情。立ち絵の3枚をそのまま使う。
///
/// 不調の絵は子ごとに描かれているものが違うので、
/// 「暗い話だから不調」で選ぶと絵と合わない。何が描かれているかは:
///
/// - 心臓 … すこし苦しそう、あせあせ、さみしげ
/// - 肺  … 怒っている
/// - 胃  … かなりボロボロで苦しそう
/// - 肝臓 … かなりボロボロで苦しそう
/// - 脳  … 泣き顔
///
/// 迷ったら futsuu にする。不調は、その絵がそのまま当てはまる行だけ。
typedef StoryFace = Condition;

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

  String get key => 'main:$stage';
}

const _genki = Condition.genki;
const _futsuu = Condition.futsuu;
const _fuchou = Condition.fuchou;

/// バトルの報酬。コインを配らない代わりに、ここが進む。
const List<StoryEpisode> kStory = [
  StoryEpisode(
    stage: 1,
    title: 'はじめて、目が合った',
    lines: [
      StoryLine('深夜のラーメンが、湯気ごと消えていった。', enemyId: 'ramen'),
      StoryLine('静かになった胸の奥。そこに、彼女は立っていた。'),
      StoryLine('……あ。', speakerId: 'heart', face: _futsuu),
      StoryLine('ほんとに、聞こえてるんだ。', speakerId: 'heart', face: _futsuu),
      StoryLine('彼女は自分の胸を押さえて、頬を赤くした。'),
      StoryLine(
        'ずるいよ。わたしはずっと、あなたのこと知ってたのに。',
        speakerId: 'heart',
        face: _fuchou,
      ),
      StoryLine('生まれた日から、一度も休まずに。ずっと、そばで。', speakerId: 'heart', face: _futsuu),
      StoryLine(
        'あなたが誰かを好きになった日も、全部わたしが跳ねてたんだよ？',
        speakerId: 'heart',
        face: _genki,
      ),
      StoryLine('……気づいてくれるの、おそすぎ。', speakerId: 'heart', face: _fuchou),
      StoryLine('そう言って、彼女はそっぽを向いた。'),
      StoryLine('けれど、胸の奥の鼓動は、さっきよりずっと速くなっていた。'),
    ],
  ),
  StoryEpisode(
    stage: 2,
    title: '息が、とまるかと思った',
    lines: [
      StoryLine('階段をのぼりきると、うしろで小さな音がした。'),
      StoryLine('はぁっ……はぁっ……ま、待って、ください……', speakerId: 'lung', face: _futsuu),
      StoryLine('振り向くと、知らない女の子が膝に手をついていた。'),
      StoryLine('ご、ごめんなさい。わたし、まだ慣れてなくて……', speakerId: 'lung', face: _futsuu),
      StoryLine('顔を上げた彼女の目が、少しうるんでいる。'),
      StoryLine('でも、うれしいんです。', speakerId: 'lung', face: _futsuu),
      StoryLine(
        'あなたが息を切らすってことは、生きて、動いてるってことだから。',
        speakerId: 'lung',
        face: _genki,
      ),
      StoryLine('……ずっと、浅い息ばっかりだったから。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女は一歩近づいて、こちらの手をとった。'),
      StoryLine('ね。いっしょに、深呼吸してくれますか。', speakerId: 'lung', face: _genki),
      StoryLine('触れた指先は、驚くほどあたたかかった。'),
    ],
  ),
  StoryEpisode(
    stage: 3,
    title: 'もっと、かまって',
    lines: [
      StoryLine('エレベーターの扉が閉じ、静けさが戻る。', enemyId: 'elevator'),
      StoryLine('ねえねえっ、今日のごはん、どうだった？', speakerId: 'stomach', face: _genki),
      StoryLine('小柄な女の子がスプーンを振りながら、距離をつめてきた。'),
      StoryLine(
        'わたしね、味はわからないの。届いたものを溶かすだけだから。',
        speakerId: 'stomach',
        face: _futsuu,
      ),
      StoryLine('でもね。', speakerId: 'stomach', face: _futsuu),
      StoryLine(
        'あなたが「おいしい」って笑った日は、なんとなくわかるんだ。',
        speakerId: 'stomach',
        face: _genki,
      ),
      StoryLine('……ふしぎだよね。顔なんて、見えないのに。', speakerId: 'stomach', face: _futsuu),
      StoryLine('彼女はこちらを見上げて、少しだけ口をとがらせた。'),
      StoryLine('急いで飲み込まないで。ちゃんと味わって。', speakerId: 'stomach', face: _futsuu),
      StoryLine('そのほうが、長く一緒にいられるでしょ？', speakerId: 'stomach', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 4,
    title: 'わたしだけの、はずだった',
    lines: [
      StoryLine('その夜、胸の奥がやけに静かだった。'),
      StoryLine('……ねえ。最近、あの子たちとよく話してるよね。', speakerId: 'heart', face: _futsuu),
      StoryLine('別に。べつに、いいんだけど。', speakerId: 'heart', face: _futsuu),
      StoryLine('鼓動が、ひとつ大きく跳ねた。'),
      StoryLine('……よくない。', speakerId: 'heart', face: _fuchou),
      StoryLine('わたし、ずっとひとりであなたを動かしてたの。', speakerId: 'heart', face: _futsuu),
      StoryLine('誰にも気づかれなくても、平気なつもりでいたの。', speakerId: 'heart', face: _fuchou),
      StoryLine(
        'なのに、見つけてもらったら……もう、戻れないじゃない。',
        speakerId: 'heart',
        face: _fuchou,
      ),
      StoryLine('彼女はこちらを見ないまま、小さく言った。'),
      StoryLine(
        '……いちばん最初に会ったの、わたしだからね。忘れないで。',
        speakerId: 'heart',
        face: _genki,
      ),
    ],
  ),
  StoryEpisode(
    stage: 5,
    title: 'はじめてのおねがい',
    lines: [
      StoryLine('五つ目の敵が崩れ落ちても、彼女は一言も発しなかった。'),
      StoryLine('眼鏡の奥の視線だけが、静かにこちらを向いている。'),
      StoryLine('……わたしのこと、忘れていましたね。', speakerId: 'liver', face: _futsuu),
      StoryLine('いいんです。それがわたしの仕事ですから。', speakerId: 'liver', face: _futsuu),
      StoryLine('痛みも出さない。悲鳴も上げない。', speakerId: 'liver', face: _futsuu),
      StoryLine('気づかれたときには、たいてい手遅れ。', speakerId: 'liver', face: _fuchou),
      StoryLine('彼女は眼鏡を外し、めずらしく目を伏せた。'),
      StoryLine('……ひとつだけ、わがままを言っても？', speakerId: 'liver', face: _futsuu),
      StoryLine('わたしが何も言わないうちに、休んでください。', speakerId: 'liver', face: _genki),
      StoryLine('あなたに倒れられたら、わたし……', speakerId: 'liver', face: _fuchou),
      StoryLine('言いかけて、彼女は口をつぐんだ。'),
      StoryLine('……いえ。なんでもありません。', speakerId: 'liver', face: _futsuu),
    ],
  ),
  StoryEpisode(
    stage: 6,
    title: 'ふたりの台所',
    lines: [
      StoryLine('台所のほうから、言い争うような声がした。'),
      StoryLine('だーかーらー、揚げ物は夜に食べちゃだめなのっ！', speakerId: 'stomach', face: _futsuu),
      StoryLine('でも、あの、わたしは油の匂いも嫌いじゃなくて……', speakerId: 'lung', face: _futsuu),
      StoryLine(
        'ハイちゃんは甘いっ！　あとで苦しむのわたしなんだからねっ！',
        speakerId: 'stomach',
        face: _futsuu,
      ),
      StoryLine('二人はこちらに気づいて、ぴたりと止まった。'),
      StoryLine('あ。', speakerId: 'lung', face: _genki),
      StoryLine('……聞いてた？', speakerId: 'stomach', face: _futsuu),
      StoryLine('顔を見合わせて、それから、どちらからともなく笑った。'),
      StoryLine('ふふ。にぎやかになりましたね。', speakerId: 'lung', face: _genki),
      StoryLine('あなたの中、前はもっと静かだったのにね！', speakerId: 'stomach', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 7,
    title: 'おやすみのまえに',
    lines: [
      StoryLine('夜が更けて、まぶたが重くなってきた。'),
      StoryLine('……ねえ。わたしが何をしてるか、知ってる？', speakerId: 'brain', face: _futsuu),
      StoryLine('静かな声の主が、本を閉じて隣に腰を下ろした。'),
      StoryLine(
        'あなたが眠っているあいだ、今日あったことを片づけてるの。',
        speakerId: 'brain',
        face: _futsuu,
      ),
      StoryLine('いる記憶を棚に並べて、いらない汚れを洗い流して。', speakerId: 'brain', face: _genki),
      StoryLine('……ひとつだけ、棚に戻さない記憶があるんだけど。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女は視線を落とし、めずらしく言葉に詰まった。'),
      StoryLine(
        '……はじめて声が届いた日のこと。あれだけは、毎晩読み返してる。',
        speakerId: 'brain',
        face: _fuchou,
      ),
      StoryLine('……言わなきゃよかった。忘れて。', speakerId: 'brain', face: _futsuu),
      StoryLine('おやすみ。ちゃんと、片づけておくから。', speakerId: 'brain', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 8,
    title: '眠らないふたり',
    lines: [
      StoryLine('丑三つ時。灯りがひとつだけ点いている。'),
      StoryLine('……あなたも起きてたんですか。', speakerId: 'liver', face: _futsuu),
      StoryLine('机の上で、二人が向かい合っていた。'),
      StoryLine('わたしは夜のほうが仕事が多いの。あなたと同じ。', speakerId: 'brain', face: _futsuu),
      StoryLine('……似た者どうしですね。', speakerId: 'liver', face: _futsuu),
      StoryLine('黙って働いて、誰にも言わない。', speakerId: 'brain', face: _futsuu),
      StoryLine('言ったら、心配をかけますから。', speakerId: 'liver', face: _futsuu),
      StoryLine('脳の彼女は、小さくため息をついた。'),
      StoryLine('……あのね。心配されるのって、そんなに悪いこと？', speakerId: 'brain', face: _futsuu),
      StoryLine('肝臓の彼女は、しばらく答えなかった。'),
      StoryLine('……そうですね。悪くは、ないのかもしれません。', speakerId: 'liver', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 9,
    title: 'その扉のむこう',
    lines: [
      StoryLine('奥へ進むほど、空気が重くなっていく。'),
      StoryLine('扉の隙間から、黒い靄が漏れていた。', enemyId: 'boss_seikatsu'),
      StoryLine(
        'この先……なにか、います。',
        speakerId: 'lung',
        face: _futsuu,
        enemyId: 'boss_seikatsu',
      ),
      StoryLine(
        '大きいよ。今までのと、ぜんぜん違う。',
        speakerId: 'stomach',
        face: _futsuu,
        enemyId: 'boss_seikatsu',
      ),
      StoryLine('五人が、扉の前で足を止めた。'),
      StoryLine('引き返しても、誰も責めません。', speakerId: 'liver', face: _futsuu),
      StoryLine('でも、放っておけば大きくなるだけ。', speakerId: 'brain', face: _futsuu),
      StoryLine('心臓の彼女が、こちらの前に立った。'),
      StoryLine('……決めるのは、あなた。', speakerId: 'heart', face: _futsuu),
      StoryLine('でも、どっちを選んでも、わたしは一緒に行くから。', speakerId: 'heart', face: _genki),
      StoryLine('扉に手をかけると、五つの鼓動が重なった。'),
    ],
  ),
  StoryEpisode(
    stage: 10,
    title: 'あなたを、わたさない',
    lines: [
      StoryLine('それは、はじめから奥にいた。', enemyId: 'boss_seikatsu'),
      StoryLine('黒い塊の表面で、見覚えのあるものが脈打っている。', enemyId: 'boss_seikatsu'),
      StoryLine('食べたもの。眠らなかった夜。座っていた時間。', enemyId: 'boss_seikatsu'),
      StoryLine(
        '……こいつ、新しく現れたんじゃない。',
        speakerId: 'heart',
        face: _futsuu,
        enemyId: 'boss_seikatsu',
      ),
      StoryLine(
        'あなたが積み上げてきたものが、形になっただけです。',
        speakerId: 'liver',
        face: _futsuu,
        enemyId: 'boss_seikatsu',
      ),
      StoryLine('こわい？', speakerId: 'brain', face: _futsuu),
      StoryLine('だいじょうぶ。息は、わたしが続かせます。', speakerId: 'lung', face: _genki),
      StoryLine('おなかも、すかせないよ！', speakerId: 'stomach', face: _genki),
      StoryLine('心臓の彼女が、一歩前に出た。'),
      StoryLine('……ねえ、聞いて。', speakerId: 'heart', face: _futsuu),
      StoryLine(
        'わたし、けっこう独占欲つよいの。知らなかったでしょ。',
        speakerId: 'heart',
        face: _futsuu,
      ),
      StoryLine(
        'あなたの最初の一拍も、最後の一拍も、ぜんぶわたしのものなんだから。',
        speakerId: 'heart',
        face: _genki,
      ),
      StoryLine('こんなやつに、わたすわけないじゃない。', speakerId: 'heart', face: _genki),
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
