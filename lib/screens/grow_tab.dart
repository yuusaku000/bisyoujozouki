import 'package:flutter/material.dart';

import '../data/lines.dart';
import '../data/sounds.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../services/audio.dart';
import '../widgets/coin_text.dart';
import '../widgets/health_bar.dart';
import '../widgets/ornate.dart';
import 'ascend_up.dart';
import 'heart_up.dart';
import 'present_sheet.dart';

/// 一人ずつ、全身で向き合う場所。一覧に詰め込むと誰の顔も見えない。
class GrowTab extends StatefulWidget {
  const GrowTab({super.key, required this.state, required this.onChanged});

  final GameState state;
  final VoidCallback onChanged;

  @override
  State<GrowTab> createState() => _GrowTabState();
}

class _GrowTabState extends State<GrowTab> {
  final _pages = PageController();
  int _index = 0;

  /// 直近の反応。しばらくすると消える。
  String? _reaction;

  GameState get state => widget.state;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  int _sayId = 0;

  /// 反応はしばらく残す。すぐ消えると、何か言ったことにすら気づかない。
  void _say(String text) {
    final id = ++_sayId;
    setState(() => _reaction = text);
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _sayId == id) setState(() => _reaction = null);
    });
  }

  void _levelUp(Organ organ) {
    if (!state.canLevelUp(organ.id)) return;
    Audio.instance.playSfx(Sfx.levelUp);
    state.levelUp(organ.id);
    widget.onChanged();
    _say(levelUpLine(organ.id, state.statusOf(organ.id).level));
  }

  Future<void> _ascend(Organ organ) async {
    if (!state.canAscend(organ.id)) return;
    // 鍵を使い切る一度きりの節目なので、重い音にする。
    Audio.instance.playSfx(Sfx.heavy);
    state.ascend(organ.id);
    widget.onChanged();

    // 鍵を使い切る一度きりの節目。一言で流さず、画面ごと止めて見せる。
    await Navigator.push(
      context,
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => AscendOverlay(
          organ: organ,
          levelCap: state.statusOf(organ.id).levelCap,
          line: kAscendLines[organ.id] ?? '……ありがとう。',
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPresents(Organ organ) async {
    final before = state.statusOf(organ.id).hearts;
    final given = await showModalBottomSheet<GiftResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PresentSheet(state: state, organ: organ),
    );
    if (given == null || !mounted) return;
    widget.onChanged();

    final after = state.statusOf(organ.id).hearts;
    if (after > before) {
      Audio.instance.playSfx(Sfx.heart);
      await Navigator.push(
        context,
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, _, _) => HeartUpOverlay(
            organ: organ,
            hearts: after,
            line: heartUpLine(organ.id, after),
          ),
        ),
      );
      if (mounted) setState(() {});
      return;
    }

    _say(
      giftLine(
        organ.id,
        favorite: given.favorite,
        seed: state.statusOf(organ.id).affection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final party = state.party;
    if (party.isEmpty) {
      return const ColoredBox(color: AppColors.background);
    }
    final organ = party[_index.clamp(0, party.length - 1)];
    final status = state.statusOf(organ.id);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.background),
        AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              center: const Alignment(0, -0.35),
              colors: [
                organ.accent.withValues(alpha: 0.36),
                organ.accent.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        PageView.builder(
          controller: _pages,
          itemCount: party.length,
          onPageChanged: (i) => setState(() {
            _index = i;
            _reaction = null;
          }),
          itemBuilder: (context, i) => _figure(party[i]),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC170E1A), Color(0x00170E1A), Color(0xF5120A16)],
              stops: [0.0, 0.28, 0.62],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              const Spacer(),
              if (_reaction != null) _reactionBubble(organ),
              _faceStrip(party),
              const SizedBox(height: 8),
              _panel(organ, status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _figure(Organ organ) {
    final condition = state.statusOf(organ.id).condition;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Align(
        alignment: Alignment.topCenter,
        child: Image.asset(organ.imagePath(condition), fit: BoxFit.contain),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          const Text(
            '育成',
            style: TextStyle(
              fontSize: 18,
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
        color: AppColors.hollow.withValues(alpha: 0.85),
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

  Widget _reactionBubble(Organ organ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: GestureDetector(
        onTap: () => setState(() => _reaction = null),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: AppColors.panelGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: organ.accent, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: organ.accent.withValues(alpha: 0.4),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  organ.facePath(Condition.genki),
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _reaction!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 横スワイプだけだと切り替えられることに気づけない。顔を並べて押せるようにする。
  Widget _faceStrip(List<Organ> party) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: party.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final organ = party[i];
          final selected = i == _index;
          final status = state.statusOf(organ.id);
          return GestureDetector(
            onTap: () {
              _pages.animateToPage(
                i,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              );
              setState(() {
                _index = i;
                _reaction = null;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 42 : 36,
                  height: selected ? 42 : 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? organ.accent
                          : AppColors.goldDim.withValues(alpha: 0.6),
                      width: selected ? 2.4 : 1.4,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: organ.accent.withValues(alpha: 0.55),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      organ.facePath(status.condition),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var h = 0; h < status.hearts; h++)
                      const Icon(
                        Icons.favorite,
                        size: 7,
                        color: AppColors.rose,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _panel(Organ organ, OrganStatus status) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: OrnatePanel(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        borderColor: organ.accent,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  organ.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
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
                const Spacer(),
                _hearts(status),
              ],
            ),
            const SizedBox(height: 10),
            _affectionBar(status),
            const SizedBox(height: 12),
            HealthBar(status: status),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: QuietButton(
                    label: 'プレゼント',
                    icon: Icons.card_giftcard,
                    onPressed: state.ownedPresents.isEmpty
                        ? null
                        : () => _openPresents(organ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: status.atCap
                      ? QuietButton(
                          label: '限界を解く ×${status.keysToAscend}',
                          icon: Icons.vpn_key,
                          onPressed: state.canAscend(organ.id)
                              ? () => _ascend(organ)
                              : null,
                        )
                      : QuietButton(
                          label: formatCoins(status.levelUpCost()),
                          icon: Icons.arrow_upward,
                          coin: true,
                          onPressed: state.canLevelUp(organ.id)
                              ? () => _levelUp(organ)
                              : null,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hearts(OrganStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < OrganStatus.maxHearts; i++)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(
              i < status.hearts ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: i < status.hearts
                  ? AppColors.rose
                  : AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }

  Widget _affectionBar(OrganStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '親密度',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                letterSpacing: 1.8,
              ),
            ),
            const Spacer(),
            Text(
              status.heartsMaxed
                  ? 'これ以上ないくらい'
                  : 'つぎの♡まで ${status.affectionToNextHeart}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        JewelBar(
          value: status.heartProgress,
          height: 9,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB3C9), AppColors.roseDeep],
          ),
        ),
      ],
    );
  }
}
