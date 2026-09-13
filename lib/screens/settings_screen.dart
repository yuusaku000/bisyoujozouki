import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../data/chara_story.dart';
import '../data/organs.dart';
import '../data/story.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onReset,
  });

  final GameState state;
  final VoidCallback onChanged;
  final Future<void> Function() onReset;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GameState get state => widget.state;

  /// 設定で触った値はその場で保存する。まとめて後で、だと取りこぼす。
  Widget _soundRow(
    String title,
    String detail,
    bool value,
    void Function(bool) set,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.rose,
          onChanged: (v) => _edit(() => set(v)),
        ),
      ],
    );
  }

  void _edit(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: OrnatePanel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          borderColor: AppColors.fuchou,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'データを消しますか',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                '日数、コイン、レベル、読んだ話、すべて最初からになります。'
                'この操作は取り消せません。',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.7,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: QuietButton(
                      label: 'やめる',
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JewelButton(
                      label: '消す',
                      height: 48,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE06A6A), Color(0xFF9C3A46)],
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;
    await widget.onReset();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Center(child: OrnateLabel('バトル')),
          const SizedBox(height: 12),
          OrnatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '戦闘の速さ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ログが1行進む間隔',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final speed in BattleSpeed.values) ...[
                      Expanded(child: _speedChip(speed)),
                      if (speed != BattleSpeed.values.last)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('おと')),
          const SizedBox(height: 12),
          OrnatePanel(
            child: Column(
              children: [
                _soundRow(
                  '効果音',
                  'つついたとき、戦っているときの音',
                  state.sfxOn,
                  (v) => state.sfxOn = v,
                ),
                const Divider(height: 22, color: AppColors.goldDim),
                _soundRow('BGM', '流れつづける曲', state.bgmOn, (v) => state.bgmOn = v),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('いまの記録')),
          const SizedBox(height: 12),
          OrnatePanel(
            child: Column(
              children: [
                _row('日数', '${state.dayCount}日目'),
                _row('コイン', formatCoins(state.coins)),
                _row('解放の鍵', '${state.keys}'),
                _row('ガチャチケット', '${state.tickets}'),
                _row('到達ステージ', '${state.clearedStage}'),
                _row('読んだ話', '${state.readEpisodes.length}'),
                _row('仲間', '${state.party.length} / 5'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('開発')),
          const SizedBox(height: 12),
          OrnatePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '開発者モード',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '動作確認のために、値を直接いじれるようにします',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.devMode,
                      activeThumbColor: AppColors.rose,
                      onChanged: (v) => _edit(() => state.devMode = v),
                    ),
                  ],
                ),
                if (state.devMode) ...[
                  const Divider(height: 26, color: AppColors.goldDim),
                  _devGroup('もちもの', [
                    ('コイン +100,000', () => state.coins += 100000),
                    ('鍵 +5', () => state.keys += 5),
                    ('チケット +10', () => state.tickets += 10),
                  ]),
                  _devGroup('みんな', [
                    ('レベル20・親密度MAX', _maxOrgans),
                    ('健康度を100に', () => _setHealth(100)),
                    ('健康度を20に', () => _setHealth(20)),
                  ]),
                  _devGroup('すすみ', [
                    ('ステージ +1', () => state.clearedStage += 1),
                    (
                      'ステージ -1',
                      () => state.clearedStage = (state.clearedStage - 1).clamp(
                        0,
                        1 << 30,
                      ),
                    ),
                    ('1日すすめる', () => state.endDay()),
                  ]),
                  _devGroup('よみもの', [
                    ('全部を既読にする', _readAll),
                    ('既読を消す', () => state.readEpisodes.clear()),
                    ('案内をもう一度', () => state.tutorialPhase = 0),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Center(child: OrnateLabel('そのほか')),
          const SizedBox(height: 12),
          OrnatePanel(
            borderColor: AppColors.fuchou,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'データの初期化',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  '最初からやり直します',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                QuietButton(
                  label: 'データを消す',
                  icon: Icons.delete_outline,
                  onPressed: _confirmReset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '臓器っち  v0.1',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  /// 全員をレベル上限まで上げ、ハートも満たす。演出の確認用。
  void _maxOrgans() {
    for (final organ in kOrgans) {
      final status = state.statusOf(organ.id);
      state.organs[organ.id] = OrganStatus(
        health: status.health,
        level: 20,
        ascensions: 1,
        affection: OrganStatus.heartThresholds[OrganStatus.maxHearts],
      );
    }
  }

  void _setHealth(int health) {
    for (final organ in kOrgans) {
      final status = state.statusOf(organ.id);
      state.organs[organ.id] = OrganStatus(
        health: health,
        level: status.level,
        ascensions: status.ascensions,
        affection: status.affection,
      );
    }
  }

  void _readAll() {
    state.readEpisodes
      ..addAll(kStory.map((e) => e.key))
      ..addAll(kCharaStory.map((e) => e.key));
  }

  Widget _devGroup(String title, List<(String, VoidCallback)> actions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, run) in actions)
                GestureDetector(
                  onTap: () => _edit(run),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.hollow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.goldDim.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _speedChip(BattleSpeed speed) {
    final selected = state.battleSpeed == speed;
    return GestureDetector(
      onTap: () => _edit(() => state.battleSpeed = speed),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.rose.withValues(alpha: 0.22)
              : AppColors.hollow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.rose
                : AppColors.goldDim.withValues(alpha: 0.5),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          speed.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.rose : AppColors.textMuted,
          ),
        ),
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
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
