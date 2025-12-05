import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/network/media_headers.dart';
import '../../../sports/providers/selected_sport_provider.dart';

class TopCategories extends ConsumerWidget {
  final List<dynamic> sports;
  final void Function(int index)? onSportSelected;
  final bool highlightSelected;

  const TopCategories({
    super.key,
    required this.sports,
    this.onSportSelected,
    this.highlightSelected = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sports.isEmpty) return const SizedBox.shrink();

    final selectedIndex =
        highlightSelected ? ref.watch(selectedSportIndexProvider) : -1;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 68,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final sport = sports[index] as Map<String, dynamic>;
            final name = sport['name']?.toString() ?? '';
            final iconUrl = sport['icon']?.toString();
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                ref.read(selectedSportIndexProvider.notifier).state = index;
                if (onSportSelected != null) {
                  onSportSelected!(index);
                }
              },
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.red : Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: SvgPicture.network(
                          iconUrl,
                          headers: mediaHeaders,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: sports.length,
        ),
      ),
    );
  }
}
