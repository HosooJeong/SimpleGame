import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/l10n_context.dart';
import '../../app/theme.dart';
import '../../games/game_registry.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final scope = AppScope.of(context);
    final l = context.l;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.resetConfirmTitle),
        content: Text(l.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await scope.records.resetAll([for (final g in allGames) g.id]);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.resetDone)),
    );
  }

  /// 언어 선택 — 기기 설정 따름 / 한국어 / English.
  Future<void> _pickLanguage(BuildContext context) async {
    final settings = AppScope.of(context).settings;
    final l = context.l;
    final options = <String?, String>{
      null: l.languageSystem,
      'ko': l.languageKorean,
      'en': l.languageEnglish,
    };

    final picked = await showDialog<_LanguageChoice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.language),
        children: [
          for (final entry in options.entries)
            ListTile(
              title: Text(entry.value),
              trailing: settings.localeCode == entry.key
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () =>
                  Navigator.pop(context, _LanguageChoice(entry.key)),
            ),
        ],
      ),
    );
    if (picked != null) settings.setLocaleCode(picked.code);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final l = context.l;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.language),
              subtitle: Text(switch (settings.localeCode) {
                'ko' => l.languageKorean,
                'en' => l.languageEnglish,
                _ => l.languageSystem,
              }),
              onTap: () => _pickLanguage(context),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(l.sound),
              secondary: const Icon(Icons.volume_up),
              value: settings.soundOn,
              onChanged: settings.setSound,
            ),
            SwitchListTile(
              title: Text(l.haptics),
              secondary: const Icon(Icons.vibration),
              value: settings.hapticsOn,
              onChanged: settings.setHaptics,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l.shareApp),
              onTap: () async {
                final shared = await scope.share.shareApp(l);
                if (!shared && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.copiedFallback)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.danger),
              title: Text(l.resetRecords,
                  style: const TextStyle(color: AppColors.danger)),
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다이얼로그를 그냥 닫은 경우(null)와 '기기 설정 따름'(code == null)을
/// 구분하기 위한 래퍼.
class _LanguageChoice {
  const _LanguageChoice(this.code);

  final String? code;
}
