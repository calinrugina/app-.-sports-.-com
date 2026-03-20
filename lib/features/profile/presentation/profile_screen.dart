import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/signup_screen.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        if (isLoggedIn) ...[
          Row(
            children: const [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logged in user',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Account settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
           ListTile(
            leading: Icon(Icons.email),
            title: Text(AppLocalizations.of(context)!.email),
            subtitle: Text(AppLocalizations.of(context)!.not_stored_demo_only),
          ),
        ] else ...[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 60, color: AppColors.gray60),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.user_not_logged_in,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redSports,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.sign_in,
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.redSports,
                      side: const BorderSide(color: AppColors.redSports, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.sign_up_action,
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Appearance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RadioListTile<ThemeMode>(
          title:  Text(AppLocalizations.of(context)!.system_default),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title:  Text(AppLocalizations.of(context)!.light),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title:  Text(AppLocalizations.of(context)!.dark),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setTheme(mode);
            }
          },
        ),
        const SizedBox(height: 24),
        if (isLoggedIn)
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label:  Text(AppLocalizations.of(context)!.logout),
            ),
          ),
        if (isLoggedIn) const SizedBox(height: 24),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.profile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }
}
