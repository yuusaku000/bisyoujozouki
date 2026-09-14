/// 世界ランキング。
///
/// 相手がいるわけではないので、順位は作りもの。世界中の人の成績が
/// 正規分布に従うものとして、自分がその何％のあたりにいるかを出す。
///
/// 本物の集計に差し替えるときも、[stageTopPercent] と
/// [heartTopPercent] の中身を入れ替えるだけで済むようにしてある。
library;

import 'dart:math';

import '../models/organ.dart';

/// 上位5%にあたる z 値。この位置に「目標」を置く。
const double _z95 = 1.6448536269514722;

/// ── ステージ ──
///
/// 65階あたりが真ん中。100階まで行けば上位5%。
/// はじめたばかりの人は下から数えたほうが早いので、上位100%に近くなる。
const double stageMedian = 65;
const double stageTop5 = 100;

/// ── 親密度 ──
///
/// ♡2のあたりが真ん中、♡5+10まで積んでようやく上位5%。
/// 段を小数で見るので、ひとつ渡すたびに少しずつ動く。
///
/// ステージより渋くしてある。物語を読みきる♡5でもまだ3割どまりで、
/// そこから先に伸ばした人だけが上に行く。
const double heartMedian = 2;
const double heartTop5 = 15;

/// 到達ステージの上位何％か。
double stageTopPercent(int clearedStage) =>
    _topPercent(clearedStage.toDouble(), stageMedian, stageTop5);

/// その子の親密度の上位何％か。[OrganStatus.heartLevel] を渡す。
double heartTopPercent(double heartLevel) =>
    _topPercent(heartLevel, heartMedian, heartTop5);

/// [median] が50%、[top5] が5%になるように正規分布を当てて、
/// [value] が上位何％かを返す。
double _topPercent(double value, double median, double top5) {
  final sd = (top5 - median) / _z95;
  final z = (value - median) / sd;
  // 0は返さない。「上位0%」は意味が通らないし、上に誰もいないことになる。
  return (_upperTail(z) * 100).clamp(0.01, 100.0);
}

/// 標準正規分布で、z より上にいる割合。
double _upperTail(double z) => 0.5 * _erfc(z / sqrt2);

/// 相補誤差関数。Abramowitz & Stegun 7.1.26 の近似で、誤差は1.5e-7ほど。
/// 順位の表示に使うだけなので、この精度で足りる。
double _erfc(double x) {
  final sign = x < 0 ? -1 : 1;
  final ax = x.abs();

  const p = 0.3275911;
  const a1 = 0.254829592;
  const a2 = -0.284496736;
  const a3 = 1.421413741;
  const a4 = -1.453152027;
  const a5 = 1.061405429;

  final t = 1 / (1 + p * ax);
  final poly = t * (a1 + t * (a2 + t * (a3 + t * (a4 + t * a5))));
  final erf = 1 - poly * exp(-ax * ax);

  return 1 - sign * erf;
}

/// 「上位 12.4%」の数のところ。
///
/// 桁を固定すると、上のほうで 0% と出たり、下のほうで 54.0% と
/// うるさくなったりする。大きいときほど粗く出す。
String formatPercent(double percent) {
  if (percent >= 10) return percent.toStringAsFixed(0);
  if (percent >= 1) return percent.toStringAsFixed(1);
  return percent.toStringAsFixed(2);
}

/// 順位につける呼び名。数字だけだと、それが良いのか分からない。
String rankTitle(double percent) {
  if (percent <= 0.1) return '伝説';
  if (percent <= 1) return '頂点';
  if (percent <= 5) return '英傑';
  if (percent <= 15) return '熟練';
  if (percent <= 35) return '常連';
  if (percent <= 60) return '見習い';
  return 'かけだし';
}
