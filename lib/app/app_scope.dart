import 'package:flutter/widgets.dart';

import '../core/feedback_service.dart';
import '../core/records_repository.dart';
import '../core/settings_controller.dart';
import '../core/share_service.dart';

/// 앱 전역 서비스 주입용 InheritedWidget.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.settings,
    required this.records,
    required this.fx,
    required this.share,
    required super.child,
  });

  final SettingsController settings;
  final RecordsRepository records;
  final FeedbackService fx;
  final ShareService share;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
