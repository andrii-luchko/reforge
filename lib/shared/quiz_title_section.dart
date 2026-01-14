import 'package:flutter/widgets.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class QuizTitleSection extends StatelessWidget {
  const QuizTitleSection({required this.title, super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 16),
          Text(
            subtitle!,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
        ],
      ],
    );
  }
}
