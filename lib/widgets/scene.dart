import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/organ.dart';

/// 画面の下地。背景の絵を敷いて、その上を暗く落とす。
///
/// ホームやバトルには部屋や血管の絵があるのに、ガチャとショップだけ
/// 真っ黒だった。同じゲームの中で、そこだけ別のアプリに見える。
class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({
    super.key,
    required this.child,
    this.asset = 'assets/bg/bg_home.png',
    this.tint = AppColors.rose,
  });

  final Widget child;
  final String asset;

  /// 上に乗せる色。画面ごとに空気を変える。
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        // 文字を読ませる画面なので、絵はかなり沈めてよい。
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                tint.withValues(alpha: 0.20),
                AppColors.background.withValues(alpha: 0.93),
                AppColors.background,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// 立ち絵の胸から上。
///
/// 立ち絵は縦に長いので、そのまま並べると場所を食う。上を切り出すと
/// 顔が大きく出て、画面に人がいることが一目で分かる。
class CharacterBust extends StatelessWidget {
  const CharacterBust({
    super.key,
    required this.organ,
    this.condition = Condition.genki,
    this.width = 96,
    this.height = 116,
  });

  final Organ organ;
  final Condition condition;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              organ.accent.withValues(alpha: 0.35),
              AppColors.hollow.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Image.asset(
          organ.imagePath(condition),
          // 頭が絵の上端にあるので、上を基準に切ると顔が入る。
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

/// 右上に出す所持数。ガチャとショップで同じ形にする。
class CountPill extends StatelessWidget {
  const CountPill({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.hollow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 画面の見出し。左に題、右に所持数。
class SceneHeader extends StatelessWidget {
  const SceneHeader({super.key, required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
