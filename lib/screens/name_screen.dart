import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sounds.dart';
import '../data/theme.dart';
import '../models/game_state.dart';
import '../services/audio.dart';
import '../widgets/ornate.dart';

/// はじめに一度だけ、呼び名を聞く。
///
/// 物語が始まる前に置く。「——来る。」のあとで名前を聞かれると、
/// 切迫した場面が止まってしまう。
class NameScreen extends StatefulWidget {
  const NameScreen({super.key, required this.onDecided});

  final void Function(String name) onDecided;

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();

  void _decide() {
    if (_name.isEmpty) return;
    // ここが最初に触られる場所。ブラウザの「音は触るまで鳴らさない」を
    // 解くきっかけにもなるので、無音にしない。
    Audio.instance.playSfx(Sfx.confirm);
    widget.onDecided(_name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.95,
            colors: [
              AppColors.panelSoft,
              AppColors.background,
              Color(0xFF0E0710),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 56,
                    color: AppColors.rose,
                    shadows: [Shadow(color: AppColors.rose, blurRadius: 20)],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '臓器っち',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 7,
                      color: AppColors.rose,
                      shadows: [Shadow(color: AppColors.rose, blurRadius: 20)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'あなたのことを、なんと呼べばいいですか',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  _field(),
                  const SizedBox(height: 10),
                  Text(
                    'あとから変えられます',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: JewelButton(
                      label: 'はじめる',
                      height: 50,
                      onPressed: _name.isEmpty ? null : _decide,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field() {
    return TextField(
      controller: _controller,
      autofocus: true,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      // 長い名前はどの画面にも収まらない。入り口で止める。
      maxLength: GameState.maxNameLength,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _decide(),
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        counterStyle: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        hintText: 'なまえ',
        hintStyle: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.5),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.hollow.withValues(alpha: 0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.goldDim.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.6),
        ),
      ),
    );
  }
}
