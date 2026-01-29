import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/app_app_bar.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class TrainingDetailsPage extends StatelessWidget {
  const TrainingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      appBar: AppAppBar(
        onPressed: () {
          Navigator.of(context).pop();
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Forge Calendar',
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
      body: const DefaultBackground(body: TrainingDetailsBody()),
    );
  }
}

class TrainingDetailsBody extends StatelessWidget {
  const TrainingDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column();
  }
}
