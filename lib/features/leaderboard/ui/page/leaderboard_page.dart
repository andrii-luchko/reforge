import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/controller/leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/widgets/factions_leaderboard_view.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leader_board_users_list.dart';
import 'package:reforge/features/leaderboard/ui/widgets/sparks.dart';
import 'package:reforge/features/leaderboard/ui/widgets/users_leaderboard_view.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/uikit/binary_option_switcher.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isStickyVisible = false;

  final double _baseHeaderHeight = 160;
  final double _usersHeaderHeight = 380;
  final double _tileHeight = 80;
  final double _separatorHeight = 8;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    final cubit = context.read<LeaderboardCubit>();
    final state = cubit.state;

    if (state.mode != LeaderboardMode.users || state.currentUserIndex == null) {
      if (_isStickyVisible) setState(() => _isStickyVisible = false);
      return;
    }

    final index = state.currentUserIndex!;

    final totalHeaderOffset = _baseHeaderHeight + _usersHeaderHeight;

    final userTopY = totalHeaderOffset + (index * _tileHeight) + (index * _separatorHeight);
    final userBottomY = userTopY + _tileHeight;

    final screenTopY = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final screenBottomY = screenTopY + _scrollController.position.viewportDimension;

    final isUserVisibleOnScreen = (userBottomY > screenTopY) && (userTopY < screenBottomY);
    final shouldShowSticky = !isUserVisibleOnScreen;

    if (_isStickyVisible != shouldShowSticky) {
      setState(() => _isStickyVisible = shouldShowSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: SafeArea(
          top: false,
          bottom: false,
          child: BlocConsumer<LeaderboardCubit, LeaderboardState>(
            listener: (context, state) {
              if (state.status == LeaderboardStatus.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverAppBar(
                          backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          automaticallyImplyLeading: false,
                          centerTitle: false,

                          floating: true,

                          title: Text(
                            'LeaderBoard',
                            style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
                          ),

                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(72),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: BinaryOptionSwitcher<LeaderboardMode>(
                                selectedValue: state.mode,
                                firstValue: LeaderboardMode.users,
                                secondValue: LeaderboardMode.factions,
                                labelBuilder: (value) => value.title(t),
                                onSelected: (value) {
                                  context.read<LeaderboardCubit>().changeMode(value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (state.mode == LeaderboardMode.users) UsersLeaderboardSlivers(state: state),

                      if (state.mode == LeaderboardMode.factions) const FactionsLeaderboardSlivers(),

                      SliverPadding(padding: EdgeInsets.only(bottom: context.appTheme.sliverBottomSpacing)),
                    ],
                  ),

                  if (state.mode == LeaderboardMode.users && state.currentUser != null)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: 16,
                      right: 16,
                      bottom: _isStickyVisible ? 100 : -150,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: RisingAuraEffect(
                          child: LeaderboardUserListTile(user: state.currentUser!),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        additionalAnimationsBehind: const [ParticlesWidget()],
      ),
    );
  }
}
