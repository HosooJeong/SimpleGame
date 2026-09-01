import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/feedback_service.dart';
import 'core/records_repository.dart';
import 'core/settings_controller.dart';
import 'core/share_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(prefs);
  final fx = FeedbackService(settings);
  await fx.init();

  runApp(
    AppScope(
      settings: settings,
      records: RecordsRepository(prefs),
      fx: fx,
      share: const ShareService(),
      child: const SnackGameApp(),
    ),
  );
}
