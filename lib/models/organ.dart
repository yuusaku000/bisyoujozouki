import 'package:flutter/material.dart';

/// 臓器の健康度を決める指標。何を測るかが臓器ごとに違う。
enum HealthMetric {
  steps('歩数'),
  stairs('階段'),
  meal('食事'),
  rest('休息'),
  sleep('睡眠');

  const HealthMetric(this.label);
  final String label;

  /// 歩数と階段は量で測れるが、食事・休息・睡眠は本人の申告しかない。
  bool get isSelfReported =>
      this == HealthMetric.meal || this == HealthMetric.rest || this == HealthMetric.sleep;
}

enum Condition {
  genki('元気'),
  futsuu('ふつう'),
  fuchou('不調');

  const Condition(this.label);
  final String label;
}

/// 臓器そのものの定義。プレイ中に変化しない。
class Organ {
  const Organ({
    required this.id,
    required this.name,
    required this.metric,
    required this.role,
    required this.accent,
  });

  final String id;
  final String name;
  final HealthMetric metric;
  final String role;
  final Color accent;

  String imagePath(Condition condition) =>
      'assets/organs/$id/${id}_${condition.name}.png';

  /// 立ち絵から顔だけを切り出したもの。バトルなど狭い場所で使う。
  String facePath(Condition condition) =>
      'assets/organs/$id/${id}_${condition.name}_face.png';
}

/// 臓器の現在の状態。健康度は日々動き、レベルは上げたら下がらない。
class OrganStatus {
  const OrganStatus({this.health = initialHealth, this.level = 1});

  final int health;
  final int level;

  static const int initialHealth = 50;
  static const int minHealth = 20;
  static const int maxHealth = 100;

  Condition get condition => switch (health) {
        >= 75 => Condition.genki,
        >= 45 => Condition.futsuu,
        _ => Condition.fuchou,
      };

  /// 戦闘力。運動で決まる健康度が主で、レベルはそれを底上げする。
  int power(int base) => (base * (health / 100) * (1 + (level - 1) * 0.1)).round();

  int levelUpCost() => 500 * level;

  OrganStatus applyHealthDelta(int delta) => OrganStatus(
        health: (health + delta).clamp(minHealth, maxHealth),
        level: level,
      );

  OrganStatus leveledUp() => OrganStatus(health: health, level: level + 1);

  Map<String, dynamic> toJson() => {'health': health, 'level': level};

  factory OrganStatus.fromJson(Map<String, dynamic> json) => OrganStatus(
        health: json['health'] as int? ?? initialHealth,
        level: json['level'] as int? ?? 1,
      );
}
