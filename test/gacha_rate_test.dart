// ignore_for_file: avoid_print
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/presents.dart';
import 'package:zoukicchi/models/present.dart';

void main() {
  test('排出率が設定どおりに出ている', () {
    const trials = 200000;
    final random = Random(42);
    final counts = <Rarity, int>{for (final r in Rarity.values) r: 0};

    for (var i = 0; i < trials; i++) {
      final p = rollOne(random);
      counts[p.rarity] = counts[p.rarity]! + 1;
    }

    for (final r in Rarity.values) {
      final actual = counts[r]! / trials * 100;
      final expected = (kGachaWeights[r] ?? 0).toDouble();
      print('${r.label}\t${actual.toStringAsFixed(2)}%  (設定 $expected%)');
      expect(actual, closeTo(expected, 0.6), reason: '${r.label} がずれている');
    }
  });

  test('10連でSSRが出る割合', () {
    const tens = 5000;
    final random = Random(7);
    var withSsr = 0;
    for (var i = 0; i < tens; i++) {
      if (rollTen(random).any((p) => p.rarity == Rarity.ssr)) withSsr++;
    }
    print(
      '10連$tens回中、SSRあり: $withSsr (${(withSsr / tens * 100).toStringAsFixed(1)}%)',
    );
  });
}
