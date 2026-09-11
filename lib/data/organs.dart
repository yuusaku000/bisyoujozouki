import 'package:flutter/material.dart';

import '../models/organ.dart';

/// 5体それぞれ健康度の決まり方が違う。運動だけでは測れない臓器は
/// 自己申告で補い、記録ではなく「世話」として入力させる。
///
/// unlockStage は物語で出会う順。最初は心臓ひとりから始まる。
const List<Organ> kOrgans = [
  Organ(
    id: 'heart',
    name: '心臓',
    metric: HealthMetric.steps,
    role: '継続ダメージ',
    accent: Color(0xFFE0455F),
    unlockStage: 0,
  ),
  Organ(
    id: 'lung',
    name: '肺',
    metric: HealthMetric.stairs,
    role: 'スタミナ',
    accent: Color(0xFF7FC4DE),
    unlockStage: 2,
  ),
  Organ(
    id: 'stomach',
    name: '胃',
    metric: HealthMetric.meal,
    role: '回復',
    accent: Color(0xFFF0A03C),
    unlockStage: 3,
  ),
  Organ(
    id: 'liver',
    name: '肝臓',
    metric: HealthMetric.rest,
    role: '状態異常の解除',
    accent: Color(0xFF9C5A4A),
    unlockStage: 5,
  ),
  Organ(
    id: 'brain',
    name: '脳',
    metric: HealthMetric.sleep,
    role: 'バフ・弱点看破',
    accent: Color(0xFFB292D4),
    unlockStage: 7,
  ),
];

Organ organById(String id) => kOrgans.firstWhere((o) => o.id == id);

/// 物語で出会った子だけが並ぶ。まだの子は鍵がかかっている。
List<Organ> unlockedOrgans(Set<String> readEpisodes) =>
    kOrgans.where((o) => o.isUnlocked(readEpisodes)).toList();
