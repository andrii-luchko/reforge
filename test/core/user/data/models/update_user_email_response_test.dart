import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/user/data/models/update_user_email_response.dart';

void main() {
  group('UpdateUserEmailResponse', () {
    test('reads only email from the partial auth user response', () {
      final response = UpdateUserEmailResponse.fromJson({
        'id': 71,
        'role': 'user',
        'password': 'must-not-enter-the-domain-model',
        'email': 'updated@example.com',
        'status': 'active',
      });

      expect(response.email, 'updated@example.com');
    });

    test('rejects a success response without email', () {
      expect(
        () => UpdateUserEmailResponse.fromJson({'id': 71}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
