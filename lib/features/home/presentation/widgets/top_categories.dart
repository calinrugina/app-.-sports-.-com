import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../sports/providers/selected_sport_provider.dart';

class TopCategories extends ConsumerWidget {
  final List<dynamic> sports;

  const TopCategories({super.key, required this.sports});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sports.isEmpty) return const SizedBox.shrink();

    final selectedIndex = ref.watch(selectedSportIndexProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: sports.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final sport = sports[index] as Map<String, dynamic>;
            final name = sport['name']?.toString() ?? 'Sport';
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                ref.read(selectedSportIndexProvider.notifier).state = index;
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isSelected ? AppColors.red : Colors.grey.shade300,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 80,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
