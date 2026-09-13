import 'package:flutter/material.dart';

import '../data/missions.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/mission.dart';
import '../widgets/ornate.dart';

/// 今日の目標を見る。
///
/// 以前は一覧から3つ選ばせていたが、選べると「今日できそうなもの」だけを
/// 選んで終われてしまう。あるく・のぼる・ととのえるが毎日1つずつ決まって
/// いるほうが、その日やることが迷わず決まる。
class MissionSheet extends StatelessWidget {
  const MissionSheet({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final missions = state.missions;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.goldDim, width: 1.2)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
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
                    '${state.dayCount}日目',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
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
                  '毎日3つ、自動で決まります。今日を記録したときに判定されます',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  for (final mission in missions) ...[
                    _card(mission),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 4),
                  if (missions.length == kMissionSlots)
                    _bonusCard()
                  else
                    _notYet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Mission mission) {
    final givesKey = mission.reward.keys > 0;

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      borderColor: givesKey ? AppColors.gold : AppColors.goldDim,
      child: Row(
        children: [
          _kindChip(mission.kind),
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
                _rewardLine(mission.reward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 何の目標かを一目で分ける。3つが並ぶので、種類が見えないと
  /// どれも同じ課題に見えてしまう。
  Widget _kindChip(MissionKind kind) {
    final color = switch (kind) {
      MissionKind.walk => AppColors.rose,
      MissionKind.climb => AppColors.gold,
      MissionKind.care => AppColors.genki,
    };

    return Container(
      // 「ととのえる」が5文字。詰めると2行に折れる
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        kind.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  /// 3つ揃えたときの取り分。1つずつの報酬より目立たせる。
  Widget _bonusCard() {
    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      borderColor: AppColors.rose,
      glow: true,
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, size: 26, color: AppColors.rose),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3つすべて達成',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                const Text(
                  'そろえた日だけ、上乗せでもらえます',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                _rewardLine(kAllMissionsBonus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// まだ全部の種類が出そろっていない日。
  ///
  /// 何も書かないと「3つと言ったのに2つしかない」と見える。
  Widget _notYet() {
    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 22, color: AppColors.textMuted),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '仲間が増えると、目標も増えます。\n'
              '3つそろった日は、上乗せの報酬がつきます',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardLine(MissionReward reward) {
    final givesKey = reward.keys > 0;

    return Row(
      children: [
        Icon(
          givesKey ? Icons.vpn_key : Icons.confirmation_number,
          size: 12,
          color: givesKey ? AppColors.gold : AppColors.rose,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            reward.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: givesKey ? AppColors.gold : AppColors.rose,
            ),
          ),
        ),
      ],
    );
  }
}
