import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_info_chip_list_view.dart';

class WorkoutDetailsSection extends StatelessWidget {
  const WorkoutDetailsSection({required this.title, required this.chips, super.key});

  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: subheadH2Medium.copyWith(color: appTheme.beige100),
          ),
        ),

        WorkoutInfoChipListView(
          chips: chips,
        ),
      ],
    );
  }
}
