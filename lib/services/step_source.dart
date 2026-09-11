import '../models/daily_input.dart';

/// その日の歩数と階段をどこから得るか。
///
/// 今は手入力だが、いずれ端末のHealth Connectから取る。差し替えたときに
/// 画面側を触らずに済むよう、取得元をここに閉じ込めている。
abstract class StepSource {
  /// 自動取得できるなら今日の値を返す。手入力の場合はnull。
  Future<DailyInput?> readToday();

  bool get isManual;
}

class ManualStepSource implements StepSource {
  @override
  Future<DailyInput?> readToday() async => null;

  @override
  bool get isManual => true;
}
