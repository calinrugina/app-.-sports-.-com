import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  /// Foarte important: dacă există sau nu tab de LIVE
  final bool hasLive;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.hasLive,
  });

  @override
  Widget build(BuildContext context) {
    // Construim lista de item-uri în aceeași ordine ca în HomeScreen:
    // 0: Home
    // 1: Live (dacă există)
    // 1 sau 2: Sports
    // ...
    final List<Map<String, dynamic>> items = [
      {
        'svgPath': 'assets/images/tab_home.svg',
        'label': 'HOME',
      },
      if (hasLive)
        {
          'svgPath': 'assets/images/tab_stream.svg',
          'label': 'LIVE',
        },
      {
        'svgPath': 'assets/images/tab_sports.svg',
        'label': 'SPORTS',
      },
      {
        'svgPath': 'assets/images/tab_studios.svg',
        'label': 'STUDIOS',
      },
      {
        'svgPath': 'assets/images/tab_more.svg',
        'label': 'MORE',
      },
    ];

    // De siguranță: clamp pe index (în caz că se schimbă numărul de tab-uri)
    final int clampedIndex =
    selectedIndex.clamp(0, items.length - 1).toInt();

    return Container(
      width: double.infinity,
      height: 80.0,
      color: Colors.black,
      // padding: const EdgeInsets.only(bottom: 4, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = index == clampedIndex;

          final String svgPath = item['svgPath'] as String;
          final String label = item['label'] as String;

          return Expanded(child: GestureDetector(
            onTap: () => onItemTapped(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              // width: 70,
              height: 80,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (isSelected)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 3.0,
                        width: double.infinity,
                        color: Colors.red,
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5,),
                      SvgPicture.asset(
                        svgPath,
                        height: 55,
                        colorFilter: ColorFilter.mode(
                          isSelected ? AppColors.redSports : Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   label,
                      //   style: TextStyle(
                      //     fontSize: 10,
                      //     color:
                      //     isSelected ? AppColors.redSports : Colors.white,
                      //     fontWeight:
                      //     isSelected ? FontWeight.w700 : FontWeight.w400,
                      //     letterSpacing: 0.8,
                      //   ),
                      // ),
                    ],
                  )
                ],
              ),
            ),
          ));
        }),
      ),
    );
  }
}