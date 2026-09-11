import 'story.dart';

/// 特定の子を育てた人だけが読める話。
///
/// レベルはコインで上げる＝歩いた量なので、「その子に時間をかけた人」に
/// だけ届く。メインの話と違い、二人きりの場面だけを書いている。
class CharaEpisode {
  const CharaEpisode({
    required this.organId,
    required this.requiredHearts,
    required this.title,
    required this.lines,
  });

  final String organId;

  /// このハート数に届くと読める。運動ではなく、渡したものの積み重ねで開く。
  final int requiredHearts;
  final String title;
  final List<StoryLine> lines;

  String get key => 'chara:$organId:$requiredHearts';
}

const _genki = StoryFace.genki;
const _futsuu = StoryFace.futsuu;
const _fuchou = StoryFace.fuchou;

const List<CharaEpisode> kCharaStory = [
  // ── 心臓 ──
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 2,
    title: '手のひらの音',
    lines: [
      StoryLine('ねえ、ちょっとこっち来て。', speakerId: 'heart', face: _futsuu),
      StoryLine('彼女はこちらの手を取ると、自分の胸にあてた。'),
      StoryLine('……聞こえる？　これ、わたし。', speakerId: 'heart', face: _fuchou),
      StoryLine('あなたが階段をのぼった日は、こんなに速くなるの。', speakerId: 'heart', face: _genki),
      StoryLine('こわいって思ってた？　ちがうよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('うれしいの。呼ばれてるみたいで。', speakerId: 'heart', face: _genki),
      StoryLine('手のひらの下で、鼓動がひとつ、大きく跳ねた。'),
    ],
  ),
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 4,
    title: 'ずっと、さきまで',
    lines: [
      StoryLine('……ひとつだけ、こわいことがあるの。', speakerId: 'heart', face: _fuchou),
      StoryLine('わたしが止まる日のことじゃないよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('あなたが、また気づかなくなる日。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女は言葉を切って、こちらを見上げた。'),
      StoryLine('忙しくなったら、すぐ忘れちゃうでしょ。あなた。', speakerId: 'heart', face: _futsuu),
      StoryLine('……だから、たまにでいいから。手をあてて。', speakerId: 'heart', face: _genki),
      StoryLine('わたし、ちゃんとここにいるから。', speakerId: 'heart', face: _genki),
    ],
  ),

  // ── 肺 ──
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 2,
    title: '風の通る場所',
    lines: [
      StoryLine('窓、開けてもいいですか。', speakerId: 'lung', face: _futsuu),
      StoryLine('返事を待たずに、彼女はカーテンを開けた。'),
      StoryLine('……はぁ。おいしい。', speakerId: 'lung', face: _genki),
      StoryLine('わたしね、あなたが吸うものしか知らないんです。', speakerId: 'lung', face: _futsuu),
      StoryLine('だから、あなたが外に出た日は、世界が広がるの。', speakerId: 'lung', face: _genki),
      StoryLine('彼女は目を閉じて、大きく息を吸い込んだ。'),
      StoryLine('……もっと、いろんな空気を知りたいな。', speakerId: 'lung', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 4,
    title: 'いっしょに、はいて',
    lines: [
      StoryLine('あの、ちょっと、いいですか。', speakerId: 'lung', face: _fuchou),
      StoryLine('彼女は珍しく、こちらの前に立ちふさがった。'),
      StoryLine('あなた、今日ずっと息が浅いです。', speakerId: 'lung', face: _fuchou),
      StoryLine('なにかあったんですね。……聞きません。', speakerId: 'lung', face: _futsuu),
      StoryLine('そっと手を差し出される。'),
      StoryLine('でも、ひとつだけ。いっしょに吸って、はいて。', speakerId: 'lung', face: _futsuu),
      StoryLine('……ね。すこし、楽になったでしょう？', speakerId: 'lung', face: _genki),
    ],
  ),

  // ── 胃 ──
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 2,
    title: 'ひとくち、ちょうだい',
    lines: [
      StoryLine('あー！　それ、なに食べてるの！', speakerId: 'stomach', face: _genki),
      StoryLine('彼女は身を乗り出して、匂いを嗅ぐ真似をした。'),
      StoryLine('いいなあ。わたし、味わえないんだもん。', speakerId: 'stomach', face: _fuchou),
      StoryLine('……でもね、ひとつだけずるいことしてるの。', speakerId: 'stomach', face: _futsuu),
      StoryLine(
        'あなたが「おいしい」って思った瞬間、あったかくなるんだ。ここが。',
        speakerId: 'stomach',
        face: _genki,
      ),
      StoryLine('だからね。ちゃんと味わって食べて。', speakerId: 'stomach', face: _genki),
      StoryLine('それ、わたしのごはんでもあるんだから。', speakerId: 'stomach', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 4,
    title: 'こわかったんだよ',
    lines: [
      StoryLine(
        'ねえ、覚えてる？　前に、まる一日なにも食べなかった日。',
        speakerId: 'stomach',
        face: _futsuu,
      ),
      StoryLine('彼女はめずらしく、スプーンを置いていた。'),
      StoryLine('わたし、ずっと待ってたの。', speakerId: 'stomach', face: _fuchou),
      StoryLine('朝も、昼も、夜も。まだかな、まだかなって。', speakerId: 'stomach', face: _fuchou),
      StoryLine('忘れられちゃったのかなって、思った。', speakerId: 'stomach', face: _fuchou),
      StoryLine('こちらの顔を見て、彼女はあわてて笑った。'),
      StoryLine(
        'あ、責めてるんじゃないよ！　ただ……さみしかっただけ。',
        speakerId: 'stomach',
        face: _genki,
      ),
    ],
  ),

  // ── 肝臓 ──
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 2,
    title: '報告書',
    lines: [
      StoryLine('彼女は分厚い紙束をめくっていた。'),
      StoryLine('……見ますか。あなたの、今月の分です。', speakerId: 'liver', face: _futsuu),
      StoryLine('差し出された紙には、細かい数字がびっしり並んでいる。'),
      StoryLine('全部わたしが処理しました。文句は言いません。', speakerId: 'liver', face: _futsuu),
      StoryLine('……ただ、見てほしかっただけです。', speakerId: 'liver', face: _fuchou),
      StoryLine('彼女は紙を引っ込めて、眼鏡を押し上げた。'),
      StoryLine('……忘れてください。仕事に戻ります。', speakerId: 'liver', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 4,
    title: 'やすみかた',
    lines: [
      StoryLine('休肝日、というものがあるそうですね。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は書類を閉じ、めずらしく椅子にもたれた。'),
      StoryLine('正直に言うと、意味が分かりませんでした。', speakerId: 'liver', face: _fuchou),
      StoryLine('休んだら、誰が処理するんですか、と。', speakerId: 'liver', face: _fuchou),
      StoryLine('……でも、最近すこし分かってきました。', speakerId: 'liver', face: _futsuu),
      StoryLine('あなたが休むと、わたしも休めるんですね。', speakerId: 'liver', face: _genki),
      StoryLine('……ずるいです。先に言ってください、そういうことは。', speakerId: 'liver', face: _genki),
    ],
  ),

  // ── 脳 ──
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 2,
    title: '棚の奥',
    lines: [
      StoryLine('本棚の前で、彼女は一冊を抜き出していた。'),
      StoryLine('これ、あなたの記憶。5年前の、なんでもない火曜日。', speakerId: 'brain', face: _futsuu),
      StoryLine('捨てようと思ったんだけど、なぜか残してる。', speakerId: 'brain', face: _futsuu),
      StoryLine('……いらない記憶って、どうやって決めるんだろうね。', speakerId: 'brain', face: _fuchou),
      StoryLine('彼女は本を元に戻し、指で背表紙をなぞった。'),
      StoryLine('まあ、場所はあるから。置いておくよ。', speakerId: 'brain', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 4,
    title: 'わたしが眠る番',
    lines: [
      StoryLine('……ひとつ、白状していい？', speakerId: 'brain', face: _fuchou),
      StoryLine('彼女は本を閉じ、こちらを見なかった。'),
      StoryLine('わたし、あなたが眠るのを待ってるの。', speakerId: 'brain', face: _futsuu),
      StoryLine('仕事のためだけじゃなくて。', speakerId: 'brain', face: _fuchou),
      StoryLine('眠ってるあいだだけ、あなたは何も考えないでしょ。', speakerId: 'brain', face: _futsuu),
      StoryLine(
        '……そのときだけ、わたしがあなたを独り占めできるから。',
        speakerId: 'brain',
        face: _fuchou,
      ),
      StoryLine('だから、ちゃんと寝て。ずるい理由でごめんね。', speakerId: 'brain', face: _genki),
    ],
  ),
];

List<CharaEpisode> episodesForOrgan(String organId) =>
    kCharaStory.where((e) => e.organId == organId).toList();

/// heartsOf は臓器ごとの現在のハート数を返す関数。
List<CharaEpisode> unlockedCharaEpisodes(int Function(String) heartsOf) =>
    kCharaStory.where((e) => heartsOf(e.organId) >= e.requiredHearts).toList();
