import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/organ.dart';

Color conditionColor(Condition condition) => switch (condition) {
      Condition.genki => AppColors.genki,
      Condition.futsuu => AppColors.futsuu,
      Condition.fuchou => AppColors.fuchou,
    };

class HealthBar extends StatelessWidget {
  const HealthBar({super.key, required this.status});

  final OrganStatus status;

  @override
  Widget build(BuildContext context) {
    final color = conditionColor(status.condition);
    // 下限20より下には落ちないので、バーもその範囲で目盛りを取る。
    final span = OrganStatus.maxHealth - OrganStatus.minHealth;
    final ratio = (status.health - OrganStatus.minHealth) / span;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('健康度',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted, letterSpacing: 1.2)),
            const SizedBox(width: 8),
            Text('${status.health}',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status.condition.label,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.panelAlt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
