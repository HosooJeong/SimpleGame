import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import 'strings.dart';
import 'theme.dart';

class SnackGameApp extends StatelessWidget {
  const SnackGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: buildAppTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      // 웹(PWA)의 넓은 데스크톱 화면에서는 모바일 폭으로 가운데 고정.
      builder: kIsWeb
          ? (context, child) => ColoredBox(
                color: AppColors.bg,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: child!,
                  ),
                ),
              )
          : null,
    );
  }
}
