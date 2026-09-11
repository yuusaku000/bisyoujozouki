import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/game_state.dart';
import '../services/save_store.dart';
import '../services/step_source.dart';
import 'grow_tab.dart';
import 'home_tab.dart';
import 'gacha_tab.dart';
import 'shop_tab.dart';

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
    setState(() => _state = state);
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

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.rose)),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomeTab(state: state, onChanged: _changed, onReset: _reset),
          GrowTab(state: state, onChanged: _changed),
          GachaTab(state: state, onChanged: _changed),
          ShopTab(state: state, onChanged: _changed),
        ],
      ),
      bottomNavigationBar: _bar(state),
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
