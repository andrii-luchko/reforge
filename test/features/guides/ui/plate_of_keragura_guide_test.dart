import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/plate_of_keragura_guide.dart';

void main() {
  test('builds the full Plate of Keragura session in order', () {
    final guide = PlateOfKeraguraGuide();
    final session = guide.session(
      includeUnlockedPlate: true,
      includeLockedPlate: true,
    );

    expect(session.id, GuideId.plateOfKeragura);
    expect(
      session.steps.map((step) => step.anchor),
      PlateOfKeraguraGuideStep.values.map(guide.anchor),
    );
  });

  test('omits unavailable card steps without changing their order', () {
    final guide = PlateOfKeraguraGuide();

    final unlockedOnly = guide.session(
      includeUnlockedPlate: true,
      includeLockedPlate: false,
    );
    expect(
      unlockedOnly.steps.map((step) => step.anchor),
      [
        guide.anchor(PlateOfKeraguraGuideStep.intro),
        guide.anchor(PlateOfKeraguraGuideStep.unlockedPlate),
      ],
    );

    final lockedOnly = guide.session(
      includeUnlockedPlate: false,
      includeLockedPlate: true,
    );
    expect(
      lockedOnly.steps.map((step) => step.anchor),
      [
        guide.anchor(PlateOfKeraguraGuideStep.intro),
        guide.anchor(PlateOfKeraguraGuideStep.lockedPlate),
      ],
    );
  });
}
