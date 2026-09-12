import 'package:flutter/material.dart';

import '../data/advice.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../models/vitals.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
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

  Widget _card(Organ organ, OrganStatus status) {
    final vitals = kVitals.read(organ, status, state.dayCount);

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
          for (final vital in vitals) ...[
            _vitalRow(vital),
            const SizedBox(height: 10),
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

  Widget _vitalRow(Vital vital) {
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
              Text(
                '目安 ${vital.normal}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                ),
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
