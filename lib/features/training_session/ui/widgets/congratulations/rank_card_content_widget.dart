import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/training_session/data/models/workout_congratulations_content.dart';
import 'package:reforge/features/training_session/domain/enums/tier.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/centered_title_section.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class RankCardContentWidget extends StatelessWidget {
  const RankCardContentWidget({
    required this.content,
    super.key,
  });

  final RankCardContent content;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final tierTitle = content.tier.title(t);

    return SingleChildScrollView(
      child: Column(
        spacing: 32,
        children: [
          Text(
            t.workout_congratulations.new_rank_unlocked,
            style: subheadH1Medium.copyWith(color: appTheme.beige100),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: context.appTheme.beige900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: AvatarCard(
                    faction: content.faction,
                    lvl: content.level,
                    rankName: tierTitle,
                    xpValue: content.xpProgress,
                  ),
                ),
              ),
            ),
          ),
          CenteredTitleSection(
            title: content.title,
            subtitle: content.description,
          ),
        ],
      ),
    );
  }
}
