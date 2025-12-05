import 'package:flutter/material.dart';

class VerticalListPlaceholder extends StatelessWidget {
  final int itemCount;

  const VerticalListPlaceholder({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
