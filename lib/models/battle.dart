import 'dart:math';

import '../data/enemies.dart';
import '../data/organs.dart';
import 'enemy.dart';
import 'organ.dart';

/// 臓器ごとの攻撃力の土台。役割の違いをここで表す。
const Map<String, int> kOrganBaseAttack = {
  'heart': 100,
  'lung': 80,
  'stomach': 40,
  'liver': 60,
  'brain': 70,
};

class BattleEvent {
  const BattleEvent(this.text, {this.actorId, this.damage, this.heal});

  final String text;
  final String? actorId;
  final int? damage;
  final int? heal;
}

class BattleResult {
  const BattleResult({
    required this.won,
    required this.turns,
    required this.log,
    required this.partyHp,
    required this.partyMaxHp,
    required this.enemyHp,
    required this.enemyMaxHp,
  });

  final bool won;
  final int turns;
  final List<BattleEvent> log;
  final int partyHp;
  final int partyMaxHp;
  final int enemyHp;
  final int enemyMaxHp;
}

/// 自動戦闘。乱数を使わないので、同じ健康度なら結果は必ず同じになる。
///
/// 勝てないときに「運が悪かった」で片付けられると、運動して強くなるという
/// 動機が働かない。負けたら素直に力不足だと分かるほうがよい。
class Battle {
  Battle({required this.organs, required this.stage});

  final Map<String, OrganStatus> organs;
  final int stage;

  static const int maxTurns = 30;
  static const double partyHpFactor = 4.0;

  int powerOf(String id) =>
      (organs[id] ?? const OrganStatus()).power(kOrganBaseAttack[id] ?? 50);

  int get partyMaxHp =>
      (kOrgans.map((o) => powerOf(o.id)).reduce((a, b) => a + b) *
              partyHpFactor)
          .round();

  BattleResult run() {
    final enemy = enemyForStage(stage);
    final scale = stageScale(stage);
    final enemyMaxHp = (enemy.baseHp * scale).round();
    final enemyAttack = (enemy.baseAttack * scale).round();

    var partyHp = partyMaxHp;
    var enemyHp = enemyMaxHp;
    var bleed = 0; // 心臓が刻む継続ダメージ
    var buff = 0; // 脳が積むダメージ上昇
    final debuffs = <Debuff>{};
    final log = <BattleEvent>[];

    var turn = 0;
    while (turn < maxTurns && partyHp > 0 && enemyHp > 0) {
      turn++;
      log.add(BattleEvent('― $turnターン目 ―'));

      if (bleed > 0 && !debuffs.contains(Debuff.namake)) {
        enemyHp -= bleed;
        log.add(BattleEvent('継続ダメージ $bleed', damage: bleed));
      }

      for (final organ in kOrgans) {
        if (enemyHp <= 0) break;
        final power = powerOf(organ.id);
        final weakened = debuffs.contains(Debuff.nemuke);

        switch (organ.id) {
          case 'heart':
            final dmg = _damage(power, buff, weakened);
            enemyHp -= dmg;
            bleed += (power * 0.2).round();
            log.add(BattleEvent('${organ.name}の鼓動  $dmg',
                actorId: organ.id, damage: dmg));

          case 'lung':
            // 長く戦うほど息が続く
            final dmg = _damage((power * (1 + turn * 0.12)).round(), buff, weakened);
            enemyHp -= dmg;
            log.add(BattleEvent('${organ.name}の呼吸  $dmg',
                actorId: organ.id, damage: dmg));

          case 'stomach':
            var heal = (power * 1.2).round();
            if (debuffs.contains(Debuff.motare)) heal = (heal / 2).round();
            partyHp = min(partyMaxHp, partyHp + heal);
            log.add(BattleEvent('${organ.name}が回復  +$heal',
                actorId: organ.id, heal: heal));

          case 'liver':
            if (debuffs.isNotEmpty) {
              final cleared = debuffs.first;
              debuffs.remove(cleared);
              log.add(BattleEvent('${organ.name}が${cleared.label}を解除',
                  actorId: organ.id));
            } else {
              final dmg = _damage(power, buff, weakened);
              enemyHp -= dmg;
              log.add(BattleEvent('${organ.name}の解毒  $dmg',
                  actorId: organ.id, damage: dmg));
            }

          case 'brain':
            buff += (power * 0.15).round();
            log.add(BattleEvent('${organ.name}が弱点を見抜いた  攻撃力+$buff',
                actorId: organ.id));
        }
      }

      if (enemyHp <= 0) break;

      if (debuffs.contains(Debuff.kori)) {
        final dmg = (partyMaxHp * 0.03).round();
        partyHp -= dmg;
        log.add(BattleEvent('こりで $dmg', damage: dmg));
      }

      partyHp -= enemyAttack;
      log.add(BattleEvent('${enemy.name}の攻撃  $enemyAttack', damage: enemyAttack));

      // 3ターンごとに不調を押しつけてくる
      if (enemy.applies != Debuff.none && turn % 3 == 0) {
        debuffs.add(enemy.applies);
        log.add(BattleEvent('${enemy.name}に${enemy.applies.label}をもらった'));
      }
    }

    final won = enemyHp <= 0 && partyHp > 0;
    log.add(BattleEvent(won ? '${enemy.name}を倒した！' : '倒れてしまった…'));

    return BattleResult(
      won: won,
      turns: turn,
      log: log,
      partyHp: max(0, partyHp),
      partyMaxHp: partyMaxHp,
      enemyHp: max(0, enemyHp),
      enemyMaxHp: enemyMaxHp,
    );
  }

  int _damage(int power, int buff, bool weakened) {
    final raw = power + buff;
    return weakened ? (raw * 0.6).round() : raw;
  }
}
