import 'daily_input.dart';

/// ミッションの報酬。コインは出さない。
///
/// コインの源は歩数だけ、という決まりを崩さないため。鍵とチケットは
/// それ自体では強さにならず、運動で得たコインと合わせてはじめて意味を持つ。
class MissionReward {
  const MissionReward({this.keys = 0, this.tickets = 0});

  final int keys;
  final int tickets;

  String get label => [
    if (keys > 0) '解放の鍵 ×$keys',
    if (tickets > 0) 'ガチャチケット ×$tickets',
  ].join('　');
}

/// その日の目標。中身はすべて運動か生活習慣にしてある。
class Mission {
  const Mission({
    required this.id,
    required this.label,
    required this.detail,
    required this.reward,
    required this.check,
  });

  final String id;
  final String label;
  final String detail;
  final MissionReward reward;

  /// 1日の記録から達成したかを判定する。
  final bool Function(DailyInput input, int stepGoal) check;

  bool isDone(DailyInput input, int stepGoal) => check(input, stepGoal);
}
