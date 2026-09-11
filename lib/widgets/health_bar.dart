import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/organ.dart';
import 'ornate.dart';

Color conditionColor(Condition condition) => switch (condition) {
      Condition.genki => AppColors.genki,
      Condition.futsuu => AppColors.futsuu,
      Condition.fuchou => AppColors.fuchou,
    };

Gradient conditionGradient(Condition condition) {
  final c = conditionColor(condition);
  return LinearGradient(
    colors: [Color.lerp(c, Colors.white, 0.35)!, c],
  );
}

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
            const Text(
              '健康度',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${status.health}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.55)),
              ),
              child: Text(
                status.condition.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        JewelBar(
          value: ratio,
          gradient: conditionGradient(status.condition),
        ),
      ],
    );
  }
}
