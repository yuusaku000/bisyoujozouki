import 'package:flutter/material.dart';

import '../data/lines.dart';
import '../data/organs.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';
import '../widgets/scene.dart';
import '../widgets/top_toast.dart';

/// コインの使い道。歩いた分をここで形にする。
class ShopTab extends StatelessWidget {
  const ShopTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  static const int keyPrice = 25000;
  static const int ticketPrice = 2500;

  /// まとめ買い。値段は単品10枚ぶんと同じで、押す回数が減るだけ。
  static const int bundleSize = 10;
  static const int bundlePrice = ticketPrice * bundleSize;

  void _buyBundle(BuildContext context) {
    const price = bundlePrice;
    if (state.coins < price) return;
    state.coins -= price;
    state.tickets += bundleSize;
    onChanged();
    showTopToast(
      context,
      'ガチャチケット ×$bundleSize を買いました',
      icon: Icons.shopping_bag,
    );
  }

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

  /// 店番。帳簿をつけるのは肝臓の仕事なので、いるなら肝臓が立つ。
  Organ _keeper() {
    final party = state.party;
    for (final organ in party) {
      if (organ.id == 'liver') return organ;
    }
    return party.isEmpty ? organById('heart') : party.first;
  }

  @override
  Widget build(BuildContext context) {
    return SceneBackdrop(
      tint: AppColors.gold,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SceneHeader(
              title: 'ショップ',
              trailing: CountPill(
                icon: Icons.circle,
                value: formatCoins(state.coins),
                color: AppColors.gold,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  _keeperPanel(),
                  const SizedBox(height: 14),
                  _item(
                    context,
                    icon: Icons.vpn_key,
                    color: AppColors.gold,
                    name: '解放の鍵',
                    detail: 'レベルの上限を1段ぶん引き上げる',
                    price: keyPrice,
                    owned: state.keys,
                    premium: true,
                    onBuy: () => _buy(context, keys: 1),
                  ),
                  const SizedBox(height: 12),
                  _item(
                    context,
                    icon: Icons.confirmation_number,
                    color: AppColors.rose,
                    name: 'ガチャチケット',
                    detail: 'おくりものを引く。渡すと親密度が上がる',
                    price: ticketPrice,
                    owned: state.tickets,
                    onBuy: () => _buy(context, tickets: 1),
                  ),
                  const SizedBox(height: 12),
                  _item(
                    context,
                    icon: Icons.confirmation_number,
                    color: AppColors.gold,
                    name: 'ガチャチケット ×$bundleSize',
                    detail: '10連ぶんをまとめて',
                    price: bundlePrice,
                    owned: state.tickets,
                    onBuy: () => _buyBundle(context),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: OrnateLabel('鍵の集めかた')),
                  const SizedBox(height: 12),
                  _hint('ボスを倒す', '10ステージごとのボスが1個落とします'),
                  _hint('きつい目標を達成する', '8000歩、階段25階、生活を全部整える'),
                  _hint('3つの目標をそろえる', 'その日の目標を全部達成すると1個'),
                  _hint('ここで買う', 'コインは歩いた分だけ貯まります'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 店番の立ち絵とひとこと。ここだけ人がいないと、倉庫の画面に見える。
  Widget _keeperPanel() {
    final organ = _keeper();

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      borderColor: AppColors.goldDim,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CharacterBust(organ: organ, width: 78, height: 94),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organ.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: organ.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kShopLines[organ.id] ?? 'いらっしゃいませ。',
                  style: const TextStyle(fontSize: 12.5, height: 1.5),
                ),
              ],
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
    bool premium = false,
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
            gradient: !affordable
                ? const LinearGradient(
                    colors: [Color(0xFF4A3556), Color(0xFF2E2038)],
                  )
                // 鍵だけ色を変える。同じボタンが縦に並ぶと、どれも同じに見える。
                : premium
                ? AppColors.goldGradient
                : AppColors.roseGradient,
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
