import 'dart:async';

import 'package:flutter/material.dart';

import '../data/enemies.dart';
import '../data/theme.dart';
import '../models/battle.dart';
import '../models/game_state.dart';

/// 自動戦闘を1行ずつ再生する。結果は開始時点で確定している。
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.state});

  final GameState state;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final int _stage = widget.state.currentStage;
  late final BattleResult _result =
      Battle(organs: widget.state.organs, stage: _stage).run();

  final _scroll = ScrollController();
  Timer? _timer;
  int _shown = 0;

  int _partyHp = 0;
  int _enemyHp = 0;

  @override
  void initState() {
    super.initState();
    _partyHp = _result.partyMaxHp;
    _enemyHp = _result.enemyMaxHp;
    _timer = Timer.periodic(const Duration(milliseconds: 420), (t) {
      if (_shown >= _result.log.length) {
        t.cancel();
        _finish();
        return;
      }
      setState(() {
        final event = _result.log[_shown];
        _applyToBars(event);
        _shown++;
      });
      _scrollToEnd();
    });
  }

  /// バーの動きはログの再生に合わせる。どの一撃で削れたのかが見えるように。
  void _applyToBars(BattleEvent event) {
    if (event.heal != null) {
      _partyHp = (_partyHp + event.heal!).clamp(0, _result.partyMaxHp);
      return;
    }
    final damage = event.damage;
    if (damage == null) return;
    if (event.actorId != null || event.text.startsWith('継続')) {
      _enemyHp = (_enemyHp - damage).clamp(0, _result.enemyMaxHp);
    } else {
      _partyHp = (_partyHp - damage).clamp(0, _result.partyMaxHp);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  void _finish() {
    if (_result.won) widget.state.clearStage(_stage);
    setState(() {});
  }

  void _skip() {
    _timer?.cancel();
    setState(() {
      _shown = _result.log.length;
      _partyHp = _result.partyHp;
      _enemyHp = _result.enemyHp;
    });
    _finish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  bool get _done => _shown >= _result.log.length;

  @override
  Widget build(BuildContext context) {
    final enemy = enemyForStage(_stage);
    final background =
        enemy.isBoss ? 'assets/bg/bg_stomach.png' : 'assets/bg/bg_vessel.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(background, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xAA120E16)),
          ),
          SafeArea(
            child: Column(
              children: [
                _header(enemy.name),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(enemy.imagePath, fit: BoxFit.contain),
                  ),
                ),
                _bar('敵', _enemyHp, _result.enemyMaxHp, AppColors.fuchou),
                const SizedBox(height: 8),
                _bar('みんな', _partyHp, _result.partyMaxHp, AppColors.genki),
                const SizedBox(height: 12),
                _logPanel(),
                _footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String enemyName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text('ステージ $_stage',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, letterSpacing: 1.2)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(enemyName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          if (!_done)
            TextButton(
              onPressed: _skip,
              style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              child: const Text('スキップ'),
            ),
        ],
      ),
    );
  }

  Widget _bar(String label, int value, int maxValue, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: maxValue == 0 ? 0 : value / maxValue),
                duration: const Duration(milliseconds: 300),
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: AppColors.panelAlt,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text('$value',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _logPanel() {
    return Container(
      height: 128,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        controller: _scroll,
        itemCount: _shown,
        itemBuilder: (context, i) {
          final event = _result.log[i];
          final isTurnMark = event.text.startsWith('―');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              event.text,
              style: TextStyle(
                fontSize: isTurnMark ? 11 : 13,
                color: isTurnMark
                    ? AppColors.textMuted
                    : event.heal != null
                        ? AppColors.genki
                        : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: _done ? () => Navigator.pop(context, _result.won) : null,
          style: FilledButton.styleFrom(
            backgroundColor: _result.won ? AppColors.accent : AppColors.panelAlt,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            !_done
                ? '戦闘中…'
                : _result.won
                    ? 'ステージ $_stage クリア！'
                    : 'もっと歩いてから挑もう',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
