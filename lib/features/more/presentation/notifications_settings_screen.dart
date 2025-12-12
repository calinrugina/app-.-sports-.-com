import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../core/widgets/under_logo_area.dart';
import '../providers/notifications_provider.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: const SportsAppBar(),

      body: Column(
        children: [
           BackHeader(title: AppLocalizations.of(context)!.notifications),

          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title:  Text(AppLocalizations.of(context)!.enable_notifications),
                value: enabled,
                onChanged: (value) {
                  ref.read(notificationsProvider.notifier).setEnabled(value);
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Teams notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Here you will be able to choose teams for which you want to receive notifications.',
              ),
              const SizedBox(height: 8),
              const Text(
                'TODO: implement real teams list from API.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),)
        ],
      )
    );
  }
}
