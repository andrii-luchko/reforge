final class UpdateUsernameResponse {
  const UpdateUsernameResponse({required this.username});

  factory UpdateUsernameResponse.fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    if (username is! String || username.isEmpty) {
      throw const FormatException('Username update response does not contain a username');
    }
    return UpdateUsernameResponse(username: username);
  }

  final String username;
}
