import 'package:reforge/features/lore/data/models/plates_model.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';

class LoreMockGenerator {
  LoreMockGenerator._();

  static List<PlatesEntity> generate(int count) {
    return List.generate(count, (index) {
      final id = index + 1;

      final body = (index.isEven) ? _styleOne(id) : _styleTwo(id);
      final level = (index + 1) * 5;
      return PlatesEntity(
        id: id,
        name: 'Plate ${_intToRoman(index + 1)}',
        title: _titles[index % _titles.length],
        imageUrl: (index % 3 == 0) ? 'https://picsum.photos/seed/$id/600/400' : null,
        loreBody: body,
        unlockLevel: level,
        isLocked: index > 5,
      );
    });
  }

  static List<PlatesModel> generateModels(int count) {
    return List.generate(count, (index) {
      final id = index + 1;

      final body = (index.isEven) ? _styleOne(id) : _styleTwo(id);
      final level = (index + 1) * 5;
      return PlatesModel(
        id: id,
        name: 'Plate ${_intToRoman(index + 1)}',
        title: _titles[index % _titles.length],
        imageUrl: (index % 3 == 0) ? 'https://picsum.photos/seed/$id/600/400' : null,
        loreBody: body,
        unlockLevel: level,
        isLocked: index > 5,
      );
    });
  }

  static String _styleOne(int id) =>
      '''
In the era of $id, before the Great Split, there was the Essence.
It wasn't just energy; it was the breath of the world itself.

Ancient scrolls tell us:
-power is a burden,
-patience is the key,
-and the soul is the ultimate anvil.

Many forgot this, but the legends remain.
''';

  static String _styleTwo(int id) =>
      '''
The echoes of the $id-th cycle still resonate in the mountains. 
Those who listen can hear the forge of the ancients.

They believed that every strike of the hammer defines a destiny. 
Without the spark, the metal is just cold stone.
''';

  static final List<String> _titles = [
    'The First Flame',
    'Echoes of Void',
    'Iron Discipline',
    'The Weaver’s Path',
    'Shattered Anvil',
    'Frozen Spirit',
    'The Last Forge',
    'Crimson Dawn',
    'Ancient Wisdom',
  ];
}

String _intToRoman(int input) {
  if (input <= 0) return input.toString();

  const map = {
    1000: 'M',
    900: 'CM',
    500: 'D',
    400: 'CD',
    100: 'C',
    90: 'XC',
    50: 'L',
    40: 'XL',
    10: 'X',
    9: 'IX',
    5: 'V',
    4: 'IV',
    1: 'I',
  };

  var num = input;
  final buffer = StringBuffer();

  for (final entry in map.entries) {
    while (num >= entry.key) {
      buffer.write(entry.value);
      num -= entry.key;
    }
  }
  return buffer.toString();
}
