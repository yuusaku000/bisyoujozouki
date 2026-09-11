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

/// 10ステージごとにボス。それ以外は通常の敵が順に出る。
///
/// 周回内の位置で選ぶ。通し番号で選ぶとボスの分だけ並びがずれて、
/// 2周目の1戦目が別の敵になってしまう。
Enemy enemyForStage(int stage) {
  if (stage % 10 == 0) return kBoss;
  final inLoop = (stage - 1) % 10;
  return kEnemies[inLoop % kEnemies.length];
}

/// 進むほど強くなる。10ステージで約2倍。
double stageScale(int stage) => 1 + (stage - 1) * 0.1;

/// 何周目の相手か。ボスを超えると同じ顔ぶれが戻ってくる。
int loopOfStage(int stage) => (stage - 1) ~/ 10;

// 周回が進むごとに、同じ敵でも呼び名が変わる。同じ名前が並ぶと
// 進んでいる実感が薄れるため。
const List<String> _loopSuffixes = [
  '',
  '・改',
  '・覚醒',
  '・真',
  '・極',
  '・災禍',
];

String enemyNameForStage(int stage) {
  final enemy = enemyForStage(stage);
  final loop = loopOfStage(stage);
  if (loop <= 0) return enemy.name;
  final suffix = loop < _loopSuffixes.length
      ? _loopSuffixes[loop]
      : '・災禍${loop - _loopSuffixes.length + 2}';
  return '${enemy.name}$suffix';
}
