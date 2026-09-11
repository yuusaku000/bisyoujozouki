import 'dart:math';

import 'package:flutter/material.dart';

import '../models/present.dart';

/// ガチャから出るもの。好物は誰か一人に決まっていて、その子に渡すと倍になる。
const List<Present> kPresents = [
  // ── N ──
  Present(
    id: 'water',
    name: 'コップ一杯の水',
    detail: 'なんでもない。でも、ないと困る',
    rarity: Rarity.n,
    affection: 4,
    icon: Icons.local_drink,
  ),
  Present(
    id: 'towel',
    name: 'あたたかいタオル',
    detail: '汗を拭くだけで、少し楽になる',
    rarity: Rarity.n,
    affection: 4,
    icon: Icons.dry_cleaning,
  ),
  Present(
    id: 'candy',
    name: 'のど飴',
    detail: '小さいけれど、気づかいの形',
    rarity: Rarity.n,
    affection: 5,
    icon: Icons.cookie,
    favoriteOf: 'lung',
  ),

  // ── R ──
  Present(
    id: 'tea',
    name: 'ハーブティー',
    detail: '湯気の匂いだけで、肩の力が抜ける',
    rarity: Rarity.r,
    affection: 10,
    icon: Icons.emoji_food_beverage,
    favoriteOf: 'liver',
  ),
  Present(
    id: 'cushion',
    name: 'やわらかいクッション',
    detail: '座り心地がぜんぜん違う',
    rarity: Rarity.r,
    affection: 10,
    icon: Icons.chair,
  ),
  Present(
    id: 'bento',
    name: '手づくりのお弁当',
    detail: '誰かのために作った時間ごと渡す',
    rarity: Rarity.r,
    affection: 12,
    icon: Icons.lunch_dining,
    favoriteOf: 'stomach',
  ),
  Present(
    id: 'bookmark',
    name: 'しおり',
    detail: '続きを読む約束',
    rarity: Rarity.r,
    affection: 12,
    icon: Icons.bookmark,
    favoriteOf: 'brain',
  ),

  // ── SR ──
  Present(
    id: 'music_box',
    name: 'オルゴール',
    detail: '鼓動と同じ速さで鳴る',
    rarity: Rarity.sr,
    affection: 26,
    icon: Icons.music_note,
    favoriteOf: 'heart',
  ),
  Present(
    id: 'aroma',
    name: 'アロマランプ',
    detail: '部屋の空気ごと入れ替わる',
    rarity: Rarity.sr,
    affection: 26,
    icon: Icons.local_fire_department,
    favoriteOf: 'lung',
  ),
  Present(
    id: 'blanket',
    name: '上等なブランケット',
    detail: '眠りの質が変わる',
    rarity: Rarity.sr,
    affection: 26,
    icon: Icons.bed,
    favoriteOf: 'brain',
  ),
  Present(
    id: 'letter',
    name: '一通の手紙',
    detail: 'なんて書いてあるかは、渡した人しか知らない',
    rarity: Rarity.sr,
    affection: 30,
    icon: Icons.mail,
  ),

  // ── SSR ──
  Present(
    id: 'ring',
    name: '小さな指輪',
    detail: 'サイズは測っていない。でも、ぴったりだった',
    rarity: Rarity.ssr,
    affection: 60,
    icon: Icons.diamond,
  ),
  Present(
    id: 'day_off',
    name: 'なにもしない一日',
    detail: '予定を全部、あなたのために空けた',
    rarity: Rarity.ssr,
    affection: 60,
    icon: Icons.wb_sunny,
    favoriteOf: 'liver',
  ),
  Present(
    id: 'promise',
    name: '約束',
    detail: 'ずっと一緒にいる、という言葉',
    rarity: Rarity.ssr,
    affection: 70,
    icon: Icons.favorite,
    favoriteOf: 'heart',
  ),
];

Present? presentById(String id) {
  for (final p in kPresents) {
    if (p.id == id) return p;
  }
  return null;
}

List<Present> presentsOf(Rarity rarity) =>
    kPresents.where((p) => p.rarity == rarity).toList();

/// 排出率。ここを触るだけで手触りが変わるので、1か所にまとめてある。
const Map<Rarity, int> kGachaWeights = {
  Rarity.n: 55,
  Rarity.r: 33,
  Rarity.sr: 10,
  Rarity.ssr: 2,
};

const int kGachaCost = 1;
const int kGachaTenCost = 10;

/// 10連は必ずSR以上が1つ出る。ぜんぶNだったときの徒労感が大きすぎる。
List<Present> rollTen(Random random) {
  final results = [for (var i = 0; i < kGachaTenCost; i++) rollOne(random)];
  final hasHigh = results.any((p) => p.rarity.stars >= Rarity.sr.stars);
  if (!hasHigh) {
    results[random.nextInt(results.length)] = _pickFrom(Rarity.sr, random);
  }
  return results;
}

Present rollOne(Random random) => _pickFrom(_rollRarity(random), random);

Rarity _rollRarity(Random random) {
  final total = kGachaWeights.values.reduce((a, b) => a + b);
  var roll = random.nextInt(total);
  for (final entry in kGachaWeights.entries) {
    roll -= entry.value;
    if (roll < 0) return entry.key;
  }
  return Rarity.n;
}

Present _pickFrom(Rarity rarity, Random random) {
  final pool = presentsOf(rarity);
  return pool[random.nextInt(pool.length)];
}
