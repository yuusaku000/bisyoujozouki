import 'dart:math';

import 'package:flutter/material.dart';

import '../data/organs.dart';
import '../data/theme.dart';
import '../models/present.dart';

/// 演出の種類。引くたびに変わる。
///
/// 同じ絵を毎回見せられると、二回目からは飛ばしたくなる。
enum RevealKind { heartbeat, neuron, wipe }

/// 結果を出す前の間。
///
/// 文字でレアリティを出すと、そこだけ読んで演出を見なくなる。
/// どの種類でも「終盤にどれだけ大きく振れるか」の一本にまとめてある。
class GachaReveal extends StatefulWidget {
  const GachaReveal({super.key, required this.best, this.kind});

  final Rarity best;

  /// 指定しなければ毎回えらび直す。
  final RevealKind? kind;

  @override
  State<GachaReveal> createState() => _GachaRevealState();
}

class _GachaRevealState extends State<GachaReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  final _seed = Random().nextInt(1 << 30);
  late final RevealKind _kind =
      widget.kind ??
      RevealKind.values[Random().nextInt(RevealKind.values.length)];

  /// レアリティごとの振れ幅。ここだけで当たりを表す。
  static const Map<Rarity, double> amplitude = {
    Rarity.n: 1.0,
    Rarity.r: 1.4,
    Rarity.sr: 2.1,
    Rarity.ssr: 3.2,
  };

  /// 種類ごとの下地の色。終盤にレアリティの色へ寄っていく。
  Color get _base => switch (_kind) {
    RevealKind.heartbeat => AppColors.rose,
    RevealKind.neuron => organById('brain').accent,
    RevealKind.wipe => AppColors.gold,
  };

  double get _peak => amplitude[widget.best] ?? 1.0;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 終盤まではどれも同じ大きさ。最初から大きいと、見る前に分かってしまう。
  double _amplitudeAt(double t) {
    if (t < 0.55) return 1.0;
    final grow = Curves.easeOutCubic.transform(((t - 0.55) / 0.35).clamp(0, 1));
    return 1 + (_peak - 1) * grow;
  }

  Color _colorAt(double t) {
    if (t < 0.55) return _base;
    final reveal = ((t - 0.55) / 0.3).clamp(0.0, 1.0);
    return Color.lerp(_base, widget.best.color, reveal)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final amp = _amplitudeAt(t);
          final color = _colorAt(t);

          return switch (_kind) {
            RevealKind.heartbeat => _Heartbeat(t: t, amp: amp, color: color),
            RevealKind.neuron => CustomPaint(
              size: Size.infinite,
              painter: _NeuronPainter(
                progress: t,
                amplitude: amp,
                color: color,
                seed: _seed,
              ),
            ),
            RevealKind.wipe => CustomPaint(
              size: Size.infinite,
              painter: _WipePainter(
                progress: t,
                amplitude: amp,
                color: color,
                seed: _seed,
              ),
            ),
          };
        },
      ),
    );
  }
}

// ── 心臓：鼓動 ──────────────────────────────────────────

class _Heartbeat extends StatelessWidget {
  const _Heartbeat({required this.t, required this.amp, required this.color});

  final double t;
  final double amp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // 終盤ほど速く打つ。大きさと速さの両方で高まりを出す。
    final rate = 1 + 5 * t;
    final beat = sin(t * rate * 2 * pi).abs();
    // 拍動の伸びは amp に掛けない。大きさは amp が担っている。
    // 掛けると SSR で枠を越えて、いちばん見せたい瞬間が切れる。
    final scale = 1 + 0.16 * beat;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 92 * amp * (0.9 + 0.25 * beat),
                    height: 92 * amp * (0.9 + 0.25 * beat),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.32 * beat),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.favorite,
                      size: 70 * amp,
                      color: color.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _EcgPainter(progress: t, color: color, amplitude: amp),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  _EcgPainter({
    required this.progress,
    required this.color,
    required this.amplitude,
  });

  final double progress;
  final Color color;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final mid = size.height / 2;
    final drawn = size.width * progress;
    final path = Path()..moveTo(0, mid);

    const spacing = 74.0;
    var x = 0.0;
    while (x < drawn) {
      final next = min(x + spacing, drawn);
      final peak = x + spacing * 0.5;
      if (peak < drawn) {
        // 山の高さも鼓動の大きさに連動させる
        final h = 20 * amplitude;
        path.lineTo(peak - 13, mid);
        path.lineTo(peak - 7, mid + h * 0.42);
        path.lineTo(peak, mid - h);
        path.lineTo(peak + 7, mid + h * 0.58);
        path.lineTo(peak + 13, mid);
      }
      path.lineTo(next, mid);
      x = next;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EcgPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.amplitude != amplitude;
}

// ── 脳：つながっていく ──────────────────────────────────

/// 点が結ばれていく。届く範囲と明るさで当たりを伝える。
class _NeuronPainter extends CustomPainter {
  _NeuronPainter({
    required this.progress,
    required this.amplitude,
    required this.color,
    required this.seed,
  });

  final double progress;
  final double amplitude;
  final Color color;
  final int seed;

  static const int _nodes = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final points = [
      for (var i = 0; i < _nodes; i++)
        Offset(
          size.width * (0.08 + rng.nextDouble() * 0.84),
          size.height * (0.16 + rng.nextDouble() * 0.68),
        ),
    ];

    // 近いところから結ぶ。総当たりだと最初から網になって、
    // つながっていく感じが出ない。
    final links = <(int, int, double)>[];
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        final d = (points[i] - points[j]).distance;
        if (d < size.shortestSide * 0.38) links.add((i, j, d));
      }
    }
    links.sort((a, b) => a.$3.compareTo(b.$3));

    // 終盤ほど遠くまで届く。当たりほど一気に広がる。
    final reach = (progress * 1.3 * (0.5 + 0.32 * amplitude)).clamp(0.0, 1.0);
    final lit = (links.length * reach).floor();

    final touched = <int>{};
    for (var i = 0; i < lit; i++) {
      final (a, b, _) = links[i];
      touched
        ..add(a)
        ..add(b);

      // 灯った直後だけ強く光らせる。全部同じ明るさだと順番が見えない。
      final fresh = (1 - (lit - i) / 7).clamp(0.0, 1.0);
      canvas.drawLine(
        points[a],
        points[b],
        Paint()
          ..strokeWidth = 0.8 + 0.45 * amplitude + 1.4 * fresh
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.2 + 0.6 * fresh),
      );
    }

    for (var i = 0; i < points.length; i++) {
      final on = touched.contains(i);
      final r = on ? 2.6 + 1.5 * amplitude : 1.6;
      if (on) {
        canvas.drawCircle(
          points[i],
          r * 3.4,
          Paint()..color = color.withValues(alpha: 0.045 * amplitude),
        );
      }
      canvas.drawCircle(
        points[i],
        r,
        Paint()..color = color.withValues(alpha: on ? 0.95 : 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(_NeuronPainter old) =>
      old.progress != progress ||
      old.amplitude != amplitude ||
      old.color != color;
}

// ── 肝臓：ふき取る ──────────────────────────────────────

/// 汚れをぬぐうと、下から光が出てくる。
/// ぬぐえた幅と光の強さで当たりを伝える。
class _WipePainter extends CustomPainter {
  _WipePainter({
    required this.progress,
    required this.amplitude,
    required this.color,
    required this.seed,
  });

  final double progress;
  final double amplitude;
  final Color color;
  final int seed;

  static const int _strokes = 4;

  @override
  void paint(Canvas canvas, Size size) {
    _glow(canvas, size);

    // 汚れを一枚のレイヤーに塗ってから、ぬぐった跡を消す。
    // Path.combine は web で効かないので、レイヤーごしに抜く。
    canvas.saveLayer(Offset.zero & size, Paint());
    _grime(canvas, size);
    _wipe(canvas, size);
    canvas.restore();
  }

  /// 下にある光。ぬぐった先に何もないと、ただ黒が出てくるだけになる。
  /// 当たりほど強く、遠くまで届く。
  void _glow(Canvas canvas, Size size) {
    // N でも光って見える明るさは残す。差は強さでつける。
    final strength = 0.45 + 0.55 * ((amplitude - 1) / 2.2).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide * (0.42 + 0.22 * progress);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: 0.14 * strength),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: (0.55 + 0.4 * progress) * strength),
            color.withValues(alpha: 0.05 * strength),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _grime(Canvas canvas, Size size) {
    final rng = Random(seed);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF2C221C),
    );
    for (var i = 0; i < 70; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        8 + rng.nextDouble() * 34,
        Paint()..color = const Color(0xFF15100D).withValues(alpha: 0.5),
      );
    }
  }

  /// ぬぐう手。上から順に一本ずつ走らせる。
  void _wipe(Canvas canvas, Size size) {
    final clear = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height / _strokes * 0.55 * amplitude;

    for (var i = 0; i < _strokes; i++) {
      final begin = i / _strokes * 0.78;
      final t = ((progress - begin) / 0.32).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final eased = Curves.easeInOutCubic.transform(t);
      final y = size.height * (i + 0.5) / _strokes;
      // 一本ごとに向きを変える。同じ向きだと機械が拭いているように見える。
      final leftToRight = i.isEven;
      final from = leftToRight ? -60.0 : size.width + 60;
      final to = leftToRight ? size.width + 60 : -60.0;

      canvas.drawLine(
        Offset(from, y),
        Offset(from + (to - from) * eased, y),
        clear,
      );
    }
  }

  @override
  bool shouldRepaint(_WipePainter old) =>
      old.progress != progress ||
      old.amplitude != amplitude ||
      old.color != color;
}
