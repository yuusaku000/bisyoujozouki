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
  // ── 第二部。倒しても積み直されると分かってからの話 ──
  StoryEpisode(
    stage: 12,
    title: '二度目の朝',
    lines: [
      StoryLine('あれから、しばらくは静かだった。'),
      StoryLine('倒したはずのものは、跡形もなくなっていた。'),
      StoryLine('——けれど、その朝。'),
      StoryLine('……ねえ。起きて。', speakerId: 'heart', face: _futsuu),
      StoryLine('声が、いつもより硬かった。'),
      StoryLine('奥のほう。また、おなじ匂いがする。', speakerId: 'heart', face: _fuchou),
      StoryLine('五人が、同じ方向を見ていた。'),
      StoryLine('……消えたわけじゃなかったんです。', speakerId: 'liver', face: _futsuu),
      StoryLine('あれは出来事じゃない。積み重ねだから。', speakerId: 'brain', face: _futsuu),
      StoryLine(
        '一度片づけても、また同じだけ積めば、また立ち上がる。',
        speakerId: 'brain',
        face: _futsuu,
      ),
      StoryLine('胃の彼女が、めずらしく黙っていた。'),
      StoryLine('……じゃあ、ずっと終わらないってこと？', speakerId: 'stomach', face: _futsuu),
      StoryLine('誰も答えなかった。'),
      StoryLine('答えのかわりに、心臓の彼女がこちらの手を取った。'),
      StoryLine('終わらなくていいよ。', speakerId: 'heart', face: _genki),
      StoryLine(
        '終わらないってことは、ずっと一緒にいるってことだもん。',
        speakerId: 'heart',
        face: _genki,
      ),
    ],
  ),
  StoryEpisode(
    stage: 14,
    title: '順番',
    lines: [
      StoryLine('はじまりは、些細なことだった。'),
      StoryLine('今日は、まず歩いてもらいます。心臓さんのぶんは後で。', speakerId: 'lung', face: _futsuu),
      StoryLine('……は？　なんで後なの。', speakerId: 'heart', face: _futsuu),
      StoryLine('空気が、すっと冷えた。'),
      StoryLine('酸素がなければ、あなたは動けません。順番の話です。', speakerId: 'lung', face: _fuchou),
      StoryLine(
        'わたしが止まったら、その酸素はどこにも行かないけど。',
        speakerId: 'heart',
        face: _futsuu,
      ),
      StoryLine('ちょ、ちょっと二人とも……', speakerId: 'stomach', face: _futsuu),
      StoryLine('胃の彼女が、あいだに入ろうとして——'),
      StoryLine('……あ。でも、食べなきゃどっちも動かないよね？', speakerId: 'stomach', face: _genki),
      StoryLine('火に油だった。'),
      StoryLine('脳の彼女が、本を閉じる音がした。'),
      StoryLine('くだらない。順位をつけても、この人は分けられない。', speakerId: 'brain', face: _futsuu),
      StoryLine(
        '……そう言うあなたが、いちばん独り占めしていますよね。',
        speakerId: 'liver',
        face: _futsuu,
      ),
      StoryLine('はじめて、五人が一斉に黙った。'),
      StoryLine('その夜、誰も口をきかなかった。'),
    ],
  ),
  StoryEpisode(
    stage: 16,
    title: 'わたしのほうが',
    lines: [
      StoryLine('険悪なまま、三日が過ぎた。'),
      StoryLine('ねえ、はっきりさせよう。', speakerId: 'heart', face: _futsuu),
      StoryLine('あなたが最初に思い出すの、誰？', speakerId: 'heart', face: _futsuu),
      StoryLine('答えようとして、言葉が出なかった。'),
      StoryLine('……ほら。困らせている。', speakerId: 'liver', face: _futsuu),
      StoryLine('困らせているのは、あなたたち全員です。', speakerId: 'liver', face: _futsuu),
      StoryLine('肺の彼女が、めずらしく声を荒らげた。'),
      StoryLine('わたしは、この人が生まれて最初に触れたものです。', speakerId: 'lung', face: _fuchou),
      StoryLine('最初の一息。あれは、わたしのものです。', speakerId: 'lung', face: _fuchou),
      StoryLine('……その前から、わたしは打ってたよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('声が、小さく震えていた。'),
      StoryLine('生まれるずっと前から。ひとりで、ずっと。', speakerId: 'heart', face: _fuchou),
      StoryLine('脳の彼女が、静かに口を開いた。'),
      StoryLine('……わたしは、この人の記憶を全部持ってる。', speakerId: 'brain', face: _futsuu),
      StoryLine('あなたたちのことも、ぜんぶ、わたしの中にある。', speakerId: 'brain', face: _futsuu),
      StoryLine('だから、いちばん近いのは自分だと思ってた。', speakerId: 'brain', face: _fuchou),
    ],
  ),
  StoryEpisode(
    stage: 18,
    title: '線を引く',
    lines: [
      StoryLine('肝臓の彼女が、紙を一枚、机に置いた。'),
      StoryLine('割り当て表を作りました。', speakerId: 'liver', face: _futsuu),
      StoryLine('朝はわたし、昼は胃さん、夜は脳さん。', speakerId: 'liver', face: _futsuu),
      StoryLine('こうすれば、争う理由がなくなります。', speakerId: 'liver', face: _futsuu),
      StoryLine('しばらく、誰も紙を見なかった。'),
      StoryLine('……肝臓ちゃん。', speakerId: 'stomach', face: _futsuu),
      StoryLine('それ、時間を分けてるだけだよね。', speakerId: 'stomach', face: _futsuu),
      StoryLine('気持ちは、分けられないよ。', speakerId: 'stomach', face: _futsuu),
      StoryLine('肝臓の彼女の手が、止まった。'),
      StoryLine('……知っています。', speakerId: 'liver', face: _fuchou),
      StoryLine('知っていて、それでも数字にするしかなかったんです。', speakerId: 'liver', face: _fuchou),
      StoryLine('わたしは、処理することしかできないので。', speakerId: 'liver', face: _fuchou),
      StoryLine('紙が、静かに床へ落ちた。'),
      StoryLine('拾おうとしたこちらの手を、彼女が押しとどめた。'),
      StoryLine('……いいんです。もう、いりません。', speakerId: 'liver', face: _futsuu),
    ],
  ),
  StoryEpisode(
    stage: 20,
    title: '選ばないで',
    lines: [
      StoryLine('その奥で、それは待っていた。', enemyId: 'boss_seikatsu'),
      StoryLine('前より、ひとまわり大きくなっている。', enemyId: 'boss_seikatsu'),
      StoryLine('黒い表面が、五つに割れて、ゆっくりと笑った。', enemyId: 'boss_seikatsu'),
      StoryLine('——ひとつ、えらべ。', enemyId: 'boss_seikatsu'),
      StoryLine('声は、頭の中に直接落ちてきた。'),
      StoryLine('——いちばん大事なものを、ひとつ。ほかは、もういらないだろう。', enemyId: 'boss_seikatsu'),
      StoryLine('五人が、こちらを見た。'),
      StoryLine('選べるわけが、なかった。'),
      StoryLine('……ねえ。選ばないで。', speakerId: 'heart', face: _fuchou),
      StoryLine('けんかしてたのに、変だよね。でも、いま分かった。', speakerId: 'heart', face: _futsuu),
      StoryLine('ひとりでも欠けたら、あなたが止まる。', speakerId: 'lung', face: _futsuu),
      StoryLine('わたしたちは、順番をつけられるものじゃなかった。', speakerId: 'brain', face: _futsuu),
      StoryLine('……争っていたのが、恥ずかしいです。', speakerId: 'liver', face: _futsuu),
      StoryLine(
        'だから、ぜんぶ持ってきなよ！　ぜんぶ、この人のなんだから！',
        speakerId: 'stomach',
        face: _genki,
      ),
      StoryLine('五つの光が、はじめて一本の束になった。', enemyId: 'boss_seikatsu'),
    ],
  ),
  StoryEpisode(
    stage: 22,
    title: '置いていかれる日',
    lines: [
      StoryLine('勝った夜は、いつも静かだ。'),
      StoryLine('……ひとつ、聞いてもいい？', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女は本を開いたまま、こちらを見なかった。'),
      StoryLine('あなたが止まる日、わたしたちはどうなるのかな。', speakerId: 'brain', face: _futsuu),
      StoryLine('部屋の温度が、少し下がった気がした。'),
      StoryLine('……順番は、たぶん決まってる。', speakerId: 'heart', face: _futsuu),
      StoryLine('わたしが止まって、そのあと肺が止まって。', speakerId: 'heart', face: _fuchou),
      StoryLine('いちばん最後まで起きてるのは、脳ちゃん。', speakerId: 'heart', face: _fuchou),
      StoryLine('脳の彼女の指が、ページの上で止まった。'),
      StoryLine('……そう。わたしが、最後に見送る。', speakerId: 'brain', face: _fuchou),
      StoryLine('あなたのことを、いちばん長く覚えていられる。', speakerId: 'brain', face: _fuchou),
      StoryLine('それが「いちばん近い」ということなら。', speakerId: 'brain', face: _fuchou),
      StoryLine('彼女は、はじめて本を閉じた。'),
      StoryLine('……そんな一番、いらなかった。', speakerId: 'brain', face: _fuchou),
      StoryLine('誰も、なにも言わなかった。'),
    ],
  ),
  StoryEpisode(
    stage: 24,
    title: '順番じゃなかった',
    lines: [
      StoryLine('翌朝、五人が揃っていた。'),
      StoryLine('昨日のこと、考えたんです。', speakerId: 'lung', face: _futsuu),
      StoryLine('わたしたちは、順番を争っていました。', speakerId: 'lung', face: _futsuu),
      StoryLine('でも、順番があるということは——', speakerId: 'lung', face: _futsuu),
      StoryLine('……いつか必ず来る、ってことだもんね。', speakerId: 'stomach', face: _futsuu),
      StoryLine('胃の彼女が、めずらしく静かに言った。'),
      StoryLine('だからね。わたし、決めたの。', speakerId: 'stomach', face: _genki),
      StoryLine('その順番、できるだけ後ろにずらす。', speakerId: 'stomach', face: _genki),
      StoryLine('それは、わたしたちだけでは無理です。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女はこちらを、まっすぐ見た。'),
      StoryLine('あなたが歩いた分だけ、後ろにずれるんです。', speakerId: 'liver', face: _futsuu),
      StoryLine('一日ぶん歩けば、一日ぶん。', speakerId: 'liver', face: _futsuu),
      StoryLine('心臓の彼女が、笑った。'),
      StoryLine('……ね。取り合ってる場合じゃなかったでしょ。', speakerId: 'heart', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 26,
    title: 'いちばんに呼ばれたい',
    lines: [
      StoryLine('争いは終わった。けれど、消えたわけではなかった。'),
      StoryLine('……ひとつだけ、わがまま言っていい？', speakerId: 'heart', face: _futsuu),
      StoryLine('夜、二人きりのときだった。'),
      StoryLine('順番はつけなくていい。ほんとに、それでいい。', speakerId: 'heart', face: _futsuu),
      StoryLine('でも、苦しいとき。', speakerId: 'heart', face: _fuchou),
      StoryLine('いちばんに、わたしを呼んで。', speakerId: 'heart', face: _fuchou),
      StoryLine('……ずるいな。それ、みんな思ってる。', speakerId: 'brain', face: _futsuu),
      StoryLine('いつのまにか、五人が部屋にいた。'),
      StoryLine('聞いていたんですか。', speakerId: 'liver', face: _futsuu),
      StoryLine('あなたが言い出すとは、思わなかっただけです。', speakerId: 'liver', face: _futsuu),
      StoryLine('わたしも呼ばれたいです。息が、苦しいとき。', speakerId: 'lung', face: _futsuu),
      StoryLine('わたしはごはんのとき！　毎日呼ばれてる！', speakerId: 'stomach', face: _genki),
      StoryLine('笑い声が、ひさしぶりに部屋へ戻ってきた。'),
      StoryLine('心臓の彼女だけが、こちらの袖を離さなかった。'),
      StoryLine('……いちばんは、ゆずらないから。', speakerId: 'heart', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 28,
    title: '最後の夜になるかもしれない',
    lines: [
      StoryLine('奥から届く音が、もう隠れなくなっていた。'),
      StoryLine('次で、たぶん最後です。', speakerId: 'liver', face: _futsuu),
      StoryLine('あれは、これまでのぜんぶが集まったもの。', speakerId: 'brain', face: _futsuu),
      StoryLine('勝てなかったらどうなるかは、誰も言わなかった。'),
      StoryLine('……だから、いま言っておく。', speakerId: 'heart', face: _futsuu),
      StoryLine('五人が、順番に口を開いた。'),
      StoryLine('わたしは、あなたの最初の息を知っています。', speakerId: 'lung', face: _futsuu),
      StoryLine('わたしは、あなたが食べたもの全部でできてる。', speakerId: 'stomach', face: _futsuu),
      StoryLine('わたしは、あなたが忘れたことまで覚えています。', speakerId: 'brain', face: _futsuu),
      StoryLine(
        'わたしは、あなたが言わなかった無理を、全部処理しました。',
        speakerId: 'liver',
        face: _futsuu,
      ),
      StoryLine('最後に、心臓の彼女がこちらの手を取った。'),
      StoryLine('……わたしは、生まれる前からあなたを呼んでた。', speakerId: 'heart', face: _futsuu),
      StoryLine('返事をもらうのに、ずいぶんかかったけどね。', speakerId: 'heart', face: _genki),
      StoryLine('明日の朝も、同じことを言わせて。', speakerId: 'heart', face: _genki),
    ],
  ),
  StoryEpisode(
    stage: 30,
    title: 'ぜんぶ、わたしたちのもの',
    lines: [
      StoryLine('扉の奥は、もう部屋の形をしていなかった。', enemyId: 'boss_seikatsu'),
      StoryLine('積み上がったものが、天井まで届いている。', enemyId: 'boss_seikatsu'),
      StoryLine('——また来たのか。', enemyId: 'boss_seikatsu'),
      StoryLine('——何度倒しても、おまえが生きるかぎり、私は建て直せる。', enemyId: 'boss_seikatsu'),
      StoryLine('その通りだった。誰も否定しなかった。'),
      StoryLine('……うん。あなたは、また来る。', speakerId: 'heart', face: _futsuu),
      StoryLine('でもね。こっちも、毎朝ちゃんと起きてる。', speakerId: 'heart', face: _genki),
      StoryLine('一日歩けば、一日ぶん押し返せます。', speakerId: 'lung', face: _futsuu),
      StoryLine('一食ちゃんと食べれば、一食ぶん。', speakerId: 'stomach', face: _genki),
      StoryLine('一晩眠れば、一晩ぶん。', speakerId: 'brain', face: _futsuu),
      StoryLine('……あなたを消せないことは、知っています。', speakerId: 'liver', face: _futsuu),
      StoryLine('でも、こちらも消えません。同じことです。', speakerId: 'liver', face: _futsuu),
      StoryLine('五人が、こちらの前に並んだ。'),
      StoryLine('この人の一日は、ぜんぶ、わたしたちのもの。', speakerId: 'heart', face: _genki),
      StoryLine('一秒だって、あなたにはやらない。', speakerId: 'heart', face: _genki),
      StoryLine('黒い山が、はじめて後ずさった。', enemyId: 'boss_seikatsu'),
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
