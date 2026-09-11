import 'package:flutter/material.dart';

import 'data/theme.dart';
import 'screens/main_shell.dart';

void main() => runApp(const ZoukicchiApp());

class ZoukicchiApp extends StatelessWidget {
  const ZoukicchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '臓器っち',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainShell(),
    );
  }
}
