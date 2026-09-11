import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/coin_text.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
import '../widgets/top_toast.dart';

/// 数字をいじる場所。ホームと分けたのは、会いに来る場所と
/// 育てる場所で気分が違うため。
class GrowTab extends StatelessWidget {
  const GrowTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                children: [
                  for (final organ in state.party) ...[
                    _card(context, organ),
                    const SizedBox(height: 12),
                  ],
                  if (state.party.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '物語を読み進めると、育てられる子が増えます',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          const Text(
            '育成',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          _counter(Icons.circle, formatCoins(state.coins), AppColors.gold),
          const SizedBox(width: 8),
          _counter(Icons.vpn_key, '${state.keys}', AppColors.rose),
        ],
      ),
    );
  }

  Widget _counter(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.hollow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Organ organ) {
    final status = state.statusOf(organ.id);
    final atCap = status.atCap;

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderColor: organ.accent,
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  organ.facePath(status.condition),
                  width: 44,
                  height: 44,
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lv.${status.level} / ${status.levelCap}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3A2A0E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${organ.metric.label}で育つ・${organ.role}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HealthBar(status: status),
          const SizedBox(height: 14),
          if (atCap)
            _ascendRow(context, organ, status)
          else
            QuietButton(
              label: 'レベルup　${formatCoins(status.levelUpCost())}',
              icon: Icons.arrow_upward,
              onPressed: state.canLevelUp(organ.id)
                  ? () {
                      state.levelUp(organ.id);
                      onChanged();
                    }
                  : null,
            ),
        ],
      ),
    );
  }

  /// 上限に当たったら、コインではなく鍵を求める。
  /// 歩くだけでは越えられない壁があるほうが、区切りになる。
  Widget _ascendRow(BuildContext context, Organ organ, OrganStatus status) {
    final need = status.keysToAscend;
    final enough = state.keys >= need;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.hollow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Text(
            'Lv.${status.levelCap} が上限です。解放の鍵 ×$need で先へ進めます',
            style: const TextStyle(fontSize: 11, color: AppColors.gold),
          ),
        ),
        const SizedBox(height: 10),
        JewelButton(
          label: enough ? '限界を解く（鍵 ×$need）' : '鍵が足りません（${state.keys} / $need）',
          icon: Icons.vpn_key,
          height: 48,
          gradient: AppColors.goldGradient,
          onPressed: enough
              ? () {
                  state.ascend(organ.id);
                  onChanged();
                  showTopToast(
                    context,
                    '${organ.name}の限界が解けました',
                    icon: Icons.auto_awesome,
                  );
                }
              : null,
        ),
      ],
    );
  }
}
