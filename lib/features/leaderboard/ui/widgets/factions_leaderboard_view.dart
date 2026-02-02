import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_factions.dart';
import 'package:reforge/features/leaderboard/ui/widgets/cards/faction_leaderboard_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/faction_mode-picker.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions/victory_point_section.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_faction_list.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';

class FactionsLeaderboardSlivers extends StatefulWidget {
  const FactionsLeaderboardSlivers({super.key});

  @override
  State<FactionsLeaderboardSlivers> createState() => _FactionsLeaderboardSliversState();
}

class _FactionsLeaderboardSliversState extends State<FactionsLeaderboardSlivers> {
  FactionShowType _selectedType = FactionShowType.list;
  FactionMode _selectedMode = FactionMode.current;

  final List<LeaderboardFactionModel> list = generateMockFactions();

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: FactionLeaderboardModePiker(
            onModeChanged: (value) {
              setState(() => _selectedMode = value);
            },
            selectedMode: _selectedMode,
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverToBoxAdapter(
            child: FactionLeaderboardCard(
              mode: _selectedMode,
              firstFaction: list[0],
              secondFaction: list[1],
              userFaction: .gakki,
              currentWeek: 2,
              totalWeeks: 4,
            ).animateEntrance(),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'War Standings',
                style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MultiOptionSwitcher<FactionShowType>(
                selectedValue: _selectedType,
                values: FactionShowType.values,
                labelBuilder: (value) => value.title(t),
                onSelected: (value) {
                  setState(() => _selectedType = value);
                },
              ),
            ),
          ),
        ),

        if (_selectedType == FactionShowType.list)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: LeaderboardFactionList(
              factions: list,
              mode: _selectedMode,
            ),
          ),

        if (_selectedType == FactionShowType.victoryPoints)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: VictoryPointSection(
                mode: _selectedMode,
                factions: list,
              ).animateEntrance(),
            ),
          ),
      ],
    );
  }
}
