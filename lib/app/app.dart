import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home/home_screen.dart';
import 'app_scope.dart';
import 'theme.dart';

class SnackGameApp extends StatelessWidget {
  const SnackGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    // 설정에서 언어를 바꾸면 앱 전체를 다시 그려야 한다.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => _buildApp(settings.localeCode),
    );
  }

  Widget _buildApp(String? localeCode) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: buildAppTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // null이면 기기 언어를 따르고, 값이 있으면 그 언어로 고정한다.
      locale: localeCode == null ? null : Locale(localeCode),
      // 후보 목록(기기 언어 또는 위에서 고정한 언어)에 한국어가 있으면 한국어,
      // 없으면 전부 영어.
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
