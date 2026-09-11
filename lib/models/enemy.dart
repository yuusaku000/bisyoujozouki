/// 敵が押しつけてくる不調。肝臓が解除する。
enum Debuff {
  none(''),
  motare('もたれ', '回復量が半分になる'),
  nemuke('眠気', '攻撃力が下がる'),
  namake('なまけ', '継続ダメージが入らなくなる'),
  kori('こり', '毎ターン少しずつ削られる');

  const Debuff(this.label, [this.description = '']);
  final String label;
  final String description;
}

/// 不摂生の擬人化。倒す相手は自分の悪習慣そのもの。
class Enemy {
  const Enemy({
    required this.id,
    required this.name,
    required this.baseHp,
    required this.baseAttack,
    required this.applies,
    this.isBoss = false,
  });

  final String id;
  final String name;
  final int baseHp;
  final int baseAttack;
  final Debuff applies;
  final bool isBoss;

  String get imagePath => 'assets/enemies/$id.png';
}
