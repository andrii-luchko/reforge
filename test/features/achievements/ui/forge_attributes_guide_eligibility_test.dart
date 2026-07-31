import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/achievements/ui/guide/forge_attributes_guide_eligibility.dart';

const _attribute = AttributesEntity(
  attribute: ForgeAttribute.kobo,
  totalXp: 100,
  currentXp: 10,
);

void main() {
  test('allows loaded attributes for an available user', () {
    expect(
      canStartForgeAttributesGuide(
        state: const AchievementsState(attributes: [_attribute]),
        userId: 71,
      ),
      isTrue,
    );
  });

  test('does not let an unrelated badge error block loaded attributes', () {
    expect(
      canStartForgeAttributesGuide(
        state: const AchievementsState(
          attributes: [_attribute],
          error: 'Badges unavailable',
        ),
        userId: 71,
      ),
      isTrue,
    );
  });

  test('rejects loading, empty attributes, and missing user', () {
    expect(
      canStartForgeAttributesGuide(
        state: const AchievementsState(
          attributes: [_attribute],
          isLoading: true,
        ),
        userId: 71,
      ),
      isFalse,
    );
    expect(
      canStartForgeAttributesGuide(
        state: const AchievementsState(),
        userId: 71,
      ),
      isFalse,
    );
    expect(
      canStartForgeAttributesGuide(
        state: const AchievementsState(attributes: [_attribute]),
        userId: null,
      ),
      isFalse,
    );
  });
}
