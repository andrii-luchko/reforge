import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/user/data/models/update_username_response.dart';

void main() {
  group('UpdateUsernameResponse', () {
    test('reads only username from a partial user response', () {
      final response = UpdateUsernameResponse.fromJson({
        'id': 71,
        'email': 'user@example.com',
        'username': 'Updated name',
        'password': 'must-not-enter-the-domain-model',
      });

      expect(response.username, 'Updated name');
    });

    test('rejects a success response without username', () {
      expect(
        () => UpdateUsernameResponse.fromJson({'id': 71}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
