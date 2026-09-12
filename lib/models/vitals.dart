import 'organ.dart';

/// 臓器ひとつぶんの計測値。
class Vital {
  const Vital({
    required this.label,
    required this.value,
    required this.unit,
    required this.normal,
    required this.inRange,
  });

  final String label;

  /// 表示する値。桁の出し方が指標ごとに違うので、整えた文字列で持つ。
  final String value;

  final String unit;

  /// 目安の範囲。数字だけ出されても、良いのか悪いのか分からない。
  final String normal;

  final bool inRange;
}

/// 計測値の出どころ。
///
/// いずれ時計から取る。差し替えたときに画面側を触らずに済むよう、
/// どう出しているかはここに閉じ込めている。
abstract class VitalSource {
  /// その臓器の計測値。先頭がホームに出る代表値。
  List<Vital> read(Organ organ, OrganStatus status, int day);
}

/// 時計がつながるまでの値。
class DerivedVitalSource implements VitalSource {
  const DerivedVitalSource();

  @override
  List<Vital> read(Organ organ, OrganStatus status, int day) {
    // 健康度20〜100を0〜1に伸ばす。0が最も悪い。
    final t =
        ((status.health - OrganStatus.minHealth) /
                (OrganStatus.maxHealth - OrganStatus.minHealth))
            .clamp(0.0, 1.0);

    // 五人の数字が同じ動き方をすると、測っているように見えない。
    // 日付と臓器で決まるぶれを足す。同じ日に開き直しても変わらない。
    final n = _noise(organ.id, day);

    return switch (organ.id) {
      'heart' => [
        _int('安静時心拍', 88 - 30 * t + n * 3, 'bpm', '50〜75', 50, 75),
        _int('心拍変動', 25 + 40 * t + n * 4, 'ms', '40以上', 40, 200),
      ],
      'lung' => [
        _int('呼吸数', 22 - 9 * t + n, '回/分', '12〜18', 12, 18),
        _one('血中酸素', 95 + 4 * t + n * 0.2, '%', '96以上', 96, 100),
      ],
      'stomach' => [
        _int('消化スコア', 45 + 50 * t + n * 3, '', '70以上', 70, 100),
        _int('食後に落ち着くまで', 60 - 48 * t + n * 4, '分', '30以内', 0, 30),
      ],
      'liver' => [
        _int('代謝スコア', 45 + 50 * t + n * 3, '', '70以上', 70, 100),
        _one('休めた時間', 2 + 12 * t + n * 0.5, '時間', '10以上', 10, 24),
      ],
      'brain' => [
        _int('睡眠スコア', 48 + 44 * t + n * 3, '', '70以上', 70, 100),
        _one('深い眠り', 0.6 + 1.3 * t + n * 0.1, '時間', '1.2以上', 1.2, 4),
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
  ) {
    final v = raw.round();
    return Vital(
      label: label,
      value: '$v',
      unit: unit,
      normal: normal,
      inRange: v >= low && v <= high,
    );
  }

  Vital _one(
    String label,
    double raw,
    String unit,
    String normal,
    double low,
    double high,
  ) {
    return Vital(
      label: label,
      value: raw.toStringAsFixed(1),
      unit: unit,
      normal: normal,
      inRange: raw >= low && raw <= high,
    );
  }
}

const VitalSource kVitals = DerivedVitalSource();
