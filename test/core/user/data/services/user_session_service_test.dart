import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/data/services/user_session_service.dart';

void main() {
  test('keeps the current user only for the lifetime of the service instance', () async {
    const user = User.newUser(id: 71, email: 'user@example.com');
    final service = UserSessionServiceImpl();

    expect(service.currentUser, isNull);
    expect(service.currentUserId, isNull);

    await service.saveUser(user);

    expect(service.currentUser, user);
    expect(service.currentUserId, 71);
    expect(UserSessionServiceImpl().currentUser, isNull);

    await service.clearUser();

    expect(service.currentUser, isNull);
    expect(service.currentUserId, isNull);
  });
}
