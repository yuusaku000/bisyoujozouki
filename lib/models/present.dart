import 'package:flutter/material.dart';

enum Rarity {
  n('N', 1, Color(0xFF9AA3B8)),
  r('R', 2, Color(0xFF6FB7E8)),
  sr('SR', 3, Color(0xFFC08BE8)),
  ssr('SSR', 4, Color(0xFFF0C45A));

  const Rarity(this.label, this.stars, this.color);
  final String label;
  final int stars;
  final Color color;
}

/// 臓器に渡すもの。親密度はこれでしか上がらない。
class Present {
  const Present({
    required this.id,
    required this.name,
    required this.detail,
    required this.rarity,
    required this.affection,
    required this.icon,
    this.favoriteOf,
  });

  final String id;
  final String name;
  final String detail;
  final Rarity rarity;

  /// 渡したときに上がる親密度。
  final int affection;
  final IconData icon;

  /// この子の好物なら効果が倍になる。誰に何を渡すかを考える余地を作る。
  final String? favoriteOf;

  int affectionFor(String organId) =>
      favoriteOf == organId ? affection * 2 : affection;

  bool isFavoriteOf(String organId) => favoriteOf == organId;
}
