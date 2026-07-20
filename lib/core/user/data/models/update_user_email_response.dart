final class UpdateUserEmailResponse {
  const UpdateUserEmailResponse({required this.email});

  factory UpdateUserEmailResponse.fromJson(Map<String, dynamic> json) {
    final email = json['email'];
    if (email is! String || email.isEmpty) {
      throw const FormatException('Email update response does not contain an email');
    }
    return UpdateUserEmailResponse(email: email);
  }

  final String email;
}
