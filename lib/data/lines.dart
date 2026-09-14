import '../models/organ.dart';

/// 一日のどのあたりか。ホームのセリフを変えるための区切り。
///
/// 深夜だけはっきり分けてあるのは、このゲームが積み重ねと戦う話だから。
/// 「まだ起きてるの」は、この子たちに言われていちばん効く一言になる。
enum TimeBand {
  asa('朝'), // 5:00〜10:59
  hiru('昼'), // 11:00〜16:59
  yoru('夜'), // 17:00〜22:59
  shinya('深夜'); // 23:00〜4:59

  const TimeBand(this.label);

  final String label;
}

TimeBand bandAt(DateTime now) {
  final hour = now.hour;
  // 深夜が日付をまたぐので、先に0時台を拾う。後ろに回すと午前2時が昼になる。
  if (hour < 5) return TimeBand.shinya;
  if (hour < 11) return TimeBand.asa;
  if (hour < 17) return TimeBand.hiru;
  if (hour < 23) return TimeBand.yoru;
  return TimeBand.shinya;
}

/// 次に時間帯が変わる瞬間。画面を開いたままでも言葉が切り替わるように、
/// ここまで待ってから起こす。1分ごとに見に行くより無駄がない。
DateTime nextBandChange(DateTime now) {
  for (final hour in [5, 11, 17, 23]) {
    if (now.hour < hour) return DateTime(now.year, now.month, now.day, hour);
  }
  return DateTime(now.year, now.month, now.day + 1, 5);
}

/// 時間帯ごとのセリフ。開いた直後に出るのはこちら。
///
/// 体調の言葉と違って、こちらは「いま何時か」しか見ていない。
/// 朝に「おかえり」と言われると、それだけで作り物に見える。
const Map<String, Map<TimeBand, List<String>>> kTimeLines = {
  'heart': {
    TimeBand.asa: ['おはよ。わたしはとっくに働いてるよ。', 'よく寝たね。いま、すごくいい速さで打ってる。'],
    TimeBand.hiru: ['お昼どき。ちょっと歩かない？　鈍っちゃうよ。', '{name}、さっきからずっと座ってない？'],
    TimeBand.yoru: ['おかえり。今日、どれくらい歩いた？', '一日おつかれさま。……ちゃんと見てたよ、わたし。'],
    TimeBand.shinya: ['まだ起きてるの。……わたしも起きてるけどさ。', 'こんな時間。速くなってるの、自分で分かる？'],
  },
  'lung': {
    TimeBand.asa: ['おはようございます。朝の空気、すこし冷たいですね。', '今日いちばん最初の一息、いただきました。'],
    TimeBand.hiru: ['窓、開けませんか。空気が止まっています。', '深呼吸ひとつ、どうですか。すぐ終わりますから。'],
    TimeBand.yoru: ['今日はよく動きましたね。息が、深いです。', '一日の終わりに、大きく吐いてください。'],
    TimeBand.shinya: ['……こんな時間まで。息、浅くなっていますよ。', '夜の空気は静かですね。……でも、そろそろ。'],
  },
  'stomach': {
    TimeBand.asa: ['おはよー！　朝ごはん、なに食べる？', 'からっぽだよー。なんか入れて？'],
    TimeBand.hiru: ['おなかすいた！　……あ、まだ？', 'お昼はちゃんと食べてね。抜くと夜がつらいから。'],
    TimeBand.yoru: ['夜ごはんの時間！　今日はなに？', '夜は軽めがうれしいな。重いと、{name}が寝れないの。'],
    TimeBand.shinya: ['夜中に食べるの、だめだからね。……ぜったい。', 'こんな時間に鳴ったら、それ、ほんとの空腹じゃないよ。'],
  },
  'liver': {
    TimeBand.asa: ['おはようございます。夜のぶんは処理し終えました。', '朝の報告です。異常ありません。'],
    TimeBand.hiru: ['午後です。休憩は取りましたか。', '働きどきですね。無理のない範囲で。'],
    TimeBand.yoru: ['本日ぶんの記録、まだですね。お待ちしています。', 'そろそろ店じまいです。夜更かしは、ほどほどに。'],
    TimeBand.shinya: [
      'この時間は、わたしの仕事が増えます。……お願いします。',
      '深夜です。追いつかなくなる前に、横になってください。',
    ],
  },
  'brain': {
    TimeBand.asa: ['おはよう。昨日のぶん、片づけておいたよ。', '起きたての頭は、まだ半分寝てる。ゆっくりでいいよ。'],
    TimeBand.hiru: ['昼過ぎは、いちばん判断が鈍る時間。大事なことは後にしよ。', '集中が切れたら、それは休めの合図だよ。'],
    TimeBand.yoru: ['そろそろ片づけを始めたい。{name}が寝てくれたら、だけど。', '今日のこと、棚に並べる準備はできてる。'],
    TimeBand.shinya: ['そろそろ、わたしの番なんだけど。', '起きてるあいだは、片づけられないんだよ。……ね。'],
  },
};

/// 臓器のセリフ。状態によって言うことが変わる。
///
/// 不調のときに責める言い方をしない。罪悪感で開きたくなくなるアプリに
/// しないための方針で、弱っていても相手を気づかう側に寄せている。
const Map<String, Map<Condition, List<String>>> kOrganLines = {
  'heart': {
    Condition.genki: [
      'いい鼓動！　今日のあなた、いい感じだよ。',
      'どくん、どくん。ちゃんと届いてる？',
      '走れそうな気がしてきた。ちょっとだけ、どう？',
      'あなたが動くと、わたしも嬉しくなる。',
    ],
    Condition.futsuu: [
      'ふつうが一番むずかしいんだよ、じつは。',
      '今日はおだやかだね。それも悪くない。',
      'もうちょっとだけ歩いてみる？　ほんの少しでいいの。',
    ],
    Condition.fuchou: [
      'ちょっと、休もっか。無理しなくていいよ。',
      'ドキドキが重たいな…でも、ちゃんと動いてるからね。',
      '責めてるんじゃないの。ただ、心配なだけ。',
    ],
  },
  'lung': {
    Condition.genki: ['すうーっ、はあーっ。気持ちいい空気！', '深呼吸、いっしょにしよ？', '階段、意外と平気だったでしょ？'],
    Condition.futsuu: ['今日はふつうの息。ふつうって安心する。', 'たまには窓、開けてみない？'],
    Condition.fuchou: ['すこし、息が浅いかも…ゆっくりでいいからね。', 'あなたが苦しくないなら、それでいい。'],
  },
  'stomach': {
    Condition.genki: [
      'ごちそうさま！　今日のごはん、よかったよ〜。',
      'ちゃんと噛んでくれてありがとう。えらい！',
      'おなか、いいかんじ。次もたのしみ。',
    ],
    Condition.futsuu: ['ほどほど。ほどほどが一番なんだよね。', 'あ、そろそろ何か食べる？'],
    Condition.fuchou: ['ちょっと、もたれてるかも…温かいもの、どう？', '食べすぎても怒らないよ。ただ、ちょっと重い。'],
  },
  'liver': {
    Condition.genki: [
      '今日は楽させてもらいました。ありがとう。',
      '休むのも仕事のうち。わたしが言うんだから間違いない。',
      '調子いいです。この調子でお願いしますね。',
    ],
    Condition.futsuu: ['まあ、こんなものでしょう。', 'たまには何もしない日を作ってくださいね。'],
    Condition.fuchou: ['すこし、働きすぎかもしれません…', '文句は言いません。でも、気づいてほしいです。'],
  },
  'brain': {
    Condition.genki: [
      '冴えてる。今日はいい判断ができそう。',
      'よく眠れた日は、世界がすこし優しく見えるね。',
      '考えごとがはかどる。いい夜だったんだね。',
    ],
    Condition.futsuu: ['まあまあ、といったところ。', '眠いような、眠くないような。'],
    Condition.fuchou: ['ねむい…すこしぼんやりする。', '今日は難しいことを決めないほうがいいかも。'],
  },
};

/// 開いた直後は、いまの時間に合わせた一言を返す。
/// つついた回数 [taps] が増えると、その日の調子の話に移る。
///
/// 不調のときだけ順番を入れ替える。弱っている日に時間の挨拶から入ると、
/// いちばん伝えたいことが後ろに回ってしまう。
///
/// どちらを選ぶときも [day] で回すので、同じ日に開き直せば同じ言葉が返る。
/// 気分がころころ変わるより、その日の調子として受け取れるほうがいい。
String lineFor(
  String organId,
  Condition condition,
  TimeBand band, {
  required int day,
  required int taps,
}) {
  final timed = kTimeLines[organId]?[band] ?? const <String>[];
  final byCondition = kOrganLines[organId]?[condition] ?? const <String>[];

  final fuchou = condition == Condition.fuchou;
  final first = fuchou ? byCondition : timed;
  final rest = fuchou ? timed : byCondition;

  if (taps == 0 && first.isNotEmpty) return first[day.abs() % first.length];

  final pool = [...first, ...rest];
  if (pool.isEmpty) return '…';
  return pool[(day + taps).abs() % pool.length];
}

/// ガチャ画面に立つ子のひとこと。
///
/// いちばん親密度の低い子が出る。「誰かが待っている」と分かると、
/// 引く理由が数字のほかにもできる。
const Map<String, String> kGachaWaitLines = {
  'heart': '……べつに、期待して待ってたわけじゃないから。',
  'lung': 'あの……なにか出たら、見せてもらえますか。',
  'stomach': 'なになに！？　わたしの好きなやつ入ってる！？',
  'liver': '……わたしの分も、あるんでしょうか。催促ではなく。',
  'brain': '興味はある。記録を取るため、ということにしておく。',
};

/// ショップの店番のひとこと。
///
/// 帳簿をつけるのは肝臓の仕事なので、いるなら肝臓が立つ。
const Map<String, String> kShopLines = {
  'liver': '……いらっしゃいませ。帳簿はわたしがつけます。',
  'heart': 'いらっしゃい。歩いたぶん、ちゃんと貯まってるよ。',
  'lung': 'いらっしゃいませ。ゆっくり選んでくださいね。',
  'stomach': 'いらっしゃーい！　どれにする？　迷っていいよ！',
  'brain': '来たね。……在庫は数えてある。好きに選んで。',
};

/// レベルが上がったときの一言。数字が増えるだけだと手応えが薄い。
const Map<String, List<String>> kLevelUpLines = {
  'heart': ['もっと強く打てる気がする！', 'ありがと。力がわいてきた。', 'この調子なら、どこまでも走れそう。'],
  'lung': ['息が、深くなった気がします。', 'ありがとうございます。もっと吸えます。', 'すこし、丈夫になれたかな。'],
  'stomach': ['よーし、なんでも溶かせるぞ！', 'えへへ、強くなっちゃった。', 'もっと食べられる気がする！'],
  'liver': ['助かります。処理が楽になりました。', '……ありがとうございます。', '仕事の効率が上がりました。'],
  'brain': ['思考がクリアになった。', '棚がひとつ増えた感じ。', 'いい判断ができそう。'],
};

/// 限界を解いたときの一言。
const Map<String, String> kAscendLines = {
  'heart': 'まだ上に行けるの？　……あなたとなら、いいよ。',
  'lung': 'まだ、深く吸えるんですね。知りませんでした。',
  'stomach': 'えっ、まだ大きくなれるの！？　やったー！',
  'liver': '限界だと思っていました。……思い込みでしたね。',
  'brain': '天井があると思っていた。訂正する。',
};

/// プレゼントを渡したときの一言。好物かどうかで変わる。
const Map<String, List<String>> kGiftLines = {
  'heart': ['わたしに……？　ありがとう。', 'ふふ、うれしい。大事にする。'],
  'lung': ['わあ……いいんですか？', 'だいじにします。ほんとうに。'],
  'stomach': ['やったー！　ありがとう！', 'えへへ、うれしいなあ。'],
  'liver': ['……もらっても、いいんですか。', 'ありがとうございます。意外と、うれしいです。'],
  'brain': ['……ありがとう。意外と、こういうの弱い。', '大事な棚に、しまっておく。'],
};

const Map<String, String> kFavoriteGiftLines = {
  'heart': 'えっ、これ……！　なんで好きだって分かったの？',
  'lung': 'これ、ずっと欲しかったんです……！　どうして分かったんですか？',
  'stomach': 'これこれこれ！　いちばん好きなやつ！',
  'liver': '……よく知っていますね。うれしいです、正直に言うと。',
  'brain': '……これを選ぶんだ。ちゃんと、見てくれてるんだね。',
};

String levelUpLine(String organId, int seed) {
  final lines = kLevelUpLines[organId];
  if (lines == null || lines.isEmpty) return 'ありがとう。';
  return lines[seed.abs() % lines.length];
}

String giftLine(String organId, {required bool favorite, required int seed}) {
  if (favorite) return kFavoriteGiftLines[organId] ?? 'ありがとう……！';
  final lines = kGiftLines[organId];
  if (lines == null || lines.isEmpty) return 'ありがとう。';
  return lines[seed.abs() % lines.length];
}

/// ハートがひとつ増えたときの一言。段階が上がるほど距離が近くなる。
const Map<String, List<String>> kHeartUpLines = {
  'heart': [
    'えっ、なに……急に。うれしいけど。',
    'ふふ。ちょっとだけ、近づいた気がする。',
    'あなたのこと、もっと知りたくなってきた。',
    'ねえ。……なんでもない。今のは、忘れて。',
    'わたし、たぶん、あなたのこと——',
  ],
  'lung': [
    'あ、ありがとうございます……！',
    'なんだか、息がしやすくなった気がします。',
    'あなたといると、深く吸えるんです。ふしぎ。',
    '……もっと、そばにいてもいいですか。',
    'この空気を、ずっと覚えていたいです。',
  ],
  'stomach': [
    'やったー！　もっとちょうだい！',
    'えへへ、うれしい。だいすき。',
    'あなたといると、おなかもこころもいっぱい。',
    'ずっといっしょにごはん食べようね。',
    '……わたし、あなたのこと、いちばん好きかも。',
  ],
  'liver': [
    '……こういうのは、慣れていません。',
    'なぜでしょう。悪い気は、しません。',
    'あなたのためなら、もう少し働けそうです。',
    '……たまには、頼ってもいいですか。わたしも。',
    'あなたのいない体は、想像できません。',
  ],
  'brain': [
    '……記録した。今日のこと。',
    'いい棚に、しまっておくね。',
    'あなたのこと、考える時間が増えた気がする。',
    '……これ、なんて名前の感情なんだろう。',
    'わかった。名前が、やっとわかった。',
  ],
};

String heartUpLine(String organId, int hearts) {
  final lines = kHeartUpLines[organId];
  if (lines == null || lines.isEmpty) return 'ありがとう。';
  return lines[(hearts - 1).clamp(0, lines.length - 1)];
}
