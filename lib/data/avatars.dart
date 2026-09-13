import '../data/enemies.dart';
import '../data/organs.dart';
import '../models/game_state.dart';
import '../models/organ.dart';

/// プロフィールのアイコン。
///
/// 顔は「出会った子」、敵は「倒した相手」しか選べない。
/// 最初から全部並んでいると、選ぶ楽しみも進める理由もなくなる。
class Avatar {
  const Avatar({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.isEnemy,
  });

  /// 保存する識別子。'organ:heart' や 'enemy:ramen' の形。
  final String id;

  final String name;
  final String imagePath;

  /// 敵の絵は顔用に切り出していないので、表示のときに寄せ方を変える。
  final bool isEnemy;
}

const String kDefaultAvatar = 'organ:heart';

/// 仲間になった子のぶん。顔は今の調子ではなく元気な顔で揃える。
List<Avatar> organAvatars(GameState state) => [
  for (final organ in state.party)
    Avatar(
      id: 'organ:${organ.id}',
      name: organ.name,
      imagePath: organ.facePath(Condition.genki),
      isEnemy: false,
    ),
];

/// 一度でも出したことのある敵。
///
/// 何周目かで並びが変わるので、到達ステージまでを順に引き直して数える。
List<Avatar> enemyAvatars(GameState state) {
  final seen = <String>{};
  for (var stage = 1; stage <= state.clearedStage; stage++) {
    seen.add(enemyForStage(stage).id);
  }

  return [
    for (final enemy in [...kEnemies, kBoss])
      if (seen.contains(enemy.id))
        Avatar(
          id: 'enemy:${enemy.id}',
          name: enemy.name,
          imagePath: enemy.imagePath,
          isEnemy: true,
        ),
  ];
}

List<Avatar> availableAvatars(GameState state) => [
  ...organAvatars(state),
  ...enemyAvatars(state),
];

/// 選んでいるアイコン。持っていないものが入っていても心臓に戻す。
///
/// データを直接いじられたときや、仕様が変わったときに崩れないように。
Avatar avatarOf(GameState state) {
  final all = availableAvatars(state);
  for (final avatar in all) {
    if (avatar.id == state.avatarId) return avatar;
  }

  final heart = organById('heart');
  return Avatar(
    id: kDefaultAvatar,
    name: heart.name,
    imagePath: heart.facePath(Condition.genki),
    isEnemy: false,
  );
}
