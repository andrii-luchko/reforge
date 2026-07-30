import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/theme/theme_data_values.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:reforge/features/guides/infrastructure/showcase_guide_driver.dart';
import 'package:reforge/features/guides/ui/guides/plate_of_keragura_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/ui/guide/lore_page_guide_scope.dart';
import 'package:reforge/features/lore/ui/page/lore_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

class _MemoryGuideProgressRepository implements GuideProgressRepository {
  final Set<(int, GuideId)> _completed = {};

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    return _completed.contains((userId, guideId));
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    _completed.add((userId, guideId));
  }
}

PlatesEntity _plate({
  required int id,
  required bool isLocked,
}) {
  return PlatesEntity(
    id: id,
    name: isLocked ? 'Locked Plate' : 'Open Plate',
    title: 'A story',
    imageUrl: null,
    loreBody: null,
    unlockLevel: isLocked ? 10 : 1,
    isLocked: isLocked,
  );
}

void main() {
  initTestTranslations();

  testWidgets('moves through intro, unlocked, and locked Plate targets', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final guide = PlateOfKeraguraGuide();
    final guideCubit = GuideCubit(
      _MemoryGuideProgressRepository(),
      ShowcaseGuideDriver(scope: lorePageGuideScope),
    );
    addTearDown(guideCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeDataValues.darkThemeData,
        home: BlocProvider<GuideCubit>.value(
          value: guideCubit,
          child: Scaffold(
            body: CustomScrollView(
              scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
              slivers: [
                SliverToBoxAdapter(
                  child: GuideTarget(
                    anchor: guide.anchor(PlateOfKeraguraGuideStep.intro),
                    scope: lorePageGuideScope,
                    tooltip: guide.tooltip(
                      PlateOfKeraguraGuideStep.intro,
                    ),
                    child: const Text('Plates'),
                  ),
                ),
                PlatesList(
                  plates: [
                    _plate(id: 1, isLocked: false),
                    _plate(id: 2, isLocked: true),
                  ],
                  guide: guide,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GuideTarget), findsNWidgets(3));

    await guideCubit.startIfNeeded(
      userId: 71,
      session: guide.session(
        includeUnlockedPlate: true,
        includeLockedPlate: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(t.guides.plateOfKeragura.introTitle),
      findsOneWidget,
    );

    await tester.tap(find.text(t.guides.controls.next));
    await tester.pumpAndSettle();
    expect(
      find.text(t.guides.plateOfKeragura.unlockedPlateTitle),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(t.guides.controls.next));
    await tester.pumpAndSettle();
    expect(
      find.text(t.guides.plateOfKeragura.lockedPlateTitle),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
