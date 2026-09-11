import 'package:flutter/material.dart';

import '../models/organ.dart';

/// 5体それぞれ健康度の決まり方が違う。運動だけでは測れない臓器は
/// 自己申告で補い、記録ではなく「世話」として入力させる。
const List<Organ> kOrgans = [
  Organ(
    id: 'heart',
    name: '心臓',
    metric: HealthMetric.steps,
    role: '継続ダメージ',
    accent: Color(0xFFE0455F),
  ),
  Organ(
    id: 'lung',
    name: '肺',
    metric: HealthMetric.stairs,
    role: 'スタミナ',
    accent: Color(0xFF7FC4DE),
  ),
  Organ(
    id: 'stomach',
    name: '胃',
    metric: HealthMetric.meal,
    role: '回復',
    accent: Color(0xFFF0A03C),
  ),
  Organ(
    id: 'liver',
    name: '肝臓',
    metric: HealthMetric.rest,
    role: '状態異常の解除',
    accent: Color(0xFF9C5A4A),
  ),
  Organ(
    id: 'brain',
    name: '脳',
    metric: HealthMetric.sleep,
    role: 'バフ・弱点看破',
    accent: Color(0xFFB292D4),
  ),
];

Organ organById(String id) => kOrgans.firstWhere((o) => o.id == id);
