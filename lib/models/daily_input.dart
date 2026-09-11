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
  }) =>
      DailyInput(
        steps: (steps ?? this.steps).clamp(0, maxSteps),
        stairs: (stairs ?? this.stairs).clamp(0, maxStairs),
        ateWell: ateWell ?? this.ateWell,
        rested: rested ?? this.rested,
        sleptWell: sleptWell ?? this.sleptWell,
      );

  /// 歩数1歩につき1コイン。階段は登るのがしんどい分だけ割がいい。
  int get coinsEarned => steps + stairs * 50;

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

/// 健康度の増減。達成すれば伸び、サボれば落ちる。
class HealthRule {
  static const int achieved = 10;
  static const int partial = 3;
  static const int missed = -5;

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
