import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';

import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_type.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';
import 'package:reforge/features/leaderboard/domain/helpers/gradient_by_rank.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_top_card.dart';
import 'package:reforge/features/leaderboard/ui/widgets/sparks.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/base_list_tile_container.dart';
import 'package:reforge/shared/switchers/multi_options_switcher.dart';
import 'package:reforge/shared/uikit/app_tag.dart';
import 'package:reforge/shared/uikit/binary_option_switcher.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ScrollController _scrollController = ScrollController();

  LeaderboardMode _selectedMode = LeaderboardMode.users;
  Faction _selectedFaction = .gakki;
  late List<LeaderboardUserModel> users;
  LeaderboardUserModel? currentUser;
  int? currentUserIndex;

  bool _isStickyVisible = false;

  final double _headersHeight = 520;

  final double _tileHeight = 80;
  final double _separatorHeight = 8;
  @override
  void initState() {
    super.initState();
    users = generateMockUsers();

    if (users.length > 25) {
      currentUserIndex = 25;
      currentUser = users[currentUserIndex!];
    }

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (currentUserIndex == null) return;

    final userTopY = _headersHeight + (currentUserIndex! * _tileHeight) + (currentUserIndex! * _separatorHeight);

    final userBottomY = userTopY + _tileHeight;

    final screenTopY = _scrollController.offset;

    final screenBottomY = _scrollController.offset + _scrollController.position.viewportDimension;

    final isUserVisibleOnScreen = (userBottomY > screenTopY) && (userTopY < screenBottomY);

    final shouldShowSticky = !isUserVisibleOnScreen;

    if (_isStickyVisible != shouldShowSticky) {
      setState(() {
        _isStickyVisible = shouldShowSticky;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const .symmetric(horizontal: 16),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      title: Text(
                        'LeaderBoard',
                        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                      ),
                      centerTitle: false,
                    ),

                    SliverPadding(
                      padding: const .only(bottom: 32),
                      sliver: SliverToBoxAdapter(
                        child: BinaryOptionSwitcher<LeaderboardMode>(
                          selectedValue: _selectedMode,
                          firstValue: .users,
                          secondValue: .factions,
                          labelBuilder: (value) => value.title(t),
                          onSelected: (value) {
                            setState(() {
                              _selectedMode = value;
                            });
                          },
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const .only(bottom: 32),
                      sliver: SliverToBoxAdapter(
                        child: MultiOptionSwitcher<Faction>(
                          selectedValue: _selectedFaction,
                          values: Faction.values,
                          labelBuilder: (value) => value.title(t),
                          onSelected: (value) => setState(() {
                            _selectedFaction = value;
                          }),
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const .only(bottom: 16),
                      sliver: SliverToBoxAdapter(
                        child: ImmortalForcesCard(),
                      ),
                    ),

                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      title: Text(
                        'Leaderboard list',
                        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                      ),
                      centerTitle: false,
                    ),

                    LeaderBoardList(
                      currentUserIndex: currentUserIndex,
                      users: users,
                    ),

                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                  ],
                ),
              ),
            ),

            if (currentUser != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 16,
                right: 16,

                bottom: _isStickyVisible ? 10 : -150,
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RisingAuraEffect(
                      child: LeaderboardListTile(user: currentUser!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LeaderBoardList extends StatelessWidget {
  const LeaderBoardList({required this.users, required this.currentUserIndex, super.key});

  final List<LeaderboardUserModel> users;
  final int? currentUserIndex;
  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: users.length,
      itemBuilder: (context, index) {
        // final isMe = index == currentUserIndex;

        final user = users[index];

        return LeaderboardListTile(user: user);
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 8,
      ),
    );
  }
}

class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({required this.user, super.key});

  final LeaderboardUserModel user;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        border: GradientBoxBorder(
          gradient: getGradientByRank(user.rank, context),
        ),
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
      ),
      child: BaseListTileContainer(
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                user.rank.toString(),
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),
            ),
            const SizedBox(width: 8),
            LeaderBoardAvatar(
              borderGradientColors: getGradientByRank(user.rank, context),
              imageUrl: user.avatarUrl,
              gradientWidth: 1.5,
              secondBorderWidth: 0,
              size: const Size(48, 48),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                user.username,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            AppTag(
              text: 'XP:${XpFormatter.precise(user.xp)}',

              textStyle: subheadH8Semibold.copyWith(color: appTheme.beige100),
            ),
          ],
        ),
      ),
    );
  }
}
