import 'package:flutter/material.dart';

import '../data/lines.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/daily_input.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../services/save_store.dart';
import '../services/step_source.dart';
import '../widgets/coin_text.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
import '../widgets/top_toast.dart';
import 'battle_screen.dart';
import 'daily_input_sheet.dart';
import 'story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = SaveStore();
  final StepSource _stepSource = ManualStepSource();

  GameState? _state;
  int _selected = 0;

  /// タップするたびに別のことを言わせるための数。
  int _talkCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await _store.load();
    final auto = await _stepSource.readToday();
    if (auto != null) state.today = auto;
    if (!mounted) return;
    setState(() => _state = state);
  }

  Future<void> _persist() async {
    final state = _state;
    if (state != null) await _store.save(state);
  }

  Organ get _organ => kOrgans[_selected];

  Future<void> _recordDay() async {
    final state = _state!;
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
    setState(() {});
    await _persist();
    if (!mounted) return;
    await _showDayResult(result);
  }

  Future<void> _goToBattle() async {
    final state = _state!;
    final stage = state.currentStage;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BattleScreen(state: state)),
    );
    if (!mounted) return;
    setState(() {});
    await _persist();

    // 読みたくなったときに読めればいい。勝った直後に読書を強制しない。
    final episode = episodeForStage(stage);
    if (episode != null && state.clearedStage >= stage && mounted) {
      _announceEpisode(episode);
    }
  }

  void _announceEpisode(StoryEpisode episode) {
    showTopToast(
      context,
      '「${episode.title}」を読めるようになりました',
      icon: Icons.auto_stories,
    );
  }

  Future<void> _openStoryList() async {
    final state = _state!;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryListScreen(
          clearedStage: state.clearedStage,
          readEpisodes: state.readEpisodes,
          levelOf: state.levelOf,
          onRead: _onEpisodeRead,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
    await _persist();
  }

  /// 読み終えた瞬間に仲間が増える。
  void _onEpisodeRead(String key) {
    final state = _state!;
    if (state.readEpisodes.contains(key)) return;
    state.markEpisodeRead(key);
    _persist();

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
                const SizedBox(height: 14),
                for (final organ in _state!.party)
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

  void _levelUp() {
    final state = _state!;
    if (!state.canLevelUp(_organ.id)) return;
    setState(() => state.levelUp(_organ.id));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.rose)),
      );
    }

    final status = state.statusOf(_organ.id);

    return Scaffold(
      body: Stack(
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
          // 背景が明るいので、上に置く文字が読めるよう落とす
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE6170E1A),
                  Color(0x40170E1A),
                  Color(0xF2120A16),
                ],
                stops: [0.0, 0.32, 0.78],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(state),
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
                        _speechBubble(state, status),
                      ],
                    ),
                  ),
                ),
                _organSwitcher(state),
                const SizedBox(height: 10),
                _statusPanel(state, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(GameState state) {
    final hasUnread = state.hasUnreadStory;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.hollow.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldDim.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              '${state.dayCount}日目',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.hollow.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldDim.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppColors.gold, size: 13),
                const SizedBox(width: 7),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Text(
                    formatCoins(state.coins),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _storyButton(hasUnread),
        ],
      ),
    );
  }

  /// アイコンだけだと何のボタンか分からないので、文字を添える。
  Widget _storyButton(bool hasUnread) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _storyButtonBody(),
        if (hasUnread) const Positioned(top: -4, right: -4, child: UnreadDot()),
      ],
    );
  }

  Widget _storyButtonBody() {
    return Material(
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_stories, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
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
    );
  }

  /// その日の調子として受け取れるよう、日付で言うことを決める。
  /// タップすれば別のことを言う。
  Widget _speechBubble(GameState state, OrganStatus status) {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.panelTop.withValues(alpha: 0.93),
                AppColors.panelBottom.withValues(alpha: 0.93),
              ],
            ),
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

  Widget _organSwitcher(GameState state) {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kOrgans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final organ = kOrgans[i];
          final selected = i == _selected;
          final unlocked = organ.isUnlocked(state.readEpisodes);
          final condition = state.statusOf(organ.id).condition;
          return GestureDetector(
            onTap: unlocked
                ? () => setState(() {
                    _selected = i;
                    _talkCount = 0;
                  })
                : () => showTopToast(
                    context,
                    'ステージ ${organ.unlockStage} をこえると出会えます',
                    icon: Icons.lock,
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 54 : 46,
                  height: selected ? 54 : 46,
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
                    child: unlocked
                        ? Image.asset(
                            organ.facePath(condition),
                            fit: BoxFit.cover,
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  0.2126, 0.7152, 0.0722, 0, 0, //
                                  0.2126, 0.7152, 0.0722, 0, 0, //
                                  0.2126, 0.7152, 0.0722, 0, 0, //
                                  0, 0, 0, 1, 0,
                                ]),
                                child: Image.asset(
                                  organ.facePath(Condition.futsuu),
                                  fit: BoxFit.cover,
                                  opacity: const AlwaysStoppedAnimation(0.35),
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.lock,
                                  size: 20,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? conditionColor(condition)
                        : AppColors.goldDim.withValues(alpha: 0.5),
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

  Widget _statusPanel(GameState state, OrganStatus status) {
    final cost = status.levelUpCost();
    final affordable = state.canLevelUp(_organ.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: OrnatePanel(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        borderColor: _organ.accent,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _organ.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lv.${status.level}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3A2A0E),
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    '${_organ.metric.label}で育つ',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            HealthBar(status: status),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: QuietButton(
                    label: formatCoins(cost),
                    icon: Icons.arrow_upward,
                    onPressed: affordable ? _levelUp : null,
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
            const SizedBox(height: 10),
            JewelButton(
              label: 'ステージ ${state.currentStage} に挑む',
              icon: Icons.local_fire_department,
              height: 50,
              gradient: const LinearGradient(
                colors: [Color(0xFF8E4BC4), Color(0xFF5B2E86)],
              ),
              onPressed: _goToBattle,
            ),
          ],
        ),
      ),
    );
  }
}
