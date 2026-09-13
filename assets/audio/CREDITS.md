# 音の出どころ

同梱している音はすべて **CC0（パブリックドメイン）** のものだけを選んでいる。
このリポジトリは公開されていて、web版はファイルそのものが配信される。
「ゲームに組み込むのは自由だが、素材の再配布は禁止」という条件の素材
（効果音ラボ、魔王魂、DOVA-SYNDROME など）は、その一点で使えない。

CC0 なので表示の義務はないが、敬意として残しておく。

## 効果音 — assets/audio/sfx/

すべて実際に録られた音。最初は Kenney の合成UI音を入れていたが、
安っぽく聞こえたので、録音素材に入れ替えた。

どれを何に使うかは、候補を並べたページで聴き比べて選んだもの。

| ファイル | 元 | 出どころ |
|---|---|---|
| tap.wav | click3.wav | C |
| page.ogg | paper_03.ogg | A |
| confirm.wav | switch28.wav | C |
| back.wav | switch12.wav | C |
| hit.ogg | hit_01.ogg | A |
| heavy.ogg | slam_04.ogg | A |
| win.ogg | sfx100v2_items_02.ogg | B |
| lose.ogg | other_04.ogg | A |
| gacha.ogg | sfx100v2_lock_open_01.ogg | B |
| reveal.ogg | glass_03.ogg | A |
| levelup.ogg | sfx100v2_items_02.ogg | B |
| heart.ogg | glass_01.ogg | A |

- **A** … rubberduck「[100 CC0 SFX](https://opengameart.org/content/100-cc0-sfx)」/ CC0
- **B** … rubberduck「[100 CC0 SFX #2](https://opengameart.org/content/100-cc0-sfx-2)」/ CC0
- **C** … Kenney「[51 UI sound effects](https://opengameart.org/content/51-ui-sound-effects-buttons-switches-and-clicks)」/ CC0
  （こちらは合成音ではなく、実際のスイッチとクリックを録ったもの）

win と levelup は同じ音。鳴る場面が離れているので、分けていない。

名前を用途に付け替えてあるだけで、中身は無加工。

## BGM — assets/audio/bgm/

| ファイル | 曲 | 作者 | 出どころ |
|---|---|---|---|
| home.ogg | Forget Me Not (in F major, looped) | Kistol | [OpenGameArt](https://opengameart.org/content/forget-me-not) / CC0 |
| battle.ogg | Dark Shrine Loop | Yubatake（qubodup 投稿） | [OpenGameArt](https://opengameart.org/content/dark-shrine-loop) / CC0 |

## 差し替えるとき

`lib/data/sounds.dart` がファイル名と用途の対応表になっている。
同じ名前で置き換えればコードは触らなくていい。

元の素材には 24bit の wav が多いが、Android やブラウザで鳴らないことが
あるので、**ogg か 16bit の wav** だけを選んでいる。

形式は ogg。Android と Chrome/Edge/Firefox では鳴るが、
**Safari は ogg を再生できない**ので、iPhone から web版を開くと無音になる。
mp3 に変換して置き換えれば直る（変換する道具がこの環境に無くて見送った）。
