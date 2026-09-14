import 'dart:math';

import '../models/enemy.dart';

const List<Enemy> kEnemies = [
  Enemy(
    id: 'ramen',
    name: '深夜のラーメン',
    baseHp: 260,
    baseAttack: 34,
    applies: Debuff.motare,
  ),
  Enemy(
    id: 'allnighter',
    name: '徹夜',
    baseHp: 300,
    baseAttack: 40,
    applies: Debuff.nemuke,
  ),
  Enemy(
    id: 'elevator',
    name: 'エレベーター',
    baseHp: 340,
    baseAttack: 30,
    applies: Debuff.namake,
  ),
  Enemy(
    id: 'chair',
    name: '座りっぱなし',
    baseHp: 380,
    baseAttack: 32,
    applies: Debuff.kori,
  ),
  Enemy(
    id: 'binge',
    name: '暴飲暴食',
    baseHp: 440,
    baseAttack: 48,
    applies: Debuff.none,
  ),
  Enemy(
    id: 'oversleep',
    name: '二度寝',
    baseHp: 320,
    baseAttack: 36,
    applies: Debuff.nemuke,
  ),
];

const Enemy kBoss = Enemy(
  id: 'boss_seikatsu',
  name: '生活習慣病',
  baseHp: 1400,
  baseAttack: 70,
  applies: Debuff.kori,
  isBoss: true,
);

/// 10ステージごとにボス。それ以外は周ごとに並びが変わる。
///
/// 挑むたびに引き直せると、弱い敵が出るまで粘れてしまうので、ステージ番号から
/// 決める。ただし完全な無作為にすると一周のうち同じ敵ばかり出たり、1戦目に
/// 最強の相手が来たりする。周ごとに全員を並べ替える形にして、偏りを防ぐ。
Enemy enemyForStage(int stage) {
  if (stage % 10 == 0) return kBoss;
  final loop = (stage - 1) ~/ 10;
  final pos = (stage - 1) % 10;
  final order = _orderForLoop(loop);
  return order[pos % order.length];
}

List<Enemy> _orderForLoop(int loop) {
  // 1周目は定義順。はじめての相手が最強では、仲間のいない人が詰む。
  if (loop == 0) return kEnemies;
  return [...kEnemies]..shuffle(Random(loop * 7919));
}

/// 進むほど強くなる。10ステージで約2倍。
double stageScale(int stage) => 1 + (stage - 1) * 0.1;

Enemy? enemyById(String id) {
  if (id == kBoss.id) return kBoss;
  for (final e in kEnemies) {
    if (e.id == id) return e;
  }
  return null;
}

/// その敵が何度目の登場か。同じ顔が何度も出るので、出るたびに数える。
int encounterIndexOf(int stage) {
  final id = enemyForStage(stage).id;
  var count = 0;
  for (var s = 1; s < stage; s++) {
    if (enemyForStage(s).id == id) count++;
  }
  return count;
}

/// 出てくるたびに変わる呼び名。
///
/// 同じ名前が並ぶと、進んでいる実感が薄れる。先頭は空で、1度目は
/// そのままの名前で出す。あとは大げさになっていく順に並べてある。
///
/// 強さとは連動していない。強さはステージ番号だけで決まるので、
/// 同じ「・改」でも相手が違えば数字はまるで違う。ここは見栄えの話。
const List<String> _rankSuffixes = [
  '',
  // 強くなっただけ
  '・改',
  '・覚醒',
  '・真',
  '・極',
  // 荒ぶる
  '・烈',
  '・轟',
  '・煉獄',
  '・災禍',
  // 位をもつ
  '・四天王',
  '・覇王',
  '・魔王',
  '・邪神',
  // 堕ちる
  '・大罪',
  '・原罪',
  '・堕天',
  '・堕天使',
  // 神めく
  '・天使',
  '・熾天使',
  '・神域',
  '・神格',
  // おしまい
  '・深淵',
  '・虚無',
  '・混沌',
  '・黙示',
  '・終焉',
  '・永劫',
  '・輪廻',
  '・無間',
];

String enemyNameForStage(int stage) {
  final enemy = enemyForStage(stage);
  final rank = encounterIndexOf(stage);
  if (rank <= 0) return enemy.name;
  if (rank < _rankSuffixes.length) return '${enemy.name}${_rankSuffixes[rank]}';

  // 使い切ったら、最後の称号に番号を足して続ける。何周しても名前が尽きない。
  final extra = rank - _rankSuffixes.length + 2;
  return '${enemy.name}${_rankSuffixes.last}$extra';
}
