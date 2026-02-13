import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

PlatesEntity createTestPlatesEntity({
  int id = 1,
  String name = 'Test',
  String title = 'Test Title',
  String? imageUrl = 'https://example.com/image.png',
  String? loreBody,
  int unlockLevel = 1,
  bool isLocked = false,
}) {
  return PlatesEntity(
    id: id,
    name: name,
    title: title,
    imageUrl: imageUrl,
    loreBody: loreBody,
    unlockLevel: unlockLevel,
    isLocked: isLocked,
  );
}

void main() {
  group('PlatesEntity', () {
    group('loreSteps', () {
      test('returns empty list when loreBody is null', () {
        final entity = createTestPlatesEntity();
        expect(entity.loreSteps, isEmpty);
      });

      test('returns single element when loreBody is single paragraph', () {
        const body = 'Single paragraph text';
        final entity = createTestPlatesEntity(loreBody: body);
        expect(entity.loreSteps, ['Single paragraph text']);
      });

      test('splits by double newline for multiple paragraphs', () {
        const body = 'First paragraph\n\nSecond paragraph\n\nThird paragraph';
        final entity = createTestPlatesEntity(loreBody: body);
        expect(entity.loreSteps, [
          'First paragraph',
          'Second paragraph',
          'Third paragraph',
        ]);
      });

      test('handles newlines with whitespace between paragraphs', () {
        const body = 'Step one\n  \n  Step two';
        final entity = createTestPlatesEntity(loreBody: body);
        expect(entity.loreSteps.length, 2);
        expect(entity.loreSteps[0], 'Step one');
        expect(entity.loreSteps[1].trim(), 'Step two');
      });
    });
  });
}
