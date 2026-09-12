import 'package:flutter/material.dart';

import '../data/chara_story.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/organ.dart';
import '../widgets/ornate.dart';
import 'story_screen.dart';

/// 話の一覧。本編とキャラ別を分け、キャラ別は子ごとに切り替える。
/// 30話を縦に並べると、目当ての話まで延々とスクロールすることになる。
class StoryListScreen extends StatefulWidget {
  const StoryListScreen({
    super.key,
    required this.clearedStage,
    required this.readEpisodes,
    required this.heartsOf,
    this.onRead,
  });

  final int clearedStage;
  final Set<String> readEpisodes;
  final int Function(String organId) heartsOf;
  final void Function(String key)? onRead;

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  int _organIndex = 0;

  Set<String> get read => widget.readEpisodes;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _open(StoryEpisode episode, String key) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          episode: episode,
          onRead: () => widget.onRead?.call(key),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  bool _mainUnread(StoryEpisode e) =>
      e.stage <= widget.clearedStage && !read.contains(e.key);

  bool _charaUnread(CharaEpisode e) =>
      widget.heartsOf(e.organId) >= e.requiredHearts && !read.contains(e.key);

  @override
  Widget build(BuildContext context) {
    final charaUnread = kCharaStory.any(_charaUnread);
    final mainUnread = kStory.any(_mainUnread);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ストーリー',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.rose,
          labelColor: AppColors.rose,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          tabs: [
            Tab(child: _tabLabel('本編', mainUnread)),
            Tab(child: _tabLabel('あの子のはなし', charaUnread)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_mainList(), _charaList()],
      ),
    );
  }

  Widget _tabLabel(String text, bool unread) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (unread) ...[const SizedBox(width: 7), const UnreadDot(size: 8)],
      ],
    );
  }

  /// まだ開いていない話は出さない。題名だけでも見えると、
  /// この先なにが起きるかが分かってしまう。
  Widget _mainList() {
    final open = unlockedEpisodes(widget.clearedStage);
    final hasMore = open.length < kStory.length;

    if (open.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'ステージに挑むと、お話が増えていきます',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: open.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == open.length) return _more();
        final episode = open[i];
        return _row(
          open: true,
          unread: _mainUnread(episode),
          child: _card(
            title: episode.title,
            subtitle: '第${i + 1}話',
            color: AppColors.rose,
            icon: Icons.auto_stories,
            onTap: () => _open(episode, episode.key),
          ),
        );
      },
    );
  }

  /// この先があることだけ伝える。何話あるかも、題名も出さない。
  Widget _more() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          'つづきは、先に進むと',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ),
    );
  }

  /// キャラ別は子ごとに切り替える。全員ぶん並べると長すぎる。
  Widget _charaList() {
    final organ = kOrgans[_organIndex];
    final episodes = episodesForOrgan(organ.id);
    final hearts = widget.heartsOf(organ.id);

    return Column(
      children: [
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: kOrgans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _organChip(i),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Text(
                organ.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: organ.accent,
                ),
              ),
              const Spacer(),
              for (var h = 0; h < OrganStatus.maxHearts; h++)
                Icon(
                  h < hearts ? Icons.favorite : Icons.favorite_border,
                  size: 14,
                  color: h < hearts
                      ? AppColors.rose
                      : AppColors.textMuted.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final episode = episodes[i];
              final open = hearts >= episode.requiredHearts;
              return _row(
                open: open,
                unread: _charaUnread(episode),
                child: _card(
                  title: open ? episode.title : '？？？',
                  subtitle: '♡${episode.requiredHearts} で解放',
                  color: open ? organ.accent : AppColors.goldDim,
                  icon: open ? Icons.favorite : Icons.lock,
                  onTap: open
                      ? () => _open(
                          StoryEpisode(
                            stage: 0,
                            title: episode.title,
                            lines: episode.lines,
                          ),
                          episode.key,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _organChip(int i) {
    final organ = kOrgans[i];
    final selected = i == _organIndex;
    final unread = episodesForOrgan(organ.id).any(_charaUnread);

    return GestureDetector(
      onTap: () => setState(() => _organIndex = i),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 52 : 44,
            height: selected ? 52 : 44,
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
                        color: organ.accent.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                organ.facePath(Condition.genki),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (unread)
            const Positioned(top: -3, right: -3, child: UnreadDot(size: 9)),
        ],
      ),
    );
  }

  Widget _row({
    required bool open,
    required bool unread,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: open ? 1 : 0.45, child: child),
        if (unread) const Positioned(top: -4, right: -4, child: UnreadDot()),
      ],
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: OrnatePanel(
          padding: const EdgeInsets.all(14),
          borderColor: color,
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
        ),
      ),
    );
  }
}

/// 未読のしるし。数は要らない。新しいものがあるかどうかだけ分かればいい。
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key, this.size = 11});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B4E),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B4E).withValues(alpha: 0.85),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}
