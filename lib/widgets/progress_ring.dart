import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';

/// どこまで進んだかの輪。
///
/// 「9 / 20」と書くより、埋まり具合のほうが先に目に入る。
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.ratio,
    this.size = 34,
    this.thickness = 3,
    this.color = AppColors.gold,
    this.child,
  });

  final double ratio;
  final double size;
  final double thickness;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          ratio: ratio.clamp(0.0, 1.0),
          thickness: thickness,
          color: color,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.ratio,
    required this.thickness,
    required this.color,
  });

  final double ratio;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(thickness / 2 + 1);

    canvas.drawArc(
      inset,
      0,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = color.withValues(alpha: 0.18),
    );

    if (ratio <= 0) return;

    canvas.drawArc(
      inset,
      -pi / 2,
      2 * pi * ratio,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [color.withValues(alpha: 0.55), color],
        ).createShader(inset),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.color != color;
}
