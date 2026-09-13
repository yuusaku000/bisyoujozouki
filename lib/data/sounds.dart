/// 鳴らす音と、その用途の対応表。
///
/// 画面のあちこちからファイル名を直に書くと、差し替えるときに
/// 全部を探して回ることになる。名前はここだけに置く。
///
/// 出どころと license は assets/audio/CREDITS.md に書いてある。
library;

/// 効果音。パスは assets/ からの相対で、audioplayers がその前を足す。
enum Sfx {
  /// 画面を軽くつついたとき。キャラをつつく、札を選ぶ。
  tap('audio/sfx/tap.wav'),

  /// 物語を1行進める。つつく音より軽くする。
  page('audio/sfx/page.ogg'),

  /// 決定。今日を記録する、買う、渡す。
  confirm('audio/sfx/confirm.wav'),

  /// 閉じる、戻る。
  back('audio/sfx/back.wav'),

  /// 味方の攻撃が当たった。
  hit('audio/sfx/hit.ogg'),

  /// 重い一撃。ボス戦の決着に使う。
  heavy('audio/sfx/heavy.ogg'),

  /// 勝った。
  win('audio/sfx/win.ogg'),

  /// 負けた。責める音にしない。
  lose('audio/sfx/lose.ogg'),

  /// ガチャを引きはじめる。
  gacha('audio/sfx/gacha.ogg'),

  /// 出たものが見える瞬間。
  reveal('audio/sfx/reveal.ogg'),

  /// レベルが上がった、限界を解いた。
  levelUp('audio/sfx/levelup.ogg'),

  /// 親密度がひとつ上がった。
  heart('audio/sfx/heart.ogg');

  const Sfx(this.asset);

  final String asset;
}

/// 流し続ける曲。切り替える場面が少ないので2つだけ。
enum Bgm {
  /// ホームと、それにぶら下がる画面。静かなピアノ。
  home('audio/bgm/home.ogg'),

  /// 戦闘。暗く、落ち着かない音。
  battle('audio/bgm/battle.ogg');

  const Bgm(this.asset);

  final String asset;
}
