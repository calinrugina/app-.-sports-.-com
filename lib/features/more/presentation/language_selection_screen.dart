import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/language/language_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(languageProvider);

    const languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'ro', 'label': 'Română'},
      {'code': 'es', 'label': 'Español'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final code = lang['code']!;
          final label = lang['label']!;
          return RadioListTile<String>(
            title: Text(label),
            value: code,
            groupValue: current,
            onChanged: (value) {
              if (value != null) {
                ref.read(languageProvider.notifier).setLanguage(value);
              }
            },
          );
        },
      ),
    );
  }
}
