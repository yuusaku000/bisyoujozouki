import 'package:audioplayers/audioplayers.dart';

import '../data/sounds.dart';

/// 音を出す係。
///
/// 方針が3つある。
///
/// 1. **鳴らないことでアプリが止まらない。** 音の仕組みが無いところ
///    （テスト、対応していないブラウザ）でも落とさない。失敗は全部飲む。
/// 2. **勝手に鳴りださない。** ブラウザは画面を触る前の再生を止めるので、
///    流したい曲を覚えておいて、次に何か触られたときに鳴らし直す。
/// 3. **効果音は重なる。** 1つの player を使い回すと、前の音が途中で切れる。
///    少数を順ぐりに使う。
///
/// web では、player を作るたびに audioplayers 自身が
/// `MissingPluginException(... xyz.luan/audioplayers.global/events)` を
/// コンソールに出す。web 実装に全体向けの通知路だけが無いためで、
/// 再生には影響しない。こちらから握り潰す手立ては無い（EventChannel の
/// listen は Dart から外へ出る呼び出しなので、setMessageHandler では
/// 捕まえられない）。package が直るのを待つしかない。
class Audio {
  Audio._();

  static final Audio instance = Audio._();

  /// 音の仕組みごと無いところ用。テストから切る。
  bool enabled = true;

  bool _sfxOn = true;
  bool _bgmOn = true;

  /// 同時に鳴る効果音の数。戦闘の連打でも足りる程度。
  static const int _sfxVoices = 4;

  AudioPlayer? _bgmPlayer;
  List<AudioPlayer>? _sfxPlayers;
  int _voice = 0;

  /// 流したい曲。ブラウザに止められても、これは覚えておく。
  Bgm? _wanted;

  /// 鳴らしはじめた曲。実際に鳴っているかは player の状態で見る。
  Bgm? _playing;

  /// はじめの音量。BGMは背に回るので、効果音より控えめにする。
  static const double defaultBgmVolume = 0.45;
  static const double defaultSfxVolume = 0.8;

  double _bgmVolume = defaultBgmVolume;
  double _sfxVolume = defaultSfxVolume;

  bool get sfxOn => _sfxOn;
  bool get bgmOn => _bgmOn;

  /// 実際に鳴らす音量。切ってあるか、つまみが0なら無音。
  double get _effectiveBgm => _bgmOn ? _bgmVolume : 0;
  double get _effectiveSfx => _sfxOn ? _sfxVolume : 0;

  /// 設定から呼ぶ。切った瞬間に止まり、点けた瞬間に戻る。
  ///
  /// 止めるときは stop だけに頼らず、音量も0にする。止める命令が
  /// 効かない実装に当たっても、それで無音にはなる。
  void apply({
    required bool sfx,
    required bool bgm,
    double? sfxVolume,
    double? bgmVolume,
  }) {
    _sfxOn = sfx;
    _bgmOn = bgm;
    if (sfxVolume != null) _sfxVolume = sfxVolume.clamp(0.0, 1.0);
    if (bgmVolume != null) _bgmVolume = bgmVolume.clamp(0.0, 1.0);

    final player = _bgmPlayer;
    if (_effectiveBgm <= 0) {
      _playing = null;
      if (player != null) {
        _quiet(() => player.setVolume(0));
        _quiet(player.stop);
      }
      return;
    }

    if (player != null) _quiet(() => player.setVolume(_effectiveBgm));
    _resume();
  }

  void playSfx(Sfx sfx) {
    // 何か触られた合図でもある。止められていた曲をここで鳴らし直す。
    _resume();
    if (!enabled || _effectiveSfx <= 0) return;

    final players = _sfxPlayers ??= [
      for (var i = 0; i < _sfxVoices; i++)
        AudioPlayer(playerId: 'zoukicchi_sfx_$i'),
    ];
    final player = players[_voice];
    _voice = (_voice + 1) % players.length;
    _quiet(() => player.play(AssetSource(sfx.asset), volume: _effectiveSfx));
  }

  /// この画面ではこの曲、と宣言する。同じ曲が鳴っていれば何もしない。
  void playBgm(Bgm bgm) {
    _wanted = bgm;
    _resume();
  }

  void _resume() {
    final wanted = _wanted;
    if (!enabled || wanted == null || _effectiveBgm <= 0) return;

    final player = _bgmPlayer ??= AudioPlayer(playerId: 'zoukicchi_bgm');
    // 鳴らしはじめたのに止まっているなら、ブラウザに止められている。
    // そのときは同じ曲でももう一度かける。
    if (_playing == wanted && player.state == PlayerState.playing) return;

    _playing = wanted;
    _quiet(() async {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(wanted.asset), volume: _effectiveBgm);
    });
  }

  /// 失敗しても黙って諦める。音が出ないより、落ちるほうが困る。
  ///
  /// 曲が鳴らなかった場合は [_playing] と player の状態が食い違うが、
  /// 次に [_resume] が呼ばれたときに状態を見てかけ直す。
  void _quiet(Future<void> Function() run) {
    try {
      run().catchError((Object _) {});
    } catch (_) {
      // 呼んだ瞬間に投げる作りの実装もある。
    }
  }
}
