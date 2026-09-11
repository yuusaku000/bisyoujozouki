import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/organ.dart';

/// 限界を解いた瞬間。天井が割れて、その先が見える。
///
/// 親密度の演出はローズのハートで「近づいた」を出している。
/// こちらは金の輪が砕ける形にして、別の出来事だと一目で分かるようにした。
class AscendOverlay extends StatefulWidget {
  const AscendOverlay({
    super.key,
    required this.organ,
    required this.levelCap,
    required this.line,
  });

  final Organ organ;

  /// 解いたあとの上限。
  final int levelCap;

  final String line;

  @override
  State<AscendOverlay> createState() => _AscendOverlayState();
}

class _AscendOverlayState extends State<AscendOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  final _random = Random();
  late final List<double> _seeds = [
    for (var i = 0; i < 18; i++) _random.nextDouble(),
  ];

  int get _previousCap => widget.levelCap - OrganStatus.capStep;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

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
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // 割れた瞬間だけ強く光る。ずっと明るいと、どこが山か分からない。
                final flash =
                    (1 - ((_controller.value - 0.14).abs() / 0.22)).clamp(
                      0.0,
                      1.0,
                    ) *
                    0.5;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.0,
                      colors: [
                        AppColors.gold.withValues(alpha: 0.22 + flash),
                        const Color(0xF00E0710),
                      ],
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.72,
                child: Image.asset(
                  widget.organ.imagePath(Condition.genki),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _Shatter(
                  progress: _controller.value,
                  seeds: _seeds,
                  color: AppColors.gold,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 26),
                  _title(),
                  const SizedBox(height: 20),
                  _capRow(),
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
        '限界突破',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 6,
          color: AppColors.gold,
          shadows: [Shadow(color: AppColors.gold, blurRadius: 22)],
        ),
      ),
    );
  }

  /// どこまで行けるようになったのかを、前の天井と並べて出す。
  /// 数字がひとつ増えただけに見えると、鍵を使った手応えが残らない。
  Widget _capRow() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final revealed = t > 0.2;
        final pop = revealed
            ? 1 + 0.5 * (1 - ((t - 0.2) * 3.2).clamp(0.0, 1.0))
            : 0.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lv.$_previousCap',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted.withValues(alpha: 0.7),
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.goldDim.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 12),
            Transform.scale(
              scale: pop,
              child: Text(
                'Lv.${widget.levelCap}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                  shadows: [Shadow(color: AppColors.gold, blurRadius: 18)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _linePanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.65),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: AppColors.panelGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gold, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 24,
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
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'タップでとじる',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 閉じていた輪が割れ、破片が外へ飛ぶ。
class _Shatter extends CustomPainter {
  _Shatter({required this.progress, required this.seeds, required this.color});

  final double progress;
  final List<double> seeds;
  final Color color;

  /// 割れる瞬間。ここまでは輪を閉じたまま見せて、ためを作る。
  static const double _break = 0.14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);

    if (progress < _break) {
      // 割れる前。輪が縮みながら光を溜める。
      final t = progress / _break;
      canvas.drawCircle(
        center,
        96 - 16 * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 + 3 * t
          ..color = color.withValues(alpha: 0.35 + 0.6 * t),
      );
      return;
    }

    _rings(canvas, center);
    _shards(canvas, center);
  }

  /// 衝撃波。時間差で2本出すと、一度きりの破裂に厚みが出る。
  void _rings(Canvas canvas, Offset center) {
    for (var i = 0; i < 2; i++) {
      final t = ((progress - _break - i * 0.09) / 0.5).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final r = 80 + 190 * Curves.easeOutCubic.transform(t);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * (1 - t)
          ..color = color.withValues(alpha: 0.75 * (1 - t)),
      );
    }
  }

  void _shards(Canvas canvas, Offset center) {
    final t = ((progress - _break) / 0.7).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(t);

    for (var i = 0; i < seeds.length; i++) {
      final seed = seeds[i];
      final angle = i / seeds.length * 2 * pi + seed * 0.4;
      final dist = (90 + 250 * eased) * (0.65 + seed * 0.7);
      final at = center + Offset(cos(angle), sin(angle)) * dist;
      final len = 14 + seed * 16;

      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(angle + eased * (1.5 + seed * 3));
      canvas.drawPath(
        Path()
          ..moveTo(0, -len / 2)
          ..lineTo(len * 0.24, 0)
          ..lineTo(0, len / 2)
          ..lineTo(-len * 0.24, 0)
          ..close(),
        Paint()..color = color.withValues(alpha: (1 - t) * 0.95),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Shatter old) => old.progress != progress;
}
