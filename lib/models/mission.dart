import '../data/missions.dart';
import 'daily_input.dart';

/// 目標を達成したときの取り分。
///
/// コインを出しても、強さの源が運動だけ、という決まりは崩れない。
/// 目標の中身が歩数・階段・生活の3つしかないので、達成すること自体が
/// 体を動かした証明になっている。
class MissionReward {
  const MissionReward({this.coins = 0, this.keys = 0, this.tickets = 0});

  final int coins;
  final int keys;
  final int tickets;

  String get label => [
    if (coins > 0) 'コイン ${_comma(coins)}',
    if (keys > 0) '解放の鍵 ×$keys',
    if (tickets > 0) 'ガチャチケット ×$tickets',
  ].join('　');

  bool get isEmpty => coins == 0 && keys == 0 && tickets == 0;

  static String _comma(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
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
