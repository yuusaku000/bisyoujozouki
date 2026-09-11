import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/game_state.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';
import '../widgets/top_toast.dart';

/// コインの使い道。歩いた分をここで形にする。
class ShopTab extends StatelessWidget {
  const ShopTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  static const int keyPrice = 30000;
  static const int ticketPrice = 5000;

  void _buy(BuildContext context, {int keys = 0, int tickets = 0}) {
    final price = keys * keyPrice + tickets * ticketPrice;
    if (state.coins < price) return;
    state.coins -= price;
    state.keys += keys;
    state.tickets += tickets;
    onChanged();
    showTopToast(
      context,
      keys > 0 ? '解放の鍵 ×$keys を買いました' : 'ガチャチケット ×$tickets を買いました',
      icon: Icons.shopping_bag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  const Text(
                    'ショップ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  _counter(
                    Icons.circle,
                    formatCoins(state.coins),
                    AppColors.gold,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  _item(
                    context,
                    icon: Icons.vpn_key,
                    color: AppColors.gold,
                    name: '解放の鍵',
                    detail: 'レベルの上限を1段ぶん引き上げる',
                    price: keyPrice,
                    owned: state.keys,
                    onBuy: () => _buy(context, keys: 1),
                  ),
                  const SizedBox(height: 12),
                  _item(
                    context,
                    icon: Icons.confirmation_number,
                    color: AppColors.rose,
                    name: 'ガチャチケット',
                    detail: '衣装を引くのに使う（準備中）',
                    price: ticketPrice,
                    owned: state.tickets,
                    onBuy: () => _buy(context, tickets: 1),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: OrnateLabel('鍵の集めかた')),
                  const SizedBox(height: 12),
                  _hint('ボスを倒す', '10ステージごとのボスが1個落とします'),
                  _hint('きつい目標を達成する', '8000歩、階段25階、生活を全部整える'),
                  _hint('ここで買う', 'コインは歩いた分だけ貯まります'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String name,
    required String detail,
    required int price,
    required int owned,
    required VoidCallback onBuy,
  }) {
    final affordable = state.coins >= price;
    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderColor: color,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '所持 $owned',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          JewelButton(
            label: '${formatCoins(price)} で買う',
            height: 46,
            gradient: affordable
                ? AppColors.roseGradient
                : const LinearGradient(
                    colors: [Color(0xFF4A3556), Color(0xFF2E2038)],
                  ),
            onPressed: affordable ? onBuy : null,
          ),
        ],
      ),
    );
  }

  Widget _hint(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  detail,
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
    );
  }
}
