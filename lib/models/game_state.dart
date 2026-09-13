import 'dart:convert';
import 'dart:math';

import '../data/organs.dart';
import '../data/chara_story.dart';
import '../data/enemies.dart';
import '../data/missions.dart';
import '../data/presents.dart';
import '../data/story.dart';
import 'daily_input.dart';
import 'mission.dart';
import 'present.dart';
import 'organ.dart';

/// 1日を締めたときに何が起きたか。画面で結果を見せるために返す。
class DayResult {
  const DayResult({
    required this.coins,
    required this.healthDeltas,
    required this.newStepGoal,
    required this.clearedMissions,
  });

  /// もらったコインの内訳。何が効いたのかを結果画面で見せる。
  final CoinBreakdown coins;

  final Map<String, int> healthDeltas;

  int get coinsEarned => coins.total;
  bool get goalAchieved => coins.goalAchieved;

  /// 目標が変わった場合のみ値が入る。
  final int? newStepGoal;

  final List<Mission> clearedMissions;
}

/// 戦闘ログの送り速度。
enum BattleSpeed {
  slow('ゆっくり', 620),
  normal('ふつう', 420),
  fast('はやい', 200);

  const BattleSpeed(this.label, this.millis);
  final String label;
  final int millis;
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
    required this.clearedStage,
    required this.readEpisodes,
    required this.keys,
    required this.tickets,
    required this.missionIds,
    required this.inventory,
    required this.pullsSinceSsr,
    this.battleSpeed = BattleSpeed.normal,
    this.tutorialPhase = 0,
    this.devMode = false,
    this.userName = '',
    this.avatarId = 'organ:heart',
    this.totalSteps = 0,
    Map<String, List<int>>? healthLog,
    Set<String>? claimedAchievements,
  }) : healthLog = healthLog ?? <String, List<int>>{},
       claimedAchievements = claimedAchievements ?? <String>{};

  /// 呼び名。はじめに一度だけ聞く。
  String userName;

  /// プロフィールのアイコン。'organ:heart' や 'enemy:ramen' の形。
  String avatarId;

  /// 名前を聞いたかどうか。空のままでも進めるが、一度は尋ねる。
  bool get hasName => userName.trim().isNotEmpty;

  /// 合わせて何歩あるいたか。1日を締めるたびに足す。
  int totalSteps;

  /// 名前の長さ。長すぎると画面のどこにも収まらない。
  static const int maxNameLength = 12;

  /// 受け取り済みの達成。報酬を二度渡さないために持つ。
  final Set<String> claimedAchievements;

  /// 臓器ごとの健康度の記録。1日を締めるたびに後ろへ足す。
  ///
  /// 推移を見せるのに要る。持っていないと、グラフが作り話になる。
  final Map<String, List<int>> healthLog;

  /// 残す日数。古いぶんは捨てる。
  static const int logDays = 14;

  /// 案内の進み具合。0=まだ、1=最初のバトルを終えた、2=案内も終わった。
  ///
  /// 説明から入ると読まれない。まず一戦させて、最初の話を開けてから案内する。
  int tutorialPhase;

  bool get tutorialDone => tutorialPhase >= 2;

  /// 開発者モード。動作確認のために数値を直接いじれるようにする。
  bool devMode;

  factory GameState.fresh() => GameState(
    coins: 0,
    organs: {for (final o in kOrgans) o.id: const OrganStatus()},
    stepGoal: initialStepGoal,
    goalStreak: 0,
    missStreak: 0,
    dayCount: 1,
    today: const DailyInput(),
    clearedStage: 0,
    readEpisodes: <String>{},
    keys: 0,
    tickets: 0,
    missionIds: <String>[],
    inventory: <String, int>{},
    pullsSinceSsr: 0,
  );

  int coins;
  Map<String, OrganStatus> organs;
  int stepGoal;
  int goalStreak;
  int missStreak;
  int dayCount;
  DailyInput today;
  int clearedStage;

  /// 読み終えた話の鍵。'main:3' や 'chara:heart:5' の形で持つ。
  /// 仲間が増えるのはクリアではなく、これを満たしたとき。
  Set<String> readEpisodes;

  /// レベルの壁を越えるための鍵。
  int keys;

  /// ガチャ用のチケット。使い道は後で作る。
  int tickets;

  /// 今日ぶんの目標。自分で選ぶ。1日を終えると空になる。
  List<String> missionIds;

  BattleSpeed battleSpeed;

  /// 持っているプレゼント。id と個数。
  Map<String, int> inventory;

  /// 天井までの数え。SSRが出るたびに0に戻る。
  int pullsSinceSsr;

  int get pullsToPity => (kPityPulls - pullsSinceSsr).clamp(0, kPityPulls);

  final Random _random = Random();

  int countOf(String presentId) => inventory[presentId] ?? 0;

  List<Present> get ownedPresents =>
      kPresents.where((p) => countOf(p.id) > 0).toList()
        ..sort((a, b) => b.rarity.stars.compareTo(a.rarity.stars));

  bool get canPull => tickets >= kGachaCost;
  bool get canPullTen => tickets >= kGachaTenCost;

  List<Present> pull({required bool ten}) {
    final cost = ten ? kGachaTenCost : kGachaCost;
    if (tickets < cost) return const [];
    tickets -= cost;
    final results = ten ? rollTen(_random) : [rollOne(_random)];

    // 天井。引いた回数が報われないままにしない。
    for (var i = 0; i < results.length; i++) {
      if (results[i].rarity == Rarity.ssr) {
        pullsSinceSsr = 0;
        continue;
      }
      pullsSinceSsr++;
      if (pullsSinceSsr >= kPityPulls) {
        results[i] = forceSsr(_random);
        pullsSinceSsr = 0;
      }
    }

    for (final p in results) {
      inventory[p.id] = countOf(p.id) + 1;
    }
    return results;
  }

  /// 渡すと親密度が上がる。好物なら倍。
  int givePresent(String organId, Present present) {
    if (countOf(present.id) <= 0) return 0;
    final gain = present.affectionFor(organId);
    inventory[present.id] = countOf(present.id) - 1;
    if (inventory[present.id] == 0) inventory.remove(present.id);
    organs[organId] = statusOf(organId).gifted(gain);
    return gain;
  }

  int heartsOf(String organId) => statusOf(organId).hearts;

  List<Mission> get missions =>
      missionIds.map(missionById).whereType<Mission>().toList();

  bool get hasMissions => missionIds.isNotEmpty;

  int get currentStage => clearedStage + 1;

  List<Organ> get party => unlockedOrgans(readEpisodes);

  void markEpisodeRead(String key) => readEpisodes.add(key);

  /// 解放済みで、まだ読んでいない話があるか。
  int levelOf(String organId) => statusOf(organId).level;

  /// 本編とキャラ編のどちらかに未読があるか。
  bool get hasUnreadStory =>
      unlockedEpisodes(
        clearedStage,
      ).any((e) => !readEpisodes.contains(e.key)) ||
      unlockedCharaEpisodes(heartsOf).any((e) => !readEpisodes.contains(e.key));

  /// バトルに勝ってもコインは出さない。
  ///
  /// 報酬でコインを配ると「バトル→コイン→レベル→強くなる」の輪が閉じ、
  /// 歩かなくても強くなれてしまう。強さの源は運動だけに保つ。
  /// 戻り値は手に入れた鍵の数。ボスだけが落とす。
  int clearStage(int stage) {
    if (stage != currentStage) return 0;
    clearedStage = stage;
    if (!enemyForStage(stage).isBoss) return 0;
    keys += bossKeyDrop;
    return bossKeyDrop;
  }

  static const int bossKeyDrop = 1;

  // 運動習慣のない人が対象なので、最初の目標は達成できる高さから始める。
  static const int initialStepGoal = 3000;
  static const int minStepGoal = 2000;
  static const int goalStepUp = 1000;
  static const int daysToRaiseGoal = 7;
  static const int daysToLowerGoal = 3;

  OrganStatus statusOf(String id) => organs[id] ?? const OrganStatus();

  /// 上限に達していると、コインがあっても上げられない。
  bool canLevelUp(String id) {
    final status = statusOf(id);
    return !status.atCap && coins >= status.levelUpCost();
  }

  void levelUp(String id) {
    if (!canLevelUp(id)) return;
    final status = statusOf(id);
    coins -= status.levelUpCost();
    organs[id] = status.leveledUp();
  }

  bool canAscend(String id) {
    final status = statusOf(id);
    return status.atCap && keys >= status.keysToAscend;
  }

  /// 壁を越える。鍵を払って上限だけを引き上げる。
  void ascend(String id) {
    if (!canAscend(id)) return;
    final status = statusOf(id);
    keys -= status.keysToAscend;
    organs[id] = status.ascended();
  }

  /// 1日を締める。入力からコインと健康度を確定し、翌日に進む。
  DayResult endDay() {
    final deltas = <String, int>{};
    // まだ出会っていない子は数えない。放っておくと、初対面のときに
    // もう弱りきっている。
    for (final organ in party) {
      final delta = HealthRule.deltaFor(
        organ: organ,
        input: today,
        stepGoal: stepGoal,
      );
      deltas[organ.id] = delta;
      organs[organ.id] = statusOf(organ.id).applyHealthDelta(delta);
    }

    for (final organ in party) {
      final log = healthLog.putIfAbsent(organ.id, () => <int>[])
        ..add(statusOf(organ.id).health);
      if (log.length > logDays) log.removeRange(0, log.length - logDays);
    }

    final cleared = missions.where((m) => m.isDone(today, stepGoal)).toList();
    for (final m in cleared) {
      keys += m.reward.keys;
      tickets += m.reward.tickets;
    }

    totalSteps += today.steps;

    final earned = today.coinsFor(stepGoal);

    coins += earned.total;
    final newGoal = _updateGoal(earned.goalAchieved);

    dayCount++;
    today = const DailyInput();
    // 翌日はまた選び直す
    missionIds = <String>[];

    return DayResult(
      coins: earned,
      healthDeltas: deltas,
      newStepGoal: newGoal,
      clearedMissions: cleared,
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
    'clearedStage': clearedStage,
    'readEpisodes': readEpisodes.toList(),
    'keys': keys,
    'tickets': tickets,
    'missionIds': missionIds,
    'battleSpeed': battleSpeed.name,
    'tutorialPhase': tutorialPhase,
    'healthLog': healthLog,
    'userName': userName,
    'avatarId': avatarId,
    'totalSteps': totalSteps,
    'claimedAchievements': claimedAchievements.toList(),
    'devMode': devMode,
    'inventory': inventory,
    'pullsSinceSsr': pullsSinceSsr,
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
        (map['today'] as Map<String, dynamic>?) ?? const {},
      ),
      clearedStage: map['clearedStage'] as int? ?? 0,
      // 以前は話の番号だけを数で持っていた。古いセーブを読めるようにする。
      readEpisodes: ((map['readEpisodes'] as List<dynamic>?) ?? const [])
          .map((e) => e is int ? 'main:$e' : e as String)
          .toSet(),
      keys: map['keys'] as int? ?? 0,
      tickets: map['tickets'] as int? ?? 0,
      missionIds: ((map['missionIds'] as List<dynamic>?) ?? const [])
          .map((e) => e as String)
          .toList(),
      // 以前は見たかどうかの真偽値だけだった。見終えていれば最後まで進める。
      userName: map['userName'] as String? ?? '',
      avatarId: map['avatarId'] as String? ?? 'organ:heart',
      totalSteps: map['totalSteps'] as int? ?? 0,
      claimedAchievements:
          ((map['claimedAchievements'] as List<dynamic>?) ?? const [])
              .map((e) => e as String)
              .toSet(),
      healthLog: {
        for (final entry
            in ((map['healthLog'] as Map<String, dynamic>?) ?? const {})
                .entries)
          entry.key: [for (final v in entry.value as List<dynamic>) v as int],
      },
      tutorialPhase:
          map['tutorialPhase'] as int? ??
          ((map['tutorialDone'] as bool? ?? false) ? 2 : 0),
      devMode: map['devMode'] as bool? ?? false,
      battleSpeed: BattleSpeed.values.firstWhere(
        (s) => s.name == map['battleSpeed'],
        orElse: () => BattleSpeed.normal,
      ),
      pullsSinceSsr: map['pullsSinceSsr'] as int? ?? 0,
      inventory: ((map['inventory'] as Map<String, dynamic>?) ?? const {}).map(
        (k, v) => MapEntry(k, v as int),
      ),
    );
  }
}
