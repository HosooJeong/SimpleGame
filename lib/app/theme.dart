import 'package:flutter/material.dart';

/// 캐주얼 팝 테마 — 따뜻한 크림 배경 + 게임별 쨍한 컬러 + 밑면 엣지(3D) 문법.
abstract final class AppColors {
  static const bg = Color(0xFFFFF4DE); // 크림
  static const bgShape = Color(0xFFFFE7BD); // 배경 장식 도형
  static const surface = Color(0xFFFFFFFF);
  static const surfaceEdge = Color(0xFFE8D3AE); // 흰 카드 밑면 엣지
  static const border = Color(0xFFF3E3C3);

  static const accent = Color(0xFFFF9600); // 브랜드 오렌지

  static const success = Color(0xFF58CC02);
  static const danger = Color(0xFFFF4B4B);

  static const textPrimary = Color(0xFF553F25); // 진한 브라운
  static const textDim = Color(0xFFB2986E);
}

/// 게임별 고유 컬러 — 같은 채도 계열의 캔디 팔레트.
abstract final class GameColors {
  static const red = Color(0xFFFF4B4B); // 반응속도
  static const blue = Color(0xFF1CB0F6); // 숫자 순서
  static const yellow = Color(0xFFFFC800); // 탭 스피드
  static const purple = Color(0xFFA560E8); // 타이밍 스톱
  static const green = Color(0xFF58CC02); // 순서 기억
  static const orange = Color(0xFFFF9600); // 정확한 10초
  static const pink = Color(0xFFF65CA8); // 다른 색 찾기
  static const indigo = Color(0xFF6979F8); // 색깔 함정
  static const teal = Color(0xFF00C2B2); // 순간 기억
  static const lime = Color(0xFFA6C700); // 반반 자르기
  static const cyan = Color(0xFF00B7E4); // 완벽한 원
  static const magenta = Color(0xFFD34FD4); // 셔플 추적
  static const emerald = Color(0xFF00C46A); // 순간 셈
  static const coral = Color(0xFFFF6B3B); // 가짜 신호
}

/// 버튼 밑면 엣지용 어두운 색 (눌림 표현은 버튼에만 사용).
Color darken(Color color, [double amount = 0.22]) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
      .toColor();
}

Color lighten(Color color, [double amount = 0.08]) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
      .toColor();
}

/// 흰 카드 공통 그림자 — 부드러운 확산 그림자.
const kCardShadow = [
  BoxShadow(
    color: Color(0x59D9B679),
    blurRadius: 12,
    offset: Offset(0, 5),
  ),
];

/// 카드 공통 데코레이션 — 소프트 섀도 스타일.
BoxDecoration cardDecoration({
  double radius = 20,
  Color color = AppColors.surface,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: kCardShadow,
    );

ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: Colors.white,
    secondary: AppColors.success,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Pretendard',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Jua',
        fontSize: 22,
        color: AppColors.textPrimary,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      // 점수·타이머·카운트다운용 게임 디스플레이 폰트.
      displayLarge: const TextStyle(
        fontFamily: 'BlackHanSans',
        fontSize: 60,
        color: AppColors.textPrimary,
        height: 1.1,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'BlackHanSans',
        fontSize: 34,
        color: AppColors.textPrimary,
        height: 1.15,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'Jua',
        fontSize: 22,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      bodySmall: const TextStyle(fontSize: 13, color: AppColors.textDim),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.success
            : AppColors.border,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
