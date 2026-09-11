import 'package:flutter/material.dart';

import '../data/presents.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/present.dart';
import '../widgets/ornate.dart';

/// チケットを使ってプレゼントを引く。出たものは臓器に渡して親密度になる。
class GachaTab extends StatefulWidget {
  const GachaTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  @override
  State<GachaTab> createState() => _GachaTabState();
}

class _GachaTabState extends State<GachaTab> {
  GameState get state => widget.state;

  Future<void> _pull({required bool ten}) async {
    final results = state.pull(ten: ten);
    if (results.isEmpty) return;
    widget.onChanged();
    await _showResults(results);
  }

  Future<void> _showResults(List<Present> results) {
    final best = results.reduce(
      (a, b) => b.rarity.stars > a.rarity.stars ? b : a,
    );

    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: OrnatePanel(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          borderColor: best.rarity.color,
          glow: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: OrnateLabel('けっか', color: best.rarity.color)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final present in results) ...[
                        _resultRow(present),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              JewelButton(
                label: 'とじる',
                height: 46,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(Present present) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: present.rarity.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: present.rarity.color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(present.icon, size: 22, color: present.rarity.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  present.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '親密度 +${present.affection}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _stars(present.rarity),
        ],
      ),
    );
  }

  Widget _stars(Rarity rarity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rarity.stars; i++)
          Icon(Icons.star, size: 12, color: rarity.color),
      ],
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
                    'ガチャ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.hollow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.goldDim.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          size: 13,
                          color: AppColors.rose,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${state.tickets}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.rose,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  OrnatePanel(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    borderColor: AppColors.rose,
                    glow: true,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          size: 46,
                          color: AppColors.rose,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'おくりものガチャ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '出たものは、あの子たちに渡せます',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        JewelButton(
                          label: '1回ひく　チケット ×$kGachaCost',
                          height: 50,
                          onPressed: state.canPull
                              ? () => _pull(ten: false)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        JewelButton(
                          label: '10回ひく　チケット ×$kGachaTenCost',
                          height: 50,
                          gradient: AppColors.goldGradient,
                          onPressed: state.canPullTen
                              ? () => _pull(ten: true)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '10回ひくと、SR以上が必ず1つ出ます',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: OrnateLabel('でるもの')),
                  const SizedBox(height: 12),
                  for (final rarity in Rarity.values.reversed) ...[
                    _rarityBlock(rarity),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rarityBlock(Rarity rarity) {
    final rate = kGachaWeights[rarity] ?? 0;
    final total = kGachaWeights.values.reduce((a, b) => a + b);
    final items = presentsOf(rarity);

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      borderColor: rarity.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stars(rarity),
              const SizedBox(width: 8),
              Text(
                rarity.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: rarity.color,
                ),
              ),
              const Spacer(),
              Text(
                '${(rate / total * 100).toStringAsFixed(rate < 5 ? 1 : 0)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final present in items)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.hollow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(present.icon, size: 12, color: rarity.color),
                      const SizedBox(width: 6),
                      Text(present.name, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
