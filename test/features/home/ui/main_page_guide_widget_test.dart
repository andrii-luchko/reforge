import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/main_page_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/home/ui/guide/home_page_guide_scope.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/avatar_card.dart';

import '../../../helpers/test_setup.dart';

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    return false;
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {}
}

void main() {
  initTestTranslations();

  testWidgets('moves through the nested avatar, rank, and level targets', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final guide = MainPageGuide();
    final guideCubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: homePageGuideScope),
    );
    addTearDown(guideCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Provider<MainPageGuide>.value(
          value: guide,
          child: BlocProvider<GuideCubit>.value(
            value: guideCubit,
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: GuideTarget(
                  anchor: guide.anchor(
                    MainPageGuideStep.characterEvolution,
                  ),
                  scope: homePageGuideScope,
                  tooltip: guide.tooltip(
                    MainPageGuideStep.characterEvolution,
                  ),
                  enableAutoScroll: true,
                  targetPadding: EdgeInsets.zero,
                  child: AvatarRankCard(
                    rank: RankEntity.mockWith(t),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GuideTarget), findsNWidgets(3));

    await guideCubit.startIfNeeded(userId: 71, session: guide.session);
    await tester.pumpAndSettle();

    expect(
      find.text(t.guides.mainPage.characterEvolutionTitle),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(t.guides.controls.next));
    await tester.pumpAndSettle();
    expect(find.text(t.guides.mainPage.rankAscensionTitle), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(t.guides.controls.next));
    await tester.pumpAndSettle();
    expect(find.text(t.guides.mainPage.levelAndLegacyTitle), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
