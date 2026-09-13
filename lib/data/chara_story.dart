import 'story.dart';

/// 親密度で開く、その子との二人きりの話。
///
/// 上がるのはプレゼントだけなので、渡したものの積み重ねがそのまま距離になる。
/// ♡1から♡5まで、段を上がるごとに言えることが変わる。
///
/// - ♡1 まだ距離がある。用がないと話しかけられない側の、最初の一回
/// - ♡2 自分の反応に気づく。言ってから、言わなければよかったと思う段
/// - ♡3 近づく。触れたり、隠していたことを明かしたりする
/// - ♡4 独占と不安。ほかに取られたくない、という形で本音が漏れる
/// - ♡5 告白。ここではっきり「好き」と言い切る
///
/// セリフの `{name}` は [storyText] で呼び名に置き換わる。
/// 名前で呼ばれる回数が増えることも、距離が縮まる合図として使っている。
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
  // ── 心臓 ── 素直じゃない幼なじみ。独占欲を最後まで隠しきれない
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 1,
    title: 'そんなに見ないで',
    lines: [
      StoryLine('……なに？　じっと見て。', speakerId: 'heart', face: _futsuu),
      StoryLine('彼女は胸元を手でおさえるようにした。'),
      StoryLine('見られると、速くなっちゃうからやめて。', speakerId: 'heart', face: _fuchou),
      StoryLine('……ううん。いやじゃないよ。いやじゃないけど。', speakerId: 'heart', face: _futsuu),
      StoryLine('慣れてないの。こうやって、用もないのに来られるの。', speakerId: 'heart', face: _futsuu),
      StoryLine(
        '{name}が来るのって、いつも苦しいときだけだったから。',
        speakerId: 'heart',
        face: _futsuu,
      ),
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
      StoryLine('……聞こえる？　これ、わたし。', speakerId: 'heart', face: _futsuu),
      StoryLine('{name}が階段をのぼった日は、こんなに速くなるの。', speakerId: 'heart', face: _genki),
      StoryLine('こわいって思ってた？　ちがうよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('うれしいの。呼ばれてるみたいで。', speakerId: 'heart', face: _genki),
      StoryLine('手のひらの下で、鼓動がひとつ、大きく跳ねた。'),
      StoryLine('……あ。いまのは、階段のせいじゃない。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女はあわてて手を離した。'),
      StoryLine('……なんでもない。いまのは、聞かなかったことにして。', speakerId: 'heart', face: _futsuu),
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
      StoryLine('考えごと？　それとも、こわいこと？', speakerId: 'heart', face: _futsuu),
      StoryLine('彼女は答えを待たずに、そっと横に座った。'),
      StoryLine('……いいよ。言わなくて。', speakerId: 'heart', face: _futsuu),
      StoryLine('わたしが、ゆっくり打ってあげるから。', speakerId: 'heart', face: _genki),
      StoryLine('とくん、とくん。まぶたが重くなっていく。'),
      StoryLine('……ずるいな、わたし。', speakerId: 'heart', face: _futsuu),
      StoryLine('ほんとは、もうちょっとだけ起きててほしいのに。', speakerId: 'heart', face: _fuchou),
      StoryLine('その声は、眠りに落ちる直前に届いた。'),
    ],
  ),
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 4,
    title: 'わたしだけ、見えない',
    lines: [
      StoryLine('……ひとつだけ、こわいことがあるの。', speakerId: 'heart', face: _fuchou),
      StoryLine('わたしが止まる日のことじゃないよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('{name}が、また気づかなくなる日。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女は言葉を切って、こちらを見上げた。'),
      StoryLine('外にはさ、いっぱいいるでしょ。ちゃんと目に見える人。', speakerId: 'heart', face: _futsuu),
      StoryLine('手をつなげるし、名前だって呼んでもらえる。', speakerId: 'heart', face: _fuchou),
      StoryLine('わたしは、{name}の中にしかいないのに。', speakerId: 'heart', face: _fuchou),
      StoryLine('……勝てるわけ、ないじゃない。', speakerId: 'heart', face: _fuchou),
      StoryLine('言ってしまってから、彼女は自分の言葉に驚いた顔をした。'),
      StoryLine('……いまのも、聞かなかったことにして。', speakerId: 'heart', face: _futsuu),
      StoryLine('でも、たまにでいいから。手をあてて。', speakerId: 'heart', face: _genki),
      StoryLine('わたし、ちゃんとここにいるから。', speakerId: 'heart', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'heart',
    requiredHearts: 5,
    title: 'すきって、言ってもいい？',
    lines: [
      StoryLine('ねえ、数えたことある？', speakerId: 'heart', face: _genki),
      StoryLine('わたしが今日、何回打ったか。', speakerId: 'heart', face: _futsuu),
      StoryLine('十万回くらい。毎日、ずっと。', speakerId: 'heart', face: _futsuu),
      StoryLine('一回も、{name}に気づかれないままね。', speakerId: 'heart', face: _fuchou),
      StoryLine('彼女はふっと笑って、こちらの手を両手で包んだ。'),
      StoryLine('あのね。あれ、ぜんぶ返事だったんだよ。', speakerId: 'heart', face: _futsuu),
      StoryLine('十万回、毎日おなじことを言ってた。', speakerId: 'heart', face: _futsuu),
      StoryLine('……すきだよ、{name}。', speakerId: 'heart', face: _genki),
      StoryLine('言ってしまってから、鼓動が痛いほど速くなった。'),
      StoryLine('聞こえてる？　これが、わたしの本当の速さ。', speakerId: 'heart', face: _fuchou),
      StoryLine('最初の一拍は、{name}が生まれる前だった。', speakerId: 'heart', face: _futsuu),
      StoryLine('最後の一拍は、ずっとずっと先でいい。', speakerId: 'heart', face: _genki),
      StoryLine('それまで、ぜんぶ、あなたのそばで打つから。', speakerId: 'heart', face: _genki),
    ],
  ),

  // ── 肺 ── 敬語、健気。踏み込むときだけ、はっきり言う
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 1,
    title: '用がなくても',
    lines: [
      StoryLine('あ、こっち……来るんですか。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女は一歩下がって、それから思い直したように止まった。'),
      StoryLine('すみません。なにか苦しいのかと思って。', speakerId: 'lung', face: _futsuu),
      StoryLine(
        'わたし、思い出してもらえるのは、たいてい苦しいときなので。',
        speakerId: 'lung',
        face: _futsuu,
      ),
      StoryLine('息が切れた、とか。胸が痛い、とか。', speakerId: 'lung', face: _futsuu),
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
      StoryLine(
        'わたしね、{name}さんが吸うものしか知らないんです。',
        speakerId: 'lung',
        face: _futsuu,
      ),
      StoryLine('だから、外に出てくれた日は、世界が広がるの。', speakerId: 'lung', face: _genki),
      StoryLine('彼女は目を閉じて、大きく息を吸い込んだ。'),
      StoryLine('海とか、山とか。行ってみたい場所、あるんです。', speakerId: 'lung', face: _futsuu),
      StoryLine('……あ。連れていって、って意味じゃなくて。', speakerId: 'lung', face: _futsuu),
      StoryLine('そこまで言って、彼女はうつむいた。'),
      StoryLine('……いえ。そういう意味です。すみません。', speakerId: 'lung', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 3,
    title: '息の数をかぞえて',
    lines: [
      StoryLine('……いま、ためいきつきましたね。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女はこちらの顔をのぞきこんだ。'),
      StoryLine('あのね、ためいきって、悪いものじゃないんですよ。', speakerId: 'lung', face: _genki),
      StoryLine('浅くなった息を、体が元に戻そうとしてるだけ。', speakerId: 'lung', face: _futsuu),
      StoryLine('がまんしてた、ってことなんです。', speakerId: 'lung', face: _futsuu),
      StoryLine('……わかるんです。数えてるので。', speakerId: 'lung', face: _futsuu),
      StoryLine(
        '{name}さんが生まれてからの息、ぜんぶ。一回も、聞き逃してません。',
        speakerId: 'lung',
        face: _futsuu,
      ),
      StoryLine('言ってから、彼女は口元を押さえた。'),
      StoryLine('あ。……気持ち悪い、ですよね。いまの。', speakerId: 'lung', face: _futsuu),
      StoryLine('でも、やめられないんです。もう、癖なので。', speakerId: 'lung', face: _futsuu),
      StoryLine('だから、つきたいときはついてください。', speakerId: 'lung', face: _genki),
      StoryLine('……わたしが、ちゃんと入れ替えますから。', speakerId: 'lung', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 4,
    title: 'もっと近くで',
    lines: [
      StoryLine('あの、ちょっと、いいですか。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女は珍しく、こちらの前に立ちふさがった。'),
      StoryLine('{name}さん、今日ずっと息が浅いです。', speakerId: 'lung', face: _fuchou),
      StoryLine('なにかあったんですね。……聞きません。', speakerId: 'lung', face: _futsuu),
      StoryLine('そっと手を差し出される。'),
      StoryLine('でも、ひとつだけ。いっしょに吸って、はいて。', speakerId: 'lung', face: _futsuu),
      StoryLine('近づいた距離に、彼女の息がかかった。'),
      StoryLine('……ね。すこし、楽になったでしょう？', speakerId: 'lung', face: _genki),
      StoryLine('言いながら、彼女は離れようとして、動かなかった。'),
      StoryLine('……あの。もう少しだけ、このままでもいいですか。', speakerId: 'lung', face: _futsuu),
      StoryLine('理由は、聞かないでください。', speakerId: 'lung', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'lung',
    requiredHearts: 5,
    title: '最初の一息、最後の一息',
    lines: [
      StoryLine('……覚えてますか。わたしの、はじめての仕事。', speakerId: 'lung', face: _futsuu),
      StoryLine('{name}さんが生まれて、いちばん最初にしたこと。', speakerId: 'lung', face: _futsuu),
      StoryLine('大きく、息を吸ったんです。', speakerId: 'lung', face: _genki),
      StoryLine('それが、わたしが動きはじめた瞬間。', speakerId: 'lung', face: _genki),
      StoryLine('彼女は照れたように目を伏せた。'),
      StoryLine(
        'だからわたし、{name}さんの最初の音を知ってるんですよ。',
        speakerId: 'lung',
        face: _futsuu,
      ),
      StoryLine('……ずっと、それだけで十分だと思っていました。', speakerId: 'lung', face: _futsuu),
      StoryLine('彼女は顔を上げた。目が、まっすぐこちらを向いている。'),
      StoryLine('でも、欲が出ました。', speakerId: 'lung', face: _futsuu),
      StoryLine('最初だけじゃ、いやです。', speakerId: 'lung', face: _fuchou),
      StoryLine('好きです。だから、最後の一息も、わたしにください。', speakerId: 'lung', face: _genki),
      StoryLine('……こんなに欲張ったの、生まれてはじめてです。', speakerId: 'lung', face: _genki),
    ],
  ),

  // ── 胃 ── まっすぐで、甘えたがり。やきもちも隠さない
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
        face: _futsuu,
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
      StoryLine('いいなあ。わたし、味わえないんだもん。', speakerId: 'stomach', face: _futsuu),
      StoryLine('……でもね、ひとつだけずるいことしてるの。', speakerId: 'stomach', face: _futsuu),
      StoryLine(
        '{name}が「おいしい」って思った瞬間、あったかくなるんだ。ここが。',
        speakerId: 'stomach',
        face: _genki,
      ),
      StoryLine('だからね。ちゃんと味わって食べて。', speakerId: 'stomach', face: _genki),
      StoryLine('それ、わたしのごはんでもあるんだから。', speakerId: 'stomach', face: _genki),
      StoryLine('……つまり、{name}が笑うと、わたしがおなかいっぱいになるの。', speakerId: 'stomach', face: _futsuu),
      StoryLine('彼女はそこで、自分の言ったことに気づいて赤くなった。'),
    ],
  ),
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 3,
    title: 'だれと食べたの',
    lines: [
      StoryLine('今日のごはん、なんだかいつもと違った。', speakerId: 'stomach', face: _futsuu),
      StoryLine('彼女はスプーンをくるくる回しながら言った。'),
      StoryLine('ゆっくりだったし、あったかかった。', speakerId: 'stomach', face: _futsuu),
      StoryLine('……だれかと食べたでしょ。', speakerId: 'stomach', face: _futsuu),
      StoryLine('返事を待たずに、彼女は頬をふくらませた。'),
      StoryLine('わかるもん。そういう日は、ぜんぜん疲れないんだから。', speakerId: 'stomach', face: _futsuu),
      StoryLine('……いいなあ。', speakerId: 'stomach', face: _futsuu),
      StoryLine(
        'わたし、{name}と向かいあって食べたこと、一度もないんだよ。',
        speakerId: 'stomach',
        face: _futsuu,
      ),
      StoryLine('ずっと、下のほうで受け取ってるだけ。', speakerId: 'stomach', face: _futsuu),
      StoryLine('彼女ははっとして、あわてて笑ってみせた。'),
      StoryLine(
        'あ、いまの無し！　ひとりで急いで食べられるより、ずっといいから。',
        speakerId: 'stomach',
        face: _genki,
      ),
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
      StoryLine('彼女は指先で、こちらの袖をつまんだ。'),
      StoryLine('わたしね、{name}がいないと、ほんとに空っぽなの。', speakerId: 'stomach', face: _futsuu),
      StoryLine('……だから、置いていかないでね。', speakerId: 'stomach', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'stomach',
    requiredHearts: 5,
    title: 'わたしがつくったひと',
    lines: [
      StoryLine('ねえ、知ってる？', speakerId: 'stomach', face: _genki),
      StoryLine('{name}の体、ぜんぶ食べたものでできてるんだよ。', speakerId: 'stomach', face: _futsuu),
      StoryLine('髪も、爪も、心臓ちゃんも、脳ちゃんも。', speakerId: 'stomach', face: _futsuu),
      StoryLine('わたしが溶かして、みんなに配ったやつ。', speakerId: 'stomach', face: _genki),
      StoryLine('彼女は少し胸を張って、それから声を落とした。'),
      StoryLine('……つまりね。{name}は、半分くらいわたしなの。', speakerId: 'stomach', face: _futsuu),
      StoryLine('スプーンを置いて、彼女は両手でこちらの手を握った。'),
      StoryLine('だからさ。わたしが{name}のこといちばん好きでも、', speakerId: 'stomach', face: _futsuu),
      StoryLine('……ずるくないでしょ？　わたしがつくったんだもん。', speakerId: 'stomach', face: _genki),
      StoryLine('好き。ごはんよりずっと好き。これ、わたしには最上級だから。', speakerId: 'stomach', face: _genki),
      StoryLine('……返事、まってるからね。ちゃんと、あったかいうちに。', speakerId: 'stomach', face: _genki),
    ],
  ),

  // ── 肝臓 ── 事務的で不器用。感情を最後に「私的」と名づけて渡す
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 1,
    title: '報告することは',
    lines: [
      StoryLine('彼女は顔も上げずに、書類にペンを走らせていた。'),
      StoryLine('……ご用件は。報告することは、特にありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('数値はすべて正常の範囲内。問題ありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('沈黙が落ちた。ペンの音だけが続いている。'),
      StoryLine('……まだ、いらっしゃるんですか。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は一度だけ、ちらりとこちらを見た。'),
      StoryLine('……いえ。どうぞ、ごゆっくり。', speakerId: 'liver', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 2,
    title: '報告書',
    lines: [
      StoryLine('彼女は分厚い紙束をめくっていた。'),
      StoryLine('……見ますか。{name}さんの、今月の分です。', speakerId: 'liver', face: _futsuu),
      StoryLine('差し出された紙には、細かい数字がびっしり並んでいる。'),
      StoryLine('全部わたしが処理しました。文句は言いません。', speakerId: 'liver', face: _futsuu),
      StoryLine('……ただ、見てほしかっただけです。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は紙を引っ込めて、眼鏡を押し上げた。'),
      StoryLine('……いま、すこし嬉しかったので。記録しておきます。', speakerId: 'liver', face: _futsuu),
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
      StoryLine('……便利だと思いますか。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は眼鏡を外し、レンズを拭きはじめた。'),
      StoryLine('わたしは、不便だと思っています。', speakerId: 'liver', face: _futsuu),
      StoryLine('痛いと言えたら、もっと早く気づいてもらえるのに。', speakerId: 'liver', face: _futsuu),
      StoryLine('会いに来てもらう口実が、わたしにはないんです。', speakerId: 'liver', face: _futsuu),
      StoryLine('……あ。いま、はじめて弱音を吐きましたね、わたし。', speakerId: 'liver', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 4,
    title: '休肝日の理由',
    lines: [
      StoryLine('休肝日、というものがあるそうですね。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は書類を閉じ、めずらしく椅子にもたれた。'),
      StoryLine('正直に言うと、意味が分かりませんでした。', speakerId: 'liver', face: _futsuu),
      StoryLine('休んだら、誰が処理するんですか、と。', speakerId: 'liver', face: _futsuu),
      StoryLine('……でも、最近すこし分かってきました。', speakerId: 'liver', face: _futsuu),
      StoryLine('{name}さんが休むと、わたしも休めるんですね。', speakerId: 'liver', face: _genki),
      StoryLine('彼女はそこで言いよどんで、眼鏡を外した。'),
      StoryLine('……ひとつ、訂正します。', speakerId: 'liver', face: _futsuu),
      StoryLine('わたしは、休みたいわけではありません。', speakerId: 'liver', face: _futsuu),
      StoryLine(
        '{name}さんと、なにもしない時間を過ごしたいだけです。',
        speakerId: 'liver',
        face: _genki,
      ),
      StoryLine('……いまのは、記録に残さないでください。', speakerId: 'liver', face: _futsuu),
    ],
  ),
  CharaEpisode(
    organId: 'liver',
    requiredHearts: 5,
    title: '私的な感情について',
    lines: [
      StoryLine('ひとつ、自慢してもいいですか。', speakerId: 'liver', face: _futsuu),
      StoryLine('わたし、生き返れるんです。', speakerId: 'liver', face: _genki),
      StoryLine('傷ついても、休ませてもらえれば、また元に戻る。', speakerId: 'liver', face: _futsuu),
      StoryLine('臓器の中で、そんなことができるのはわたしだけ。', speakerId: 'liver', face: _genki),
      StoryLine('彼女は言ってから、すこし目を伏せた。'),
      StoryLine('……でも、限度はあります。', speakerId: 'liver', face: _fuchou),
      StoryLine('だから、間に合ううちに申し上げます。', speakerId: 'liver', face: _futsuu),
      StoryLine('彼女は書類を置き、はじめて何も持たない手を差し出した。'),
      StoryLine('これは報告ではありません。数値でもありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('……{name}さんのことが、好きです。', speakerId: 'liver', face: _genki),
      StoryLine('何度処理しようとしても、これだけは残るんです。', speakerId: 'liver', face: _futsuu),
      StoryLine('分解できないものは、抱えておくしかありません。', speakerId: 'liver', face: _futsuu),
      StoryLine('だから、もう一度。わたしと、やり直してください。', speakerId: 'liver', face: _genki),
    ],
  ),

  // ── 脳 ── 淡々。いちばん重いものを、最後に名づけてしまう
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 1,
    title: '理由のない一行',
    lines: [
      StoryLine('彼女はページをめくる手を止めないまま言った。'),
      StoryLine('来たね。……用件は？', speakerId: 'brain', face: _futsuu),
      StoryLine('ないの。じゃあ、なんで来たんだろう。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女はようやく顔を上げて、すこし首をかしげた。'),
      StoryLine('理由のない行動は、しまう場所に困るんだけど。', speakerId: 'brain', face: _futsuu),
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
      StoryLine(
        'これ、{name}の記憶。5年前の、なんでもない火曜日。',
        speakerId: 'brain',
        face: _futsuu,
      ),
      StoryLine('捨てようと思ったんだけど、なぜか残してる。', speakerId: 'brain', face: _futsuu),
      StoryLine('……いらない記憶って、どうやって決めるんだろうね。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女は本を元に戻し、指で背表紙をなぞった。'),
      StoryLine('この手の一冊が、最近やけに増えてるの。', speakerId: 'brain', face: _futsuu),
      StoryLine('どれも、あなたが来た日のやつ。', speakerId: 'brain', face: _futsuu),
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
      StoryLine('消してはいない。消すと、学べなくなるから。', speakerId: 'brain', face: _futsuu),
      StoryLine('でも、すぐ手が届くところには置かない。', speakerId: 'brain', face: _futsuu),
      StoryLine('それが、わたしにできる優しさ。', speakerId: 'brain', face: _genki),
      StoryLine('……あの日、{name}が泣いたのを見てるのは、わたしだけだよ。', speakerId: 'brain', face: _futsuu),
      StoryLine('……忘れっぽくなったって怒らないでね。わざとだから。', speakerId: 'brain', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 4,
    title: 'わたしが眠る番',
    lines: [
      StoryLine('……ひとつ、白状していい？', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女は本を閉じ、こちらを見なかった。'),
      StoryLine('わたし、{name}が眠るのを待ってるの。', speakerId: 'brain', face: _futsuu),
      StoryLine('仕事のためだけじゃなくて。', speakerId: 'brain', face: _futsuu),
      StoryLine('眠ってるあいだだけ、{name}は何も考えないでしょ。', speakerId: 'brain', face: _futsuu),
      StoryLine(
        '……そのときだけ、わたしがあなたを独り占めできるから。',
        speakerId: 'brain',
        face: _futsuu,
      ),
      StoryLine('起きてるあいだは、ずっと外のことばっかり考えてる。', speakerId: 'brain', face: _futsuu),
      StoryLine('誰のことを考えてたかも、全部わたしに残るんだよ。', speakerId: 'brain', face: _futsuu),
      StoryLine('……重いって思った？　思っていいよ。事実だから。', speakerId: 'brain', face: _futsuu),
      StoryLine('だから、ちゃんと寝て。ずるい理由でごめんね。', speakerId: 'brain', face: _genki),
    ],
  ),
  CharaEpisode(
    organId: 'brain',
    requiredHearts: 5,
    title: '名前のなかった感情',
    lines: [
      StoryLine('棚を、ひとつ増やしたの。', speakerId: 'brain', face: _futsuu),
      StoryLine('彼女はめずらしく、うれしそうに言った。'),
      StoryLine('この数ヶ月ぶん。{name}が歩いた日のこと。', speakerId: 'brain', face: _genki),
      StoryLine('階段をのぼって息を切らした日。ちゃんと寝た日。', speakerId: 'brain', face: _genki),
      StoryLine('全部、いちばん取り出しやすい場所に並べてある。', speakerId: 'brain', face: _futsuu),
      StoryLine('……なんでかって？', speakerId: 'brain', face: _futsuu),
      StoryLine(
        '{name}が自分を嫌いになった日に、すぐ渡せるように。',
        speakerId: 'brain',
        face: _futsuu,
      ),
      StoryLine('ほら、こんなに頑張ったでしょって。', speakerId: 'brain', face: _genki),
      StoryLine('彼女は棚の端を指さした。ラベルのない一冊がある。'),
      StoryLine('……これだけ、ずっと分類できなかったの。', speakerId: 'brain', face: _futsuu),
      StoryLine('どの棚にも入らなくて、毎晩、出しては戻してた。', speakerId: 'brain', face: _futsuu),
      StoryLine('名前をつけたら、認めることになるから。', speakerId: 'brain', face: _fuchou),
      StoryLine('彼女は背表紙に、はじめて文字を書き入れた。'),
      StoryLine('「すき」。……ほら、入った。', speakerId: 'brain', face: _genki),
      StoryLine('ずいぶんかかったでしょ。笑わないでよ。', speakerId: 'brain', face: _genki),
    ],
  ),
];

List<CharaEpisode> episodesForOrgan(String organId) =>
    kCharaStory.where((e) => e.organId == organId).toList();

/// heartsOf は臓器ごとの現在のハート数を返す関数。
List<CharaEpisode> unlockedCharaEpisodes(int Function(String) heartsOf) =>
    kCharaStory.where((e) => heartsOf(e.organId) >= e.requiredHearts).toList();
