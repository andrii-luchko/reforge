import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';

class AttributesEntity {
  const AttributesEntity({
    required this.attribute,
    required this.totalXp,
    required this.currentXp,
  });

  final ForgeAttribute attribute;
  final int totalXp;
  final int currentXp;

  double get progress => currentXp / totalXp;
}
