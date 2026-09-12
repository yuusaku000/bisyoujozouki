import 'organ.dart';

/// 臓器ひとつぶんの計測値。
class Vital {
  const Vital({
    required this.label,
    required this.raw,
    required this.value,
    required this.unit,
    required this.normal,
    required this.low,
    required this.high,
    required this.higherIsBetter,
  });

  final String label;

  /// グラフを引くための素の値。表示は value を使う。
  final double raw;

  /// 表示する値。桁の出し方が指標ごとに違うので、整えた文字列で持つ。
  final String value;

  final String unit;

  /// 目安の範囲。数字だけ出されても、良いのか悪いのか分からない。
  final String normal;

  final double low;
  final double high;

  /// 増えたときに良い指標か。心拍は下がるほど良く、睡眠は上がるほど良い。
  /// 推測で決めると、心拍が上がったのを緑で出すような間違いが起きる。
  final bool higherIsBetter;

  bool get inRange => raw >= low && raw <= high;
}

/// 計測値の出どころ。
///
/// いずれ時計から取る。差し替えたときに画面側を触らずに済むよう、
/// どう出しているかはここに閉じ込めている。
abstract class VitalSource {
  const VitalSource();

  /// その臓器の計測値。先頭がホームに出る代表値。
  List<Vital> read(Organ organ, OrganStatus status, int day) =>
      readAt(organ, status.health, day);

  /// 健康度と日付を直接渡す。過去の日のぶんを引き直して推移を出すため。
  List<Vital> readAt(Organ organ, int health, int day);
}

/// 時計がつながるまでの値。
class DerivedVitalSource extends VitalSource {
  const DerivedVitalSource();

  @override
  List<Vital> readAt(Organ organ, int health, int day) {
    // 健康度20〜100を0〜1に伸ばす。0が最も悪い。
    final t =
        ((health - OrganStatus.minHealth) /
                (OrganStatus.maxHealth - OrganStatus.minHealth))
            .clamp(0.0, 1.0);

    // 五人の数字が同じ動き方をすると、測っているように見えない。
    // 日付と臓器で決まるぶれを足す。同じ日に開き直しても変わらない。
    final n = _noise(organ.id, day);

    return switch (organ.id) {
      'heart' => [
        _int('安静時心拍', 88 - 30 * t + n * 3, 'bpm', '50〜75', 50, 75, false),
        _int('心拍変動', 25 + 40 * t + n * 4, 'ms', '40以上', 40, 200, true),
      ],
      'lung' => [
        _int('呼吸数', 22 - 9 * t + n, '回/分', '12〜18', 12, 18, false),
        _one('血中酸素', 95 + 4 * t + n * 0.2, '%', '96以上', 96, 100, true),
      ],
      'stomach' => [
        _int('消化スコア', 45 + 50 * t + n * 3, '', '70以上', 70, 100, true),
        _int('食後に落ち着くまで', 60 - 48 * t + n * 4, '分', '30以内', 0, 30, false),
      ],
      'liver' => [
        _int('代謝スコア', 45 + 50 * t + n * 3, '', '70以上', 70, 100, true),
        _one('休めた時間', 2 + 12 * t + n * 0.5, '時間', '10以上', 10, 24, true),
      ],
      'brain' => [
        _int('睡眠スコア', 48 + 44 * t + n * 3, '', '70以上', 70, 100, true),
        _one('深い眠り', 0.6 + 1.3 * t + n * 0.1, '時間', '1.2以上', 1.2, 4, true),
      ],
      _ => const [],
    };
  }

  /// 臓器と日付から決まる −1.0〜1.0 のぶれ。
  double _noise(String id, int day) {
    var h = day * 2654435761;
    for (final code in id.codeUnits) {
      h = (h ^ code) * 16777619;
    }
    return ((h.abs() % 1000) / 500.0) - 1.0;
  }

  Vital _int(
    String label,
    double raw,
    String unit,
    String normal,
    double low,
    double high,
    bool higherIsBetter,
  ) {
    final v = raw.round();
    return Vital(
      label: label,
      raw: v.toDouble(),
      value: '$v',
      unit: unit,
      normal: normal,
      low: low,
      high: high,
      higherIsBetter: higherIsBetter,
    );
  }

  Vital _one(
    String label,
    double raw,
    String unit,
    String normal,
    double low,
    double high,
    bool higherIsBetter,
  ) {
    final v = double.parse(raw.toStringAsFixed(1));
    return Vital(
      label: label,
      raw: v,
      value: v.toStringAsFixed(1),
      unit: unit,
      normal: normal,
      low: low,
      high: high,
      higherIsBetter: higherIsBetter,
    );
  }
}

const VitalSource kVitals = DerivedVitalSource();
