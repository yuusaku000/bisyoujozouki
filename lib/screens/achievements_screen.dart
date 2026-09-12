import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';

/// これまでに積み上げたもの。
///
/// 日々の記録は消えていくので、残ったものを並べる場所がいる。
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final GameState state;
  final VoidCallback onChanged;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  GameState get state => widget.state;

  void _claim(Achievement achievement) {
    if (!achievement.isDone(state)) return;
    if (!state.claimedAchievements.add(achievement.id)) return;

    setState(() {
      state.keys += achievement.reward.keys;
      state.tickets += achievement.reward.tickets;
    });
    widget.onChanged();
  }

  void _claimAll() {
    for (final achievement in claimable(state)) {
      _claim(achievement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = kAchievements.where((a) => a.isDone(state)).length;
    final ready = claimable(state);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'あしあと',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _summary(done, ready.length),
          const SizedBox(height: 18),
          for (final group in AchieveGroup.values) ...[
            Center(child: OrnateLabel(group.label)),
            const SizedBox(height: 10),
            for (final achievement in achievementsIn(group)) ...[
              _tile(achievement),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _summary(int done, int ready) {
    return OrnatePanel(
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '達成',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                '$done',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                ),
              ),
              Text(
                ' / ${kAchievements.length}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (ready > 0) ...[
            const SizedBox(height: 12),
            JewelButton(
              label: '$ready こ まとめて受け取る',
              height: 46,
              onPressed: _claimAll,
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(Achievement achievement) {
    final progress = achievement.progress(state);
    final done = achievement.isDone(state);
    final claimed = state.claimedAchievements.contains(achievement.id);
    final color = done ? AppColors.gold : AppColors.goldDim;

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      borderColor: claimed ? AppColors.goldDim : color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                done ? Icons.emoji_events : Icons.lock_outline,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: done
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (claimed)
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.genki,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _bar(achievement.ratio(state), done),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${formatCoins(progress.clamp(0, achievement.target))}'
                ' / ${formatCoins(achievement.target)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                achievement.reward.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: claimed ? AppColors.textMuted : AppColors.gold,
                ),
              ),
            ],
          ),
          if (done && !claimed) ...[
            const SizedBox(height: 10),
            JewelButton(
              label: '受け取る',
              height: 40,
              onPressed: () => _claim(achievement),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bar(double ratio, bool done) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(height: 6, color: AppColors.hollow),
          FractionallySizedBox(
            widthFactor: ratio,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: done
                    ? AppColors.goldGradient
                    : LinearGradient(
                        colors: [
                          AppColors.goldDim.withValues(alpha: 0.8),
                          AppColors.goldDim,
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
