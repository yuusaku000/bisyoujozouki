import 'package:flutter/gestures.dart';
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
      scrollBehavior: const _DragAnywhere(),
      // builder に置くと、下から出る紙や上に重なる幕もまとめて覆える。
      // home に置くと、そういう場所を触ったときだけ何も出なくなる。
      builder: (context, child) => TapEffects(child: child ?? const SizedBox()),
      home: const MainShell(),
    );
  }
}

/// つかんで動かせるものを増やす。
///
/// web の既定では、指とペンでしか掴めない扱いになっている。そのせいで
/// マウスで横に振っても、育成の立ち絵が捲れなかった。
class _DragAnywhere extends MaterialScrollBehavior {
  const _DragAnywhere();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
