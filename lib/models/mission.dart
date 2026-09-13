import '../data/missions.dart';
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

  bool get isEmpty => keys == 0 && tickets == 0;
}

/// その日の目標。中身はすべて運動か生活習慣にしてある。
class Mission {
  const Mission({
    required this.id,
    required this.kind,
    required this.requires,
    required this.label,
    required this.detail,
    required this.reward,
    required this.check,
  });

  final String id;

  /// あるく・のぼる・ととのえる。1日にこの3種類が1つずつ出る。
  final MissionKind kind;

  /// 判定に、どの子の記録が要るか。
  ///
  /// まだ会っていない子の項目は、記録の画面に出てこない。入力できない
  /// ことを目標に出すと、その日はどうやっても達成できない。
  final List<String> requires;

  bool isAvailable(Set<String> party) => requires.every(party.contains);

  final String label;
  final String detail;
  final MissionReward reward;

  /// 1日の記録から達成したかを判定する。
  final bool Function(DailyInput input, int stepGoal) check;

  bool isDone(DailyInput input, int stepGoal) => check(input, stepGoal);
}
