import 'package:flutter/material.dart';

import '../data/advice.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../models/vitals.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
import '../widgets/vital_chart.dart';
import '../widgets/today_clock.dart';

/// きょうの計測値と、本人からの一言。
///
/// ホームには代表値しか出ない。数字の意味と、明日なにをすればいいのかは
/// ここでまとめて見せる。
class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'からだの記録',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Center(
            child: TodayClock(
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final organ in state.party) ...[
            _card(organ, state.statusOf(organ.id)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  /// 指標ごとの推移。記録した健康度を、その日の日付で引き直す。
  ///
  /// 記録が足りないうちは、いちばん古い値で前を埋める。
  /// 点がひとつでは線にならず、グラフの意味がない。
  List<List<double>> _series(Organ organ, OrganStatus status, int count) {
    // 記録は1日を締めた時点の値。いまの健康度はその最後の1件と同じなので、
    // 足すと末尾が重なり、増減が出ないか、ぶれの差だけの嘘の増減になる。
    final recorded = state.healthLog[organ.id];
    final log = (recorded == null || recorded.isEmpty)
        ? [status.health]
        : [...recorded];
    final filled = [
      for (var i = 0; i < count - log.length; i++) log.first,
      ...log.length > count ? log.sublist(log.length - count) : log,
    ];

    final today = state.dayCount;
    final rows = [
      for (var i = 0; i < filled.length; i++)
        kVitals.readAt(organ, filled[i], today - (filled.length - 1 - i)),
    ];

    return [
      for (var m = 0; m < rows.first.length; m++)
        [for (final row in rows) row[m].raw],
    ];
  }

  Widget _card(Organ organ, OrganStatus status) {
    final vitals = kVitals.read(organ, status, state.dayCount);
    final series = _series(organ, status, _spanDays);

    return OrnatePanel(
      borderColor: organ.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: organ.accent, width: 1.6),
                ),
                child: ClipOval(
                  child: Image.asset(
                    organ.facePath(status.condition),
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                organ.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: organ.accent,
                ),
              ),
              const Spacer(),
              _conditionChip(status.condition),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < vitals.length; i++) ...[
            _vitalRow(vitals[i], series[i]),
            VitalChart(
              points: series[i],
              low: vitals[i].low,
              high: vitals[i].high,
              color: organ.accent,
            ),
            const SizedBox(height: 4),
            _axis(),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 2),
          _adviceBox(organ, status),
        ],
      ),
    );
  }

  Widget _conditionChip(Condition condition) {
    final color = conditionColor(condition);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        condition.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  static const int _spanDays = 7;

  /// 昨日からどれだけ動いたか。上がったか下がったかだけ分かればいい。
  Widget _delta(List<double> points, bool moreIsBetter) {
    if (points.length < 2) return const SizedBox.shrink();

    final diff = points.last - points[points.length - 2];
    if (diff.abs() < 0.05) {
      return const Text(
        '±0',
        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
      );
    }

    final up = diff > 0;
    final good = up == moreIsBetter;
    final text =
        '${up ? '+' : ''}${diff.abs() < 10 ? diff.toStringAsFixed(1) : diff.round()}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 16,
          color: good ? AppColors.genki : AppColors.fuchou,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: good ? AppColors.genki : AppColors.fuchou,
          ),
        ),
      ],
    );
  }

  Widget _axis() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$_spanDays日前',
          style: TextStyle(fontSize: 9, color: AppColors.textMuted),
        ),
        Text('きょう', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _vitalRow(Vital vital, List<double> points) {
    final color = vital.inRange ? AppColors.genki : AppColors.fuchou;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vital.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '目安 ${vital.normal}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _delta(points, vital.higherIsBetter),
                ],
              ),
            ],
          ),
        ),
        Text(
          vital.value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.1,
          ),
        ),
        if (vital.unit.isNotEmpty) ...[
          const SizedBox(width: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              vital.unit,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _adviceBox(Organ organ, OrganStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: organ.accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        adviceFor(organ.id, status.condition),
        style: const TextStyle(fontSize: 13, height: 1.6),
      ),
    );
  }
}
