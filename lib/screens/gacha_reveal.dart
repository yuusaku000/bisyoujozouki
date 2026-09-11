import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/present.dart';

/// 結果を出す前の間。心電図が脈打ち、当たりほど速く明るくなる。
///
/// 体の中の話なので、演出も体の中のもので揃えている。
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
    duration: const Duration(milliseconds: 2200),
  );

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

  /// 終盤までは当たりを隠す。最初から金色だと引く意味がない。
  Color _colorAt(double t) {
    if (t < 0.62) return AppColors.rose;
    final reveal = ((t - 0.62) / 0.2).clamp(0.0, 1.0);
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
          final color = _colorAt(t);
          // 終盤ほど鼓動が速くなる
          final beat = 1 + 5 * t;
          final pulse = 1 + 0.12 * sin(t * beat * 2 * pi).abs();

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: pulse,
                  child: Icon(
                    Icons.favorite,
                    size: 92,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _EcgPainter(progress: t, color: color),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  opacity: t > 0.62 ? 1 : 0,
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    widget.best.label,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: widget.best.color,
                      shadows: [
                        Shadow(color: widget.best.color, blurRadius: 22),
                      ],
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
  _EcgPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mid = size.height / 2;
    final path = Path()..moveTo(0, mid);
    final drawn = size.width * progress;

    // 一定間隔で山を描く。間は平らな線。
    const spacing = 78.0;
    var x = 0.0;
    while (x < drawn) {
      final next = min(x + spacing, drawn);
      final peak = x + spacing * 0.5;
      if (peak < drawn) {
        path.lineTo(peak - 12, mid);
        path.lineTo(peak - 6, mid + 10);
        path.lineTo(peak, mid - 22);
        path.lineTo(peak + 6, mid + 14);
        path.lineTo(peak + 12, mid);
      }
      path.lineTo(next, mid);
      x = next;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EcgPainter old) =>
      old.progress != progress || old.color != color;
}
