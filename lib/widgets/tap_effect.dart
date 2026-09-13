import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/theme.dart';

/// 触ったところに小さな花火を出す。
///
/// 押した手応えが画面から返ってこないと、反応したのかどうか分からない。
/// 実際に何かが起きる場所だけに置くと、押しても何も起きなかったときに
/// 無反応になるので、アプリ全体をこれで包んで、どこを触っても出す。
///
/// 触ったことを邪魔しないよう、受け取りは [HitTestBehavior.translucent] で
/// 素通しにし、描くほうは [IgnorePointer] で触れないようにしてある。
class TapEffects extends StatefulWidget {
  const TapEffects({super.key, required this.child});

  final Widget child;

  /// 描いている層の目印。MaterialApp の中にも CustomPaint はたくさんあるので、
  /// 試験から見分けるために付けてある。
  static const Key layerKey = ValueKey('tap-effects');

  @override
  State<TapEffects> createState() => _TapEffectsState();
}

class _TapEffectsState extends State<TapEffects>
    with SingleTickerProviderStateMixin {
  /// 一度に残す数。連打されても増え続けないように上限を置く。
  static const int _maxLive = 8;

  static const Duration _life = Duration(milliseconds: 520);

  final List<_Burst> _bursts = [];
  final Random _random = Random();

  /// ticker が動き出してからの時間。
  ///
  /// 実時計ではなくこちらを使う。画面が止まっているあいだは進まないし、
  /// 試験の中でも時間を進められる。
  Duration _elapsed = Duration.zero;

  /// 出ているあいだだけ回す。常時回しておくと、何も触っていない時間まで
  /// 毎フレーム起こすことになる。
  ///
  /// 遅延生成にすると、一度も触られないまま捨てられたときに dispose の中で
  /// 作ることになり、そこで落ちる。最初に作ってしまう。
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _elapsed = elapsed;
    _bursts.removeWhere((b) => elapsed - b.born > _life);
    if (_bursts.isEmpty) _ticker.stop();
    setState(() {});
  }

  void _spawn(Offset at) {
    // start すると経過時間は0に戻る。止まるのは空のときだけなので、
    // 残っているものの起点がずれることはない。
    if (!_ticker.isActive) {
      _elapsed = Duration.zero;
      _ticker.start();
    }

    if (_bursts.length >= _maxLive) _bursts.removeAt(0);
    _bursts.add(_Burst(at: at, born: _elapsed, seed: _random.nextInt(360)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 素通し。下にあるボタンの反応を奪わない。
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _spawn(event.localPosition),
      child: Stack(
        children: [
          widget.child,
          if (_bursts.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: TapEffects.layerKey,
                  painter: _BurstPainter(
                    bursts: _bursts,
                    now: _elapsed,
                    life: _life,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Burst {
  _Burst({required this.at, required this.born, required this.seed});

  final Offset at;

  /// 出たときの経過時間。
  final Duration born;

  /// 飛ぶ向きをひとつずつずらす。毎回そろっていると作り物に見える。
  final int seed;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.bursts, required this.now, required this.life});

  final List<_Burst> bursts;
  final Duration now;
  final Duration life;

  /// 飛ばす粒の数。増やすと散らかって、押した場所が分からなくなる。
  static const int _sparks = 6;

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final t =
          (now - burst.born).inMicroseconds / life.inMicroseconds.toDouble();
      if (t < 0 || t > 1) continue;
      _paintOne(canvas, burst, t.clamp(0.0, 1.0));
    }
  }

  void _paintOne(Canvas canvas, _Burst burst, double t) {
    // 広がりは最初が速く、終わりに向かって止まる。等速だと機械に見える。
    final spread = Curves.easeOutCubic.transform(t);
    // 消え際だけ急がせる。二乗で落とすと、出た直後にもう薄い。
    final fade = 1 - Curves.easeInQuad.transform(t);

    _flash(canvas, burst.at, spread, fade);
    _ring(canvas, burst.at, spread, fade);
    _spray(canvas, burst, spread, fade);
  }

  /// 押した瞬間の光。輪だけだと、細くて背景に負ける。
  void _flash(Canvas canvas, Offset at, double spread, double fade) {
    final paint = Paint()
      ..color = AppColors.rose.withValues(alpha: 0.5 * fade * (1 - spread))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(at, 16 + 26 * spread, paint);
  }

  /// 広がる輪。押した場所そのものを指す。
  void _ring(Canvas canvas, Offset at, double spread, double fade) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * (1 - spread) + 0.8
      ..color = AppColors.rose.withValues(alpha: fade);

    canvas.drawCircle(at, 10 + 48 * spread, paint);
  }

  /// 外へ飛ぶ粒。ハートと小さな光を交ぜる。
  void _spray(Canvas canvas, _Burst burst, double spread, double fade) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < _sparks; i++) {
      final angle = (burst.seed + i * (360 / _sparks)) * pi / 180;
      // 粒ごとに飛距離を変える。そろっていると輪に見えて、輪と重なる。
      final reach = 40.0 + (i.isEven ? 18 : 0) + (burst.seed % 9);
      final at = burst.at + Offset(cos(angle), sin(angle)) * spread * reach;

      final heart = i.isEven;
      paint.color = (heart ? AppColors.rose : AppColors.gold).withValues(
        alpha: fade,
      );

      if (heart) {
        _heart(canvas, at, 9 * (1 - spread * 0.45), paint);
      } else {
        canvas.drawCircle(at, 3.4 * (1 - spread * 0.55), paint);
      }
    }
  }

  /// 小さなハート。[at] を中心に、[s] をだいたいの半径として描く。
  void _heart(Canvas canvas, Offset at, double s, Paint paint) {
    final path = Path()
      ..moveTo(at.dx, at.dy + s * 0.75)
      ..cubicTo(
        at.dx - s * 1.5,
        at.dy - s * 0.2,
        at.dx - s * 0.5,
        at.dy - s * 1.2,
        at.dx,
        at.dy - s * 0.35,
      )
      ..cubicTo(
        at.dx + s * 0.5,
        at.dy - s * 1.2,
        at.dx + s * 1.5,
        at.dy - s * 0.2,
        at.dx,
        at.dy + s * 0.75,
      );

    canvas.drawPath(path, paint);
  }

  // 時間が進むたびに描き直す。中身の比較では止まっているか分からない。
  @override
  bool shouldRepaint(_BurstPainter old) => true;
}
