import 'package:flutter/material.dart';

class BackHeader extends StatelessWidget {
  final String title;

  const BackHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.red,),
              onPressed: canPop ? () => Navigator.of(context).pop() : null,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
