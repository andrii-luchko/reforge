import 'package:flutter/material.dart';
import 'package:reforge/shared/uikit/app_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WorkoutInfoChipListView extends StatelessWidget {
  const WorkoutInfoChipListView({required this.chips, super.key});
  final List<String> chips;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            Skeleton.leaf(child: AppChip(label: chips[i])),
            if (i != chips.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
