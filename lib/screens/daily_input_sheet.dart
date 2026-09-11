import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/organs.dart';
import '../data/theme.dart';
import '../models/daily_input.dart';
import '../widgets/coin_text.dart';
import '../widgets/ornate.dart';

/// 今日の行動を記録する。歩数と階段はいずれ端末から自動で取る。
class DailyInputSheet extends StatefulWidget {
  const DailyInputSheet({
    super.key,
    required this.initial,
    required this.stepGoal,
    required this.readEpisodes,
  });

  final DailyInput initial;
  final int stepGoal;

  /// まだ出会っていない臓器の項目は出さない。
  final Set<String> readEpisodes;

  @override
  State<DailyInputSheet> createState() => _DailyInputSheetState();
}

class _DailyInputSheetState extends State<DailyInputSheet> {
  late DailyInput _input = widget.initial;
  late final _stepsController = TextEditingController(
    text: _input.steps > 0 ? '${_input.steps}' : '',
  );
  late final _stairsController = TextEditingController(
    text: _input.stairs > 0 ? '${_input.stairs}' : '',
  );

  @override
  void dispose() {
    _stepsController.dispose();
    _stairsController.dispose();
    super.dispose();
  }

  bool _has(String organId) =>
      organById(organId).isUnlocked(widget.readEpisodes);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.panelGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.goldDim, width: 1.2)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hollow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(child: OrnateLabel('きょうの記録')),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '目標 ${widget.stepGoal}歩',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _numberField(
                controller: _stepsController,
                label: '歩数',
                suffix: '歩',
                organName: '心臓',
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(steps: v)),
              ),
              if (_has('lung')) ...[
                const SizedBox(height: 14),
                _numberField(
                  controller: _stairsController,
                  label: '上った階段',
                  suffix: '階',
                  organName: '肺',
                  onChanged: (v) =>
                      setState(() => _input = _input.copyWith(stairs: v)),
                ),
              ],
              const SizedBox(height: 20),
              if (_has('stomach'))
                _toggle(
                  title: 'ちゃんと食べた',
                  subtitle: '腹八分目で、食事を抜かなかった',
                  organName: '胃',
                  value: _input.ateWell,
                  onChanged: (v) =>
                      setState(() => _input = _input.copyWith(ateWell: v)),
                ),
              if (_has('liver'))
                _toggle(
                  title: '体を休めた',
                  subtitle: '飲みすぎず、無理をしなかった',
                  organName: '肝臓',
                  value: _input.rested,
                  onChanged: (v) =>
                      setState(() => _input = _input.copyWith(rested: v)),
                ),
              if (_has('brain'))
                _toggle(
                  title: 'よく眠れた',
                  subtitle: '7時間以上、夜更かしをしなかった',
                  organName: '脳',
                  value: _input.sleptWell,
                  onChanged: (v) =>
                      setState(() => _input = _input.copyWith(sleptWell: v)),
                ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.hollow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.goldDim.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'もらえるコイン',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatCoins(_input.coinsEarned),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              JewelButton(
                label: '1日を終える',
                onPressed: () => Navigator.pop(context, _input),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String organName,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithOrgan(label, organName),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (text) => onChanged(int.tryParse(text) ?? 0),
          decoration: InputDecoration(
            suffixText: suffix,
            filled: true,
            fillColor: AppColors.hollow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggle({
    required String title,
    required String subtitle,
    required String organName,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelWithOrgan(title, organName),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.rose,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// どの臓器に効く入力なのかを添える。世話をしている感覚を出すため。
  Widget _labelWithOrgan(String label, String organName) {
    final organ = kOrgans.firstWhere((o) => o.name == organName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: organ.accent.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            organ.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: organ.accent,
            ),
          ),
        ),
      ],
    );
  }
}
