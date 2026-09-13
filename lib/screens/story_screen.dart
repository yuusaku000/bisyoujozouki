import 'package:flutter/material.dart';

import '../data/enemies.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/enemy.dart';
import '../models/organ.dart';

/// 1話を読む画面。タップで1行ずつ進む。
class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.episode,
    required this.userName,
    this.onRead,
  });

  final StoryEpisode episode;

  /// セリフの中でこの人を呼ぶときの名前。名前で呼ばれるかどうかで、
  /// 同じ一行の近さが変わる。
  final String userName;

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
            storyText(line.text, widget.userName),
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
