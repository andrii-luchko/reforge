import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/controller/quiz_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/ui/widgets/faction_selector.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class SelectMainFactionStep extends StatelessWidget {
  const SelectMainFactionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.main_faction.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 16),
        Text(
          t.quiz.steps.main_faction.subtitle,
          style: bodyLRegular.copyWith(color: context.appTheme.beige600),
        ),
        const SizedBox(height: 32),
        BlocSelector<QuizCubit, QuizState, Faction?>(
          selector: (state) => state.mainFaction,
          builder: (context, mainFaction) {
            final cubit = context.read<QuizCubit>();
            return FactionSelector(
              selectedFaction: mainFaction,
              onFactionChanged: cubit.setMainFaction,
            );
          },
        ),
      ],
    );
  }
}
