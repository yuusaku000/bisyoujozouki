import 'dart:math';

import 'package:flutter/material.dart';

import '../data/lines.dart';
import '../data/organs.dart';
import '../data/presents.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../models/present.dart';
import '../widgets/ornate.dart';
import '../widgets/scene.dart';
import 'gacha_reveal.dart';

/// チケットを使ってプレゼントを引く。出たものは臓器に渡して親密度になる。
class GachaTab extends StatefulWidget {
  const GachaTab({
    super.key,
    required this.state,
    required this.onChanged,
    this.visit = 0,
  });

  final GameState state;
  final VoidCallback onChanged;

  /// タブを開き直した回数。変わるたびに立つ子を引き直す。
  final int visit;

  @override
  State<GachaTab> createState() => _GachaTabState();
}

class _GachaTabState extends State<GachaTab> {
  GameState get state => widget.state;

  /// 立つ子を決める数。開き直すたびに引き直す。
  ///
  /// 毎フレーム引き直すと、触るたびに入れ替わって落ち着かない。
  /// 開いているあいだは同じ子のままにする。
  int _seed = Random().nextInt(1 << 30);

  @override
  void didUpdateWidget(GachaTab old) {
    super.didUpdateWidget(old);
    if (old.visit != widget.visit) _seed = Random().nextInt(1 << 30);
  }

  Future<void> _pull({required bool ten}) async {
    final results = state.pull(ten: ten);
    if (results.isEmpty) return;
    widget.onChanged();

    final best = results.reduce(
      (a, b) => b.rarity.stars > a.rarity.stars ? b : a,
    );
    await Navigator.push(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => GachaReveal(best: best.rarity),
      ),
    );
    if (!mounted) return;
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

  /// 立つ子。仲間の中から適当にひとり。
  ///
  /// まだ誰とも会っていないうちは心臓が立つ。
  Organ get _waiting {
    final party = state.party;
    if (party.isEmpty) return organById('heart');
    return party[_seed % party.length];
  }

  @override
  Widget build(BuildContext context) {
    return SceneBackdrop(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SceneHeader(
              title: 'ガチャ',
              trailing: CountPill(
                icon: Icons.confirmation_number,
                value: '${state.tickets}',
                color: AppColors.rose,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  _drawPanel(),
                  const SizedBox(height: 22),
                  const Center(child: OrnateLabel('でるもの')),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'ハートのついたものは、その子の好物。渡すと倍になります',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
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

  Widget _drawPanel() {
    final organ = _waiting;

    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      borderColor: AppColors.rose,
      glow: true,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CharacterBust(organ: organ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'おくりものガチャ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bubble(organ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          JewelButton(
            label: '1回ひく　チケット ×$kGachaCost',
            height: 50,
            onPressed: state.canPull ? () => _pull(ten: false) : null,
          ),
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              JewelButton(
                label: '10回ひく　チケット ×$kGachaTenCost',
                height: 50,
                gradient: AppColors.goldGradient,
                onPressed: state.canPullTen ? () => _pull(ten: true) : null,
              ),
              // 得なほうが分かるように、札を貼っておく。
              Positioned(top: -7, right: 10, child: _tag('SR 確定')),
            ],
          ),
        ],
      ),
    );
  }

  /// その子の待っている一言。吹き出しの形にして、画面の中の声だと分かるように。
  Widget _bubble(Organ organ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: organ.accent.withValues(alpha: 0.6)),
      ),
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
          const SizedBox(height: 3),
          Text(
            kGachaWaitLines[organ.id] ?? '……なにか、くれるんですか。',
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.roseDeep,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.rose),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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
              for (final present in items) _presentChip(present, rarity),
            ],
          ),
        ],
      ),
    );
  }

  /// でるもの1つ。好物なら、その子の顔をつける。
  ///
  /// 誰の好物かが分かると、引く前から渡す相手が決まる。
  /// データには前から入っていたのに、どこにも出していなかった。
  Widget _presentChip(Present present, Rarity rarity) {
    final owner = present.favoriteOf;
    final organ = owner == null ? null : organById(owner);

    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, organ == null ? 10 : 5, 5),
      decoration: BoxDecoration(
        color: AppColors.hollow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (organ?.accent ?? rarity.color).withValues(
            alpha: organ == null ? 0.25 : 0.75,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(present.icon, size: 12, color: rarity.color),
          const SizedBox(width: 6),
          Text(present.name, style: const TextStyle(fontSize: 11)),
          if (organ != null) ...[
            const SizedBox(width: 7),
            Icon(Icons.favorite, size: 9, color: organ.accent),
            const SizedBox(width: 3),
            ClipOval(
              child: Image.asset(
                organ.facePath(Condition.genki),
                width: 18,
                height: 18,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
