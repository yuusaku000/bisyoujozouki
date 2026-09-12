import 'package:flutter/material.dart';

import '../data/theme.dart';

/// 読み込みのあいだ出す画面。
///
/// webでは index.html の幕と同じ絵にしてある。最初の絵が出た瞬間に
/// 幕を上げるので、見た目が変わらなければ切り替わったと気づかれない。
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 二段の鼓動。ひと呼吸のあいだに大小ふたつ打つ。
  double _beat(double t) {
    if (t < 0.14) return 1 + 0.16 * (t / 0.14);
    if (t < 0.28) return 1.16 - 0.16 * ((t - 0.14) / 0.14);
    if (t < 0.42) return 1 + 0.09 * ((t - 0.28) / 0.14);
    if (t < 0.56) return 1.09 - 0.09 * ((t - 0.42) / 0.14);
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.16),
            radius: 0.9,
            colors: [
              AppColors.panelSoft,
              AppColors.background,
              Color(0xFF0E0710),
            ],
            stops: [0.0, 0.62, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.scale(
                  scale: _beat(_controller.value),
                  child: child,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 84,
                  color: AppColors.rose,
                  shadows: [Shadow(color: AppColors.rose, blurRadius: 22)],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                '臓器っち',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 7,
                  color: AppColors.rose,
                  shadows: [Shadow(color: AppColors.rose, blurRadius: 22)],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '読み込んでいます…',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 26),
              _bar(),
            ],
          ),
        ),
      ),
    );
  }

  /// 進み具合は本当には分からないので、動いていることだけ見せる。
  Widget _bar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 168,
        height: 3,
        child: ColoredBox(
          color: AppColors.textMuted.withValues(alpha: 0.18),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_controller.value);
              return Align(
                alignment: Alignment(-1.1 + 2.7 * t, 0),
                child: Container(
                  width: 64,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00FF88AC),
                        AppColors.rose,
                        Color(0x00FF88AC),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
