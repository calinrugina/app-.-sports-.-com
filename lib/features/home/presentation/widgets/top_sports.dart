import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../../core/app_functions.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/network/media_headers.dart';
import '../../../sports/providers/selected_sport_provider.dart';

class SportsOnTop extends ConsumerWidget {
  final List<dynamic> sports;
  final void Function(int index)? onSportSelected;
  final bool highlightSelected;

  const SportsOnTop({
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
      // padding: const EdgeInsets.symmetric(vertical: AppConfig.paddingInside),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          // padding: const EdgeInsets.symmetric(horizontal: 10),
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
                width: 90,
               decoration: BoxDecoration(
                  color: isSelected ? AppColors.redSports : AppColors.darkTabs,
                  // borderRadius: BorderRadius.circular(10),
                ),
                // padding:
                //     const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: SvgIconLoader(
                          iconUrl: iconUrl,
                          headers: mediaHeaders,
                          size: 40,
                        ),
                      )
                    else
                      const Icon(
                        Icons.sports,
                        color: Colors.white,
                        size: 24,
                      ),
                    const SizedBox(height: 1),
                    Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 14, color: Colors.white)
                      // const TextStyle(
                      //   fontSize: 10,
                      //   color: Colors.white,
                      //   fontWeight: FontWeight.w500,
                      // ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 1),
          itemCount: sports.length,
        ),
      ),
    );
  }
}
