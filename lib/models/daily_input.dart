import 'organ.dart';

/// その日の行動。歩数と階段はいずれ端末から取るが、今は手入力。
class DailyInput {
  const DailyInput({
    this.steps = 0,
    this.stairs = 0,
    this.ateWell = false,
    this.rested = false,
    this.sleptWell = false,
  });

  final int steps;
  final int stairs;
  final bool ateWell;
  final bool rested;
  final bool sleptWell;

  static const int stairsGoal = 5;

  // 手入力なので、人間にありえない値が入る。青天井だと経済が壊れる。
  static const int maxSteps = 100000;
  static const int maxStairs = 500;

  bool selfReportFor(HealthMetric metric) => switch (metric) {
    HealthMetric.meal => ateWell,
    HealthMetric.rest => rested,
    HealthMetric.sleep => sleptWell,
    _ => false,
  };

  DailyInput copyWith({
    int? steps,
    int? stairs,
    bool? ateWell,
    bool? rested,
    bool? sleptWell,
  }) => DailyInput(
    steps: (steps ?? this.steps).clamp(0, maxSteps),
    stairs: (stairs ?? this.stairs).clamp(0, maxStairs),
    ateWell: ateWell ?? this.ateWell,
    rested: rested ?? this.rested,
    sleptWell: sleptWell ?? this.sleptWell,
  );

  /// 何もしていない日は0。倍率は「動いた分」に掛かるだけで、
  /// それ自体はコインを生まない。歩かずに稼げると、歩く理由がなくなる。
  CoinBreakdown coinsFor(int stepGoal) => CoinBreakdown(
    fromSteps: steps,
    fromStairs: stairs * stairsCoin,
    goalBonus: steps >= stepGoal ? stepGoal ~/ goalBonusDivisor : 0,
    habits: [ateWell, rested, sleptWell].where((v) => v).length,
  );

  /// 歩数1歩につき1コイン。階段は登るのがしんどい分だけ割がいい。
  static const int stairsCoin = 50;

  /// 目標達成でもらえる分。目標が上がれば、ごほうびも上がる。
  static const int goalBonusDivisor = 4;

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'stairs': stairs,
    'ateWell': ateWell,
    'rested': rested,
    'sleptWell': sleptWell,
  };

  factory DailyInput.fromJson(Map<String, dynamic> json) => DailyInput(
    steps: (json['steps'] as int? ?? 0).clamp(0, maxSteps),
    stairs: (json['stairs'] as int? ?? 0).clamp(0, maxStairs),
    ateWell: json['ateWell'] as bool? ?? false,
    rested: json['rested'] as bool? ?? false,
    sleptWell: json['sleptWell'] as bool? ?? false,
  );
}

/// その日のコインの内訳。合計だけ出すと、何が効いたのか分からない。
class CoinBreakdown {
  const CoinBreakdown({
    required this.fromSteps,
    required this.fromStairs,
    required this.goalBonus,
    required this.habits,
  });

  final int fromSteps;
  final int fromStairs;
  final int goalBonus;

  /// たべた・休めた・寝た のうち、できた数。
  final int habits;

  /// ひとつごとに2割増し。3つ揃えば1.6倍。
  ///
  /// 歩数と違ってこの3つは自己申告で、数字にも出ない。
  /// 倍率という分かりやすい形にしないと、報告する意味を感じられない。
  static const double perHabit = 0.2;

  double get multiplier => 1 + perHabit * habits;

  int get base => fromSteps + fromStairs + goalBonus;

  int get total => (base * multiplier).round();

  /// 倍率で上乗せされた分。
  int get habitBonus => total - base;

  bool get goalAchieved => goalBonus > 0;
}

/// 健康度の増減。達成すれば伸び、サボれば落ちる。
class HealthRule {
  // 頑張った日の手応えを大きくする。伸びが小さいと、歩いた実感が
  // 数字に出ず、続ける理由が弱くなる。
  static const int achieved = 18;
  static const int partial = 6;
  static const int missed = -6;

  static int deltaFor({
    required Organ organ,
    required DailyInput input,
    required int stepGoal,
  }) {
    if (organ.metric.isSelfReported) {
      return input.selfReportFor(organ.metric) ? achieved : missed;
    }

    final (value, goal) = switch (organ.metric) {
      HealthMetric.steps => (input.steps, stepGoal),
      _ => (input.stairs, DailyInput.stairsGoal),
    };

    if (value >= goal) return achieved;
    if (value >= goal / 2) return partial;
    return missed;
  }
}
