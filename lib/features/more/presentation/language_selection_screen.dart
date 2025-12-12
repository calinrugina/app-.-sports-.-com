import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_config_app/l10n/app_localizations.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    const languages = [
      {
        'code': 'en',
        'label': 'English',
        'asset': 'assets/images/flags/en.png',
      },
      {
        'code': 'ro',
        'label': 'Română',
        'asset': 'assets/images/flags/ro.png',
      },
      {
        'code': 'es',
        'label': 'Español',
        'asset': 'assets/images/flags/es.png',
      },
      {
        'code': 'hi',
        'label': 'हिंदी',
        'asset': 'assets/images/flags/hi.png',
      },
      // {
      //   'code': 'de',
      //   'label': 'Deutsch',
      //   'asset': 'assets/images/flags/de.png',
      // },
      /*{
        'code': 'fr',
        'label': 'Français',
        'asset': 'assets/images/flags/fr.png',
      },

      {
        'code': 'it',
        'label': 'Italiano',
        'asset': 'assets/images/flags/it.png',
      },
      {
        'code': 'pt',
        'label': 'Português',
        'asset': 'assets/images/flags/pt.png',
      },
      {
        'code': 'ar',
        'label': 'العربية',
        'asset': 'assets/images/flags/ar.png',
      },
      {
        'code': 'sv',
        'label': 'Svenska',
        'asset': 'assets/images/flags/sv.png',
      },
      */
    ];

    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: AppLocalizations.of(context)!.select_language),
          Expanded(
            child: ListView.separated(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lang = languages[index];
                final code = lang['code']!;
                final label = lang['label']!;
                final assetPath = lang['asset']!;
                final isSelected = code == current;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 🔥 steag din assets
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade200,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                              isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}