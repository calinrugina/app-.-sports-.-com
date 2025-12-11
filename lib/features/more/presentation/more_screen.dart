import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_config_app/core/theme/colors.dart';
import 'package:upgrader/upgrader.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/widgets/under_logo_area.dart';
import '../presentation/notifications_settings_screen.dart';
import '../presentation/language_selection_screen.dart';
import '../presentation/simple_webview_screen.dart';
import '../../../core/app_config.dart';
final _upgraderInstance = Upgrader(
  // debugDisplayAlways: true, // Pentru test
);

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final languageCode = ref.watch(languageProvider);
    final versionAsyncValue = ref.watch(appVersionProvider);

    final isLight = themeMode == ThemeMode.light;
    final isDark = themeMode == ThemeMode.dark;

    return Center(
      child: UpgradeAlert(
          // 2. Personalizați proprietățile Upgrader-ului, dacă doriți
          upgrader: _upgraderInstance,
          child: ListView(
            children: [
              WelcomeBanner(
                title: "Welcome to Sports.com",
                subtitle: "You now have access to personalized content and more.",
              ),
              SizedBox(height: 15,),
              Padding(padding: EdgeInsets.all(16), child: Text(
                'Other options',
                style: Theme.of(context).textTheme.headlineLarge,

              ),),
              ListTile(
                title:  Text('Notifications',
                  style: Theme.of(context).textTheme.bodyLarge,

                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsSettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title:  Text('Terms & Conditions',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SimpleWebViewScreen(
                        title: 'Terms & Conditions',
                        url: '${AppConfig.baseUrl}/$languageCode/terms-and-conditions?no-header=true&theme=${isLight?'light':'dark'}',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title:  Text('Privacy Policy',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SimpleWebViewScreen(
                        title: 'Privacy Policy',
                        url: '${AppConfig.baseUrl}/$languageCode/privacy-policy?no-header=true&theme=${isLight?'light':'dark'}',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title:  Text('Language',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                // subtitle: Text(_languageLabel(languageCode),style: Theme.of(context).textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 25,),
              Padding(padding: EdgeInsets.all(16), child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkGrey: AppColors.gray20, // fundalul "barei"
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:Row(
                    children: [
                      // LIGHT
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isLight ? Colors.white :  AppColors.darkTabs,
                                width: 2,
                              ),
                                color: isLight  ? Colors.white: AppColors.darkTabs                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                Icon(Icons.wb_sunny_outlined,
                                    color: isDark  ? Colors.white: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'Light',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: isDark  ? Colors.white: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // DARK
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.black :  AppColors.gray20,
                                width: 2,
                              ),
                              color: isDark ? Colors.black :  AppColors.gray20,

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                Icon(Icons.dark_mode, color: isDark?Colors.white:Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'Dark',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: isDark?Colors.white:Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),),
              /*
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
              */
              const SizedBox(height: 100),
              versionAsyncValue.when(
                // A. Datele sunt gata (Data)
                data: (version) => Text(
                  'Versiune: $version',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // B. Datele se încarcă (Loading)
                loading: () => const Text(
                  'Versiune: Loading...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // C. A apărut o eroare (Error)
                error: (error, stackTrace) => Text(
                  'Eroare versiune: $error',
                  style: const TextStyle(fontSize: 12, color: AppColors.redSports),
                ),
              )
            ],
          )),
    );
  }
}
