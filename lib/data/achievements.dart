import 'dart:math';

import '../models/game_state.dart';
import '../models/mission.dart';
import '../models/organ.dart';
import 'chara_story.dart';
import 'organs.dart';
import 'story.dart';

/// まとまり。並べるときの見出しに使う。
enum AchieveGroup {
  walk('あるく'),
  grow('そだてる'),
  fight('たたかう'),
  bond('分かりあう'),
  read('よむ');

  const AchieveGroup(this.label);
  final String label;
}

/// 達成の記録。
///
/// 報酬はミッションと同じく鍵とチケットだけ。コインの源は歩数だけ、
/// という決まりを崩さない。
class Achievement {
  const Achievement({
    required this.id,
    required this.group,
    required this.title,
    required this.detail,
    required this.target,
    required this.progress,
    required this.reward,
  });

  final String id;
  final AchieveGroup group;
  final String title;
  final String detail;

  /// 達成に必要な数。
  final int target;

  /// いまの数。target に届けば達成。
  final int Function(GameState state) progress;

  final MissionReward reward;

  bool isDone(GameState state) => progress(state) >= target;

  /// 0.0〜1.0。棒の長さに使う。
  double ratio(GameState state) =>
      (progress(state) / target).clamp(0.0, 1.0).toDouble();
}

int _maxLevel(GameState state) =>
    kOrgans.map((o) => state.levelOf(o.id)).fold(0, (a, b) => a > b ? a : b);

int _maxHearts(GameState state) =>
    kOrgans.map((o) => state.heartsOf(o.id)).fold(0, (a, b) => a > b ? a : b);

int _maxAscensions(GameState state) => kOrgans
    .map((o) => state.statusOf(o.id).ascensions)
    .fold(0, (a, b) => a > b ? a : b);

int _mainRead(GameState state) =>
    kStory.where((e) => state.readEpisodes.contains(e.key)).length;

int _charaRead(GameState state) =>
    kCharaStory.where((e) => state.readEpisodes.contains(e.key)).length;

const List<Achievement> kAchievements = [
  // ── あるく ──
  Achievement(
    id: 'first_day',
    group: AchieveGroup.walk,
    title: 'はじめの一歩',
    detail: '1日ぶんを記録する',
    target: 1,
    progress: _daysRecorded,
    reward: MissionReward(tickets: 1),
  ),
  Achievement(
    id: 'days_7',
    group: AchieveGroup.walk,
    title: '一週間',
    detail: '7日つづける',
    target: 7,
    progress: _daysRecorded,
    reward: MissionReward(keys: 1),
  ),
  Achievement(
    id: 'days_30',
    group: AchieveGroup.walk,
    title: 'ひと月',
    detail: '30日つづける',
    target: 30,
    progress: _daysRecorded,
    reward: MissionReward(keys: 2, tickets: 5),
  ),
  Achievement(
    id: 'days_100',
    group: AchieveGroup.walk,
    title: '百日',
    detail: '100日つづける',
    target: 100,
    progress: _daysRecorded,
    reward: MissionReward(keys: 3, tickets: 10),
  ),
  Achievement(
    id: 'steps_100k',
    group: AchieveGroup.walk,
    title: '十万歩',
    detail: '合わせて100,000歩あるく',
    target: 100000,
    progress: _totalSteps,
    reward: MissionReward(tickets: 3),
  ),
  Achievement(
    id: 'steps_1m',
    group: AchieveGroup.walk,
    title: '百万歩',
    detail: '合わせて1,000,000歩あるく',
    target: 1000000,
    progress: _totalSteps,
    reward: MissionReward(keys: 3, tickets: 10),
  ),

  // ── そだてる ──
  Achievement(
    id: 'level_2',
    group: AchieveGroup.grow,
    title: 'はじめてのレベルアップ',
    detail: '誰かをLv.2にする',
    target: 2,
    progress: _maxLevel,
    reward: MissionReward(tickets: 1),
  ),
  Achievement(
    id: 'level_10',
    group: AchieveGroup.grow,
    title: '天井に触れる',
    detail: '誰かをLv.10にする',
    target: 10,
    progress: _maxLevel,
    reward: MissionReward(tickets: 2),
  ),
  Achievement(
    id: 'ascend_1',
    group: AchieveGroup.grow,
    title: '限界を超える',
    detail: 'はじめて限界を解く',
    target: 1,
    progress: _maxAscensions,
    reward: MissionReward(keys: 1),
  ),
  Achievement(
    id: 'level_30',
    group: AchieveGroup.grow,
    title: 'まだ上がある',
    detail: '誰かをLv.30にする',
    target: 30,
    progress: _maxLevel,
    reward: MissionReward(keys: 3, tickets: 5),
  ),

  // ── たたかう ──
  Achievement(
    id: 'stage_1',
    group: AchieveGroup.fight,
    title: 'はじめての勝利',
    detail: 'ステージ1をこえる',
    target: 1,
    progress: _stage,
    reward: MissionReward(tickets: 1),
  ),
  Achievement(
    id: 'stage_10',
    group: AchieveGroup.fight,
    title: '扉のむこう',
    detail: 'ステージ10をこえる',
    target: 10,
    progress: _stage,
    reward: MissionReward(keys: 1, tickets: 2),
  ),
  Achievement(
    id: 'stage_20',
    group: AchieveGroup.fight,
    title: '二度目でも',
    detail: 'ステージ20をこえる',
    target: 20,
    progress: _stage,
    reward: MissionReward(keys: 2, tickets: 3),
  ),
  Achievement(
    id: 'stage_30',
    group: AchieveGroup.fight,
    title: 'いちばん奥',
    detail: 'ステージ30をこえる',
    target: 30,
    progress: _stage,
    reward: MissionReward(keys: 3, tickets: 10),
  ),

  // ── 分かりあう ──
  Achievement(
    id: 'party_5',
    group: AchieveGroup.bond,
    title: '五人そろう',
    detail: '全員と出会う',
    target: 5,
    progress: _partySize,
    reward: MissionReward(tickets: 3),
  ),
  Achievement(
    id: 'heart_1',
    group: AchieveGroup.bond,
    title: 'はじめての♡',
    detail: '誰かの親密度を♡1にする',
    target: 1,
    progress: _maxHearts,
    reward: MissionReward(tickets: 1),
  ),
  Achievement(
    id: 'heart_5',
    group: AchieveGroup.bond,
    title: 'いちばん近い人',
    detail: '誰かの親密度を♡5にする',
    target: 5,
    progress: _maxHearts,
    reward: MissionReward(keys: 2, tickets: 5),
  ),
  Achievement(
    id: 'heart_all',
    group: AchieveGroup.bond,
    title: '選べない',
    detail: '全員の親密度を♡5にする',
    target: 5,
    progress: _allHearts,
    reward: MissionReward(keys: 5, tickets: 10),
  ),

  // ── よむ ──
  Achievement(
    id: 'read_main_10',
    group: AchieveGroup.read,
    title: '第一部',
    detail: '本編を10話読む',
    target: 10,
    progress: _mainRead,
    reward: MissionReward(tickets: 2),
  ),
  Achievement(
    id: 'read_all',
    group: AchieveGroup.read,
    title: '語り部',
    detail: 'すべての話を読む',
    target: 1,
    progress: _readEverything,
    reward: MissionReward(keys: 3, tickets: 10),
  ),
];

int _daysRecorded(GameState state) => state.dayCount - 1;
int _totalSteps(GameState state) => state.totalSteps;
int _stage(GameState state) => state.clearedStage;
int _partySize(GameState state) => state.party.length;

/// いちばん低い子のハート数。全員そろってはじめて5になる。
int _allHearts(GameState state) =>
    kOrgans.map((o) => state.heartsOf(o.id)).fold(OrganStatus.maxHearts, min);

int _readEverything(GameState state) =>
    (_mainRead(state) == kStory.length &&
        _charaRead(state) == kCharaStory.length)
    ? 1
    : 0;

List<Achievement> achievementsIn(AchieveGroup group) =>
    kAchievements.where((a) => a.group == group).toList();

/// 達成していて、まだ受け取っていないもの。
List<Achievement> claimable(GameState state) => kAchievements
    .where((a) => a.isDone(state) && !state.claimedAchievements.contains(a.id))
    .toList();
