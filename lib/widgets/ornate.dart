import 'package:flutter/material.dart';

import '../data/theme.dart';

/// 金の細縁とグラデーションを持つ枠。安っぽい平面塗りを避けるための土台。
class OrnatePanel extends StatelessWidget {
  const OrnatePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.borderColor,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.goldDim;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          if (glow)
            BoxShadow(color: border.withValues(alpha: 0.28), blurRadius: 22),
        ],
      ),
      child: child,
    );
  }
}

/// 見出しの左右に細い金線を添える。区切りに文字だけ置くと締まらない。
class OrnateLabel extends StatelessWidget {
  const OrnateLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _line(c, true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ),
        _line(c, false),
      ],
    );
  }

  Widget _line(Color c, bool toRight) => Container(
    width: 22,
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: toRight
            ? [c.withValues(alpha: 0), c]
            : [c, c.withValues(alpha: 0)],
      ),
    ),
  );
}

/// 中身が光るゲージ。素のLinearProgressIndicatorは味気ない。
class JewelBar extends StatelessWidget {
  const JewelBar({
    super.key,
    required this.value,
    required this.gradient,
    this.height = 12,
    this.animate = true,
  });

  final double value;
  final Gradient gradient;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.hollow,
        borderRadius: BorderRadius.circular(height),
        border: Border.all(
          color: AppColors.goldDim.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value.clamp(0.0, 1.0)),
            duration: Duration(milliseconds: animate ? 380 : 0),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => FractionallySizedBox(
              widthFactor: v == 0 ? 0.0001 : v,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(height),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.45,
                    widthFactor: 0.92,
                    child: Container(
                      margin: const EdgeInsets.only(top: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.26),
                        borderRadius: BorderRadius.circular(height),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 主役のボタン。押せないときは金気を抜いて沈ませる。
class JewelButton extends StatelessWidget {
  const JewelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              gradient: gradient ?? AppColors.roseGradient,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.roseDeep.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
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
}

/// 控えめなほうのボタン。金の細縁だけで主張を抑える。
class QuietButton extends StatelessWidget {
  const QuietButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.hollow.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: AppColors.goldDim.withValues(alpha: 0.7),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: AppColors.gold),
                    const SizedBox(width: 7),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
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
}
