import 'package:flutter/material.dart';

import '../data/lines.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/daily_input.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/coin_text.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
import '../data/achievements.dart';
import '../data/avatars.dart';
import '../models/vitals.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';
import '../widgets/progress_ring.dart';
import '../widgets/today_clock.dart';
import 'vitals_screen.dart';
import 'tutorial.dart';
import '../widgets/top_toast.dart';
import 'battle_screen.dart';
import 'daily_input_sheet.dart';
import 'mission_sheet.dart';
import 'settings_screen.dart';
import 'story_list_screen.dart';

/// 会いに来る場所。数字をいじるのは育成タブに置いてある。
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onReset,
    this.anchors,
  });

  final GameState state;
  final VoidCallback onChanged;
  final Future<void> Function() onReset;

  /// 案内で指す場所の目印。案内を終えた人には渡ってこない。
  final HomeAnchors? anchors;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selected = 0;

  /// タップするたびに別のことを言わせるための数。
  int _talkCount = 0;

  GameState get state => widget.state;

  Organ get _organ {
    final party = state.party;
    if (party.isEmpty) return kOrgans.first;
    return party[_selected.clamp(0, party.length - 1)];
  }

  Future<void> _openMissions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MissionSheet(state: state, onChanged: widget.onChanged),
    );
    if (mounted) setState(() {});
  }

  Future<void> _recordDay() async {
    final input = await showModalBottomSheet<DailyInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyInputSheet(
        initial: state.today,
        stepGoal: state.stepGoal,
        readEpisodes: state.readEpisodes,
      ),
    );
    if (input == null || !mounted) return;

    state.today = input;
    final result = state.endDay();
    widget.onChanged();
    if (!mounted) return;
    await _showDayResult(result);
  }

  Future<void> _goToBattle() async {
    final stage = state.currentStage;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BattleScreen(state: state)),
    );
    if (!mounted) return;
    widget.onChanged();

    // 読みたくなったときに読めればいい。勝った直後に読書を強制しない。
    final episode = episodeForStage(stage);
    if (episode != null && state.clearedStage >= stage && mounted) {
      showTopToast(
        context,
        '「${episode.title}」を読めるようになりました',
        icon: Icons.auto_stories,
      );
    }
  }

  /// 杯のしるし。輪の埋まり具合で、何かが貯まる場所だと分かるようにする。
  ///
  /// 小さな線画だけだと設定や情報のアイコンに紛れて、押す気にならない。
  /// 名前と顔。押すとプロフィールへ。
  ///
  /// 自分の記録がどこにあるのかは、自分の顔が置いてあるのが
  /// いちばん分かりやすい。
  Widget _profileButton() {
    final avatar = avatarOf(state);

    return GestureDetector(
      onTap: _openProfile,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: AppColors.hollow.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarCircle(avatar: avatar, size: 26, border: 1.2),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 74),
              child: Text(
                state.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfileScreen(state: state, onChanged: widget.onChanged),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _trophyButton() {
    final done = kAchievements.where((a) => a.isDone(state)).length;
    final ready = claimable(state).isNotEmpty;

    return GestureDetector(
      onTap: _openAchievements,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ProgressRing(
              ratio: done / kAchievements.length,
              size: 34,
              thickness: 2.6,
              child: const Icon(
                Icons.emoji_events,
                size: 17,
                color: AppColors.gold,
              ),
            ),
            if (ready)
              const Positioned(top: -2, right: -2, child: UnreadDot(size: 10)),
          ],
        ),
      ),
    );
  }

  Future<void> _openAchievements() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AchievementsScreen(state: state, onChanged: widget.onChanged),
      ),
    );
    if (mounted) setState(() {});
  }

  /// 設定で変えた値も保存する。戻ってきてから通すのを忘れると、
  /// アプリを閉じた時点で元に戻る。
  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          state: state,
          onChanged: widget.onChanged,
          onReset: widget.onReset,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openStoryList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryListScreen(
          clearedStage: state.clearedStage,
          readEpisodes: state.readEpisodes,
          heartsOf: state.heartsOf,
          onRead: _onEpisodeRead,
        ),
      ),
    );
    if (mounted) widget.onChanged();
  }

  /// 読み終えた瞬間に仲間が増える。
  void _onEpisodeRead(String key) {
    if (state.readEpisodes.contains(key)) return;
    state.markEpisodeRead(key);
    widget.onChanged();

    for (final organ in kOrgans) {
      if ('main:${organ.unlockStage}' == key && mounted) {
        showTopToast(context, '${organ.name}が仲間になりました', icon: Icons.favorite);
      }
    }
  }

  Future<void> _showDayResult(DayResult result) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: OrnatePanel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          glow: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: OrnateLabel('1日のおわり')),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      '獲得コイン',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '+${formatCoins(result.coinsEarned)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                // 何が効いたのかを残す。合計だけだと、明日の行動が変わらない。
                if (result.coins.goalAchieved || result.coins.habits > 0) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (result.coins.goalAchieved)
                        _coinChip(
                          '目標達成 +${formatCoins(result.coins.goalBonus)}',
                          AppColors.rose,
                        ),
                      if (result.coins.habits > 0)
                        _coinChip(
                          'いたわり×${result.coins.multiplier.toStringAsFixed(1)}'
                          ' +${formatCoins(result.coins.habitBonus)}',
                          AppColors.gold,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                for (final organ in state.party)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            organ.facePath(Condition.futsuu),
                            width: 26,
                            height: 26,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(organ.name, style: const TextStyle(fontSize: 14)),
                        const Spacer(),
                        _deltaChip(result.healthDeltas[organ.id] ?? 0),
                      ],
                    ),
                  ),
                if (result.clearedMissions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const OrnateLabel('達成した目標'),
                  const SizedBox(height: 8),
                  for (final mission in result.clearedMissions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 15,
                            color: AppColors.genki,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mission.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            mission.reward.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (result.newStepGoal != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    result.goalAchieved
                        ? '続けられているので、目標を${result.newStepGoal}歩に上げました'
                        : '目標を${result.newStepGoal}歩に下げました。まずは届く数から',
                    style: const TextStyle(fontSize: 12, color: AppColors.rose),
                  ),
                ],
                const SizedBox(height: 20),
                JewelButton(
                  label: 'とじる',
                  height: 46,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _coinChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _deltaChip(int delta) {
    final positive = delta >= 0;
    final color = positive ? AppColors.genki : AppColors.fuchou;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '${positive ? '+' : ''}$delta',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = state.statusOf(_organ.id);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/bg/bg_home.png', fit: BoxFit.cover),
        // 見ている子の色を部屋に落とす。誰といるのかが空気で分かる。
        AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.15,
              center: const Alignment(0, -0.25),
              colors: [
                _organ.accent.withValues(alpha: 0.42),
                _organ.accent.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xE6170E1A), Color(0x40170E1A), Color(0xF2120A16)],
              stops: [0.0, 0.32, 0.82],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _topBar(),
              _mark(widget.anchors?.today, _todayLine()),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _talkCount++),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Center(
                        child: Image.asset(
                          _organ.imagePath(status.condition),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(top: 2, right: 4, child: _vitalCard(status)),
                      _speechBubble(status),
                    ],
                  ),
                ),
              ),
              _mark(widget.anchors?.party, _partyStrip()),
              const SizedBox(height: 12),
              _actions(status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 4),
      child: Row(
        children: [
          _profileButton(),
          const SizedBox(width: 8),
          _mark(
            widget.anchors?.coin,
            _pill(
              formatCoins(state.coins),
              icon: Icons.circle,
              color: AppColors.gold,
            ),
          ),
          const Spacer(),
          _mark(widget.anchors?.story, _storyButton()),
          _trophyButton(),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  /// 現実の日付・時刻と、今日の目標歩数。
  ///
  /// 「N日目」はゲームの中の数字なので、現実のいつの記録なのか分からない。
  /// 目標も、記録シートを開くまで見えないのでは狙いようがない。
  /// 案内で指せるように目印を付ける。案内がないときは素通し。
  Widget _mark(GlobalKey? key, Widget child) =>
      key == null ? child : KeyedSubtree(key: key, child: child);

  Widget _todayLine() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            '${state.dayCount}日目 ・ ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const TodayClock(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          const Icon(Icons.directions_walk, size: 13, color: AppColors.rose),
          const SizedBox(width: 4),
          Text(
            '目標 ${formatCoins(state.stepGoal)}歩',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.rose,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, {IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openStoryList,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppColors.roseGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories, size: 15, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'ストーリー',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.hasUnreadStory)
          const Positioned(top: -4, right: -4, child: UnreadDot()),
      ],
    );
  }

  Widget _speechBubble(OrganStatus status) {
    final text = lineFor(
      _organ.id,
      status.condition,
      state.dayCount + _talkCount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 2),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: Container(
          key: ValueKey(text),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          decoration: BoxDecoration(
            gradient: AppColors.panelGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _organ.accent.withValues(alpha: 0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _organ.accent.withValues(alpha: 0.22),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.asset(
                  _organ.facePath(status.condition),
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14, height: 1.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// いま見ている子の計測値。頭の横に、その子のぶんだけ。
  ///
  /// 五人ぶん並べると数字の壁になる。誰の値なのかも分かりにくい。
  /// 顔の隣にあれば、見ている子のものだと説明がいらない。
  Widget _vitalCard(OrganStatus status) {
    final vitals = kVitals.read(_organ, status, state.dayCount);

    return Container(
      constraints: const BoxConstraints(maxWidth: 102),
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _organ.accent.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final vital in vitals) ...[
            Text(
              vital.label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vital.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: vital.inRange
                        ? AppColors.textPrimary
                        : AppColors.fuchou,
                  ),
                ),
                if (vital.unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      vital.unit,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],
          GestureDetector(
            onTap: _openVitals,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '詳細',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                Icon(Icons.chevron_right, size: 13, color: AppColors.gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVitals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VitalsScreen(state: state)),
    );
    if (mounted) setState(() {});
  }

  Widget _partyStrip() {
    final party = state.party;
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: party.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final organ = party[i];
          final selected = i == _selected;
          final condition = state.statusOf(organ.id).condition;
          return GestureDetector(
            onTap: () => setState(() {
              _selected = i;
              _talkCount = 0;
            }),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 48 : 42,
                  height: selected ? 48 : 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? organ.accent
                          : AppColors.goldDim.withValues(alpha: 0.6),
                      width: selected ? 2.5 : 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: organ.accent.withValues(alpha: 0.55),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      organ.facePath(condition),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 18,
                  height: 3,
                  decoration: BoxDecoration(
                    color: conditionColor(condition),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actions(OrganStatus status) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        children: [
          _mark(
            widget.anchors?.record,
            Row(
              children: [
                Expanded(
                  child: QuietButton(
                    label: state.hasMissions
                        ? '今日の目標 ${state.missionIds.length}'
                        : '目標をえらぶ',
                    icon: Icons.checklist,
                    onPressed: _openMissions,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: JewelButton(
                    label: '今日を記録する',
                    height: 48,
                    onPressed: _recordDay,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _mark(
            widget.anchors?.battle,
            JewelButton(
              label: 'ステージ ${state.currentStage} に挑む',
              icon: Icons.local_fire_department,
              height: 48,
              gradient: const LinearGradient(
                colors: [Color(0xFF8E4BC4), Color(0xFF5B2E86)],
              ),
              onPressed: _goToBattle,
            ),
          ),
        ],
      ),
    );
  }
}
