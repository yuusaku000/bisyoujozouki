import '../models/organ.dart';

/// 数字を見せたあとの一言。本人の口から言わせる。
///
/// 表だけ出しても、明日なにをすればいいのかが分からない。
/// 生活で動かせることだけを言う。
const Map<String, Map<Condition, String>> kAdvice = {
  'heart': {
    Condition.genki: 'いい感じ。ちゃんと下がりきってる。\nこのまま、歩く日を続けて。',
    Condition.futsuu: '悪くはないけど、もうすこし。\n階段をひとつぶん、増やせない？',
    Condition.fuchou: '……速いまま、戻りきってないの。\n今日は早めに休んで。お願い。',
  },
  'lung': {
    Condition.genki: '深く吸えています。\n外に出た日は、やっぱり違いますね。',
    Condition.futsuu: 'すこし浅いかもしれません。\n信号待ちのあいだだけでも、深呼吸を。',
    Condition.fuchou: '息が上がりやすくなっています。\n走らなくていいので、歩く時間を延ばして。',
  },
  'stomach': {
    Condition.genki: '絶好調！　よく回ってるよ。\nこのペースで食べてね。',
    Condition.futsuu: 'ちょっと急いで食べてない？\nあと5回、よく噛んでみて。',
    Condition.fuchou: '……重いよ。まだ残ってる感じ。\n今日はあたたかいものを、少なめに。',
  },
  'liver': {
    Condition.genki: '良好です。休めている証拠ですね。\nこの調子でお願いします。',
    Condition.futsuu: '処理が溜まり気味です。\n今夜は、何も入れない時間をください。',
    Condition.fuchou: '……限界が近いです。\nお願いですから、一日だけ休んでください。',
  },
  'brain': {
    Condition.genki: 'よく眠れてる。整理がはかどったよ。\nおかげで棚がきれい。',
    Condition.futsuu: '浅い眠りが多いかな。\n寝る1時間前に、画面を閉じてみて。',
    Condition.fuchou: '片づけが追いついてない。\n……今日は、早く寝て。ぜんぶ後回しでいいから。',
  },
};

String adviceFor(String organId, Condition condition) =>
    kAdvice[organId]?[condition] ?? '……とくに、言うことはありません。';
