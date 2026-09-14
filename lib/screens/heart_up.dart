import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/organ.dart';

/// ハートがひとつ増えた瞬間。数字がひとつ動いただけで終わらせない。
class HeartUpOverlay extends StatefulWidget {
  const HeartUpOverlay({
    super.key,
    required this.organ,
    required this.hearts,
    required this.line,
  });

  final Organ organ;
  final int hearts;
  final String line;

  @override
  State<HeartUpOverlay> createState() => _HeartUpOverlayState();
}

class _HeartUpOverlayState extends State<HeartUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  final _random = Random();
  late final List<double> _seeds = [
    for (var i = 0; i < 14; i++) _random.nextDouble(),
  ];

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  /// 演出が終わったか。終わるまでは閉じさせない。
  ///
  /// 一度きりの場面なので、触った拍子に飛ばしてしまうと戻せない。
  bool get _done => _controller.status == AnimationStatus.completed;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          if (_done) Navigator.pop(context);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.0,
                  colors: [
                    widget.organ.accent.withValues(alpha: 0.4),
                    const Color(0xF00E0710),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _HeartRain(
                  progress: _controller.value,
                  seeds: _seeds,
                  color: AppColors.rose,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.74,
                child: Image.asset(
                  widget.organ.imagePath(Condition.genki),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _title(),
                  const SizedBox(height: 18),
                  _heartRow(),
                  const Spacer(),
                  _linePanel(),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return ScaleTransition(
      scale: Tween(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: const Text(
        '親密度が上がった',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: AppColors.rose,
          shadows: [Shadow(color: AppColors.rose, blurRadius: 20)],
        ),
      ),
    );
  }

  /// 増えた1つだけ遅れて光る。どれが増えたのかが分かる。
  Widget _heartRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < OrganStatus.maxHearts; i++)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final isNew = i == widget.hearts - 1;
              final filled = i < widget.hearts;
              final t = _controller.value;
              final pop = isNew
                  ? 1 + 0.55 * (1 - (t * 2.2).clamp(0.0, 1.0))
                  : 1.0;
              final show = !isNew || t > 0.18;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: pop,
                  child: Icon(
                    filled && show ? Icons.favorite : Icons.favorite_border,
                    size: isNew ? 34 : 28,
                    color: filled && show
                        ? AppColors.rose
                        : AppColors.textMuted.withValues(alpha: 0.5),
                    shadows: isNew && show
                        ? const [Shadow(color: AppColors.rose, blurRadius: 18)]
                        : null,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _linePanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.25, 0.6),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: AppColors.panelGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.organ.accent, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: widget.organ.accent.withValues(alpha: 0.45),
                blurRadius: 22,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.organ.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: widget.organ.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.line,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 10),
              // 閉じられるようになってから出す。先に出ていると、
              // 押しても閉じないあいだ、壊れているように見える。
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => AnimatedOpacity(
                    opacity: _done ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: const Text(
                      'タップでとじる',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartRain extends CustomPainter {
  _HeartRain({
    required this.progress,
    required this.seeds,
    required this.color,
  });

  final double progress;
  final List<double> seeds;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      // 残りの時間を全部使って上がる。決め打ちの長さにすると、
      // 遅く出たものが上がりきる前に演出が終わってしまう。
      final delay = seed * 0.4;
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = size.width * (0.08 + seed * 0.84);
      final y = size.height * (0.85 - t * 0.8);
      final fade = (1 - t) * 0.85;
      final scale = 0.6 + seed * 0.8;

      final paint = Paint()..color = color.withValues(alpha: fade);
      _drawHeart(canvas, Offset(x, y), 9 * scale, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + r * 0.8)
      ..cubicTo(
        center.dx - r * 1.6,
        center.dy - r * 0.4,
        center.dx - r * 0.5,
        center.dy - r * 1.4,
        center.dx,
        center.dy - r * 0.4,
      )
      ..cubicTo(
        center.dx + r * 0.5,
        center.dy - r * 1.4,
        center.dx + r * 1.6,
        center.dy - r * 0.4,
        center.dx,
        center.dy + r * 0.8,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartRain old) => old.progress != progress;
}
