import 'dart:convert';

import '../data/organs.dart';
import 'daily_input.dart';
import 'organ.dart';

/// 1日を締めたときに何が起きたか。画面で結果を見せるために返す。
class DayResult {
  const DayResult({
    required this.coinsEarned,
    required this.healthDeltas,
    required this.goalAchieved,
    required this.newStepGoal,
  });

  final int coinsEarned;
  final Map<String, int> healthDeltas;
  final bool goalAchieved;

  /// 目標が変わった場合のみ値が入る。
  final int? newStepGoal;
}

class GameState {
  GameState({
    required this.coins,
    required this.organs,
    required this.stepGoal,
    required this.goalStreak,
    required this.missStreak,
    required this.dayCount,
    required this.today,
  });

  factory GameState.fresh() => GameState(
        coins: 0,
        organs: {for (final o in kOrgans) o.id: const OrganStatus()},
        stepGoal: initialStepGoal,
        goalStreak: 0,
        missStreak: 0,
        dayCount: 1,
        today: const DailyInput(),
      );

  int coins;
  Map<String, OrganStatus> organs;
  int stepGoal;
  int goalStreak;
  int missStreak;
  int dayCount;
  DailyInput today;

  // 運動習慣のない人が対象なので、最初の目標は達成できる高さから始める。
  static const int initialStepGoal = 3000;
  static const int minStepGoal = 2000;
  static const int goalStepUp = 1000;
  static const int daysToRaiseGoal = 7;
  static const int daysToLowerGoal = 3;

  OrganStatus statusOf(String id) => organs[id] ?? const OrganStatus();

  bool canLevelUp(String id) => coins >= statusOf(id).levelUpCost();

  void levelUp(String id) {
    final status = statusOf(id);
    if (coins < status.levelUpCost()) return;
    coins -= status.levelUpCost();
    organs[id] = status.leveledUp();
  }

  /// 1日を締める。入力からコインと健康度を確定し、翌日に進む。
  DayResult endDay() {
    final deltas = <String, int>{};
    for (final organ in kOrgans) {
      final delta = HealthRule.deltaFor(
        organ: organ,
        input: today,
        stepGoal: stepGoal,
      );
      deltas[organ.id] = delta;
      organs[organ.id] = statusOf(organ.id).applyHealthDelta(delta);
    }

    final earned = today.coinsEarned;
    final achieved = today.steps >= stepGoal;

    coins += earned;
    final newGoal = _updateGoal(achieved);

    dayCount++;
    today = const DailyInput();

    return DayResult(
      coinsEarned: earned,
      healthDeltas: deltas,
      goalAchieved: achieved,
      newStepGoal: newGoal,
    );
  }

  /// 続けば目標を上げ、つまずきが続けば下げる。挫折させないための調整。
  int? _updateGoal(bool achieved) {
    if (achieved) {
      goalStreak++;
      missStreak = 0;
      if (goalStreak >= daysToRaiseGoal) {
        goalStreak = 0;
        stepGoal += goalStepUp;
        return stepGoal;
      }
      return null;
    }

    missStreak++;
    goalStreak = 0;
    if (missStreak >= daysToLowerGoal && stepGoal > minStepGoal) {
      missStreak = 0;
      stepGoal = (stepGoal - goalStepUp).clamp(minStepGoal, 1 << 30);
      return stepGoal;
    }
    return null;
  }

  String encode() => json.encode({
        'coins': coins,
        'organs': organs.map((k, v) => MapEntry(k, v.toJson())),
        'stepGoal': stepGoal,
        'goalStreak': goalStreak,
        'missStreak': missStreak,
        'dayCount': dayCount,
        'today': today.toJson(),
      });

  factory GameState.decode(String source) {
    final map = json.decode(source) as Map<String, dynamic>;
    final saved = (map['organs'] as Map<String, dynamic>?) ?? {};
    return GameState(
      coins: map['coins'] as int? ?? 0,
      organs: {
        for (final o in kOrgans)
          o.id: saved[o.id] == null
              ? const OrganStatus()
              : OrganStatus.fromJson(saved[o.id] as Map<String, dynamic>),
      },
      stepGoal: map['stepGoal'] as int? ?? initialStepGoal,
      goalStreak: map['goalStreak'] as int? ?? 0,
      missStreak: map['missStreak'] as int? ?? 0,
      dayCount: map['dayCount'] as int? ?? 1,
      today: DailyInput.fromJson(
          (map['today'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}
