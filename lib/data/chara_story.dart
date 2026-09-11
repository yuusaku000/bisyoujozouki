import 'story.dart';

/// 親密度で開く、その子との二人きりの話。
///
/// 上がるのはプレゼントだけなので、渡したものの積み重ねがそのまま距離になる。
/// ♡1から♡5まで、近づくほど言えることが変わっていく。
/// ♡1はまだ距離がある。用がないと話しかけられない側の、最初の一回。
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
    requiredHearts: 1,
    title: 'そんなに見ないで',
    lines: [
      StoryLine('……なに？　じっと見て。', speakerId: 'heart', face: _futsuu),
      StoryLine('彼女は胸元を手でおさえるようにした。'),
      StoryLine('見られると、速くなっちゃうからやめて。', speakerId: 'heart', face: _fuchou),
      StoryLine('……ううん。いやじゃないよ。いやじゃないけど。', speakerId: 'heart', face: _futsuu),
      StoryLine('慣れてないの。こうやって、用もないのに来られるの。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女は小さく息をついて、それから顔を上げた。'),
      StoryLine('……また来ていいよ。次はもうちょっと、ちゃんと話す。', speakerId: 'heart', face: _genki),
    ],
  ),
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
    requiredHearts: 3,
    title: 'しずかな夜に',
    lines: [
      StoryLine('眠れない夜だった。'),
      StoryLine('……起きてるの、知ってるよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('だって、わたしの速さでわかるもん。', speakerId: 'heart', face: _genki),
      StoryLine('考えごと？　それとも、こわいこと？', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女は答えを待たずに、そっと横に座った。'),
      StoryLine('……いいよ。言わなくて。', speakerId: 'heart', face: _futsuu),
      StoryLine('わたしが、ゆっくり打ってあげるから。', speakerId: 'heart', face: _genki),
      StoryLine('とくん、とくん。まぶたが、重くなっていった。'),
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
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 5,
    title: 'さいごの一拍まで',
    lines: [
      StoryLine('ねえ、数えたことある？', speakerId: 'heart', face: _genki),
      StoryLine('わたしが今日、何回打ったか。', speakerId: 'heart', face: _futsuu),
      StoryLine('十万回くらい。毎日、ずっと。', speakerId: 'heart', face: _futsuu),
      StoryLine('一回も、あなたに気づかれないままね。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女はふっと笑って、こちらの手を両手で包んだ。'),
      StoryLine('でも、もういいの。気づいてもらえたから。', speakerId: 'heart', face: _genki),
      StoryLine('最初の一拍は、あなたが生まれる前だった。', speakerId: 'heart', face: _futsuu),
      StoryLine('最後の一拍は、ずっとずっと先でいい。', speakerId: 'heart', face: _genki),
      StoryLine('それまで、ぜんぶ、あなたのそばで打つから。', speakerId: 'heart', face: _genki),
    ],
  ),

  // ── 肺 ──
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 1,
    title: '用がなくても',
    lines: [
      StoryLine('あ、こっち……来るんですか。', speakerId: 'lung', face: _fuchou),
      StoryLine('彼女は一歩下がって、それから思い直したように止まった。'),
      StoryLine('すみません。なにか苦しいのかと思って。', speakerId: 'lung', face: _futsuu),
      StoryLine(
        'わたし、思い出してもらえるのは、たいてい苦しいときなので。',
        speakerId: 'lung',
        face: _futsuu,
      ),
      StoryLine('息が切れた、とか。胸が痛い、とか。', speakerId: 'lung', face: _fuchou),
      StoryLine('そこまで言って、彼女はあわてて首を振った。'),
      StoryLine(
        'あ、文句じゃないです。……その、うれしい、ってことです。',
        speakerId: 'lung',
        face: _genki,
      ),
    ],
  ),
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
    requiredHearts: 3,
    title: 'ためいきの理由',
    lines: [
      StoryLine('……いま、ためいきつきましたね。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女はこちらの顔をのぞきこんだ。'),
      StoryLine('あのね、ためいきって、悪いものじゃないんですよ。', speakerId: 'lung', face: _genki),
      StoryLine('浅くなった息を、体が元に戻そうとしてるだけ。', speakerId: 'lung', face: _futsuu),
      StoryLine('がまんしてた、ってことなんです。', speakerId: 'lung', face: _fuchou),
      StoryLine('だから、つきたいときはついてください。', speakerId: 'lung', face: _genki),
      StoryLine('……わたしが、ちゃんと入れ替えますから。', speakerId: 'lung', face: _genki),
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
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 5,
    title: 'はじめての呼吸',
    lines: [
      StoryLine('……覚えてますか。わたしの、はじめての仕事。', speakerId: 'lung', face: _futsuu),
      StoryLine('あなたが生まれて、いちばん最初にしたこと。', speakerId: 'lung', face: _futsuu),
      StoryLine('大きく、息を吸ったんです。', speakerId: 'lung', face: _genki),
      StoryLine('それが、わたしが動きはじめた瞬間。', speakerId: 'lung', face: _genki),
      StoryLine('彼女は照れたように目を伏せた。'),
      StoryLine('だからわたし、あなたの最初の音を知ってるんですよ。', speakerId: 'lung', face: _fuchou),
      StoryLine('……ちょっと、自慢です。', speakerId: 'lung', face: _genki),
    ],
  ),

  // ── 胃 ──
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 1,
    title: 'おなかの音',
    lines: [
      StoryLine('あっ、来た来た！　ねえ、さっきの聞こえた？', speakerId: 'stomach', face: _genki),
      StoryLine('彼女は自分のおなかをぽんぽんと叩いてみせた。'),
      StoryLine('あの音、わたしだよ。恥ずかしがらないでよね。', speakerId: 'stomach', face: _genki),
      StoryLine(
        '準備できてますよー、って言ってるだけなんだから。',
        speakerId: 'stomach',
        face: _futsuu,
      ),
      StoryLine(
        '……あ、でも。聞こえないふりされると、しょんぼりする。',
        speakerId: 'stomach',
        face: _fuchou,
      ),
      StoryLine('彼女は上目づかいにこちらをのぞきこんだ。'),
      StoryLine('だから、鳴ったら返事してね。……ね、約束！', speakerId: 'stomach', face: _genki),
    ],
  ),
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
    requiredHearts: 3,
    title: 'だれかと食べるごはん',
    lines: [
      StoryLine('今日のごはん、なんだかいつもと違った。', speakerId: 'stomach', face: _futsuu),
      StoryLine('彼女はスプーンをくるくる回しながら言った。'),
      StoryLine('ゆっくりだったし、あったかかった。', speakerId: 'stomach', face: _genki),
      StoryLine('……だれかと食べたでしょ。', speakerId: 'stomach', face: _genki),
      StoryLine('わかるよ。そういう日は、ぜんぜん疲れないもん。', speakerId: 'stomach', face: _futsuu),
      StoryLine('ひとりで急いで食べる日は、けっこうしんどいの。', speakerId: 'stomach', face: _fuchou),
      StoryLine('……だから、たまにでいいから。ね？', speakerId: 'stomach', face: _genki),
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
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 5,
    title: 'あなたをつくるもの',
    lines: [
      StoryLine('ねえ、知ってる？', speakerId: 'stomach', face: _genki),
      StoryLine('あなたの体、ぜんぶ食べたものでできてるんだよ。', speakerId: 'stomach', face: _futsuu),
      StoryLine('髪も、爪も、心臓ちゃんも、脳ちゃんも。', speakerId: 'stomach', face: _futsuu),
      StoryLine('わたしが溶かして、みんなに配ったやつ。', speakerId: 'stomach', face: _genki),
      StoryLine('彼女は少し胸を張って、それから声を落とした。'),
      StoryLine(
        '……だからね。あなたが大事にされてないと、悲しいの。',
        speakerId: 'stomach',
        face: _fuchou,
      ),
      StoryLine('わたしが作ったんだもん。大事にしてよ。', speakerId: 'stomach', face: _genki),
    ],
  ),

  // ── 肝臓 ──
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 1,
    title: '報告することは',
    lines: [
      StoryLine('彼女は顔も上げずに、書類にペンを走らせていた。'),
      StoryLine('……ご用件は。報告することは、特にありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('数値はすべて正常の範囲内。問題ありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('沈黙が落ちた。ペンの音だけが続いている。'),
      StoryLine('……まだ、いらっしゃるんですか。', speakerId: 'liver', face: _fuchou),
      StoryLine('彼女は一度だけ、ちらりとこちらを見た。'),
      StoryLine('……いえ。どうぞ、お好きなだけ。', speakerId: 'liver', face: _futsuu),
    ],
  ),
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
    requiredHearts: 3,
    title: '沈黙の理由',
    lines: [
      StoryLine('わたしは「沈黙の臓器」と呼ばれています。', speakerId: 'liver', face: _futsuu),
      StoryLine('痛みを感じる神経が、ほとんど通っていないので。', speakerId: 'liver', face: _futsuu),
      StoryLine('……便利だと思いますか。', speakerId: 'liver', face: _fuchou),
      StoryLine('彼女は眼鏡を外し、レンズを拭きはじめた。'),
      StoryLine('わたしは、不便だと思っています。', speakerId: 'liver', face: _fuchou),
      StoryLine('痛いと言えたら、もっと早く気づいてもらえるのに。', speakerId: 'liver', face: _fuchou),
      StoryLine('……あ。いま、はじめて弱音を吐きましたね、わたし。', speakerId: 'liver', face: _genki),
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
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 5,
    title: 'もういちど、はじめから',
    lines: [
      StoryLine('ひとつ、自慢してもいいですか。', speakerId: 'liver', face: _futsuu),
      StoryLine('わたし、生き返れるんです。', speakerId: 'liver', face: _genki),
      StoryLine('傷ついても、休ませてもらえれば、また元に戻る。', speakerId: 'liver', face: _futsuu),
      StoryLine('臓器の中で、そんなことができるのはわたしだけ。', speakerId: 'liver', face: _genki),
      StoryLine('彼女は言ってから、すこし目を伏せた。'),
      StoryLine('……でも、限度はあります。', speakerId: 'liver', face: _fuchou),
      StoryLine('だから、間に合ううちに。お願いします。', speakerId: 'liver', face: _futsuu),
      StoryLine('わたしは、あなたともう一度やり直したいので。', speakerId: 'liver', face: _genki),
    ],
  ),

  // ── 脳 ──
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 1,
    title: '理由のない一行',
    lines: [
      StoryLine('彼女はページをめくる手を止めないまま言った。'),
      StoryLine('来たね。……用件は？', speakerId: 'brain', face: _futsuu),
      StoryLine('ないの。じゃあ、なんで来たんだろう。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女はようやく顔を上げて、すこし首をかしげた。'),
      StoryLine('理由のない行動は、しまう場所に困るんだけど。', speakerId: 'brain', face: _fuchou),
      StoryLine('ペンの音。彼女は新しい一行を書き足した。'),
      StoryLine('……まあ、いいや。「来た」とだけ書いておく。', speakerId: 'brain', face: _genki),
    ],
  ),
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
    requiredHearts: 3,
    title: '忘れさせてあげる',
    lines: [
      StoryLine('……ひどいこと言われた日、あったよね。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女は棚の高いところを見上げていた。'),
      StoryLine('あれ、奥のほうにしまっておいた。', speakerId: 'brain', face: _futsuu),
      StoryLine('消してはいない。消すと、学べなくなるから。', speakerId: 'brain', face: _fuchou),
      StoryLine('でも、すぐ手が届くところには置かない。', speakerId: 'brain', face: _futsuu),
      StoryLine('それが、わたしにできる優しさ。', speakerId: 'brain', face: _genki),
      StoryLine('……忘れっぽくなったって怒らないでね。わざとだから。', speakerId: 'brain', face: _genki),
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
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 5,
    title: 'いちばん新しい記憶',
    lines: [
      StoryLine('棚を、ひとつ増やしたの。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女はめずらしく、うれしそうに言った。'),
      StoryLine('この数ヶ月ぶん。あなたが歩いた日のこと。', speakerId: 'brain', face: _genki),
      StoryLine('階段をのぼって息を切らした日。ちゃんと寝た日。', speakerId: 'brain', face: _genki),
      StoryLine('全部、いちばん取り出しやすい場所に並べてある。', speakerId: 'brain', face: _futsuu),
      StoryLine('……なんでかって？', speakerId: 'brain', face: _fuchou),
      StoryLine('あなたが自分を嫌いになった日に、すぐ渡せるように。', speakerId: 'brain', face: _futsuu),
      StoryLine('ほら、こんなに頑張ったでしょって。', speakerId: 'brain', face: _genki),
    ],
  ),
];

List<CharaEpisode> episodesForOrgan(String organId) =>
    kCharaStory.where((e) => e.organId == organId).toList();

/// heartsOf は臓器ごとの現在のハート数を返す関数。
List<CharaEpisode> unlockedCharaEpisodes(int Function(String) heartsOf) =>
    kCharaStory.where((e) => heartsOf(e.organId) >= e.requiredHearts).toList();
