# 音の出どころ

同梱している音はすべて **CC0（パブリックドメイン）** のものだけを選んでいる。
このリポジトリは公開されていて、web版はファイルそのものが配信される。
「ゲームに組み込むのは自由だが、素材の再配布は禁止」という条件の素材
（効果音ラボ、魔王魂、DOVA-SYNDROME など）は、その一点で使えない。

CC0 なので表示の義務はないが、敬意として残しておく。

## 効果音 — assets/audio/sfx/

すべて実際に録られた音。最初は Kenney の合成UI音を入れていたが、
安っぽく聞こえたので、録音素材に入れ替えた。

| ファイル | 元 | 出どころ |
|---|---|---|
| tap.ogg | plop_01.ogg | A |
| page.ogg | book_flip.1.ogg | C |
| confirm.ogg | paper_02.ogg | A |
| back.ogg | sfx100v2_door_04.ogg | B |
| hit.ogg | hit_02.ogg | A |
| heavy.ogg | gong_01.ogg | A |
| win.ogg | bell_01.ogg | A |
| lose.ogg | door_close_01.ogg | A |
| gacha.ogg | sfx100v2_items_01.ogg | B |
| reveal.ogg | glass_03.ogg | A |
| levelup.ogg | bell_03.ogg | A |
| heart.ogg | glass_01.ogg | A |

- **A** … rubberduck「[100 CC0 SFX](https://opengameart.org/content/100-cc0-sfx)」/ CC0
- **B** … rubberduck「[100 CC0 SFX #2](https://opengameart.org/content/100-cc0-sfx-2)」/ CC0
- **C** … StarNinjas「[10 Book Page Flips](https://opengameart.org/content/10-book-page-flips)」/ CC0

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
