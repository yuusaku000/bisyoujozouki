import 'dart:math';

import 'package:flutter/material.dart';

import '../data/theme.dart';

/// 指標ひとつぶんの推移。
///
/// 数字だけだと、今日が良い日なのか悪い日なのかしか分からない。
/// 線にすると、上がってきているのか落ちているのかが見える。
class VitalChart extends StatelessWidget {
  const VitalChart({
    super.key,
    required this.points,
    required this.low,
    required this.high,
    required this.color,
    this.height = 66,
  });

  /// 古い順。最後が今日。
  final List<double> points;

  /// 目安の範囲。帯で敷く。
  final double low;
  final double high;

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          points: points,
          low: low,
          high: high,
          color: color,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
    required this.low,
    required this.high,
    required this.color,
  });

  final List<double> points;
  final double low;
  final double high;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // 縦の範囲。下限は必ず入れる。帯の下辺が見えないと、
    // 届いているのかどうかが読めない。
    final pmin = points.reduce(min);
    final pmax = points.reduce(max);
    var lo = min(pmin, low);
    var hi = max(pmax, low);
    if (hi - lo < 1e-6) {
      lo -= 1;
      hi += 1;
    }

    // 上限は遠すぎるなら入れない。心拍変動の「40以上」のように
    // 実質上限のない指標で入れると、線が下に潰れて読めなくなる。
    if (high - hi <= (hi - lo) * 1.2) hi = max(hi, high);

    final pad = (hi - lo) * 0.18;
    lo -= pad;
    hi += pad;

    double y(double v) => size.height * (1 - (v - lo) / (hi - lo));
    double x(int i) => points.length == 1
        ? size.width / 2
        : size.width * i / (points.length - 1);

    _grid(canvas, size);
    _band(canvas, size, y);
    _line(canvas, size, x, y);
  }

  /// 薄い横線。目盛りがないと、線が宙に浮いて見える。
  void _grid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final gy = size.height * i / 3;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), paint);
    }
  }

  /// 目安の帯。画面の外に出るぶんは切る。
  void _band(Canvas canvas, Size size, double Function(double) y) {
    final top = y(high).clamp(0.0, size.height);
    final bottom = y(low).clamp(0.0, size.height);
    if ((top - bottom).abs() < 0.5) return;

    canvas.drawRect(
      Rect.fromLTRB(0, min(top, bottom), size.width, max(top, bottom)),
      Paint()..color = AppColors.genki.withValues(alpha: 0.10),
    );
  }

  void _line(
    Canvas canvas,
    Size size,
    double Function(int) x,
    double Function(double) y,
  ) {
    final spots = [
      for (var i = 0; i < points.length; i++) Offset(x(i), y(points[i])),
    ];

    if (spots.length > 1) {
      final path = Path()..moveTo(spots.first.dx, spots.first.dy);
      for (final spot in spots.skip(1)) {
        path.lineTo(spot.dx, spot.dy);
      }

      // 線の下を薄く塗る。折れ線だけより、量として読める。
      final fill = Path.from(path)
        ..lineTo(spots.last.dx, size.height)
        ..lineTo(spots.first.dx, size.height)
        ..close();
      canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.14));

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    for (final spot in spots.take(spots.length - 1)) {
      canvas.drawCircle(spot, 2, Paint()..color = color.withValues(alpha: 0.6));
    }

    // 今日だけ大きく。どれが最新かが分かるように。
    final last = spots.last;
    canvas.drawCircle(last, 5.5, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(last, 3.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.points != points || old.color != color;
}
