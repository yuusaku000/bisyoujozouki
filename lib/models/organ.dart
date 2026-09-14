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
      this == HealthMetric.meal ||
      this == HealthMetric.rest ||
      this == HealthMetric.sleep;
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
    required this.unlockStage,
  });

  final String id;
  final String name;
  final HealthMetric metric;
  final String role;
  final Color accent;

  /// この番号の話を読むと仲間になる。0なら最初からいる。
  /// クリアではなく「読んだか」で決まる。出会う場面を飛ばして
  /// 仲間が増えても、その子が誰なのか分からないままになる。
  final int unlockStage;

  bool isUnlocked(Set<String> readEpisodes) =>
      unlockStage == 0 || readEpisodes.contains('main:$unlockStage');

  String imagePath(Condition condition) =>
      'assets/organs/$id/${id}_${condition.name}.png';

  /// 立ち絵から顔だけを切り出したもの。バトルなど狭い場所で使う。
  String facePath(Condition condition) =>
      'assets/organs/$id/${id}_${condition.name}_face.png';
}

/// 臓器の現在の状態。健康度は日々動き、レベルは上げたら下がらない。
class OrganStatus {
  const OrganStatus({
    this.health = initialHealth,
    this.level = 1,
    this.ascensions = 0,
    this.affection = 0,
  });

  final int health;
  final int level;

  /// 限界を解いた回数。上限は10ごとに壁がある。
  final int ascensions;

  static const int capStep = 10;

  /// いまのレベル上限。壁を越えるには鍵がいる。
  int get levelCap => capStep * (ascensions + 1);

  bool get atCap => level >= levelCap;

  /// 次の壁を越えるのに必要な鍵の数。先へ行くほど重くなる。
  int get keysToAscend => ascensions + 1;

  /// プレゼントで貯まる。運動では上がらない。
  final int affection;

  /// 物語が開ききるハートの数。ここまでで話は全部読める。
  ///
  /// 上限ではない。この先は ♡5+1、♡5+2 と足されていく。
  static const int maxHearts = 5;

  /// ハート1つぶんに必要な累計。先へ行くほど遠くなる。
  static const List<int> heartThresholds = [0, 40, 110, 230, 420, 700];

  /// ♡5から先、ひとつ上がるのに要る量。
  ///
  /// 表のきざみは 40・70・120・190・280 と、増え方が 20 ずつ大きくなる。
  /// その伸び方をそのまま延ばす。
  static int _gapAfter(int heart) => 280 + 110 * (heart - 4);

  /// そのハート数に届くのに要る累計。表の外も計算で出す。
  static int thresholdFor(int heart) {
    if (heart <= 0) return 0;
    if (heart < heartThresholds.length) return heartThresholds[heart];

    var total = heartThresholds.last;
    for (var h = heartThresholds.length - 1; h < heart; h++) {
      total += _gapAfter(h);
    }
    return total;
  }

  /// ♡の数。5で止まらない。
  int get hearts {
    var count = 0;
    while (affection >= thresholdFor(count + 1)) {
      count++;
    }
    return count;
  }

  /// 物語を開ききったか。ハートの上限ではない。
  bool get storyDone => hearts >= maxHearts;

  /// ♡5から先の上乗せぶん。0なら上乗せ無し。
  int get extraHearts => hearts <= maxHearts ? 0 : hearts - maxHearts;

  /// 画面に出す形。♡5までは数だけ、その先は「5+2」と足して見せる。
  String get heartLabel =>
      extraHearts == 0 ? '$hearts' : '$maxHearts+$extraHearts';

  /// いまのハートの中での進み具合。
  double get heartProgress {
    final from = thresholdFor(hearts);
    final to = thresholdFor(hearts + 1);
    return ((affection - from) / (to - from)).clamp(0.0, 1.0);
  }

  int get affectionToNextHeart => thresholdFor(hearts + 1) - affection;

  /// 小数まで入れたハートの段。順位を出すのに使う。
  ///
  /// 貯まった値そのもので順位を出すと、先へ行くほど1段が重いせいで、
  /// ♡1から♡5までがひとかたまりに潰れてしまう。
  double get heartLevel => hearts + heartProgress;

  OrganStatus gifted(int points) => OrganStatus(
    health: health,
    level: level,
    ascensions: ascensions,
    affection: affection + points,
  );

  static const int initialHealth = 80;
  static const int minHealth = 20;
  static const int maxHealth = 100;

  Condition get condition => switch (health) {
    >= 75 => Condition.genki,
    >= 45 => Condition.futsuu,
    _ => Condition.fuchou,
  };

  /// 戦闘力。運動で決まる健康度が主で、レベルはそれを底上げする。
  int power(int base) =>
      (base * (health / 100) * (1 + (level - 1) * 0.1)).round();

  int levelUpCost() => 500 * level;

  OrganStatus applyHealthDelta(int delta) => OrganStatus(
    health: (health + delta).clamp(minHealth, maxHealth),
    level: level,
    ascensions: ascensions,
    affection: affection,
  );

  OrganStatus leveledUp() => OrganStatus(
    health: health,
    level: level + 1,
    ascensions: ascensions,
    affection: affection,
  );

  OrganStatus ascended() => OrganStatus(
    health: health,
    level: level,
    ascensions: ascensions + 1,
    affection: affection,
  );

  Map<String, dynamic> toJson() => {
    'health': health,
    'level': level,
    'ascensions': ascensions,
    'affection': affection,
  };

  factory OrganStatus.fromJson(Map<String, dynamic> json) => OrganStatus(
    health: json['health'] as int? ?? initialHealth,
    level: json['level'] as int? ?? 1,
    ascensions: json['ascensions'] as int? ?? 0,
    affection: json['affection'] as int? ?? 0,
  );
}
