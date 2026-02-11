import 'dart:math';

import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';

class NotificationGenerator {
  const NotificationGenerator._();
  static final Random _random = Random(15);

  static List<NotificationEntity> generateMocks(int count) {
    return List.generate(count, (index) {
      final type = NotificationType.values[_random.nextInt(NotificationType.values.length)];
      final data = _getMockDataByType(type);

      return NotificationEntity(
        id: index,
        title: data['title']!,
        subtitle: data['subtitle']!,

        date: DateTime.now().subtract(
          Duration(
            hours: _random.nextInt(72),
            minutes: _random.nextInt(60),
          ),
        ),
        type: type,
      );
    });
  }

  static Map<String, String> _getMockDataByType(NotificationType type) {
    return switch (type) {
      NotificationType.plateUnlocked => {
        'title': 'New Plate Unlocked',
        'subtitle': 'Another fragment of the world’s history is now revealed',
      },
      NotificationType.xpSummary => {
        'title': 'XP Summary',
        'subtitle': 'Your XP gains for today are ready.',
      },
      NotificationType.rankUpdate => {
        'title': 'Rank Progress Update',
        'subtitle': 'You’re close to reaching the next rank.',
      },
      NotificationType.weeklyWinner => {
        'title': 'Weekly Faction Winner',
        'subtitle': 'This week’s faction results are in.',
      },
      NotificationType.paymentFailed => {
        'title': 'Payment Failed',
        'subtitle': 'Please update your payment method',
      },
    };
  }
}
