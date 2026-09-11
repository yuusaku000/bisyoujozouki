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
Enemy enemyForStage(int stage) => stage % 10 == 0 ? kBoss : kEnemies[(stage - 1) % kEnemies.length];

/// 進むほど強くなる。10ステージで約2倍。
double stageScale(int stage) => 1 + (stage - 1) * 0.1;
