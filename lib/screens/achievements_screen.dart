import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';
import '../widgets/progress_ring.dart';

/// これまでに積み上げたもの。
///
/// 日々の記録は流れていくので、残ったものを並べる場所がいる。
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

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  /// 受け取れるものを光らせる。並びの中で埋もれると気づかれない。
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  GameState get state => widget.state;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

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
          _header(),
          const SizedBox(height: 20),
          for (final group in AchieveGroup.values) ...[
            _groupHead(group),
            const SizedBox(height: 10),
            for (final achievement in achievementsIn(group)) ...[
              _tile(achievement),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // ── 上の総括 ──────────────────────────────────────────

  Widget _header() {
    final done = kAchievements.where((a) => a.isDone(state)).length;
    final ready = claimable(state).length;

    return OrnatePanel(
      glow: true,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                ratio: done / kAchievements.length,
                size: 84,
                thickness: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$done',
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      '/ ${kAchievements.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'あなたが積み上げたもの',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ready > 0
                          ? '受け取れるものが $ready こ あります'
                          : '歩いた日、読んだ話、上げたレベル。\nぜんぶ数えてあります。',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ready > 0) ...[
            const SizedBox(height: 14),
            JewelButton(
              label: 'ぜんぶ受け取る',
              icon: Icons.redeem,
              height: 46,
              onPressed: _claimAll,
            ),
          ],
        ],
      ),
    );
  }

  Widget _groupHead(AchieveGroup group) {
    final all = achievementsIn(group);
    final done = all.where((a) => a.isDone(state)).length;

    return Row(
      children: [
        Expanded(child: Center(child: OrnateLabel(group.label))),
        Text(
          '$done / ${all.length}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: done == all.length ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ── ひとつぶん ────────────────────────────────────────

  Widget _tile(Achievement achievement) {
    final done = achievement.isDone(state);
    final claimed = state.claimedAchievements.contains(achievement.id);
    final ready = done && !claimed;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = ready ? 0.35 + 0.45 * _pulse.value : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: ready
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: glow),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: OrnatePanel(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        borderColor: ready
            ? AppColors.gold
            : (done
                  ? AppColors.goldDim
                  : AppColors.goldDim.withValues(alpha: 0.45)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _medal(achievement, done, claimed),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        done ? achievement.title : '？？？',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: done
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        achievement.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 9),
                      _progress(achievement, done),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _rewardChips(achievement, claimed),
                const Spacer(),
                if (claimed)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.genki,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '受け取り済み',
                        style: TextStyle(fontSize: 10, color: AppColors.genki),
                      ),
                    ],
                  ),
              ],
            ),
            if (ready) ...[
              const SizedBox(height: 11),
              JewelButton(
                label: '受け取る',
                height: 40,
                gradient: AppColors.goldGradient,
                onPressed: () => _claim(achievement),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 位によって色を変える。重いものほど眩しくしておくと、
  /// 並べたときに「次はこれ」が決めやすい。
  Widget _medal(Achievement achievement, bool done, bool claimed) {
    final tier = achievement.reward.keys;
    final color = !done
        ? AppColors.textMuted.withValues(alpha: 0.4)
        : switch (tier) {
            0 => const Color(0xFFB98D63),
            1 || 2 => const Color(0xFFCFD4DC),
            _ => AppColors.gold,
          };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color.withValues(alpha: done ? 0.9 : 0.4)),
        boxShadow: done
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)]
            : null,
      ),
      child: Icon(
        done ? Icons.emoji_events : Icons.lock_outline,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _progress(Achievement achievement, bool done) {
    final value = achievement.progress(state).clamp(0, achievement.target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 7, color: AppColors.hollow),
              FractionallySizedBox(
                widthFactor: achievement.ratio(state),
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: done
                        ? AppColors.goldGradient
                        : LinearGradient(
                            colors: [
                              AppColors.goldDim.withValues(alpha: 0.7),
                              AppColors.goldDim,
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${formatCoins(value)} / ${formatCoins(achievement.target)}',
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  /// 報酬は文字より形で。鍵とチケットは絵が違うので一目で分かる。
  Widget _rewardChips(Achievement achievement, bool claimed) {
    final dim = claimed ? 0.45 : 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (achievement.reward.keys > 0)
          _chip(Icons.vpn_key, achievement.reward.keys, dim),
        if (achievement.reward.keys > 0 && achievement.reward.tickets > 0)
          const SizedBox(width: 6),
        if (achievement.reward.tickets > 0)
          _chip(Icons.confirmation_number, achievement.reward.tickets, dim),
      ],
    );
  }

  Widget _chip(IconData icon, int count, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.hollow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(
              '×$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
