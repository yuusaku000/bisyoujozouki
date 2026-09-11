import '../models/daily_input.dart';
import '../models/mission.dart';

/// 選べる目標の一覧。きつい条件ほど鍵が出る。
const List<Mission> kMissions = [
  Mission(
    id: 'goal',
    label: '目標の歩数を歩く',
    detail: 'その日の目標をきっちり達成する',
    reward: MissionReward(tickets: 1),
    check: _goal,
  ),
  Mission(
    id: 'goal_half_more',
    label: '目標の1.5倍あるく',
    detail: 'いつもより少しだけ遠回りして帰る',
    reward: MissionReward(tickets: 2),
    check: _goalAndHalf,
  ),
  Mission(
    id: 'long_walk',
    label: '8000歩あるく',
    detail: '本気の日。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _longWalk,
  ),
  Mission(
    id: 'stairs',
    label: '階段を10階のぼる',
    detail: 'エレベーターを使わない',
    reward: MissionReward(tickets: 2),
    check: _stairs,
  ),
  Mission(
    id: 'stairs_hard',
    label: '階段を25階のぼる',
    detail: '脚が笑う。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _stairsHard,
  ),
  Mission(
    id: 'eat',
    label: 'ちゃんと食べる',
    detail: '腹八分目で、食事を抜かない',
    reward: MissionReward(tickets: 1),
    check: _eat,
  ),
  Mission(
    id: 'rest',
    label: '体を休める',
    detail: '飲みすぎず、無理をしない',
    reward: MissionReward(tickets: 1),
    check: _rest,
  ),
  Mission(
    id: 'sleep',
    label: 'よく眠る',
    detail: '7時間以上、夜更かしをしない',
    reward: MissionReward(tickets: 1),
    check: _sleep,
  ),
  Mission(
    id: 'all_care',
    label: '食事・休息・睡眠すべて',
    detail: '生活を全部整える。鍵が手に入る',
    reward: MissionReward(keys: 1),
    check: _allCare,
  ),
];

/// 1日に選べる数。全部は選べないので、その日の自分に合わせて決める。
const int kMissionSlots = 3;

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
bool _stairs(DailyInput input, int goal) => input.stairs >= 10;
bool _stairsHard(DailyInput input, int goal) => input.stairs >= 25;
bool _eat(DailyInput input, int goal) => input.ateWell;
bool _rest(DailyInput input, int goal) => input.rested;
bool _sleep(DailyInput input, int goal) => input.sleptWell;
bool _allCare(DailyInput input, int goal) =>
    input.ateWell && input.rested && input.sleptWell;
