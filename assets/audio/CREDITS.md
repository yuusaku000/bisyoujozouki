# 音の出どころ

同梱している音はすべて **CC0（パブリックドメイン）** のものだけを選んでいる。
このリポジトリは公開されていて、web版はファイルそのものが配信される。
「ゲームに組み込むのは自由だが、素材の再配布は禁止」という条件の素材
（効果音ラボ、魔王魂、DOVA-SYNDROME など）は、その一点で使えない。

CC0 なので表示の義務はないが、敬意として残しておく。

## 効果音 — assets/audio/sfx/

Kenney（<https://kenney.nl>）/ CC0 1.0

| ファイル | 元 | パック |
|---|---|---|
| tap.ogg | click_002.ogg | Interface Sounds |
| page.ogg | click_005.ogg | Interface Sounds |
| confirm.ogg | confirmation_002.ogg | Interface Sounds |
| back.ogg | close_002.ogg | Interface Sounds |
| lose.ogg | error_002.ogg | Interface Sounds |
| gacha.ogg | glass_002.ogg | Interface Sounds |
| hit.ogg | impactGeneric_light_001.ogg | Impact Sounds |
| heavy.ogg | impactBell_heavy_001.ogg | Impact Sounds |
| win.ogg | jingles_STEEL00.ogg | Music Jingles |
| reveal.ogg | jingles_STEEL07.ogg | Music Jingles |
| levelup.ogg | jingles_PIZZI02.ogg | Music Jingles |
| heart.ogg | jingles_PIZZI00.ogg | Music Jingles |

名前を用途に付け替えてあるだけで、中身は無加工。

## BGM — assets/audio/bgm/

| ファイル | 曲 | 作者 | 出どころ |
|---|---|---|---|
| home.ogg | Forget Me Not (in F major, looped) | Kistol | [OpenGameArt](https://opengameart.org/content/forget-me-not) / CC0 |
| battle.ogg | Dark Shrine Loop | Yubatake（qubodup 投稿） | [OpenGameArt](https://opengameart.org/content/dark-shrine-loop) / CC0 |

## 差し替えるとき

`lib/data/sounds.dart` がファイル名と用途の対応表になっている。
同じ名前で置き換えればコードは触らなくていい。

形式は ogg。Android と Chrome/Edge/Firefox では鳴るが、
**Safari は ogg を再生できない**ので、iPhone から web版を開くと無音になる。
mp3 に変換して置き換えれば直る（変換する道具がこの環境に無くて見送った）。
