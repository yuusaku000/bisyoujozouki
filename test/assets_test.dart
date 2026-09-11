import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/data/organs.dart';
import 'package:zoukicchi/models/organ.dart';

/// 画像パスの綴り間違いは実行時まで気づけないので、ファイルの実在を確認する。
void main() {
  test('臓器の立ち絵が3状態ぶん揃っている', () {
    final missing = <String>[];
    for (final organ in kOrgans) {
      for (final condition in Condition.values) {
        final path = organ.imagePath(condition);
        if (!File(path).existsSync()) missing.add(path);
      }
    }
    expect(missing, isEmpty);
  });

  test('健康度から状態への変換', () {
    expect(const OrganStatus(health: 100).condition, Condition.genki);
    expect(const OrganStatus(health: 75).condition, Condition.genki);
    expect(const OrganStatus(health: 74).condition, Condition.futsuu);
    expect(const OrganStatus(health: 45).condition, Condition.futsuu);
    expect(const OrganStatus(health: 44).condition, Condition.fuchou);
    expect(const OrganStatus(health: 20).condition, Condition.fuchou);
  });

  test('背景と敵の画像が揃っている', () {
    const paths = [
      'assets/bg/bg_home.png',
      'assets/bg/bg_vessel.png',
      'assets/bg/bg_stomach.png',
      'assets/enemies/ramen.png',
      'assets/enemies/allnighter.png',
      'assets/enemies/elevator.png',
      'assets/enemies/chair.png',
      'assets/enemies/binge.png',
      'assets/enemies/oversleep.png',
      'assets/enemies/boss_seikatsu.png',
    ];
    final missing = paths.where((p) => !File(p).existsSync()).toList();
    expect(missing, isEmpty);
  });
}
