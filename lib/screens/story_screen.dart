import 'package:flutter/material.dart';

import '../data/organs.dart';
import '../data/story.dart';
import '../data/theme.dart';
import '../models/organ.dart';

/// 1話を読む画面。タップで1行ずつ進む。
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.episode});

  final StoryEpisode episode;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _index = 0;

  bool get _isLast => _index >= widget.episode.lines.length - 1;

  void _advance() {
    if (_isLast) {
      Navigator.pop(context);
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.episode.lines[_index];
    final speaker = line.speakerId == null ? null : organById(line.speakerId!);

    return Scaffold(
      body: GestureDetector(
        onTap: _advance,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/bg/bg_home.png', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xDD16111A)),
            ),
            if (speaker != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.72,
                  child: Image.asset(
                    speaker.imagePath(Condition.futsuu),
                    fit: BoxFit.contain,
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
        color: AppColors.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (speaker != null) ...[
            Text(
              speaker.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: speaker.accent,
              ),
            ),
            const SizedBox(height: 8),
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 解放済みの話の一覧。
class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key, required this.clearedStage});

  final int clearedStage;

  @override
  Widget build(BuildContext context) {
    final unlocked = unlockedEpisodes(clearedStage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ストーリー',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.background,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kStory.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final episode = kStory[i];
          final open = unlocked.contains(episode);
          return Opacity(
            opacity: open ? 1 : 0.45,
            child: Material(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: open
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryScreen(episode: episode),
                          ),
                        )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        open ? Icons.menu_book : Icons.lock,
                        size: 18,
                        color: open ? AppColors.accent : AppColors.textMuted,
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
                      Text(
                        'ステージ ${episode.stage}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
