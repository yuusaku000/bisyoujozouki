import 'package:flutter/material.dart';

import '../data/theme.dart';

/// 画面上部に短く出して、勝手に消える知らせ。
///
/// 下から出る通知は操作したいボタンに重なるうえ、消えるまで居座る。
/// 見えればいい類の知らせなので、邪魔にならない場所と長さにしている。
void showTopToast(BuildContext context, String message, {IconData? icon}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _TopToast(
      message: message,
      icon: icon,
      onFinished: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  const _TopToast({required this.message, required this.onFinished, this.icon});

  final String message;
  final IconData? icon;
  final VoidCallback onFinished;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1900), () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.6), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.panelGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: AppColors.gold),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
