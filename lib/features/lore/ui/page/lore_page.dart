import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/ui/widgets/lore_card.dart';
import 'package:reforge/features/lore/ui/widgets/plate_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class LorePage extends StatelessWidget {
  const LorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultBackground(
        body: LoreBody(),
        additionalAnimationsBehind: [ParticlesWidget()],
      ),
    );
  }
}

class LoreBody extends StatefulWidget {
  const LoreBody({super.key});

  @override
  State<LoreBody> createState() => _LoreBodyState();
}

class _LoreBodyState extends State<LoreBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      unawaited(context.read<LoreCubit>().loadMore());
    }
  }

  static List<PlatesEntity> _skeletonPlaceholders() => List.generate(
    5,
    (i) => PlatesEntity(
      id: -i - 1,
      name: '',
      title: '',
      imageUrl: null,
      loreBody: null,
      unlockLevel: 0,
      isLocked: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return SafeArea(
      top: false,
      child: BlocListener<LoreCubit, LoreState>(
        listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          final error = state.error;
          if (error != null) {
            toastification.showErrorToast(
              error,
              context,
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
          context.read<LoreCubit>().onRefresh();
          await context.read<LoreCubit>().loadLore();
        },
          child: BlocBuilder<LoreCubit, LoreState>(
            builder: (context, state) {
              final displayedItems = state.isLoading && state.items.isEmpty ? _skeletonPlaceholders() : state.items;
              final totalCount = state.totalCount > 0 ? state.totalCount : state.items.length;

              return Skeletonizer(
                enabled: state.isLoading && state.items.isEmpty,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 16),
                      sliver: SliverAppBar(
                        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        automaticallyImplyLeading: false,
                        centerTitle: false,
                        title: Skeleton.keep(
                          child: Text(
                            t.lore.pageTitle,
                            style: subheadH1Medium.copyWith(color: appTheme.beige100),
                          ),
                        ),
                        actions: [
                          Center(
                            child: Text(
                              t.lore.totalPlate(count: totalCount),
                              style: subheadH5Medium.copyWith(color: appTheme.beige700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: PlatesList(
                        plates: displayedItems,
                        loadingDetailId: state.loadingDetailId,
                      ),
                    ),

                    if (state.isLoadingMore)
                      const SliverPadding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        sliver: SliverToBoxAdapter(child: PaginationLoader()),
                      ),

                    SliverPadding(
                      padding: EdgeInsets.only(bottom: appTheme.sliverBottomSpacing / 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PlatesList extends StatelessWidget {
  const PlatesList({
    required this.plates,
    this.loadingDetailId,
    super.key,
  });

  final List<PlatesEntity> plates;
  final int? loadingDetailId;

  @override
  Widget build(BuildContext context) {
    return plates.isEmpty
        ? SliverEmptyListMessage(
            title: t.lore.emptyTitle,
            subtitle: t.lore.emptySubtitle,
            icon: Icons.auto_stories_outlined,
          )
        : SliverList.separated(
            itemCount: plates.length,
            itemBuilder: (context, index) {
              final item = plates[index];
              if (item.id < 0) {
                return const LoreCardShimmer().animateEntrance();
              }
              return Skeleton.replace(
                replacement: const LoreCardShimmer(),
                child: PlateListTile(
                  model: item,
                  loadingDetailId: loadingDetailId,
                  onTap: () => context.read<LoreCubit>().loadPlateDetail(item.id),
                ),
              ).animateEntrance();
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
  }
}
