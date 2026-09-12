import 'package:flutter_test/flutter_test.dart';
import 'package:zoukicchi/widgets/today_clock.dart';

void main() {
  group('今日の表示', () {
    test('曜日がずれない', () {
      // DateTime.weekday は月曜が1。添字を1引き忘れると全部ずれる
      expect(formatToday(DateTime(2026, 9, 7, 9, 5)), '9月7日(月)  9:05');
      expect(formatToday(DateTime(2026, 9, 12, 13, 45)), '9月12日(土)  13:45');
      expect(formatToday(DateTime(2026, 9, 13, 0, 0)), '9月13日(日)  0:00');
    });

    test('分は2桁、時と月日は詰めない', () {
      expect(formatToday(DateTime(2026, 1, 3, 7, 9)), '1月3日(土)  7:09');
    });
  });
}
