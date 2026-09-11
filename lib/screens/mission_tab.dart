import 'package:flutter/material.dart';

import '../data/missions.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/mission.dart';
import '../widgets/ornate.dart';

/// 今日の目標を自分で選ぶ。押しつけられた課題より、選んだ約束のほうが守れる。
class MissionTab extends StatelessWidget {
  const MissionTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  bool _isChosen(Mission m) => state.missionIds.contains(m.id);

  void _toggle(Mission m) {
    if (_isChosen(m)) {
      state.missionIds.remove(m.id);
    } else if (state.missionIds.length < kMissionSlots) {
      state.missionIds.add(m.id);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final chosen = state.missionIds.length;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children: [
                  const Text(
                    '今日の目標',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$chosen / $kMissionSlots',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: chosen == kMissionSlots
                          ? AppColors.genki
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '選んだ目標は、今日を記録したときに判定されます',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                itemCount: kMissions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _card(kMissions[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Mission mission) {
    final chosen = _isChosen(mission);
    final full = state.missionIds.length >= kMissionSlots && !chosen;
    final givesKey = mission.reward.keys > 0;

    return Opacity(
      opacity: full ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: full ? null : () => _toggle(mission),
          child: OrnatePanel(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            borderColor: chosen
                ? AppColors.rose
                : givesKey
                ? AppColors.gold
                : AppColors.goldDim,
            glow: chosen,
            child: Row(
              children: [
                Icon(
                  chosen ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 22,
                  color: chosen ? AppColors.rose : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mission.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            givesKey
                                ? Icons.vpn_key
                                : Icons.confirmation_number,
                            size: 12,
                            color: givesKey ? AppColors.gold : AppColors.rose,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            mission.reward.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: givesKey ? AppColors.gold : AppColors.rose,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
