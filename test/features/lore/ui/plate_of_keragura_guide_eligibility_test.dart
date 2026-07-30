import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/lore/controller/lore_cubit.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/ui/guide/plate_of_keragura_guide_eligibility.dart';

PlatesEntity _plate() {
  return PlatesEntity(
    id: 1,
    name: 'First Plate',
    title: 'The Beginning',
    imageUrl: null,
    loreBody: null,
    unlockLevel: 1,
    isLocked: false,
  );
}

void main() {
  test('allows a loaded non-empty list for an available user', () {
    expect(
      canStartPlateOfKeraguraGuide(
        state: LoreState(items: [_plate()]),
        userId: 71,
      ),
      isTrue,
    );
  });

  test('rejects missing user, loading, error, and empty states', () {
    final items = [_plate()];

    expect(
      canStartPlateOfKeraguraGuide(
        state: LoreState(items: items),
        userId: null,
      ),
      isFalse,
    );
    expect(
      canStartPlateOfKeraguraGuide(
        state: LoreState(items: items, isLoading: true),
        userId: 71,
      ),
      isFalse,
    );
    expect(
      canStartPlateOfKeraguraGuide(
        state: LoreState(items: items, error: 'Network error'),
        userId: 71,
      ),
      isFalse,
    );
    expect(
      canStartPlateOfKeraguraGuide(
        state: const LoreState(),
        userId: 71,
      ),
      isFalse,
    );
  });
}
