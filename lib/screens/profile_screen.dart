import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/achievements.dart';
import '../data/avatars.dart';
import '../data/chara_story.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';
import '../widgets/progress_ring.dart';

/// あなたの記録。
///
/// 積み上げた数字がどこにも出ていないと、続けている実感が数字に戻らない。
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final GameState state;
  final VoidCallback onChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GameState get state => widget.state;

  void _pick(Avatar avatar) {
    if (state.avatarId == avatar.id) return;
    setState(() => state.avatarId = avatar.id);
    widget.onChanged();
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: state.userName);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: OrnatePanel(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: OrnateLabel('なまえ')),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                maxLength: GameState.maxNameLength,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                onSubmitted: (v) => Navigator.pop(context, v),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.hollow,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.goldDim.withValues(alpha: 0.7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.rose,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: QuietButton(
                      label: 'やめる',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JewelButton(
                      label: '決める',
                      height: 48,
                      onPressed: () => Navigator.pop(context, controller.text),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;
    final trimmed = name?.trim() ?? '';
    // 空にはできない。名前が消えると、呼びかける相手がいなくなる。
    if (trimmed.isEmpty) return;

    setState(() => state.userName = trimmed);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'プロフィール',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _card(),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('これまで')),
          const SizedBox(height: 12),
          _records(),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('アイコン')),
          const SizedBox(height: 12),
          _picker(),
        ],
      ),
    );
  }

  // ── 名刺 ──────────────────────────────────────────────

  Widget _card() {
    final avatar = avatarOf(state);
    final done = kAchievements.where((a) => a.isDone(state)).length;

    return OrnatePanel(
      glow: true,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Row(
        children: [
          AvatarCircle(avatar: avatar, size: 76, border: 2.2),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        state.hasName ? state.userName : 'なまえ未設定',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: state.hasName
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _rename,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          size: 15,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.dayCount}日目 ・ ステージ ${state.clearedStage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ProgressRing(
                      ratio: done / kAchievements.length,
                      size: 26,
                      thickness: 2.4,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'あしあと $done / ${kAchievements.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 記録 ──────────────────────────────────────────────

  Widget _records() {
    final mainRead = kStory.where((e) => state.readEpisodes.contains(e.key));
    final charaRead = kCharaStory.where(
      (e) => state.readEpisodes.contains(e.key),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _big('つづけた日数', '${state.dayCount}', '日')),
            const SizedBox(width: 10),
            Expanded(child: _big('あるいた歩数', formatCoins(state.totalSteps), '歩')),
          ],
        ),
        const SizedBox(height: 10),
        OrnatePanel(
          child: Column(
            children: [
              _row('いまの目標', '${formatCoins(state.stepGoal)} 歩'),
              _row('到達ステージ', '${state.clearedStage}'),
              _row('仲間', '${state.party.length} / 5'),
              _row('本編', '${mainRead.length} / ${kStory.length} 話'),
              _row('あの子のはなし', '${charaRead.length} / ${kCharaStory.length} 話'),
              _row('もっているコイン', formatCoins(state.coins)),
            ],
          ),
        ),
      ],
    );
  }

  /// 目立たせたい2つだけ大きく出す。全部同じ大きさだと表になってしまう。
  Widget _big(String label, String value, String unit) {
    return OrnatePanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ── アイコン選び ──────────────────────────────────────

  Widget _picker() {
    final organs = organAvatars(state);
    final enemies = enemyAvatars(state);

    return OrnatePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pickerGroup('出会った子', organs, 5 - organs.length),
          if (enemies.isNotEmpty) ...[
            const SizedBox(height: 16),
            _pickerGroup('倒した相手', enemies, 0),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              '倒した相手も、ここから選べるようになります',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pickerGroup(String title, List<Avatar> avatars, int locked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final avatar in avatars) _choice(avatar),
            // まだ来ていないぶんは錠前で見せる。増えることが分かる。
            for (var i = 0; i < locked; i++) _lockedChoice(),
          ],
        ),
      ],
    );
  }

  Widget _choice(Avatar avatar) {
    final selected = avatarOf(state).id == avatar.id;

    return GestureDetector(
      onTap: () => _pick(avatar),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarCircle(
            avatar: avatar,
            size: selected ? 58 : 52,
            border: selected ? 2.6 : 1.2,
            color: selected ? AppColors.rose : AppColors.goldDim,
            glow: selected,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 62,
            child: Text(
              avatar.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                color: selected ? AppColors.rose : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedChoice() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.hollow,
            border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.4)),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        const SizedBox(width: 62, height: 12),
      ],
    );
  }
}

/// 丸いアイコン。
///
/// 敵の絵は顔用に切り出していないので、そのまま丸に収めると
/// body ばかり映る。上寄せにして顔が入るようにする。
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.avatar,
    this.size = 52,
    this.border = 1.4,
    this.color = AppColors.rose,
    this.glow = false,
  });

  final Avatar avatar;
  final double size;
  final double border;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.hollow,
        border: Border.all(color: color, width: border),
        boxShadow: glow
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          avatar.imagePath,
          fit: BoxFit.cover,
          alignment: avatar.isEnemy ? Alignment.topCenter : Alignment.center,
        ),
      ),
    );
  }
}
