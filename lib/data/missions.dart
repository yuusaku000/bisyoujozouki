import '../models/daily_input.dart';
import '../models/mission.dart';

/// 目標の種類。1日にひとつずつ、ここから選ばれる。
///
/// 無作為に3つ引くと、歩く目標ばかりの日と、生活の目標ばかりの日ができる。
/// 種類ごとに1つと決めておけば、どの日も「あるく・のぼる・ととのえる」が
/// 1つずつ並ぶ。体を動かす日と、休む日に偏らない。
enum MissionKind {
  walk('あるく'),
  climb('のぼる'),
  care('ととのえる');

  const MissionKind(this.label);

  final String label;
}

/// 目標の一覧。きつい条件ほど鍵が出る。
///
/// 種類ごとに、やさしい順に並べてある。
const List<Mission> kMissions = [
  // ── あるく ──
  Mission(
    id: 'goal',
    requires: ['heart'],
    kind: MissionKind.walk,
    label: '目標の歩数を歩く',
    detail: 'その日の目標をきっちり達成する',
    reward: MissionReward(tickets: 1),
    check: _goal,
  ),
  Mission(
    id: 'goal_half_more',
    requires: ['heart'],
    kind: MissionKind.walk,
    label: '目標の1.5倍あるく',
    detail: 'いつもより少しだけ遠回りして帰る',
    reward: MissionReward(tickets: 2),
    check: _goalAndHalf,
  ),
  Mission(
    id: 'long_walk',
    requires: ['heart'],
    kind: MissionKind.walk,
    label: '8000歩あるく',
    detail: '本気の日。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _longWalk,
  ),

  // ── のぼる ──
  Mission(
    id: 'stairs_light',
    requires: ['lung'],
    kind: MissionKind.climb,
    label: '階段を5階のぼる',
    detail: '一駅ぶんの階段くらい',
    reward: MissionReward(tickets: 1),
    check: _stairsLight,
  ),
  Mission(
    id: 'stairs',
    requires: ['lung'],
    kind: MissionKind.climb,
    label: '階段を10階のぼる',
    detail: 'エレベーターを使わない',
    reward: MissionReward(tickets: 2),
    check: _stairs,
  ),
  Mission(
    id: 'stairs_hard',
    requires: ['lung'],
    kind: MissionKind.climb,
    label: '階段を25階のぼる',
    detail: '脚が笑う。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _stairsHard,
  ),

  // ── ととのえる ──
  Mission(
    id: 'eat',
    requires: ['stomach'],
    kind: MissionKind.care,
    label: 'ちゃんと食べる',
    detail: '腹八分目で、食事を抜かない',
    reward: MissionReward(tickets: 1),
    check: _eat,
  ),
  Mission(
    id: 'rest',
    requires: ['liver'],
    kind: MissionKind.care,
    label: '体を休める',
    detail: '飲みすぎず、無理をしない',
    reward: MissionReward(tickets: 1),
    check: _rest,
  ),
  Mission(
    id: 'sleep',
    requires: ['brain'],
    kind: MissionKind.care,
    label: 'よく眠る',
    detail: '7時間以上、夜更かしをしない',
    reward: MissionReward(tickets: 1),
    check: _sleep,
  ),
  Mission(
    id: 'all_care',
    requires: ['stomach', 'liver', 'brain'],
    kind: MissionKind.care,
    label: '食事・休息・睡眠すべて',
    detail: '生活を全部整える。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _allCare,
  ),
];

/// 1日に出る数。種類ごとに1つなので、種類の数と同じになる。
const int kMissionSlots = 3;

/// 3つとも達成した日だけの上乗せ。
///
/// ひとつずつの報酬を足すだけだと、できそうな目標だけ拾って終わりになる。
/// 揃えたときにだけ鍵が出るようにして、「今日は3つとも」を狙わせる。
const MissionReward kAllMissionsBonus = MissionReward(keys: 1, tickets: 2);

/// その日の3つ。
///
/// 選ばせるのをやめたのは、選べると「今日できそうなもの」だけを選べて
/// しまうから。決まっていれば、その日にやることが迷わず決まる。
///
/// [day] と仲間の顔ぶれだけで決まるので、同じ日に何度開いても同じ3つが出る。
/// まだ会っていない子の項目は記録できないので、その種類はこの日は出ない。
List<Mission> missionsForDay(int day, Set<String> party) {
  final out = <Mission>[];
  for (final kind in MissionKind.values) {
    final pool = [
      for (final m in kMissions)
        if (m.kind == kind && m.isAvailable(party)) m,
    ];
    if (pool.isEmpty) continue;

    // 種類ごとに違う速さで送る。同じ速さだと3つが毎日いっせいに
    // 入れ替わって、組み合わせが数日ぶんしか現れない。
    final step = kind.index + 1;
    out.add(pool[(day * step + kind.index).abs() % pool.length]);
  }
  return out;
}

Mission? missionById(String id) {
  for (final m in kMissions) {
    if (m.id == id) return m;
  }
  return null;
}

bool _goal(DailyInput input, int goal) => input.steps >= goal;
bool _goalAndHalf(DailyInput input, int goal) =>
    input.steps >= (goal * 1.5).round();
bool _longWalk(DailyInput input, int goal) => input.steps >= 8000;
bool _stairsLight(DailyInput input, int goal) => input.stairs >= 5;
bool _stairs(DailyInput input, int goal) => input.stairs >= 10;
bool _stairsHard(DailyInput input, int goal) => input.stairs >= 25;
bool _eat(DailyInput input, int goal) => input.ateWell;
bool _rest(DailyInput input, int goal) => input.rested;
bool _sleep(DailyInput input, int goal) => input.sleptWell;
bool _allCare(DailyInput input, int goal) =>
    input.ateWell && input.rested && input.sleptWell;
