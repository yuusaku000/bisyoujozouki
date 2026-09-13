import 'dart:async';

import 'package:flutter/material.dart';

import '../data/enemies.dart';
import '../data/theme.dart';
import '../models/battle.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/ornate.dart';

/// 自動戦闘を1行ずつ再生する。結果は開始時点で確定している。
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.state});

  final GameState state;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final int _stage = widget.state.currentStage;
  late final BattleResult _result = Battle(
    organs: widget.state.organs,
    stage: _stage,
    party: widget.state.party,
  ).run();

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
    _timer = Timer.periodic(
      Duration(milliseconds: widget.state.battleSpeed.millis),
      (t) {
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
      },
    );
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

  StageReward _reward = const StageReward();

  void _finish() {
    if (_result.won) _reward = widget.state.clearStage(_stage);
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
    final background = enemy.isBoss
        ? 'assets/bg/bg_stomach.png'
        : 'assets/bg/bg_vessel.png';

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
                _header(enemyNameForStage(_stage)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _enemyFigure(enemy.imagePath),
                  ),
                ),
                _bar('敵', _enemyHp, _result.enemyMaxHp, AppColors.fuchou),
                const SizedBox(height: 10),
                _party(),
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

  /// 敵名は「・覚醒」などが付いて伸びるので、段名と同じ行に並べない。
  /// 横に押し込むと、名前のほうが削られて読めなくなる。
  Widget _header(String enemyName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ステージ $_stage',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enemyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
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

  bool get _defeated => _enemyHp <= 0;

  /// 倒れたら傾いて沈み、そのまま消えていく。
  ///
  /// 薄く残していたが、倒したのに居座っているように見える。
  /// 消えきるまで見せたほうが、片がついた感じが出る。
  Widget _enemyFigure(String path) {
    return AnimatedSlide(
      offset: _defeated ? const Offset(0, 0.26) : Offset.zero,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeIn,
      child: AnimatedRotation(
        turns: _defeated ? 0.055 : 0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _defeated ? 0 : 1,
          // 沈みきる少し前に消える。消えた場所に絵が残らない。
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeInCubic,
          child: AnimatedScale(
            scale: _defeated ? 0.88 : 1,
            duration: const Duration(milliseconds: 900),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _defeated ? Colors.black54 : Colors.transparent,
                BlendMode.srcATop,
              ),
              child: Image.asset(path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  /// いま行動している臓器を光らせる。誰が何をしたかを絵で分かるように。
  String? get _actingId {
    if (_shown == 0 || _done) return null;
    return _result.log[_shown - 1].actorId;
  }

  Widget _party() {
    final acting = _actingId;
    return SizedBox(
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final organ in widget.state.party)
            Builder(
              builder: (context) {
                final condition =
                    (widget.state.organs[organ.id] ?? const OrganStatus())
                        .condition;
                final active = organ.id == acting;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 58 : 48,
                  height: active ? 58 : 48,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? organ.accent : AppColors.hollow,
                      width: active ? 3 : 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: organ.accent.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      organ.facePath(condition),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: JewelBar(
              value: maxValue == 0 ? 0 : value / maxValue,
              height: 13,
              gradient: LinearGradient(
                colors: [Color.lerp(color, Colors.white, 0.35)!, color],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
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
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldDim.withValues(alpha: 0.55)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_reward.isEmpty) ...[
            // 数が多いほど横に並ぶ。狭い画面でははみ出すので折り返す
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_reward.tickets > 0)
                  _rewardPill(
                    Icons.confirmation_number,
                    'ガチャチケット ×${_reward.tickets}',
                    AppColors.rose,
                  ),
                if (_reward.keys > 0)
                  _rewardPill(
                    Icons.vpn_key,
                    '解放の鍵 ×${_reward.keys}',
                    AppColors.gold,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _finishButton(),
        ],
      ),
    );
  }

  Widget _rewardPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _finishButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: JewelButton(
        label: !_done
            ? '戦闘中…'
            : _result.won
            ? 'ステージ $_stage クリア！'
            : 'もっと歩いてから挑もう',
        gradient: _result.won
            ? AppColors.roseGradient
            : const LinearGradient(
                colors: [Color(0xFF4A3556), Color(0xFF2E2038)],
              ),
        onPressed: _done ? () => Navigator.pop(context, _result.won) : null,
      ),
    );
  }
}
