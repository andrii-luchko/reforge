import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/achievements/ui/widgets/attribute_system_section.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_details_bottom_sheet.dart';
import 'package:reforge/features/achievements/ui/widgets/badges_preview.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/controller/guide_start_result.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/entities/guide_session.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/guides/ui/widgets/guide_tooltip.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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

class _MockAnalyticsService extends Mock implements AnalyticsService {}

AttributesEntity _attribute(ForgeAttribute attribute) {
  return AttributesEntity(
    attribute: attribute,
    totalXp: 100,
    currentXp: 10,
  );
}

Widget _harness({
  required GuideCubit guideCubit,
  required ForgeAttributesGuide guide,
  required List<AttributesEntity> attributes,
}) {
  return MaterialApp(
    theme: ThemeDataValues.darkThemeData,
    home: Provider<ForgeAttributesGuide>.value(
      value: guide,
      child: BlocProvider<GuideCubit>.value(
        value: guideCubit,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AttributeSystemSection(
              attributes: attributes,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  initTestTranslations();

  testWidgets('mounts one target per available attribute in canonical order', (
    tester,
  ) async {
    final guide = ForgeAttributesGuide();
    final guideCubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: achievementsPageGuideScope),
    );
    addTearDown(guideCubit.close);

    await tester.pumpWidget(
      _harness(
        guideCubit: guideCubit,
        guide: guide,
        attributes: [
          _attribute(ForgeAttribute.kannuki),
          _attribute(ForgeAttribute.kobo),
          _attribute(ForgeAttribute.kannuki),
          _attribute(ForgeAttribute.sensho),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GuideTarget), findsNWidgets(4));
    expect(
      find.text(t.achievements.forgeAttributes.kobo.title),
      findsOneWidget,
    );
    expect(
      find.text(t.achievements.forgeAttributes.sensho.title),
      findsOneWidget,
    );
    expect(
      find.text(t.achievements.forgeAttributes.kannuki.title),
      findsNWidgets(2),
    );

    final koboTop = tester.getTopLeft(
      find.text(t.achievements.forgeAttributes.kobo.title),
    );
    final wazaTop = tester.getTopLeft(
      find.text(t.achievements.forgeAttributes.sensho.title),
    );
    final tagaTop = tester.getTopLeft(
      find.text(t.achievements.forgeAttributes.kannuki.title).first,
    );
    expect(koboTop.dy, lessThan(wazaTop.dy));
    expect(wazaTop.dy, lessThan(tagaTop.dy));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('moves through all six targets on a compact viewport', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final guide = ForgeAttributesGuide();
    final guideCubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: achievementsPageGuideScope),
    );
    addTearDown(guideCubit.close);
    final attributes = [
      for (final attribute in forgeAttributesDisplayOrder) _attribute(attribute),
    ];

    await tester.pumpWidget(
      _harness(
        guideCubit: guideCubit,
        guide: guide,
        attributes: attributes,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'The underlying attribute section must fit the compact viewport.',
    );

    await guideCubit.startIfNeeded(
      userId: 71,
      session: guide.session(
        availableAttributes: forgeAttributesDisplayOrder,
      )!,
    );
    await tester.pumpAndSettle();

    expect(
      find.text(t.guides.forgeAttributes.introTitle),
      findsOneWidget,
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'The intro step must fit the compact viewport.',
    );

    final expectedTitles = [
      t.guides.forgeAttributes.koboTitle,
      t.guides.forgeAttributes.kozuchiTitle,
      t.guides.forgeAttributes.wazaTitle,
      t.guides.forgeAttributes.shogenTandaTitle,
      t.guides.forgeAttributes.tagaTitle,
    ];
    for (final title in expectedTitles) {
      await tester.tap(find.text(t.guides.controls.next));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: '$title must fit the compact viewport.',
      );
    }
    expect(find.text('6 / 6'), findsOneWidget);
    expect(find.text(t.guides.controls.finish), findsOneWidget);
    expect(find.text(t.guides.controls.next), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('keeps the permanent bottom sheet aligned with guide copy', (
    tester,
  ) async {
    final analytics = _MockAnalyticsService();
    when(() => analytics.logEvent(any())).thenAnswer((_) async {});
    when(() => analytics.logEvent(any(), any())).thenAnswer((_) async {});
    if (di.getIt.isRegistered<AnalyticsService>()) {
      await di.getIt.unregister<AnalyticsService>();
    }
    di.getIt.registerSingleton<AnalyticsService>(analytics);
    addTearDown(() => di.getIt.unregister<AnalyticsService>());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AttributeSystemSection(
              attributes: [_attribute(ForgeAttribute.kobo)],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text(t.guides.forgeAttributes.koboDescription),
      findsOneWidget,
    );
  });

  testWidgets('scrolls the badge preview into view without covering its cards', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final guide = ForgeAttributesGuide();
    final guideCubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: achievementsPageGuideScope),
    );
    final scrollController = ScrollController();
    addTearDown(guideCubit.close);
    addTearDown(scrollController.dispose);

    const badges = [
      BadgeEntity(imageUrl: '', title: 'Warden', isLocked: true),
      BadgeEntity(imageUrl: '', title: 'Sentinel', isLocked: true),
      BadgeEntity(imageUrl: '', title: 'Enforcer', isLocked: true),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: Provider<ForgeAttributesGuide>.value(
          value: guide,
          child: BlocProvider<GuideCubit>.value(
            value: guideCubit,
            child: Scaffold(
              body: BlocBuilder<GuideCubit, GuideState>(
                builder: (context, state) {
                  return CustomScrollView(
                    controller: scrollController,
                    scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
                    physics: state is GuideRunning ? const NeverScrollableScrollPhysics() : null,
                    slivers: const [
                      SliverToBoxAdapter(child: SizedBox(height: 900)),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: BadgesPreview(badges: badges),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final result = await guideCubit.startIfNeeded(
      userId: 71,
      session: GuideSession(
        id: GuideId.forgeAttributes,
        steps: [
          GuideStep(
            anchor: guide.anchor(ForgeAttributesGuideStep.badges),
          ),
        ],
      ),
    );
    expect(result, GuideStartResult.started);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.text(t.guides.forgeAttributes.badgesTitle), findsOneWidget);
    expect(find.text(t.guides.controls.finish), findsOneWidget);
    expect(scrollController.offset, greaterThan(0));
    expect(find.byType(BadgeCard), findsNWidgets(3));
    expect(
      tester.widgetList<BadgeCard>(find.byType(BadgeCard)).every((card) => !card.isInteractionEnabled),
      isTrue,
    );
    final tooltipRect = tester.getRect(find.byType(GuideTooltip));
    for (var index = 0; index < 3; index++) {
      final rect = tester.getRect(find.byType(BadgeCard).at(index));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(568));
      expect(tooltipRect.bottom, lessThanOrEqualTo(rect.top));
    }

    await tester.tap(find.byType(BadgeCard).first);
    await tester.pump();
    expect(find.byType(BadgeDetailsBottomSheet), findsNothing);
    expect(guideCubit.state, isA<GuideRunning>());
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
