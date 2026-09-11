import '../models/organ.dart';

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

/// 日数で変えることで、同じ日に開き直しても同じ言葉が返る。
/// 気分がころころ変わるより、その日の調子として受け取れるほうがいい。
String lineFor(String organId, Condition condition, int seed) {
  final lines = kOrganLines[organId]?[condition];
  if (lines == null || lines.isEmpty) return '…';
  return lines[seed.abs() % lines.length];
}

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
