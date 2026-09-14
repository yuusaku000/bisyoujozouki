import 'package:flutter/material.dart';

import '../data/organs.dart';
import '../data/ranking.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/ornate.dart';
import '../widgets/scene.dart';

/// 世界での立ち位置。
///
/// 中身は作りもので、通信はしていない（[stageTopPercent] を参照）。
/// 画面には、その仕掛けを書かない。順位として受け取ってもらうため。
class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final stagePercent = stageTopPercent(state.clearedStage);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SceneBackdrop(
        tint: AppColors.gold,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 18, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'ランキング',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                  children: [
                    _stagePanel(stagePercent),
                    const SizedBox(height: 22),
                    const Center(child: OrnateLabel('親密度')),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'この子を、世界でどれだけ大事にできているか',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final organ in state.party) ...[
                      _organRow(organ),
                      const SizedBox(height: 10),
                    ],
                    if (state.party.length < kOrgans.length) ...[
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'まだ会っていない子は、出会ってから並びます',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stagePanel(double percent) {
    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      borderColor: AppColors.gold,
      glow: true,
      child: Column(
        children: [
          const Text(
            'どこまで潜れたか',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '上位',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Text(
                formatPercent(percent),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                  shadows: [Shadow(color: AppColors.gold, blurRadius: 18)],
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _titleChip(percent),
          const SizedBox(height: 14),
          Text(
            'ステージ ${state.clearedStage} まで到達',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _organRow(Organ organ) {
    final status = state.statusOf(organ.id);
    final percent = heartTopPercent(status.heartLevel);

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
      borderColor: organ.accent.withValues(alpha: 0.7),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              organ.facePath(Condition.genki),
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      organ.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: organ.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite, size: 11, color: AppColors.rose),
                    const SizedBox(width: 3),
                    Text(
                      status.heartLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '上位 ${formatPercent(percent)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rankTitle(percent),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _titleChip(double percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Text(
        rankTitle(percent),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.gold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
