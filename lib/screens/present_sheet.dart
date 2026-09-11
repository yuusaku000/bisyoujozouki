import 'package:flutter/material.dart';

import '../data/theme.dart';
import '../models/game_state.dart';
import '../models/organ.dart';
import '../models/present.dart';

class GiftResult {
  const GiftResult({required this.present, required this.favorite});

  final Present present;
  final bool favorite;
}

/// 誰に何を渡すかを選ぶ。好物には印が付く。
class PresentSheet extends StatelessWidget {
  const PresentSheet({super.key, required this.state, required this.organ});

  final GameState state;
  final Organ organ;

  @override
  Widget build(BuildContext context) {
    final owned = state.ownedPresents;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.goldDim, width: 1.2)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.hollow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  organ.facePath(Condition.genki),
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${organ.name}に渡す',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '好きなものを渡すと、効果が倍になります',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: owned.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'まだ何も持っていません。ガチャで引いてみてください',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: owned.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _row(context, owned[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Present present) {
    final favorite = present.isFavoriteOf(organ.id);
    final gain = present.affectionFor(organ.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          state.givePresent(organ.id, present);
          Navigator.pop(
            context,
            GiftResult(present: present, favorite: favorite),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.hollow.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: favorite
                  ? AppColors.rose
                  : present.rarity.color.withValues(alpha: 0.55),
              width: favorite ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(present.icon, size: 22, color: present.rarity.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            present.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (favorite) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: AppColors.rose,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      present.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+$gain',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: favorite ? AppColors.rose : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '×${state.countOf(present.id)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
