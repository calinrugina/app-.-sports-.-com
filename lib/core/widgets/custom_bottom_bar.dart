
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

    // 🚀 MODIFICARE: Calculăm manual padding-ul de jos (pentru bara de sistem)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Înlocuim SafeArea cu un Container care setează culoarea de fundal
    // (inclusiv sub bara de navigare a sistemului) la negru.
    return Container(
      width: double.infinity,
      // Înălțimea vizibilă a barei (80.0) + înălțimea barei de navigare a sistemului
      height: 65.0 + bottomPadding,
      color: Colors.black, // 🚀 SOLUȚIE: Fundalul este forțat la negru

      // Aplicăm padding-ul necesar pentru a împinge conținutul barei deasupra
      // zonei de navigare a sistemului (gesturi/butoane).
      padding: EdgeInsets.only(bottom: bottomPadding),

      // Conținutul barei de navigare rămâne neschimbat
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
              // Înălțimea acestui SizedBox este acum fixă la 80,
              // deoarece padding-ul este aplicat pe părintele Container.
              height: 70,
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
                      const SizedBox(height: 5,),
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