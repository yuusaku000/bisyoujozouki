import 'dart:async';

import 'package:flutter/material.dart';

const List<String> _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

/// 「9月12日(土)  13:45」の形にする。
///
/// DateTime.weekday は月曜が1。添字にするときに1引く必要があり、
/// ここを間違えると曜日が1日ずれたまま誰も気づかない。
String formatToday(DateTime now) {
  final weekday = _weekdays[now.weekday - 1];
  final minute = now.minute.toString().padLeft(2, '0');
  return '${now.month}月${now.day}日($weekday)  ${now.hour}:$minute';
}

/// 現実の日付と時刻。
///
/// 画面には「N日目」しか出ていないので、いつの記録なのかが分からない。
/// 歩数を入れるのは一日の終わりなので、日付が変わったかどうかも効いてくる。
class TodayClock extends StatefulWidget {
  const TodayClock({super.key, this.style});

  final TextStyle? style;

  @override
  State<TodayClock> createState() => _TodayClockState();
}

class _TodayClockState extends State<TodayClock> with WidgetsBindingObserver {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextMinute();
  }

  /// 分が変わる瞬間に合わせて起こす。
  /// 一定間隔で見に行くと、その間隔ぶんだけ表示が遅れる。
  void _scheduleNextMinute() {
    _timer?.cancel();
    _timer = Timer(
      Duration(seconds: 60 - _now.second, milliseconds: -_now.millisecond),
      () {
        if (!mounted) return;
        setState(() => _now = DateTime.now());
        _scheduleNextMinute();
      },
    );
  }

  /// 閉じているあいだタイマーは進まない。戻ってきたら取り直す。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    setState(() => _now = DateTime.now());
    _scheduleNextMinute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(formatToday(_now), style: widget.style);
  }
}
