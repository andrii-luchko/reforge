import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/animations_extension.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/domain/mock/lore_mock_generator.dart';
import 'package:reforge/features/lore/ui/widgets/lore_card.dart';
import 'package:reforge/features/lore/ui/widgets/plate_list_tile.dart';
import 'package:reforge/shared/animations/particles/particles.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

class LoreBody extends StatelessWidget {
  const LoreBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final mockedItems = LoreMockGenerator.generate(10);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<LoreCubit>().loadLore(),
        child: BlocBuilder<LoreCubit, LoreState>(
          builder: (context, state) {
            final displayedItems = state.isLoading ? mockedItems : state.items;
            return Skeletonizer(
              enabled: state.isLoading,
              child: CustomScrollView(
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
                          'Plates of Jiku',
                          style: subheadH1Medium.copyWith(color: appTheme.beige100),
                        ),
                      ),
                      actions: [
                        Center(
                          child: Text(
                            'Total Plate: ${state.items.length}',
                            style: subheadH5Medium.copyWith(color: appTheme.beige700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: PlatesList(plates: displayedItems),
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
    );
  }
}

class PlatesList extends StatelessWidget {
  const PlatesList({required this.plates, super.key});

  final List<PlatesEntity> plates;

  @override
  Widget build(BuildContext context) {
    return plates.isEmpty
        ? const SliverEmptyListMessage(
            title: 'No Plates Found',
            subtitle: 'It seems there are no plates available at the moment. Please check back later.',
            icon: Icons.auto_stories_outlined,
          )
        : SliverList.separated(
            itemCount: plates.length,
            itemBuilder: (context, index) {
              final item = plates[index];
              return Skeleton.replace(
                replacement: const LoreCardShimmer(),
                child: PlateListTile(model: item),
              ).animateEntrance();
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
  }
}
