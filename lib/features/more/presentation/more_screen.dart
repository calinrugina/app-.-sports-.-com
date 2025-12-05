import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/language/language_provider.dart';
import '../presentation/notifications_settings_screen.dart';
import '../presentation/language_selection_screen.dart';
import '../presentation/simple_webview_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  String _languageLabel(String code) {
    switch (code) {
      case 'ro':
        return 'Română';
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final languageCode = ref.watch(languageProvider);

    return ListView(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Teams & alerts preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsSettingsScreen(),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(_languageLabel(languageCode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LanguageSelectionScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms & Conditions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SimpleWebViewScreen(
                  title: 'Terms & Conditions',
                  url: 'https://sports.com/en/terms-and-conditions',
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SimpleWebViewScreen(
                  title: 'Privacy Policy',
                  url: 'https://sports.com/en/privacy-policy',
                ),
              ),
            );
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Theme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System default'),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
