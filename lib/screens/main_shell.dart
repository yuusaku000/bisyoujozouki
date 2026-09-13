import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/game_state.dart';
import '../services/save_store.dart';
import '../services/step_source.dart';
import 'battle_screen.dart';
import 'boot_screen.dart';
import 'name_screen.dart';
import 'grow_tab.dart';
import 'home_tab.dart';
import 'gacha_tab.dart';
import '../data/story.dart';
import 'shop_tab.dart';
import 'story_screen.dart';
import 'tutorial.dart';

/// 画面が増えたので下のタブで分ける。ホームに全部載せると、
/// 立ち絵を見る場所なのか数字をいじる場所なのか分からなくなる。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _store = SaveStore();
  final StepSource _stepSource = ManualStepSource();

  final _anchors = HomeAnchors();

  GameState? _state;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await _store.load();
    final auto = await _stepSource.readToday();
    if (auto != null) state.today = auto;
    if (!mounted) return;

    await _warmUp(state);
    if (!mounted) return;
    setState(() => _state = state);
  }

  /// 最初に出る画面の絵を先に読んでおく。
  ///
  /// 立ち絵は1枚1MB近くある。読み込みながら出すと、背景だけの画面に
  /// 子が後から現れることになり、できあがっていないように見える。
  Future<void> _warmUp(GameState state) async {
    final paths = <String>{
      'assets/bg/bg_home.png',
      for (final organ in state.party) ...[
        organ.imagePath(state.statusOf(organ.id).condition),
        organ.facePath(state.statusOf(organ.id).condition),
      ],
    };

    await Future.wait([
      for (final path in paths)
        // 1枚読めなくても先へ進める。ここで止まると何も遊べない。
        precacheImage(AssetImage(path), context, onError: (_, _) {}),
    ]);
  }

  /// どのタブから変更しても、同じ道を通して保存する。
  void _changed() {
    setState(() {});
    final state = _state;
    if (state != null) _store.save(state);
  }

  Future<void> _reset() async {
    await _store.clear();
    if (!mounted) return;
    setState(() => _state = GameState.fresh());
  }

  /// 最初の一戦と、そのまま続く第1話。
  ///
  /// 倒した直後が初対面の場面なので、一覧に戻して探させず、
  /// そのまま読ませる。案内はそのあと。
  Future<void> _introBattle(GameState state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BattleScreen(state: state)),
    );
    if (!mounted) return;

    final first = episodeForStage(1);
    if (first != null && state.clearedStage >= 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryScreen(
            episode: first,
            onRead: () => state.markEpisodeRead(first.key),
          ),
        ),
      );
      if (!mounted) return;
    }

    state.tutorialPhase = 1;
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) return const BootScreen();

    // 名前を聞くのは物語より前。「——来る。」のあとで尋ねると、
    // 切迫した場面がそこで止まってしまう。
    if (!state.hasName) {
      return NameScreen(
        onDecided: (name) {
          state.userName = name;
          _changed();
        },
      );
    }

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [
              HomeTab(
                state: state,
                onChanged: _changed,
                onReset: _reset,
                anchors: _anchors,
              ),
              GrowTab(state: state, onChanged: _changed),
              GachaTab(state: state, onChanged: _changed),
              ShopTab(state: state, onChanged: _changed),
            ],
          ),
          bottomNavigationBar: KeyedSubtree(
            key: _anchors.nav,
            child: _bar(state),
          ),
        ),
        // まず一戦、それから画面の案内。順番はここで決まる。
        if (state.tutorialPhase == 0)
          Positioned.fill(
            child: IntroOverlay(onBattle: () => _introBattle(state)),
          ),
        if (state.tutorialPhase == 1)
          Positioned.fill(
            child: TutorialOverlay(
              anchors: _anchors,
              onDone: () {
                state.tutorialPhase = 2;
                _changed();
              },
            ),
          ),
      ],
    );
  }

  Widget _bar(GameState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.panelGradient,
        border: Border(
          top: BorderSide(color: AppColors.goldDim.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _item(0, Icons.home_rounded, 'ホーム'),
              _item(1, Icons.favorite_rounded, '育成'),
              _item(2, Icons.card_giftcard_rounded, 'ガチャ', dot: state.canPull),
              _item(3, Icons.storefront_rounded, 'ショップ'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label, {bool dot = false}) {
    final selected = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.rose : AppColors.textMuted,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? AppColors.rose : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (dot)
              Positioned(
                top: 8,
                right: 22,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B4E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
