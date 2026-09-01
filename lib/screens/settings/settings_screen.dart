import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../games/game_registry.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final scope = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.resetConfirmTitle),
        content: const Text(Strings.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Strings.delete,
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await scope.records.resetAll([for (final g in allGames) g.id]);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(Strings.resetDone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          children: [
            SwitchListTile(
              title: const Text(Strings.sound),
              secondary: const Icon(Icons.volume_up),
              value: settings.soundOn,
              onChanged: settings.setSound,
            ),
            SwitchListTile(
              title: const Text(Strings.haptics),
              secondary: const Icon(Icons.vibration),
              value: settings.hapticsOn,
              onChanged: settings.setHaptics,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text(Strings.shareApp),
              onTap: () async {
                final shared = await scope.share.shareApp();
                if (!shared && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(Strings.copiedFallback)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.danger),
              title: const Text(Strings.resetRecords,
                  style: TextStyle(color: AppColors.danger)),
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
      ),
    );
  }
}
