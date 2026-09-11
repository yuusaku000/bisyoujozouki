import 'package:flutter/material.dart';

import '../data/organs.dart';
import '../data/theme.dart';
import '../models/daily_input.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../services/save_store.dart';
import '../services/step_source.dart';
import '../widgets/health_bar.dart';
import 'daily_input_sheet.dart';

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
      builder: (_) =>
          DailyInputSheet(initial: state.today, stepGoal: state.stepGoal),
    );
    if (input == null || !mounted) return;

    state.today = input;
    final result = state.endDay();
    setState(() {});
    await _persist();
    if (!mounted) return;
    await _showDayResult(result);
  }

  Future<void> _showDayResult(DayResult result) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          '1日の結果',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '獲得コイン',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    '+${result.coinsEarned}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.coin,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.panelAlt),
              for (final organ in kOrgans)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
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
                  style: const TextStyle(fontSize: 12, color: AppColors.accent),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('とじる'),
          ),
        ],
      ),
    );
  }

  Widget _deltaChip(int delta) {
    final positive = delta >= 0;
    final color = positive ? AppColors.genki : AppColors.fuchou;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${positive ? '+' : ''}$delta',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
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
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final status = state.statusOf(_organ.id);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg/bg_home.png', fit: BoxFit.cover),
          // 背景が明るいので、上に置く文字が読めるよう暗く落とす
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC1C1620),
                  Color(0x551C1620),
                  Color(0xEE1C1620),
                ],
                stops: [0.0, 0.35, 0.8],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(state),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      _organ.imagePath(status.condition),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                _organSwitcher(state),
                _statusPanel(state, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text(
            '${state.dayCount}日目',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          const Icon(Icons.monetization_on, color: AppColors.coin, size: 20),
          const SizedBox(width: 6),
          Text(
            '${state.coins}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.coin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _organSwitcher(GameState state) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kOrgans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final organ = kOrgans[i];
          final selected = i == _selected;
          final condition = state.statusOf(organ.id).condition;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? organ.accent.withValues(alpha: 0.3)
                    : AppColors.panel.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? organ.accent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    organ.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      color: conditionColor(condition),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusPanel(GameState state, OrganStatus status) {
    final cost = status.levelUpCost();
    final affordable = state.canLevelUp(_organ.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _organ.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lv.${status.level}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _organ.accent,
                ),
              ),
              const Spacer(),
              // 役割名が長い臓器があるので、横に並べず幅を譲らせる
              Flexible(
                child: Text(
                  '${_organ.metric.label}で育つ・${_organ.role}',
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
          const SizedBox(height: 12),
          HealthBar(status: status),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: affordable ? _levelUp : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coin,
                    side: const BorderSide(color: AppColors.panelAlt),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('レベルup  $cost'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _recordDay,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '今日を記録する',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
