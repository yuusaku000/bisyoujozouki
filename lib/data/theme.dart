import 'package:flutter/material.dart';

/// 深いプラムに薔薇色と金を乗せる。可愛さだけだと安っぽくなるので、
/// 彩度を落とした暗色を土台にして、光る部分を絞っている。
class AppColors {
  static const background = Color(0xFF170E1A);
  static const backgroundDeep = Color(0xFF0E0710);

  static const panelTop = Color(0xFF3A2544);
  static const panelBottom = Color(0xFF241531);
  static const panelSoft = Color(0xFF2E1D38);
  static const hollow = Color(0xFF1B1023);

  static const gold = Color(0xFFE3C07A);
  static const goldDim = Color(0xFF8A6E42);
  static const rose = Color(0xFFFF88AC);
  static const roseDeep = Color(0xFFD44B78);

  static const textPrimary = Color(0xFFF8EEF4);
  static const textMuted = Color(0xFFB39EBC);

  static const genki = Color(0xFF7BE6A8);
  static const futsuu = Color(0xFFE3C07A);
  static const fuchou = Color(0xFFFF7A8A);

  static const panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [panelTop, panelBottom],
  );

  static const roseGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF9DBB), Color(0xFFE05C8B)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF3D9A4), Color(0xFFCFA85E)],
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.rose,
      surface: AppColors.panelSoft,
    ),
    // 同梱した書体を既定にする。端末やブラウザの持ち物に頼らない。
    textTheme: base.textTheme.apply(
      fontFamily: 'NotoSansJP',
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'NotoSansJP'),
  );
}
