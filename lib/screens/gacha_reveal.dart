import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/present.dart';

/// 結果を出す前の間。鼓動の大きさで当たりを伝える。
///
/// 文字でレアリティを出すと、そこだけ読んで演出を見なくなる。
/// 高鳴りが大きいほどいいものが出ている、という一本の合図にまとめた。
class GachaReveal extends StatefulWidget {
  const GachaReveal({super.key, required this.best});

  final Rarity best;

  @override
  State<GachaReveal> createState() => _GachaRevealState();
}

class _GachaRevealState extends State<GachaReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  /// レアリティごとの高鳴りの大きさ。ここだけで当たりを表す。
  static const Map<Rarity, double> _amplitude = {
    Rarity.n: 1.0,
    Rarity.r: 1.4,
    Rarity.sr: 2.1,
    Rarity.ssr: 3.2,
  };

  double get _peak => _amplitude[widget.best] ?? 1.0;

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
    if (t < 0.55) return AppColors.rose;
    final reveal = ((t - 0.55) / 0.3).clamp(0.0, 1.0);
    return Color.lerp(AppColors.rose, widget.best.color, reveal)!;
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
                // 鼓動に合わせて広がる光。大きいほど遠くまで届く。
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
                    painter: _EcgPainter(
                      progress: t,
                      color: color,
                      amplitude: amp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
