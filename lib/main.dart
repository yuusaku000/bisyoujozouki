import 'package:flutter/material.dart';

import 'data/theme.dart';
import 'screens/main_shell.dart';
import 'widgets/tap_effect.dart';

void main() => runApp(const ZoukicchiApp());

class ZoukicchiApp extends StatelessWidget {
  const ZoukicchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '臓器っち',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // builder に置くと、下から出る紙や上に重なる幕もまとめて覆える。
      // home に置くと、そういう場所を触ったときだけ何も出なくなる。
      builder: (context, child) => TapEffects(child: child ?? const SizedBox()),
      home: const MainShell(),
    );
  }
}
