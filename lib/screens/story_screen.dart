import 'package:flutter/material.dart';

import '../data/chara_story.dart';
import '../data/enemies.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/enemy.dart';
import '../models/organ.dart';
import '../widgets/ornate.dart';

/// 1話を読む画面。タップで1行ずつ進む。
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.episode, this.onRead});

  final StoryEpisode episode;

  /// 最後まで読んだときに呼ばれる。仲間が増えるのはこの瞬間。
  final VoidCallback? onRead;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _index = 0;
  bool _notified = false;

  bool get _isLast => _index >= widget.episode.lines.length - 1;

  @override
  void initState() {
    super.initState();
    if (_isLast) _markRead();
  }

  void _markRead() {
    if (_notified) return;
    _notified = true;
    widget.onRead?.call();
  }

  void _advance() {
    if (_isLast) {
      Navigator.pop(context);
      return;
    }
    setState(() => _index++);
    if (_isLast) _markRead();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.episode.lines[_index];
    final speaker = line.speakerId == null ? null : organById(line.speakerId!);
    final enemy = line.enemyId == null ? null : enemyById(line.enemyId!);

    return Scaffold(
      body: GestureDetector(
        onTap: _advance,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 敵と対峙している場面で部屋が映っていると緊張感が消える
            Image.asset(
              enemy == null
                  ? 'assets/bg/bg_home.png'
                  : enemy.isBoss
                  ? 'assets/bg/bg_stomach.png'
                  : 'assets/bg/bg_vessel.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.1,
                  colors: [
                    // 敵が出ている行は空気ごと暗くする
                    enemy != null
                        ? const Color(0xFF3A1020).withValues(alpha: 0.55)
                        : (speaker?.accent ?? AppColors.rose).withValues(
                            alpha: 0.22,
                          ),
                    const Color(0xF2120A16),
                  ],
                ),
              ),
            ),
            if (enemy != null)
              _enemyFigure(enemy)
            else if (speaker != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.72,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Image.asset(
                      speaker.imagePath(line.face),
                      key: ValueKey('${speaker.id}_${line.face.name}'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  _header(),
                  const Spacer(),
                  _textPanel(line, speaker),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 敵は画面の上半分に大きく据える。臓器の立ち絵と同じ位置に置くと、
  /// 仲間の一人のように見えてしまう。
  Widget _enemyFigure(Enemy enemy) {
    return Align(
      alignment: const Alignment(0, -0.28),
      child: FractionallySizedBox(
        heightFactor: 0.56,
        widthFactor: 0.86,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: ColorFiltered(
            key: ValueKey(enemy.id),
            colorFilter: const ColorFilter.mode(
              Color(0x33000000),
              BlendMode.srcATop,
            ),
            child: Image.asset(enemy.imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          Flexible(
            child: Text(
              widget.episode.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _textPanel(StoryLine line, Organ? speaker) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (speaker?.accent ?? AppColors.goldDim).withValues(alpha: 0.7),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (speaker != null) ...[
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    speaker.facePath(line.face),
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  speaker.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: speaker.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(
            line.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: speaker == null
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${_index + 1} / ${widget.episode.lines.length}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                _isLast ? 'タップでとじる' : 'タップでつづき',
                style: const TextStyle(fontSize: 12, color: AppColors.rose),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 解放済みの話の一覧。
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
  final void Function(String key)? onRead;
  final int Function(String organId) heartsOf;

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  int get clearedStage => widget.clearedStage;
  Set<String> get readEpisodes => widget.readEpisodes;

  /// 読み終えて戻ってきたら、しるしを消すために組み直す。
  Future<void> _open(StoryEpisode episode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          episode: episode,
          onRead: () => widget.onRead?.call(episode.key),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = unlockedEpisodes(clearedStage);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ストーリー',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: OrnateLabel('本編')),
          const SizedBox(height: 14),
          for (final episode in kStory) ...[
            _row(
              open: unlocked.contains(episode),
              unread:
                  unlocked.contains(episode) &&
                  !readEpisodes.contains(episode.key),
              child: _card(context, episode, unlocked.contains(episode)),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          const Center(child: OrnateLabel('あの子のはなし')),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              '親密度を上げると読めるようになります',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          for (final organ in kOrgans)
            for (final episode in episodesForOrgan(organ.id)) ...[
              _row(
                open: widget.heartsOf(organ.id) >= episode.requiredHearts,
                unread:
                    widget.heartsOf(organ.id) >= episode.requiredHearts &&
                    !readEpisodes.contains(episode.key),
                child: _charaCard(context, organ, episode),
              ),
              const SizedBox(height: 10),
            ],
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

  Future<void> _openChara(CharaEpisode episode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryScreen(
          episode: StoryEpisode(
            stage: 0,
            title: episode.title,
            lines: episode.lines,
          ),
          onRead: () => widget.onRead?.call(episode.key),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _charaCard(BuildContext context, Organ organ, CharaEpisode episode) {
    final open = widget.heartsOf(organ.id) >= episode.requiredHearts;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: open ? () => _openChara(episode) : null,
        child: OrnatePanel(
          padding: const EdgeInsets.all(14),
          borderColor: open ? organ.accent : AppColors.goldDim,
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  organ.facePath(Condition.genki),
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      open ? episode.title : '？？？',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      open
                          ? organ.name
                          : '${organ.name}　♡${episode.requiredHearts} で解放',
                      style: TextStyle(
                        fontSize: 11,
                        color: open ? organ.accent : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!open)
                const Icon(Icons.lock, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, StoryEpisode episode, bool open) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: open ? () => _open(episode) : null,
        child: OrnatePanel(
          padding: const EdgeInsets.all(16),
          borderColor: open ? AppColors.rose : AppColors.goldDim,
          child: Row(
            children: [
              Icon(
                open ? Icons.auto_stories : Icons.lock,
                size: 18,
                color: open ? AppColors.rose : AppColors.textMuted,
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  open ? episode.title : '？？？',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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
