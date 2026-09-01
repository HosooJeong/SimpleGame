import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home/home_screen.dart';
import 'theme.dart';

class SnackGameApp extends StatelessWidget {
  const SnackGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: buildAppTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // 시스템 언어가 한국어면 한국어, 그 밖에는 전부 영어.
      localeListResolutionCallback: (locales, supported) {
        final isKorean = locales?.any((l) => l.languageCode == 'ko') ?? false;
        return isKorean ? const Locale('ko') : const Locale('en');
      },
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
